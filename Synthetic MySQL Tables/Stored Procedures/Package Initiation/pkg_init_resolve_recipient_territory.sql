USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `pkg_init_resolve_recipient_territory`;
DELIMITER $$

CREATE PROCEDURE `pkg_init_resolve_recipient_territory`(
    IN p_zip_code VARCHAR(10),
    IN p_city VARCHAR(100),
    IN p_state_code CHAR(2),
    OUT p_territory_id INT
)
SQL SECURITY INVOKER
BEGIN
    DECLARE v_zip5 CHAR(5);
    DECLARE v_state_code CHAR(2);
    DECLARE v_city VARCHAR(100);
    DECLARE v_match_count INT DEFAULT 0;

    SET p_territory_id = NULL;
    SET v_zip5 = LEFT(TRIM(p_zip_code), 5);
    SET v_state_code = UPPER(TRIM(p_state_code));
    SET v_city = UPPER(TRIM(p_city));

    IF p_state_code IS NULL OR TRIM(p_state_code) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Recipient state code is required.';
    END IF;

    IF v_state_code <> 'TX' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Recipient state code must be TX for the current demo.';
    END IF;

    IF p_city IS NULL OR TRIM(p_city) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Recipient city is required.';
    END IF;

    IF p_zip_code IS NULL OR TRIM(p_zip_code) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Recipient ZIP code is required.';
    END IF;

    IF CHAR_LENGTH(v_zip5) <> 5 OR v_zip5 REGEXP '[^0-9]' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Recipient ZIP code must contain a valid 5-digit ZIP.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM `zip_geo`
        WHERE `zip_code` = v_zip5
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Recipient ZIP code does not exist in zip_geo.';
    END IF;

    -- Prefer an exact ZIP + city + state match when it resolves uniquely.
    SELECT COUNT(*)
    INTO v_match_count
    FROM `territory` t
    WHERE t.`state` = v_state_code
      AND UPPER(TRIM(t.`city`)) = v_city
      AND t.`zip_code` = v_zip5;

    IF v_match_count = 1 THEN
        SELECT MAX(t.`territory_id`)
        INTO p_territory_id
        FROM `territory` t
        WHERE t.`state` = v_state_code
          AND UPPER(TRIM(t.`city`)) = v_city
          AND t.`zip_code` = v_zip5;
    ELSEIF v_match_count > 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Recipient territory is ambiguous for the provided ZIP, city, and state.';
    END IF;

    -- Fall back to an exact ZIP + state match only if it is unique.
    IF p_territory_id IS NULL THEN
        SELECT COUNT(*)
        INTO v_match_count
        FROM `territory` t
        WHERE t.`state` = v_state_code
          AND t.`zip_code` = v_zip5;

        IF v_match_count = 1 THEN
            SELECT MAX(t.`territory_id`)
            INTO p_territory_id
            FROM `territory` t
            WHERE t.`state` = v_state_code
              AND t.`zip_code` = v_zip5;
        END IF;
    END IF;

    -- Fall back to an exact city + state match only if it is unique.
    IF p_territory_id IS NULL THEN
        SELECT COUNT(*)
        INTO v_match_count
        FROM `territory` t
        WHERE t.`state` = v_state_code
          AND UPPER(TRIM(t.`city`)) = v_city;

        IF v_match_count = 1 THEN
            SELECT MAX(t.`territory_id`)
            INTO p_territory_id
            FROM `territory` t
            WHERE t.`state` = v_state_code
              AND UPPER(TRIM(t.`city`)) = v_city;
        END IF;
    END IF;

    IF p_territory_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Unable to resolve a unique recipient territory.';
    END IF;
END $$

DELIMITER ;

SELECT
    `ROUTINE_SCHEMA`,
    `ROUTINE_NAME`,
    `ROUTINE_TYPE`
FROM `information_schema`.`ROUTINES`
WHERE `ROUTINE_SCHEMA` = 'postal_bi_system'
  AND `ROUTINE_NAME` = 'pkg_init_resolve_recipient_territory';
