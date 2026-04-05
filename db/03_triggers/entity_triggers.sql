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
