const { AuthenticatedClient, createAuthenticatedClient, isFinalizedGrant, isPendingGrant } = require('@interledger/open-payments');
const WebSocket = require('ws');
const http = require('http');

const PORT = 30343;

async function getAuthenticatedClient() {
  return await createAuthenticatedClient({
    walletAddressUrl: "https://ilp.interledger-test.dev/ptr1",
    privateKey: Buffer.from("LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1DNENBUUF3QlFZREsyVndCQ0lFSUc0S0oydFQ3MEZuNDNpTWJWMC9SMGJ4WWgzckZmcDZNZkd2UTBJa0VTRzEKLS0tLS1FTkQgUFJJVkFURSBLRVktLS0tLQ==", 'base64'),
    keyId: 'db6e641f-6c3f-443e-bb39-2a08c856d0da',
    validateResponses: false
  });
}

async function getWalletAddressInfo(client, walletAddress) {
  try {
    return await client.walletAddress.get({ url: "https://ilp.interledger-test.dev/ptr1" });
  } catch (error) {
    console.error(`Error fetching wallet address info: ${error.message}`);
    throw error;
  }
}

async function createIncomingPayment(client, value, walletAddressDetails) {
  const grant = await client.grant.request(
    { url: walletAddressDetails.authServer },
    {
      access_token: {
        access: [{ type: 'incoming-payment', actions: ["read", "create", "complete"] }],
      },
    }
  );

  if (isPendingGrant(grant)) {
    throw new Error('Expected non-interactive grant for incoming payment');
  }

  return await client.incomingPayment.create(
    {
      url: new URL(walletAddressDetails.id).origin,
      accessToken: grant.access_token.value,
    },
    {
      walletAddress: walletAddressDetails.id,
      incomingAmount: {
        value: value,
        assetCode: walletAddressDetails.assetCode,
        assetScale: walletAddressDetails.assetScale,
      },
    }
  );
}

async function createQuote(client, incomingPaymentUrl, walletAddressDetails) {
  const grant = await client.grant.request(
    { url: walletAddressDetails.authServer },
    {
      access_token: {
        access: [{ type: 'quote', actions: ['create', 'read', 'read-all'] }],
      },
    }
  );

  if (isPendingGrant(grant)) {
    throw new Error('Expected non-interactive grant for quote');
  }

  return await client.quote.create(
    {
      url: walletAddressDetails.resourceServer,
      accessToken: grant.access_token.value,
    },
    {
      method: 'ilp',
      walletAddress: walletAddressDetails.id,
      receiver: incomingPaymentUrl,
    }
  );
}

async function getOutgoingPaymentAuthorization(client, walletAddressDetails) {
  const grant = await client.grant.request(
    { url: walletAddressDetails.authServer },
    {
      access_token: {
        access: [{
          identifier: walletAddressDetails.id,
          type: 'outgoing-payment',
          actions: ['list', 'list-all', 'read', 'read-all', 'create'],
        }],
      },
      interact: { start: ['redirect'] },
    }
  );

  if (!isPendingGrant(grant)) {
    throw new Error('Expected interactive grant for outgoing payment');
  }

  return grant;
}

async function createOutgoingPayment(client, walletAddressUrl, grant, quote) {
  let finalizedGrant;
  await new Promise((resolve) => setTimeout(resolve, 5000));
  while (true) {
    console.log('Polling for finalized grant...');
    const currentGrant = await client.grant.continue({
      accessToken: grant.continue.access_token.value,
      url: grant.continue.uri,
    });

    if (isFinalizedGrant(currentGrant)) {
      finalizedGrant = currentGrant;
      break;
    }
    await new Promise((resolve) => setTimeout(resolve, 7000));
  }

  return await client.outgoingPayment.create(
    {
      url: walletAddressUrl.resourceServer,
      accessToken: finalizedGrant.access_token.value,
    },
    {
      walletAddress: walletAddressUrl.id,
      quoteId: quote.id,
    }
  );
}

async function handlePaymentProcess(ws, data) {
  const client = await getAuthenticatedClient();
  const { sendWallet, receiverWallet, amountMoney } = data;

  if (!sendWallet || !receiverWallet || !amountMoney) {
    throw new Error('Invalid input format. Expected: sendWallet, receiverWallet, amountMoney');
  }

  const senderWalletsDetails = await getWalletAddressInfo(client, sendWallet);
  const receiverWalletsDetails = await getWalletAddressInfo(client, receiverWallet);

  const incomingPayment = await createIncomingPayment(client, amountMoney, receiverWalletsDetails);
  console.log('Incoming payment created:', incomingPayment);

  const quote = await createQuote(client, incomingPayment.id, senderWalletsDetails);
  const outgoingPaymentGrant = await getOutgoingPaymentAuthorization(client, senderWalletsDetails);

  ws.send(JSON.stringify({ redirectUrl: outgoingPaymentGrant.interact.redirect }));
  
  const completedPayment = await createOutgoingPayment(client, senderWalletsDetails, outgoingPaymentGrant, quote);
  console.log('Outgoing payment completed:', completedPayment);
  
  ws.send(JSON.stringify({ status: 'Payment process completed successfully' }));
}

const server = http.createServer();
const wss = new WebSocket.Server({ server });

wss.on('connection', (ws) => {
  console.log('Client connected');

  ws.on('message', async (message) => {
    try {
      const data = JSON.parse(message);
      console.log('Received from client:', data);
      await handlePaymentProcess(ws, data);
    } catch (error) {
      console.error('Error processing payment:', error);
      ws.send(JSON.stringify({ error: error.message }));
    }
  });

  ws.on('close', () => {
    console.log('Client disconnected');
  });
});

server.listen(PORT, () => {
  console.log(`WebSocket server is running on port ${PORT}`);
});

server.on('error', (err) => {
  console.error('Server error:', err);
});