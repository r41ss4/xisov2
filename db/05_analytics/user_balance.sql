-- Show current balance of users by usd_account_id
SELECT 
    usd_account_id,
    SUM(amount) AS balance
FROM ledger
GROUP BY usd_account_id;