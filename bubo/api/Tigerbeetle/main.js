// app.js
const express = require('express');
const { createAccounts, createTransfers } = require('./tigerbeetleClient');
const app = express();
app.use(express.json());  // For parsing JSON bodies

const port = 3000;

// Route to create accounts
app.post('/accounts', async (req, res) => {
    const { accountId, ledger } = req.body;
    const accounts = [{
        id: BigInt(accountId),   // TigerBeetle uses BigInt for IDs
        debits_pending: 0n,
        debits_posted: 0n,
        credits_pending: 0n,
        credits_posted: 0n,
        user_data_128: 0n,
        user_data_64: 0n,
        user_data_32: 0,
        reserved: 0,
        ledger: ledger || 1,
        code: 718,
        flags: 0,
        timestamp: 0n
    }];

    const accountErrors = await createAccounts(accounts);
    if (accountErrors.length > 0) {
        return res.status(400).json({ errors: accountErrors });
    }
    res.status(201).json({ message: 'Account created successfully' });
});
// Route to get transaction history for a specific account
app.get('/accounts/:accountId/transfers', async (req, res) => {
    const { accountId } = req.params;
    try {
        const transfers = await getAccountTransfers(accountId);
        if (transfers.length === 0) {
            return res.status(404).json({ message: 'No transfers found for this account' });
        }
        res.status(200).json(transfers);
    } catch (error) {
        res.status(500).json({ error: 'Error retrieving transaction history' });
    }
});

// Route to create a transfer
app.post('/transfers', async (req, res) => {
    const { debitAccountId, creditAccountId, amount } = req.body;
    const transfers = [{
        id: BigInt(Date.now()),   // Use a time-based ID
        debit_account_id: BigInt(debitAccountId),
        credit_account_id: BigInt(creditAccountId),
        amount: BigInt(amount),
        pending_id: 0n,
        user_data_128: 0n,
        user_data_64: 0n,
        user_data_32: 0,
        timeout: 0,
        ledger: 1,
        code: 720,
        flags: 0,
        timestamp: 0n
    }];

    const transferErrors = await createTransfers(transfers);
    if (transferErrors.length > 0) {
        return res.status(400).json({ errors: transferErrors });
    }
    res.status(201).json({ message: 'Transfer successful' });
});

// Start the server
app.listen(port, () => {
    console.log(`BudgetLock TigerBeetle API running on port ${port}`);
});
