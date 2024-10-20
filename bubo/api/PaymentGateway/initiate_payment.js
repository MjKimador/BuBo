const { AuthenticatedClient, createAuthenticatedClient, isFinalizedGrant, isPendingGrant } = require('@interledger/open-payments');
const { randomUUID } = require('crypto');

async function getAuthenticatedClient() {
  const client = await createAuthenticatedClient({
    walletAddressUrl: "https://ilp.interledger-test.dev/ptr1",
    privateKey: Buffer.from("LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1DNENBUUF3QlFZREsyVndCQ0lFSUc0S0oydFQ3MEZuNDNpTWJWMC9SMGJ4WWgzckZmcDZNZkd2UTBJa0VTRzEKLS0tLS1FTkQgUFJJVkFURSBLRVktLS0tLQ==", 'base64'),
    keyId: 'db6e641f-6c3f-443e-bb39-2a08c856d0da',
    validateResponses: false
  });
  return client;
}

async function getWalletAddressInfo(client, walletAddressUrl) {
  try {
    const walletAddressDetails = await client.walletAddress.get({ url: walletAddressUrl });
    return walletAddressDetails;
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
        access: [{ type: 'incoming-payment', actions: ["read", "create", "complete"] }]
      }
    }
  );

  if (isPendingGrant(grant)) {
    throw new Error('Expected non-interactive grant');
  }

  const incomingPayment = await client.incomingPayment.create(
    { url: new URL(walletAddressDetails.id).origin, accessToken: grant.access_token.value },
    {
      walletAddress: walletAddressDetails.id,
      incomingAmount: { value, assetCode: walletAddressDetails.assetCode, assetScale: walletAddressDetails.assetScale }
    }
  );

  return incomingPayment;
}

async function createQuote(client, incomingPaymentUrl, walletAddressDetails) {
  const grant = await client.grant.request(
    { url: walletAddressDetails.authServer },
    {
      access_token: {
        access: [{ type: 'quote', actions: ['create', 'read', 'read-all'] }]
      }
    }
  );

  if (isPendingGrant(grant)) {
    throw new Error('Expected non-interactive grant');
  }

  const quote = await client.quote.create(
    { url: walletAddressDetails.resourceServer, accessToken: grant.access_token.value },
    { method: 'ilp', walletAddress: walletAddressDetails.id, receiver: incomingPaymentUrl }
  );

  return quote;
}

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).send('Method not allowed');
  }

  try {
    const { senderWallet, receiverWallet, amount } = req.body;
    const client = await getAuthenticatedClient();

    const senderWalletsDetails = await getWalletAddressInfo(client, senderWallet);
    const receiverWalletsDetails = await getWalletAddressInfo(client, receiverWallet);

    if (!receiverWalletsDetails) {
      return res.status(400).send('Invalid receiver wallet');
    }

    const incomingPayment = await createIncomingPayment(client, amount, receiverWalletsDetails);
    if (!senderWalletsDetails) {
      return res.status(400).send('Invalid sender wallet');
    }

    const myQuote = await createQuote(client, incomingPayment.id, senderWalletsDetails);
    const outPayment = await getOutgoingPaymentAuthorization(client, senderWalletsDetails);

    if (!isPendingGrant(outPayment)) {
      return res.status(400).send('Payment authorization failed');
    }

    res.status(200).json({ redirectUrl: outPayment.interact.redirect });
  } catch (error) {
    console.error('Error processing payment:', error);
    res.status(500).send('Internal server error');
  }
}
