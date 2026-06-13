USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `pkg_init_resolve_business_territory`;
DELIMITER $$

CREATE PROCEDURE `pkg_init_resolve_business_territory`(
    IN p_business_id BINARY(16),
    OUT p_territory_id INT
)
SQL SECURITY INVOKER
BEGIN
    DECLARE v_business_territory_id INT;
    DECLARE v_city VARCHAR(50);
    DECLARE v_state_code CHAR(2);
    DECLARE v_zip_code VARCHAR(10);

    SET p_territory_id = NULL;

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

    SELECT
        b.`territory_id`,
        b.`city`,
        b.`state_code`,
        b.`zip_code`
    INTO
        v_business_territory_id,
        v_city,
        v_state_code,
        v_zip_code
    FROM `business` b
    WHERE b.`business_id` = p_business_id;

    IF v_business_territory_id IS NOT NULL AND EXISTS (
        SELECT 1
        FROM `territory` t
        WHERE t.`territory_id` = v_business_territory_id
    ) THEN
        SET p_territory_id = v_business_territory_id;
    ELSE
        IF v_city IS NULL OR TRIM(v_city) = '' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Business city is required to resolve territory.';
        END IF;

        IF v_zip_code IS NULL OR TRIM(v_zip_code) = '' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Business ZIP code is required to resolve territory.';
        END IF;

        CALL `pkg_init_resolve_recipient_territory`(
            v_zip_code,
            v_city,
            v_state_code,
            p_territory_id
        );
    END IF;

    IF p_territory_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Unable to resolve business territory.';
    END IF;
END $$

DELIMITER ;

SELECT
    `ROUTINE_SCHEMA`,
    `ROUTINE_NAME`,
    `ROUTINE_TYPE`
FROM `information_schema`.`ROUTINES`
WHERE `ROUTINE_SCHEMA` = 'postal_bi_system'
  AND `ROUTINE_NAME` = 'pkg_init_resolve_business_territory';
