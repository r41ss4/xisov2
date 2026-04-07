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
);