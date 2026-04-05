
-- Create triggers needed when users create a transaction (payin, payout or deposit)
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
        ledger_id
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
        ledger_id
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

DELIMITER ;