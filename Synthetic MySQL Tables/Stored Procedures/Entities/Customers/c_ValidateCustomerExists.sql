USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `c_ValidateCustomerExists`;
DELIMITER $$

CREATE PROCEDURE `c_ValidateCustomerExists`(
    IN p_customer_id BINARY(16)
)
SQL SECURITY INVOKER
BEGIN
    IF p_customer_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Customer ID is required.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM `customer`
        WHERE `customer_id` = p_customer_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Customer does not exist.';
    END IF;
END $$

DELIMITER ;
