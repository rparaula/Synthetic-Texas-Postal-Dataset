USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `b_ValidateBusinessExists`;
DELIMITER $$

CREATE PROCEDURE `b_ValidateBusinessExists`(
    IN p_business_id BINARY(16)
)
SQL SECURITY INVOKER
BEGIN
    IF p_business_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Business ID is required.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM `business`
        WHERE `business_id` = p_business_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Business does not exist.';
    END IF;
END $$

DELIMITER ;
