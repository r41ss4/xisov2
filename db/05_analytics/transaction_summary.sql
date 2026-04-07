-- Show current count and total value of transactions by type
SELECT 
    transaction_type,
    COUNT(*) AS total_tx,
    SUM(amount) AS total_amount
FROM ledger
GROUP BY transaction_type;