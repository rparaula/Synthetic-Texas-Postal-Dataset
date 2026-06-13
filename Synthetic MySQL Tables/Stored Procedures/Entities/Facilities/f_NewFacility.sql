USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `f_NewFacility`;
DELIMITER $$

CREATE PROCEDURE `f_NewFacility`(
    IN p_facility_type_id INT,
    IN p_manager_employee_id INT,
    IN p_facility_name VARCHAR(100),
    IN p_street_address VARCHAR(120),
    IN p_county VARCHAR(45),
    IN p_city VARCHAR(60),
    IN p_state_code CHAR(2),
    IN p_zip_code VARCHAR(10),
    IN p_facility_department_prefix VARCHAR(30),
    IN p_territory_id INT,
    OUT p_facility_id INT
)
SQL SECURITY INVOKER
BEGIN
    DECLARE v_facility_name VARCHAR(100);
    DECLARE v_street_address VARCHAR(120);
    DECLARE v_county VARCHAR(45);
    DECLARE v_city VARCHAR(60);
    DECLARE v_state_code CHAR(2);
    DECLARE v_zip_code VARCHAR(10);
    DECLARE v_prefix_candidate VARCHAR(30);
    DECLARE v_base_prefix VARCHAR(30);
    DECLARE v_territory_exists INT DEFAULT 0;
    DECLARE v_manager_exists INT DEFAULT 0;
    DECLARE v_facility_type_is_active INT DEFAULT 0;
    DECLARE v_prefix_suffix INT DEFAULT 1;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SET v_facility_name = NULLIF(TRIM(p_facility_name), '');
    SET v_street_address = NULLIF(TRIM(p_street_address), '');
    SET v_county = NULLIF(UPPER(TRIM(p_county)), '');
    SET v_city = NULLIF(UPPER(TRIM(p_city)), '');
    SET v_state_code = UPPER(TRIM(p_state_code));
    SET v_zip_code = NULLIF(TRIM(p_zip_code), '');
    SET v_prefix_candidate = NULLIF(UPPER(TRIM(p_facility_department_prefix)), '');

    IF p_facility_type_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Facility type ID is required.';
    END IF;

    IF v_facility_name IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Facility name is required.';
    END IF;

    IF v_street_address IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Facility street address is required.';
    END IF;

    IF v_county IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Facility county is required.';
    END IF;

    IF v_city IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Facility city is required.';
    END IF;

    IF v_state_code IS NULL OR CHAR_LENGTH(v_state_code) <> 2 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Facility state code must be a 2-character value.';
    END IF;

    IF v_zip_code IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Facility ZIP code is required.';
    END IF;

    IF CHAR_LENGTH(v_zip_code) NOT IN (5, 10) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Facility ZIP code must be 5 or 10 characters.';
    END IF;

    START TRANSACTION;

    SELECT COUNT(*)
    INTO v_facility_type_is_active
    FROM `facility_type`
    WHERE `facility_type_id` = p_facility_type_id
      AND `is_active` = 1;

    IF v_facility_type_is_active = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Facility type does not exist or is inactive.';
    END IF;

    IF p_territory_id IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_territory_exists
        FROM `territory`
        WHERE `territory_id` = p_territory_id;

        IF v_territory_exists = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Facility territory does not exist.';
        END IF;
    END IF;

    IF p_manager_employee_id IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_manager_exists
        FROM `employee`
        WHERE `employee_id` = p_manager_employee_id;

        IF v_manager_exists = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Facility manager employee does not exist.';
        END IF;
    END IF;

    IF v_prefix_candidate IS NULL THEN
        SET v_base_prefix = REGEXP_REPLACE(UPPER(v_facility_name), '[^A-Z0-9]+', '');
        SET v_base_prefix = NULLIF(v_base_prefix, '');

        IF v_base_prefix IS NULL THEN
            SET v_base_prefix = 'FACILITY';
        END IF;

        SET v_base_prefix = LEFT(v_base_prefix, 30);
        SET v_prefix_candidate = v_base_prefix;

        WHILE EXISTS (
            SELECT 1
            FROM `facility`
            WHERE `facility_department_prefix` = v_prefix_candidate
        ) DO
            SET v_prefix_suffix = v_prefix_suffix + 1;
            SET v_prefix_candidate = CONCAT(
                LEFT(v_base_prefix, 30 - CHAR_LENGTH(CAST(v_prefix_suffix AS CHAR))),
                CAST(v_prefix_suffix AS CHAR)
            );
        END WHILE;
    ELSE
        IF EXISTS (
            SELECT 1
            FROM `facility`
            WHERE `facility_department_prefix` = v_prefix_candidate
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Facility department prefix already exists.';
        END IF;
    END IF;

    INSERT INTO `facility` (
        `facility_type_id`,
        `manager_employee_id`,
        `facility_name`,
        `street_address`,
        `county`,
        `city`,
        `state_code`,
        `zip_code`,
        `facility_department_prefix`,
        `territory_id`
    )
    VALUES (
        p_facility_type_id,
        p_manager_employee_id,
        v_facility_name,
        v_street_address,
        v_county,
        v_city,
        v_state_code,
        v_zip_code,
        v_prefix_candidate,
        p_territory_id
    );

    SET p_facility_id = LAST_INSERT_ID();

    COMMIT;
END $$

DELIMITER ;
