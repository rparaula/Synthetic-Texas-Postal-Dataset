USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `pkg_init_ValidateB2CPackageInputs`;
DELIMITER $$

CREATE PROCEDURE `pkg_init_ValidateB2CPackageInputs`(

    IN p_recipient_customer_id BINARY(16),
    IN p_sender_business_id BINARY(16),
    IN p_service_type_id INT,
    IN p_weight_oz DECIMAL(8,2),
    IN p_length_in DECIMAL(8,2),
    IN p_width_in DECIMAL(8,2),
    IN p_height_in DECIMAL(8,2),
    IN p_received_date DATETIME,
    IN p_expected_delivery_date DATETIME
)
SQL SECURITY INVOKER
BEGIN
    IF p_recipient_customer_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Recipient customer ID is required for B2C package creation.';
    END IF;

    IF p_sender_business_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sender business ID is required for B2C package creation.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM `customer` c
        WHERE c.`customer_id` = p_recipient_customer_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Recipient customer does not exist.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM `business` b
        WHERE b.`business_id` = p_sender_business_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sender business does not exist.';
    END IF;

    IF p_service_type_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Service type ID is required.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM `service_type` st
        WHERE st.`service_type_id` = p_service_type_id
          AND st.`is_active` = 1
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Service type is invalid or inactive.';
    END IF;

    IF p_weight_oz IS NULL OR p_weight_oz <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Package weight_oz must be greater than 0.';
    END IF;

    IF p_length_in IS NULL OR p_length_in <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Package length_in must be greater than 0.';
    END IF;

    IF p_width_in IS NULL OR p_width_in <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Package width_in must be greater than 0.';
    END IF;

    IF p_height_in IS NULL OR p_height_in <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Package height_in must be greater than 0.';
    END IF;

    IF p_received_date IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Received timestamp is required.';
    END IF;

    IF p_expected_delivery_date IS NOT NULL
       AND p_expected_delivery_date < p_received_date THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Expected delivery timestamp must be greater than or equal to received timestamp.';
    END IF;
END $$

DELIMITER ;

SELECT
    `ROUTINE_SCHEMA`,
    `ROUTINE_NAME`,
    `ROUTINE_TYPE`
FROM `information_schema`.`ROUTINES`
WHERE `ROUTINE_SCHEMA` = 'postal_bi_system'
  AND `ROUTINE_TYPE` = 'PROCEDURE'
  AND `ROUTINE_NAME` = 'pkg_init_ValidateB2CPackageInputs';