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


