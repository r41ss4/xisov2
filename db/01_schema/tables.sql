-- Create db and use
CREATE DATABASE xiso_staging
USE xiso_staging

-- Create tables
-- Create users main table
CREATE TABLE users (
    user_id PRIMARY KEY, CHAR(15),
    usd_account_id CHAR(15), UNIQUE, NOT NULL, 
    user_name VARCHAR(255), NOT NULL, DEFAULT 'USER_NAME',
    user_lastname VARCHAR(255), NOT NULL, DEFAULT 'USER_LASTNAME',
    phone VARCHAR(255), UNIQUE, NOT NULL, 
    email VARCHAR(255), UNIQUE, NOT NULL, 
    address VARCHAR(255), NOT NULL, 
    notional_id VARCHAR(255), UNIQUE, NOT NULL, 
    birthdate DATE  
)

-- Create cards 
CREATE TABLE user_cards (
    user_id PRIMARY KEY, CHAR(15),
    provider_id CHAR(4),
    method_name VARCHAR(255),
    card_num INTEGER(20),
    cvv_num INTEGER(3),
    card_name VARCHAR(255),
    card_lastname VARCHAR(255),
    card_expiration_date DATE
)

-- Create usd account 
CREATE TABLE usd_account (
    user_account_id PRIMARY KEY, CHAR(15), 
    user_id CHAR(15), UNIQUE, NOT NULL,
    amount DECIMAL(15, 2), NOT NULL, DEFAULT 0, 
    currency VARCHAR(3), DEFAULT 'USD',
    user_name VARCHAR(255), NOT NULL, DEFAULT 'USER_NAME',
    user_lastname VARCHAR(255), NOT NULL, DEFAULT 'USER_LASTNAME'
)

-- Create financial providers
CREATE TABLE financial_providers (
    provider_id PRIMARY KEY, CHAR(4),
    provider_name VARCHAR(255), UNIQUE, NOT NULL, 
    provider_type VARCHAR(255), NOT NULL,
    payin_status BOOLEAN, DEFAULT FALSE,
    payout_status BOOLEAN, DEFAULT FALSE,
    provider_fee INTEGER
)

-- Create merchants
CREATE TABLE merchants (
  merchant_id PRIMARY KEY, CHAR(10),
  merchant_name varchar(255) UNIQUE, NOT NULL,
  merchant_type varchar(255), NOT NULL,
  amount decimal (15, 2) NOT NULL,
  currency varchar(3) DEFAULT 'USD',
  merchant_fee integer
);


-- Create deposits as transaction from user account to merchant
CREATE TABLE deposit (
    deposit_id PRIMARY KEY, CHAR(40), 
    usd_account_id CHAR(15), NOT NULL, 
    amount DECIMAL(15, 2), NOT NULL,
    currency VARCHAR(3), DEFAULT 'USD',
    external_id CHAR(40), UNIQUE, NOT NULL, DEFAULT(UUID()),
    deposit_date TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
)

-- Create payin as transaction from financial provider to user account
CREATE TABLE payin (
    payin_id PRIMARY KEY, CHAR(40), 
    usd_account_id CHAR(15), NOT NULL, 
    amount DECIMAL(15, 2), NOT NULL,
    currency VARCHAR(3), DEFAULT 'USD',
    provider_id CHAR(4), NOT NULL, 
    provider_fee INTEGER,
    external_id CHAR(40), UNIQUE, NOT NULL, DEFAULT(UUID()),
    payin_date TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
)

-- Create payout as transaction from user account to financial provider
CREATE TABLE payout (
    payout_id PRIMARY KEY, CHAR(40), 
    usd_account_id CHAR(15), NOT NULL, 
    amount DECIMAL(15, 2), NOT NULL,
    currency VARCHAR(3), DEFAULT 'USD',
    provider_id CHAR(4), NOT NULL, 
    wallet_fee INTEGER,
    external_id CHAR(40), UNIQUE, NOT NULL, DEFAULT(UUID()),
    payout_date TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
)

-- Create leger for all transactions
CREATE TABLE ledger (
    ledger_id CHAR(40) PRIMARY KEY,
    usd_account_id CHAR(15), NOT NULL,
    amount DECIMAL(15,2), NOT NULL, 
    -- 'payin', 'payout', 'deposit'
    transaction_type VARCHAR(50),
    -- id from original table
    transaction_id CHAR(40),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);