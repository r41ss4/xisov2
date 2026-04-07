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
