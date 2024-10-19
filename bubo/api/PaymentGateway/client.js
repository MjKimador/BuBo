const net = require('net');

// Create a connection to the server on localhost:3003
const client = new net.Socket();
const HOST = '127.0.0.1';  // Server IP address (localhost)
const PORT = 3003;         // Port number the server is listening on

// Connect to the server
client.connect(PORT, HOST, () => {
  console.log('Connected to server');

  // Prepare wallet information and amount to send to the server
  const sendWallet = "b40ce34e-5db6-487a-abdd-d1a93e9f9457";
  const receiverWallet = "247e60e4-a5aa-4291-a5b6-2b2389662d91";
  const amountMoney = "100";

  // Send data to the server (wallet1, wallet2, amount)
  const dataToSend = `${sendWallet} ${receiverWallet} ${amountMoney}`;
  client.write(dataToSend);

  console.log(`Sent to server: ${dataToSend}`);
});

// Handle incoming data from the server
client.on('data', (data) => {
  console.log(`Received from server: ${data.toString()}`);

  // Close the connection after receiving a response
  client.end();
});

// Handle connection close
client.on('close', () => {
  console.log('Connection closed');
});

// Handle connection errors
client.on('error', (error) => {
  console.error(`Connection error: ${error.message}`);
});
