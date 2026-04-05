-- Foreig keys
-- Alter tables for foreign keys and references

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
ALTER TABLE ledger ADD FOREIGN KEY (transaction_id) REFERENCES payout (payout_id);
ALTER TABLE ledger ADD FOREIGN KEY (transaction_id) REFERENCES payin (payin_id);
ALTER TABLE ledger ADD FOREIGN KEY (transaction_id) REFERENCES deposit (deposit_id);



