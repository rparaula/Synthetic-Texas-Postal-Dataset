USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `pkg_init_resolve_customer_territory`;
DELIMITER $$

CREATE PROCEDURE `pkg_init_resolve_customer_territory`(
    IN p_customer_id BINARY(16),
    OUT p_territory_id INT
)
SQL SECURITY INVOKER
BEGIN
    DECLARE v_customer_territory_id INT;
    DECLARE v_city VARCHAR(50);
    DECLARE v_state_code CHAR(2);
    DECLARE v_zip_code VARCHAR(10);

    SET p_territory_id = NULL;

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

    SELECT
        c.`territory_id`,
        c.`city`,
        c.`state_code`,
        c.`zip_code`
    INTO
        v_customer_territory_id,
        v_city,
        v_state_code,
        v_zip_code
    FROM `customer` c
    WHERE c.`customer_id` = p_customer_id;

    IF v_customer_territory_id IS NOT NULL AND EXISTS (
        SELECT 1
        FROM `territory` t
        WHERE t.`territory_id` = v_customer_territory_id
    ) THEN
        SET p_territory_id = v_customer_territory_id;
    ELSE
        CALL `pkg_init_resolve_recipient_territory`(
            v_zip_code,
            v_city,
            v_state_code,
            p_territory_id
        );
    END IF;

    IF p_territory_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Unable to resolve customer territory.';
    END IF;
END $$

DELIMITER ;

SELECT
    `ROUTINE_SCHEMA`,
    `ROUTINE_NAME`,
    `ROUTINE_TYPE`
FROM `information_schema`.`ROUTINES`
WHERE `ROUTINE_SCHEMA` = 'postal_bi_system'
  AND `ROUTINE_NAME` = 'pkg_init_resolve_customer_territory';
