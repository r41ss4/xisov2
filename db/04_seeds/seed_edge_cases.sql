-- STEP: 04_seeds
-- PURPOSE: create seed for edge testing
-- COMMAND: SOURCE db/04_seeds/seed_edge_cases.sql;

-- SET variables from seed_basic.sql
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



-- Zero amount transactions test
-- Zero amount deposit 
INSERT INTO deposit (usd_account_id, amount, currency, merchant_id, merchant_name) 
VALUES (
    @test_usd_account_id, 
    00.00, 'USD', 
    @test_merchant_id, 
    'Acme Corp'
);
-- EXPECT: FAIL (CHECK constraint) 

-- Zero amount payin 
INSERT INTO payin (usd_account_id, amount, currency, provider_id, provider_name, provider_fee)
VALUES (
    @test_usd_account_id, 
    00.00, 'USD', 
    @test_provider_id, 
    'VISA', 0
);
-- EXPECT: FAIL (CHECK constraint) 

-- Zero amount payout 
INSERT INTO payout (usd_account_id, amount, currency, provider_id, provider_name) 
VALUES (
    @test_usd_account_id, 
    00.00, 'USD', 
    @test_provider_id, 
    'VISA', 0
);
-- EXPECT: FAIL (CHECK constraint) 


-- Very large amount
-- Large amount deposit 
INSERT INTO deposit (usd_account_id, amount, currency, merchant_id, merchant_name) 
VALUES (
    @test_usd_account_id, 
    999999999999999.99, 'USD', 
    @test_merchant_id, 
    'Acme Corp'
);
-- EXPECT: PASS 

-- Large amount payin 
INSERT INTO payin (usd_account_id, amount, currency, provider_id, provider_name, provider_fee)
VALUES (
    @test_usd_account_id, 
    999999999999999.99, 'USD', 
    @test_provider_id, 
    'VISA', 0
);
-- EXPECT: PASS 

-- Large amount payout 
INSERT INTO payout (usd_account_id, amount, currency, provider_id, provider_name) 
VALUES (
    @test_usd_account_id, 
    999999999999999.99, 'USD', 
    @test_provider_id, 
    'VISA', 0
);
-- EXPECT: PASS 



-- Duplicate phone/email attempt
-- Users same email
INSERT INTO users (user_name, user_lastname, email, phone, national_id, birthdate) 
VALUES ('Sara', 'Bibi', 'hehe@faky.com', '689798578', '9368966', '1999-05-12');
-- EXPECT: PASS 

INSERT INTO users (user_name, user_lastname, email, phone, national_id, birthdate) 
VALUES ('Jeff', 'Jeffrey', 'hehe@faky.com', '809807985', '29080983', '2000-04-11');
-- EXPECT: FAIL (UNIQUE constraint) 


-- Users same phone
INSERT INTO users (user_name, user_lastname, email, phone, national_id, birthdate) 
VALUES ('Brenda', 'Johnson', 'not@faky.com', '36887986', '790890809', '1999-05-12');
-- EXPECT: PASS 

INSERT INTO users (user_name, user_lastname, email, phone, national_id, birthdate) 
VALUES ('Ashley', 'Lewis', 'now@faky.com', '36887986', '12789798', '2000-04-11');
-- EXPECT: FAIL (UNIQUE constraint) 



-- Missing optional fields
-- Missing birthdate
INSERT INTO users (user_name, user_lastname, email, phone, national_id) 
VALUES ('Ken', 'Ivy', 'hehe@faky.com', '9478564', '790890809');
-- EXPECT: PASS 


-- Invalid data insert
-- Invalid provider_id
INSERT INTO payin (usd_account_id, amount, currency, provider_id)
VALUES (@usd_account_id, 50, 'USD', 'XXXX');
-- EXPECT: FAIL (FK constraint) 

-- Forcing ID payin
INSERT INTO payin (payin_id, usd_account_id, amount, currency, provider_id)
VALUES ('MANUAL_ID_TEST', @usd_account_id, 50, 'USD', @provider_id);
-- EXPECT: FAIL (FK constraint) 
