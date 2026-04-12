-- PURPOSE: create seed for multiple users and transactions

DELIMITER //

CREATE PROCEDURE seed_heavy_users()
BEGIN
    -- Declare variable
    DECLARE u INT DEFAULT 0;
    DECLARE t INT;
    DECLARE balance DECIMAL(15,2);
    DECLARE amount DECIMAL(15,2);
    DECLARE current_usd_account_id CHAR(15);
    DECLARE current_user_id CHAR(15);


    -- Loop until 1000
    WHILE u < 1000 DO

        -- Set balance 0 per user
        SET balance = 0;

        -- Insert new users
        INSERT INTO users (user_name, user_lastname, email, phone, national_id, birthdate)
        VALUES (
            CONCAT('User', u),
            'LoadTest',
            CONCAT('user', u, '@test.com'),
            CONCAT('698', LPAD(u, 7, '0')),
            CONCAT('ID', u),
            '1990-01-01'
        );

        -- Get user_id as last inserted logically
        SELECT user_id INTO current_user_id
        FROM users
        WHERE user_name = CONCAT('User', u);

        -- Get usd_account_id 
        SELECT usd_account_id INTO current_usd_account_id
        FROM usd_accounts
        WHERE user_id = current_user_id;

        -- Set for loop
        SET t = 0;
        WHILE t < 50 DO

            -- Set for amount tracking
            SET amount = RAND() * 1000;

            -- Insert payin for users
            INSERT INTO payin (usd_account_id, amount, currency, provider_id, provider_name)
            VALUES 
                (current_usd_account_id, 
                amount,
                'USD',
                (SELECT provider_id FROM financial_provider LIMIT 1),
                (SELECT provider_name FROM financial_provider LIMIT 1)
            );

            
            -- Set for new amount tracking after payin
            SET balance = balance + amount;
            SET t = t + 1;

        END WHILE;

        -- Condition payout trigger for randomness
        IF balance > 0 THEN
            SET amount = RAND() * balance;

            -- Insert payout for users
            INSERT INTO payout (usd_account_id, amount, currency, provider_id, provider_name)
            VALUES 
                (current_usd_account_id, 
                amount,
                'USD',
                (SELECT provider_id FROM financial_provider LIMIT 1),
                (SELECT provider_name FROM financial_provider LIMIT 1)
            );        

            -- Set new amount tracking after payout
            SET balance = balance - amount;

        -- Close ends
        END IF;

        -- Set increment of u
        SET u = u + 1;
    END WHILE;
    
END//

DELIMITER ;