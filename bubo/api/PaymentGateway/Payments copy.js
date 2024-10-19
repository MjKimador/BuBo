const express = require('express');
const { createAuthenticatedClient } = require('@interledger/open-payments');

const app = express();
const port = 3000;

app.use(express.json());

// Endpoint to initiate payment
app.post('/api/initiate-payment', async (req, res) => {
  try {
    const { shopName, amount, externalRef, patronWallet } = req.body;
    const ShopName = shopName || 'Shoes shop';
    const TransactionDescription = 'Purchase at ' + ShopName;
    const AssetCode = 'ZAR';
    const AssetScale = 2;
    const Amount = amount || '5';
    const ExternalRef = externalRef || 'INV';
    const EmporiumWallet = 'https://ilp.interledger-test.dev/zar1';
    const fs = require('fs');
    const EmporiumPrivateKey = fs.readFileSync('C:/Bubo/BuBo/bubo/api/PaymentGateway/EmporiumPrivateKey.pem', 'utf8');
    const EmporiumKeyID = "db487b0c-72da-4986-acc1-69c02a332395";
    const Description = 'Your purchase at ' + ShopName;
    const PatronWallet = 'https://ilp.interledger-test.dev/paymentpointer1';

    // Create an authenticated client
    const client = await createAuthenticatedClient({
      walletAddressUrl: EmporiumWallet,
      keyId: EmporiumKeyID,
      privateKey: EmporiumPrivateKey
    });

    // Get the Emporium's wallet
    const emporiumWallet = await client.walletAddress.get({ url: EmporiumWallet });

    // Get the Patron's wallet
    const PatronWalletAddress = await client.walletAddress.get({ url: PatronWallet });
    // Create an incoming payment for the emporium
    const incomingPaymentGrant = await client.grant.request(
      { url: emporiumWallet.authServer },
      {
        access_token: {
          access: [
            {
              type: 'incoming-payment',
              actions: ['read-all','create']
            }
          ]
        }
      }
    );

    const incomingPayment = await client.incomingPayment.create(
      {
        url: new URL(emporiumWallet.id).origin,
        accessToken: incomingPaymentGrant.access_token.value
      },
      {
        walletAddress: emporiumWallet.id,
        incomingAmount: {
          assetCode: AssetCode,
          assetScale: AssetScale,
          value: Amount
        },
        metadata: {
          externalRef: ExternalRef,
          description: TransactionDescription
        }
      }
    );
    // Create quote for the patron
    const quoteGrant = await client.grant.request(
      { url: PatronWallet.authServer },
      {
        access_token: {
          access: [
            {
              type: 'quote',
              actions: ['create','read']
            }
          ]
        }
      }
    );

    const quote = await client.quote.create(
      {
        url: new URL(PatronWallet.id).origin,
        accessToken: quoteGrant.access_token.value
      },
      {
        walletAddress: PatronWallet.id,
        receiver: incomingPayment.id,
        method: 'ilp'
      }
    );

    // Create outgoing payment on patron's wallet
    const outgoingPaymentGrant = await client.grant.request(
      { url: PatronWallet.authServer },
      {
        access_token: {
          access: [
            {
              type: 'outgoing-payment',
              actions: ['read','create','list'],
              identifier: PatronWallet.id,
              limits: {
                debitAmount: quote.debitAmount,
                receiveAmount: quote.receiveAmount
              }
            }
          ]
        },
        interact: {
          start: ['redirect'],
          finish: {
            method: 'redirect',
            uri: EmporiumWallet,
            nonce: uuid()
          }
        }
      }
    );

    const finalizedOutgoingPaymentGrant = await client.grant.continue(
      {
        accessToken: outgoingPaymentGrant.access_token.value,
        url: outgoingPaymentGrant.continue.uri
      },
      { interact_ref: INTERACT_REF_FROM_URL }
    );

    const outgoingPayment = await client.outgoingPayment.create(
      {
        url: new URL(PatronWallet.id).origin,
        accessToken: finalizedOutgoingPaymentGrant.access_token.value
      },
      {
        walletAddress: PatronWallet.id,
        quoteId: quote.id,
        metadata: {
          description: Description
        }
      }
    );

    res.json({
      success: true,
      incomingPayment,
      outgoingPayment
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: error.message });
  }
});

app.listen(port, () => {
  console.log(`Payment API listening at http://localhost:${port}`);
});