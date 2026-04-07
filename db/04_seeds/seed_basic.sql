-- STEP: 04_seeds
-- PURPOSE: create seed for basic testing

-- INSERT main entities
-- INSERT user info in users table
INSERT INTO users (user_name, user_lastname, email, phone, national_id, birthdate) 
VALUES ('Tester', 'Testty', 'hi@faky.com', '598678778', '73520962', '1999-04-11');


-- INSERT provider info in financial_provider table
INSERT INTO financial_provider (provider_name, provider_type, payin_status, payout_status, provider_fee)
VALUES ('VISA', 'Credit Card', TRUE, TRUE, 10);


-- INSERT merchant info in merchants table
INSERT INTO merchant (merchant_name, merchant_type, amount, currency, merchant_fee) 
VALUES ('Acme Corp', 'Retail', 10000.00, 'USD', 2);



-- SET variables
-- SET usd_account_id of new user to reuse
SELECT usd_account_id 
INTO @test_usd_account_id 
FROM usd_accounts
WHERE user_id = (
    SELECT user_id 
    FROM users 
    WHERE user_name = 'Tester' 
    LIMIT 1
);


-- SET merchant_id of new merchant to reuse
SELECT merchant_id 
INTO @test_merchant_id
FROM merchant
WHERE merchant_id = (
    SELECT merchant_id 
    FROM merchant 
    WHERE merchant_name = 'Acme Corp' 
    LIMIT 1
);


-- SET provider_id of new provider to reuse
SELECT provider_id 
INTO @test_provider_id
FROM financial_provider
WHERE provider_id = (
    SELECT provider_id 
    FROM financial_provider 
    WHERE provider_name = 'VISA' 
    LIMIT 1
);



-- INSERT transactions
-- INSERT payin transactions 
-- Use the usd_account_id and provider_id automatically generated from previous inserts
INSERT INTO payin (usd_account_id, amount, currency, provider_id, provider_name, provider_fee)
VALUES (
    @test_usd_account_id, 
    3000.00, 'USD', 
    @test_provider_id, 
    'VISA', 675
);


-- INSERT payout transactions
-- Use the usd_account_id and provider_id automatically generated from previous inserts
INSERT INTO payout (usd_account_id, amount, currency, provider_id, provider_name) 
VALUES (
    @test_usd_account_id, 
    30.00, 'USD', 
    @test_provider_id, 
    'VISA'
);


-- INSERT deposit transactions
-- Use the usd_account_id and merchant_id automatically generated from previous inserts
INSERT INTO deposit (usd_account_id, amount, currency, merchant_id, merchant_name) 
VALUES (
    @test_usd_account_id, 
    100.00, 'USD', 
    @test_merchant_id, 
    'Acme Corp'
);





