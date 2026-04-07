-- STEP: 01_schema
-- PURPOSE: create core tables

-- Drop if needed & create
DROP DATABASE IF EXISTS xiso_staging;
CREATE DATABASE xiso_staging;
USE xiso_staging;

-- Create users main table
CREATE TABLE users (
    user_id CHAR(15) PRIMARY KEY,
    usd_account_id CHAR(15) UNIQUE NOT NULL, 
    user_name VARCHAR(255) NOT NULL DEFAULT 'USER_NAME',
    user_lastname VARCHAR(255) NOT NULL DEFAULT 'USER_LASTNAME',
    phone VARCHAR(255) UNIQUE NOT NULL, 
    email VARCHAR(255) UNIQUE NOT NULL, 
    address VARCHAR(255), 
    national_id VARCHAR(255) UNIQUE NOT NULL, 
    birthdate DATE  
);

-- Create cards 
CREATE TABLE user_cards (
    user_id CHAR(15) PRIMARY KEY,
    provider_id CHAR(4),
    method_name VARCHAR(255) NOT NULL,
    card_num INTEGER(20) NOT NULL,
    cvv_num INTEGER(3) NOT NULL,
    card_name VARCHAR(255) NOT NULL,
    card_lastname VARCHAR(255) NOT NULL,
    card_expiration_date DATE NOT NULL
);

-- Create usd account 
CREATE TABLE usd_accounts (
    usd_account_id CHAR(15) PRIMARY KEY, 
    user_id CHAR(15) UNIQUE NOT NULL,
    amount DECIMAL(15, 2) NOT NULL DEFAULT 0, 
    currency VARCHAR(3) DEFAULT 'USD',
    user_name VARCHAR(255) NOT NULL DEFAULT 'USER_NAME',
    user_lastname VARCHAR(255) NOT NULL DEFAULT 'USER_LASTNAME'
);

-- Create financial providers
CREATE TABLE financial_provider (
    provider_id CHAR(4) PRIMARY KEY,
    provider_name VARCHAR(255) UNIQUE NOT NULL, 
    provider_type VARCHAR(255) NOT NULL,
    payin_status BOOLEAN DEFAULT FALSE,
    payout_status BOOLEAN DEFAULT FALSE,
    provider_fee INTEGER
);

-- Create merchants
CREATE TABLE merchant (
  merchant_id CHAR(10) PRIMARY KEY,
  merchant_name VARCHAR(255) UNIQUE NOT NULL,
  merchant_type VARCHAR(255) NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'USD',
  merchant_fee INTEGER
);


-- Create deposits as transaction from user account to merchant
CREATE TABLE deposit (
    deposit_id CHAR(40) PRIMARY KEY, 
    usd_account_id CHAR(15) NOT NULL, 
    amount DECIMAL(15, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    external_id CHAR(40) UNIQUE NOT NULL DEFAULT(UUID()),
    deposit_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    merchant_id CHAR(10),
    merchant_name VARCHAR(255) NOT NULL,
    CHECK (amount > 0)
);

-- Create payin as transaction from financial provider to user account
CREATE TABLE payin (
    payin_id CHAR(40) PRIMARY KEY, 
    usd_account_id CHAR(15) NOT NULL, 
    amount DECIMAL(15, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    provider_id CHAR(4) NOT NULL, 
    provider_name VARCHAR(255) NOT NULL,
    provider_fee INTEGER,
    external_id CHAR(40) UNIQUE NOT NULL DEFAULT(UUID()),
    payin_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (amount > 0)
);

-- Create payout as transaction from user account to financial provider
CREATE TABLE payout (
    payout_id CHAR(40) PRIMARY KEY, 
    usd_account_id CHAR(15) NOT NULL, 
    amount DECIMAL(15, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    provider_id CHAR(4) NOT NULL,
    provider_name VARCHAR(255) NOT NULL, 
    wallet_fee INTEGER,
    external_id CHAR(40) UNIQUE NOT NULL DEFAULT(UUID()),
    payout_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    CHECK (amount > 0)
);

-- Create leger for all transactions
CREATE TABLE ledger (
    ledger_id CHAR(40) PRIMARY KEY,
    usd_account_id CHAR(15) NOT NULL,
    amount DECIMAL(15,2) NOT NULL, 
    -- 'payin', 'payout', 'deposit'
    transaction_type VARCHAR(50),
    -- id from original table
    transaction_id CHAR(40),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (amount != 0)
);-- STEP: 01_schema
-- PURPOSE: create foreign keys

-- Foreign keys of user_cards
ALTER TABLE user_cards ADD FOREIGN KEY (user_id) REFERENCES users (user_id);
ALTER TABLE user_cards ADD FOREIGN KEY (provider_id) REFERENCES financial_provider (provider_id);


-- Foreign keys of usd_accounts
ALTER TABLE usd_accounts ADD FOREIGN KEY (user_id) REFERENCES users (user_id);


-- Foreign keys of deposit
ALTER TABLE deposit ADD FOREIGN KEY (merchant_id) REFERENCES merchant (merchant_id);
ALTER TABLE deposit ADD FOREIGN KEY (usd_account_id) REFERENCES usd_accounts (usd_account_id);


-- Foreign keys of payin
ALTER TABLE payin ADD FOREIGN KEY (provider_id) REFERENCES financial_provider (provider_id);
ALTER TABLE payin ADD FOREIGN KEY (usd_account_id) REFERENCES usd_accounts (usd_account_id);


-- Foreign keys of payout
ALTER TABLE payout ADD FOREIGN KEY (provider_id) REFERENCES financial_provider (provider_id);
ALTER TABLE payout ADD FOREIGN KEY (usd_account_id) REFERENCES usd_accounts (usd_account_id);


-- Foreign keys of leger
ALTER TABLE ledger ADD FOREIGN KEY (usd_account_id) REFERENCES usd_accounts (usd_account_id);



-- STEP: 02_procedures
-- PURPOSE: create procedures for all db

-- Create produres needed when users create an account
-- Create stored procedure to generate a unique 15-digit user_id
DELIMITER //

CREATE PROCEDURE generate_user_id(OUT new_id CHAR(15))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE temp_id CHAR(15);

    -- Loop until a unique ID is found
    WHILE NOT done DO
        -- Generate a unique 15-digit ID
        SET temp_id = LPAD(FLOOR(RAND() * 1000000000000000), 15, '0');

        -- Check if this ID already exists
        IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = temp_id) THEN
            SET done = TRUE;
        END IF;
    END WHILE;

    -- Set the output parameter
    SET new_id = temp_id;
END//

DELIMITER ;

-- Create stored procedure to generate a unique 15 digit and letter usd_account_id
DELIMITER //

CREATE PROCEDURE generate_alphanumeric_id(OUT new_usd_account_id CHAR(15))
BEGIN
    DECLARE done INT DEFAULT FALSE;
	DECLARE temp_usd_id CHAR(15);
    DECLARE chars CHAR(36) DEFAULT '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    DECLARE i INT DEFAULT 1;
    DECLARE random_index INT;

    -- Function to generate a random alphanumeric ID
    SET @generate_random_id = CONCAT(
        SUBSTRING(chars, FLOOR(RAND() * 36) + 1, 1),
        SUBSTRING(chars, FLOOR(RAND() * 36) + 1, 1),
        SUBSTRING(chars, FLOOR(RAND() * 36) + 1, 1),
        SUBSTRING(chars, FLOOR(RAND() * 36) + 1, 1),
        SUBSTRING(chars, FLOOR(RAND() * 36) + 1, 1),
        SUBSTRING(chars, FLOOR(RAND() * 36) + 1, 1),
        SUBSTRING(chars, FLOOR(RAND() * 36) + 1, 1),
        SUBSTRING(chars, FLOOR(RAND() * 36) + 1, 1),
        SUBSTRING(chars, FLOOR(RAND() * 36) + 1, 1),
        SUBSTRING(chars, FLOOR(RAND() * 36) + 1, 1),
        SUBSTRING(chars, FLOOR(RAND() * 36) + 1, 1),
        SUBSTRING(chars, FLOOR(RAND() * 36) + 1, 1),
        SUBSTRING(chars, FLOOR(RAND() * 36) + 1, 1),
        SUBSTRING(chars, FLOOR(RAND() * 36) + 1, 1),
        SUBSTRING(chars, FLOOR(RAND() * 36) + 1, 1)
    );

    -- Loop until a unique ID is found
    WHILE NOT done DO
        -- Generate a random 15-character alphanumeric ID
        SET temp_usd_id = @generate_random_id;

        -- Check if this ID already exists
        IF NOT EXISTS (SELECT 1 FROM usd_accounts WHERE usd_account_id = temp_usd_id) THEN
            SET done = TRUE;
        END IF;
    END WHILE;

    -- Set the output parameter
    SET new_usd_account_id = temp_usd_id;
END//

DELIMITER ;


-- Create procedures needed for inserts in financial provider id
-- Create stored procedure to generate a unique 3 digit and letters id for providers
DELIMITER //

CREATE PROCEDURE generate_provider_id(OUT new_provider_id CHAR(4))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE temp_provider_id CHAR(4);
    DECLARE chars CHAR(36) DEFAULT '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    
    -- Loop until a unique ID is found
    WHILE NOT done DO
        -- Generate a random 4-character alphanumeric ID
        SET temp_provider_id = CONCAT(
            SUBSTRING(chars, FLOOR(RAND() * 36) + 1, 1),
            SUBSTRING(chars, FLOOR(RAND() * 36) + 1, 1),
            SUBSTRING(chars, FLOOR(RAND() * 36) + 1, 1),
            SUBSTRING(chars, FLOOR(RAND() * 36) + 1, 1)
        );
        
        -- Check if this ID already exists
        IF NOT EXISTS (SELECT 1 FROM financial_provider WHERE provider_id = temp_provider_id) THEN
            SET done = TRUE;
        END IF;
    END WHILE;

    -- Set the output parameter
    SET new_provider_id = temp_provider_id;
END//

DELIMITER ;


-- Create elements needed when users create a transaction (payin, payout or deposit)
-- Create stored procedure to generate a unique 40 digit and letter id for transactions
DELIMITER //

CREATE PROCEDURE generate_trans_id(OUT new_trans_id CHAR(40))
BEGIN
    DECLARE found_id CHAR(40);
    DECLARE exists_check INT DEFAULT 1;

    -- Loop to ensure uniqueness
    WHILE exists_check > 0 DO
        -- Generate a 40-char hex string using SHA2 and a random seed
        SET found_id = LEFT(SHA2(CONCAT(UUID(), RAND()), 256), 40);

        -- Check all three tables at once
        SELECT COUNT(*) INTO exists_check FROM (
            SELECT payout_id AS id FROM payout WHERE payout_id = found_id
            UNION ALL
            SELECT payin_id FROM payin WHERE payin_id = found_id
            UNION ALL
            SELECT deposit_id FROM deposit WHERE deposit_id = found_id
        ) AS combined_ids;
    END WHILE;

    -- Set the output parameter
    SET new_trans_id = found_id;
END//

DELIMITER ;


-- Create procedure needed when merchants create an account
-- Create stored procedure to generate a unique 10-digit merchant_id
DELIMITER //

CREATE PROCEDURE generate_merchant_id(OUT new_merchant_id CHAR(10))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE temp_merchant_id CHAR(10);

    -- Loop until a unique ID is found
    WHILE NOT done DO
        -- Generate a unique 10-digit ID
        SET temp_merchant_id = LPAD(FLOOR(RAND() * 1000000000000000), 10, '0');

        -- Check if this ID already exists
        IF NOT EXISTS (SELECT 1 FROM merchant WHERE merchant_id = temp_merchant_id) THEN
            SET done = TRUE;
        END IF;
    END WHILE;

    -- Set the output parameter
    SET new_merchant_id = temp_merchant_id;
END//

DELIMITER ;


-- STEP: 03_triggers
-- PURPOSE: create user triggers

-- Create triggers needed when users create an account
-- Create trigger to generate user_id  and usd_account_id before insert
DELIMITER //

CREATE TRIGGER before_user_insert
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    DECLARE new_user_id CHAR(15);
    DECLARE new_usd_account_id CHAR(15);
    
    -- Call the stored procedure to generate a new user ID
    CALL generate_user_id(new_user_id);
    
    -- Set the new user ID for the inserted row
    SET NEW.user_id = new_user_id;

    -- Call the stored procedure to generate a new usd account ID
    CALL generate_alphanumeric_id(new_usd_account_id);

    -- Set the new usd account ID for the inserted row
    SET NEW.usd_account_id = new_usd_account_id;


END//

DELIMITER ;

-- Create trigger to cascade info when user creates an account
DELIMITER //

CREATE TRIGGER after_user_insert
AFTER INSERT ON users
FOR EACH ROW
BEGIN

     -- Insert into usd_accounts
    INSERT INTO usd_accounts (
        usd_account_id,
        user_id,
        amount,
        currency,
        user_name,
        user_lastname
    ) VALUES (
        NEW.usd_account_id,
        NEW.user_id,
        -- Default value for amount
        0.00,  
        -- Default value for currency        
        'USD',         
        NEW.user_name,
        NEW.user_lastname
        
    );
END//

DELIMITER ;
-- STEP: 03_triggers
-- PURPOSE: create triggers for transactions

-- Create triggers needed when users create a transaction as payin, payout or deposit
-- Create trigger for id for payin
DELIMITER //

CREATE TRIGGER before_payin_insert
BEFORE INSERT ON payin
FOR EACH ROW
BEGIN
    DECLARE new_trans_id CHAR(40);

    -- Call the stored procedure to generate a new transaction ID
    CALL generate_trans_id(new_trans_id);

    -- Set the new transaction ID for the inserted row
    SET NEW.payin_id = new_trans_id;
END//

DELIMITER ;

-- Create trigger for id for payout
DELIMITER //

CREATE TRIGGER before_payout_insert
BEFORE INSERT ON payout
FOR EACH ROW
BEGIN
    DECLARE new_trans_id CHAR(40);

    -- Call the stored procedure to generate a new transaction ID
    CALL generate_trans_id(new_trans_id);

    -- Set the new transaction ID for the inserted row
    SET NEW.payout_id = new_trans_id;
END//

DELIMITER ;

-- Create trigger for id for deposit
DELIMITER //

CREATE TRIGGER before_deposit_insert
BEFORE INSERT ON deposit
FOR EACH ROW
BEGIN
    DECLARE new_trans_id CHAR(40);

    -- Call the stored procedure to generate a new transaction ID
    CALL generate_trans_id(new_trans_id);

    -- Set the new transaction ID for the inserted row
    SET NEW.deposit_id = new_trans_id;
END//

DELIMITER ;



-- Ledger triggers
-- Create trigger for payin to ledger
DELIMITER //

CREATE TRIGGER after_payin_insert
AFTER INSERT ON payin
FOR EACH ROW
BEGIN

    -- Insert into ledger
    INSERT INTO ledger (
        ledger_id,
        usd_account_id,
        transaction_id,
        amount,
        transaction_type
    ) VALUES (
        -- Automatically generate ledger_id
        UUID(),
        NEW.usd_account_id,
        NEW.payin_id,
        +NEW.amount,       
        'payin'
    );
END//

DELIMITER ;

-- Create trigger for payout to ledger
DELIMITER //

CREATE TRIGGER after_payout_insert
AFTER INSERT ON payout
FOR EACH ROW
BEGIN

    -- Insert into ledger
    INSERT INTO ledger (
        ledger_id,
        usd_account_id,
        transaction_id,
        amount,
        transaction_type
    ) VALUES (
        -- Automatically generate ledger_id
        UUID(),
        NEW.usd_account_id,
        NEW.payout_id,
        -NEW.amount,       
        'payout'
    );
END//

DELIMITER ;

-- Create trigger for deposit to ledger
DELIMITER //

CREATE TRIGGER after_deposit_insert
AFTER INSERT ON deposit
FOR EACH ROW
BEGIN

    -- Insert into ledger
    INSERT INTO ledger (
        ledger_id,
        usd_account_id,
        transaction_id,
        amount,
        transaction_type
    ) VALUES (
        -- Automatically generate ledger_id
        UUID(),
        NEW.usd_account_id,
        NEW.deposit_id,
        -NEW.amount,       
        'deposit'
    );
END//

DELIMITER ;-- STEP: 03_triggers
-- PURPOSE: create triggers for merchants and providers

-- Create trigger needed for inserts in financial provider id
-- Create trigger for id for financial_provider
DELIMITER //

CREATE TRIGGER before_provider_insert
BEFORE INSERT ON financial_provider
FOR EACH ROW
BEGIN
    DECLARE new_provider_id CHAR(4);

    -- Call the stored procedure to generate a new provider ID
    CALL generate_provider_id(new_provider_id);

    -- Set the new provider ID for the inserted row
    SET NEW.provider_id = new_provider_id;
END//

DELIMITER ;


-- Create triggers needed when merchants create an account
-- Create trigger to generate merchant_id before insert
DELIMITER //

CREATE TRIGGER before_merchant_insert
BEFORE INSERT ON merchant
FOR EACH ROW
BEGIN
    DECLARE new_merchant_id CHAR(10);
    
    -- Call the stored procedure to generate a new user ID
    CALL generate_merchant_id(new_merchant_id);
    
    -- Set the new user ID for the inserted row
    SET NEW.merchant_id = new_merchant_id;

    -- Call the stored procedure to generate a new usd account ID
    CALL generate_merchant_id(new_merchant_id);

    -- Set the new usd account ID for the inserted row
    SET NEW.merchant_id = new_merchant_id;


END//
DELIMITER ;-- STEP: 04_seeds
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





