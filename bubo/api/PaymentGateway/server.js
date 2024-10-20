const { AuthenticatedClient, createAuthenticatedClient, isFinalizedGrant, isPendingGrant } = require('@interledger/open-payments');
const { randomUUID } = require('crypto');
const net = require('net');
const { encode } = require('punycode');

async function getAuthenticatedClient() {
  const client = await createAuthenticatedClient({
    walletAddressUrl:"https://ilp.interledger-test.dev/ptr1",
    privateKey: Buffer.from("LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1DNENBUUF3QlFZREsyVndCQ0lFSUc0S0oydFQ3MEZuNDNpTWJWMC9SMGJ4WWgzckZmcDZNZkd2UTBJa0VTRzEKLS0tLS1FTkQgUFJJVkFURSBLRVktLS0tLQ==",'base64'),
    keyId: 'db6e641f-6c3f-443e-bb39-2a08c856d0da',
    validateResponses: false
  });
  return client;
}

async function getWalletAddressInfo(client, input) {
  

  // Check if input is a payment pointer
  
  
  try {

    const walletAddressDetails = await client.walletAddress.get({
      url: "https://ilp.interledger-test.dev/ptr1",
    });

    return walletAddressDetails;
  } catch (error) {
    console.error(`Error fetching wallet address info: ${error.message}`);
    throw error;
  }
}


async function createIncomingPayment(client, value, walletAddressDetails) {
  console.log('** creating incoming payment grant req');
  console.log(walletAddressDetails);

  const grant = await client.grant.request(
    {
      url: walletAddressDetails.authServer,
    },
    {
      access_token: {
        access: [
          {
            type: 'incoming-payment',
            actions: ["read", "create", "complete"],
          },
        ],
      },
    }
  );

  if (isPendingGrant(grant)) {
    throw new Error('Expected non-interactive grant');
  }

  const incomingPayment = await client.incomingPayment.create(
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

  console.log('** inc');
  console.log(incomingPayment);
  return incomingPayment;
}

async function createQuote(client, incomingPaymentUrl, walletAddressDetails) {
  console.log('** 2 req');
  console.log(walletAddressDetails);

  const grant = await client.grant.request(
    {
      url: walletAddressDetails.authServer,
    },
    {
      access_token: {
        access: [
          {
            type: 'quote',
            actions: ['create', 'read', 'read-all'],
          },
        ],
      },
    }
  );

  if (isPendingGrant(grant)) {
    throw new Error('Expected non-interactive grant');
  }

  const quote = await client.quote.create(
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

  console.log('** quote');
  console.log(quote);
  return quote;
}

async function getOutgoingPaymentAuthorization(client, walletAddressDetails) {
  const grant = await client.grant.request(
    {
      url: walletAddressDetails.authServer,
    },
    {
      access_token: {
        access: [
          {
            identifier: walletAddressDetails.id,
            type: 'outgoing-payment',
            actions: ['list', 'list-all', 'read', 'read-all', 'create'],
          },
        ],
      },
      interact: {
        start: ['redirect'],
      },
    }
  );

  if (!isPendingGrant(grant)) {
    throw new Error('Expected interactive grant');
  }

  return grant;
}

async function createOutgoingPayment(client, walletAddressUrl, grant, quote) {
  let grant2;
  while (true) {
    console.log('trying to get payment.......');

    grant2 = await client.grant.continue({
      accessToken: grant.continue.access_token.value,
      url: grant.continue.uri,
    });

    console.log(grant2);
    if (isFinalizedGrant(grant2)) {
      break;
    } else {
      console.log('sleeping....');
      await new Promise((r) => setTimeout(r, 2000));
    }
  }

  const outgoingPayment = await client.outgoingPayment.create(
    {
      url: walletAddressUrl.resourceServer,
      accessToken: grant2.access_token.value,
    },
    {
      walletAddress: walletAddressUrl.id,
      quoteId: quote.id,
    }
  );

  return outgoingPayment;
}

// Create a TCP server
const server = net.createServer((socket) => {
  console.log('Client connected');
  

  socket.on('data', async (data) => {
    const client = await getAuthenticatedClient();
    
    console.log(`Received from client: ${data.toString()}`);
    const args = data.toString().split(' ');
    const sendWallet = args[0];
    const receiverWallet = args[1];
    const amountMoney = args[2];

    const senderWalletsDetails = await getWalletAddressInfo(client, sendWallet);
    const receiverWalletsDetails = await getWalletAddressInfo(client, receiverWallet);
    if (!receiverWalletsDetails) {
      throw new Error();
    }

    const incomingPayment = await createIncomingPayment(client, amountMoney, receiverWalletsDetails);
    console.log(incomingPayment);
    if (!senderWalletsDetails) {
      throw new Error();
    }

    const myQuote = await createQuote(client, incomingPayment.id, senderWalletsDetails);
    const outPayment = await getOutgoingPaymentAuthorization(client, senderWalletsDetails);

    if (!isPendingGrant(outPayment)) {
      throw new Error();
    }

    socket.write(`Server received: ${outPayment.interact.redirect}`);
    const completePayment = await createOutgoingPayment(client, senderWalletsDetails, outPayment, myQuote);
  });

  socket.on('end', () => {
    console.log('Client disconnected');
  });
});

server.listen(33335, () => {
  console.log('Server is listening on port 3003');
});