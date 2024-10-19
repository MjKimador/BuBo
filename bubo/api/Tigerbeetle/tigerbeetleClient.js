// tigerbeetleClient.js
const axios = require('axios');

const TB_ADDRESS = process.env.TB_ADDRESS || '127.0.0.1:3000';  // Use the TigerBeetle address
const cluster_id = 0n;  // Cluster ID

// Create the TigerBeetle client
const createClient = () => ({
    cluster_id,
    replica_addresses: [TB_ADDRESS]
});

// Example method to create an account
const createAccounts = async (accounts) => {
    try {
        const response = await axios.post(`http://${TB_ADDRESS}/create_accounts`, accounts);
        return response.data;
    } catch (error) {
        console.error('Error creating accounts:', error);
        return [];
    }
};
const getAccountTransfers = async (accountId) => {
    const filter = {
        account_id: BigInt(accountId),  // Use BigInt for account ID
        user_data_128: 0n,             // No filter by UserData (can be adjusted as needed)
        user_data_64: 0n,
        user_data_32: 0,
        code: 0,                       // No filter by Code
        timestamp_min: 0n,             // No filter by Timestamp (optional)
        timestamp_max: 0n,             // No filter by Timestamp (optional)
        limit: 100,                    // Limit the number of transfers (adjustable)
        flags: 0                       // Include all transfers (credits and debits)
    };

    try {
        const response = await axios.post(`http://${TB_ADDRESS}/get_account_transfers`, filter);
        return response.data;
    } catch (error) {
        console.error('Error fetching account transfers:', error);
        return [];
    }
};

// Example method to create transfers
const createTransfers = async (transfers) => {
    try {
        const response = await axios.post(`http://${TB_ADDRESS}/create_transfers`, transfers);
        return response.data;
    } catch (error) {
        console.error('Error creating transfers:', error);
        return [];
    }
};

module.exports = {
    createClient,
    createAccounts,
    createTransfers,
    getAccountTransfers
};
