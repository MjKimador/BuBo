// Variables for the transaction
var TransactionDescription = 'Purchase at Shoe Shop';
var AssetCode ='ZAR';
var AssetScale = 2;
var Amount = '5000';
var ExternalRef = '#INV2022-8363828';
var EmporiumWallet = 'https://online-marketplace.com/usa';
var PatronWallet = 'https://cloud-nine-wallet.com/alice';
var EmporiumPublicKey = 'KEY_ID';
var EmporiumPrivateKey = 'KEY_ID';

// Import the function to create an authenticated client from the Open Payments library
import { createAuthenticatedClient } from '@interledger/open-payments'

// Asynchronously create an authenticated client to interact with the Open Payments API
const client = await createAuthenticatedClient({
  walletAddressUrl: EmporiumWallet,
  keyId: EmporiumPrivateKey, 
  privateKey: EmporiumPrivateKey 
})

// Get the wallet of the emporium
const shoeShopWalletAddress = await client.walletAddress.get({
    url: EmporiumWallet
  })
  
 // Get the wallet of the patron 
  const customerWalletAddress = await client.walletAddress.get({
    url: PatronWallet
  })

  //Create IncomingPayment for the emporium
  const incomingPaymentGrant = await client.grant.request(
    { url: EmporiumWallet.authServer },
    {
      access_token: {
        access: [
          {
            type: 'incoming-payment',
            actions: ['read-all', 'create']
          }
        ]
      }
    }
  )

  const incomingPayment = await client.incomingPayment.create(
    {
      url: new URL(EmporiumWallet.id).origin,
      accessToken: incomingPaymentGrant.access_token.value
    },
    {
      walletAddress: EmporiumWallet.id,
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
  )


  // Request a grant to create a quote for the patron's wallet address
const quoteGrant = await client.grant.request(
    { url: PatronWallet.authServer },  // The authorization server URL of the customer's wallet
    {
      access_token: {
        access: [
          {
            type: 'quote',         // Requesting access to the 'quote' resource type
            actions: ['create', 'read']  // Permissions: create and read quotes
          }
        ]
      }
    }
  )
  
  // Use the granted access token to create a payment quote
  // The quote will tell the patron how much the payment will cost, over the Interledger Protocol (ILP)
  const quote = await client.quote.create(
    {
      url: new URL(PatronWallet.id).origin, 
      accessToken: quoteGrant.access_token.value      
    },
    {
      walletAddress: PatronWallet.id,  // The customer's wallet address
      receiver: incomingPayment.id,             // The receiver's payment pointer or ID (the payment destination)
      method: 'ilp'                             // Specifies the payment method, which is ILP (Interledger Protocol)
    }
  )
  