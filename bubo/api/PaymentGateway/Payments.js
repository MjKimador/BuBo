// Variables for the transaction
var ShopName = 'Shoes shop';
var TransactionDescription = 'Purchase at '+ShopName;
var AssetCode ='ZAR';
var AssetScale = 2;
var Amount = '5000';
var ExternalRef = '#INV2022-8363828';
var EmporiumWallet = 'https://online-marketplace.com/usa';
var PatronWallet = 'https://cloud-nine-wallet.com/alice';
var EmporiumPublicKey = 'KEY_ID';
var EmporiumPrivateKey = 'KEY_ID';
var Description = 'Your purchase at '+ShopName;

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


  // Request a grant to create a quote for the patron 's wallet address
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
  // The quote will tell the patron  how much the payment will cost, over the Interledger Protocol (ILP)
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
  
 // Create an outgoing payment on Alice's wallet.
const outgoingPaymentGrant = await client.grant.request(
    // First, provide the URL of Alice's wallet's authorization server
    { url: PatronWallet.authServer },
    
    {
      // Request an access token with specific permissions (grants) for outgoing payments
      access_token: {
        access: [
          {
            type: 'outgoing-payment', 
            actions: ['read', 'create', 'list'], 
            identifier: PatronWallet.id, 
  
            // Set limits for the outgoing payment based on the quote
            limits: {
              debitAmount: quote.debitAmount, // The maximum amount that can be debited from patron's wallet (based on the quote)
              receiveAmount: quote.receiveAmount // The amount the patron will receive, also derived from the quote
            }
          }
        ]
      },
  
      // The 'interact' block is used to facilitate interaction with the patron  to get their consent
      interact: {
        start: ['redirect'], 
  
        // After the patron gives consent, the interaction is completed and she'll be redirected
        finish: {
          method: 'redirect',
  
          // This is the URI to which the patron will be redirected after the interaction (successful payment consent)
          uri: EmporiumWallet,
  
          nonce: uuid() // A unique nonce to track this interaction for security purposes
        }
      }
    }
  );
   

// Continue the grant process after the patron has approved the request
const finalizedOutgoingPaymentGrant = await client.grant.continue(
    {
      accessToken: outgoingPaymentGrant.access_token.value, 
  
      url: outgoingPaymentGrant.continue.uri 
    },
    
    { interact_ref: INTERACT_REF_FROM_URL } 
  );
  
  // Create an OutgoingPayment on the patron's account after the grant interaction flow has been completed and they have given their consent to the payment
const outgoingPayment = await client.outgoingPayment.create(
    {
      url: new URL(PatronWallet.id).origin,
      accessToken: finalizedOutgoingPaymentGrant.access_token.value // This token authorizes the outgoing payment creation
    },
    
    {
      walletAddress: PatronWallet.id, // Alice's wallet address
      quoteId: quote.id,
      metadata: { 
        description: Description // A brief description of the payment transaction
      }
    }
  );

  // *************************************
 // NEW CODE
 // *************************************
 