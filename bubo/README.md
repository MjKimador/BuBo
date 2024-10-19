# bubo
#Financial accounting
Description:This project is a Node.js API that interfaces with the TigerBeetle financial accounting system. It allows you to create accounts and perform transactions using the high-performance TigerBeetle backend.

Requirements:
Before starting, make sure you have the following installed:

Node.js (v14 or later)
TigerBeetle (latest release)

Setup
1. Install TigerBeetle
Download and set up TigerBeetle from its official repository or website.

For example, for Linux:

bash
Copy code
curl -Lo tigerbeetle.zip https://linux.tigerbeetle.com && unzip tigerbeetle.zip
./tigerbeetle format --cluster=0 --replica=0 --replica-count=1 --development 0_0.tigerbeetle
./tigerbeetle start --addresses=127.0.0.1:3000 --development 0_0.tigerbeetle
This command creates a TigerBeetle data file and starts the TigerBeetle server on 127.0.0.1:3000.

2. Set Up the Node.js API
Clone the Repository
Clone this project to your local machine:

bash
Copy code
git clone  https://github.com/MjKimador/BuBo.git 
cd tigerbeetle-api
Install Dependencies
bash
Copy code
npm install
3. Configure the API
You can configure the TigerBeetle address and other environment variables in a .env file:

bash
Copy code
TB_ADDRESS=127.0.0.1:3000
4. Start the API
Run the following command to start the API:

bash
Copy code
node app.js
The server will start on port 3000.

API Endpoints
1. Create Account
This endpoint allows you to create an account in TigerBeetle.

URL: POST /accounts
Request Body:
json
Copy code
{
  "accountId": 1,
  "ledger": 700
}
Response:
json
Copy code
{
  "message": "Account created successfully"
}
2. Create Transfer
This endpoint allows you to create a transfer between two accounts.

URL: POST /transfers
Request Body:
json
Copy code
{
  "debitAccountId": 1,
  "creditAccountId": 2,
  "amount": 100
}
Response:
json
Copy code
{
  "message": "Transfer successful"
}
Running in PowerShell
If you're using PowerShell, make sure to properly format your Invoke-WebRequest calls:

powershell

Invoke-WebRequest -Uri http://localhost:3000/accounts -Method POST -Headers @{ "Content-Type" = "applicat


