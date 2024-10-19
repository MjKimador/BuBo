import { createAuthenticatedClient } from '@interledger/open-payments'

const client = await createAuthenticatedClient({
  walletAddressUrl: 'https://online-marketplace.com/usa',
  keyId: KEY_ID,
  privateKey: PRIVATE_KEY
  // The public JWK with this key (and keyId) would be available at https://online-marketplace.com/usa/jwks.json
})

// Get the wallet of the emporium
const shoeShopWalletAddress = await client.walletAddress.get({
    url: 'https://happy-life-bank.com/shoe-shop'
  })
  
 // Get the wallet of the patron 
  const customerWalletAddress = await client.walletAddress.get({
    url: 'https://cloud-nine-wallet.com/alice'
  })