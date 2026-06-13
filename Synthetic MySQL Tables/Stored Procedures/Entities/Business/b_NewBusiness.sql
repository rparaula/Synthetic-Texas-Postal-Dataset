USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `b_NewBusiness`;
DELIMITER $$

CREATE PROCEDURE `b_NewBusiness`(
    IN p_business_name VARCHAR(150),
    IN p_street_address VARCHAR(150),
    IN p_county VARCHAR(50),
    IN p_city VARCHAR(50),
    IN p_state_code CHAR(2),
    IN p_zip_code VARCHAR(10),
    IN p_territory_id INT,
    IN p_phone_number VARCHAR(20),
    IN p_email VARCHAR(100),
    IN p_preferred_facility_id INT,
    OUT p_business_id BINARY(16)
)
SQL SECURITY INVOKER
BEGIN
    DECLARE v_business_id BINARY(16);
    DECLARE v_business_name VARCHAR(150);
    DECLARE v_street_address VARCHAR(150);
    DECLARE v_county VARCHAR(50);
    DECLARE v_city VARCHAR(50);
    DECLARE v_state_code CHAR(2);
    DECLARE v_zip_code VARCHAR(10);
    DECLARE v_phone_number VARCHAR(20);
    DECLARE v_email VARCHAR(100);
    DECLARE v_territory_exists INT DEFAULT 0;
    DECLARE v_mail_processing_facility_exists INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SET v_business_name = NULLIF(TRIM(p_business_name), '');
    SET v_street_address = NULLIF(TRIM(p_street_address), '');
    SET v_county = NULLIF(UPPER(TRIM(p_county)), '');
    SET v_city = NULLIF(UPPER(TRIM(p_city)), '');
    SET v_state_code = UPPER(TRIM(p_state_code));
    SET v_zip_code = NULLIF(TRIM(p_zip_code), '');
    SET v_phone_number = NULLIF(TRIM(p_phone_number), '');
    SET v_email = LOWER(NULLIF(TRIM(p_email), ''));

    IF v_business_name IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Business name is required.';
    END IF;

    IF v_state_code IS NULL OR CHAR_LENGTH(v_state_code) <> 2 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Business state code must be a 2-character value.';
    END IF;

    IF v_state_code <> 'TX' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Business state code must be TX.';
    END IF;

    IF v_email IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Business email is required.';
    END IF;

    IF v_email NOT REGEXP '^[^[:space:]@]+@[^[:space:]@]+\\.[^[:space:]@]+$' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Business email format is invalid.';
    END IF;

    IF v_zip_code IS NOT NULL AND CHAR_LENGTH(v_zip_code) NOT IN (5, 10) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Business ZIP code must be 5 or 10 characters.';
    END IF;

    START TRANSACTION;

    IF p_territory_id IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_territory_exists
        FROM `territory`
        WHERE `territory_id` = p_territory_id;

        IF v_territory_exists = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Business territory does not exist.';
        END IF;
    END IF;

    IF p_preferred_facility_id IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_mail_processing_facility_exists
        FROM `facility` f
        JOIN `facility_type` ft
            ON ft.`facility_type_id` = f.`facility_type_id`
        WHERE f.`facility_id` = p_preferred_facility_id
          AND UPPER(ft.`facility_type_name`) = 'MAIL PROCESSING';

        IF v_mail_processing_facility_exists = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Business preferred facility must be an existing Mail Processing facility.';
        END IF;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM `business`
        WHERE `email` = v_email
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Business email already exists.';
    END IF;

    SET v_business_id = UUID_TO_BIN(UUID());

    INSERT INTO `business` (
        `business_id`,
        `business_name`,
        `street_address`,
        `county`,
        `city`,
        `state_code`,
        `zip_code`,
        `territory_id`,
        `phone_number`,
        `email`,
        `preferred_facility_id`
    )
    VALUES (
        v_business_id,
        v_business_name,
        v_street_address,
        v_county,
        v_city,
        v_state_code,
        v_zip_code,
        p_territory_id,
        v_phone_number,
        v_email,
        p_preferred_facility_id
    );

    COMMIT;

    SET p_business_id = v_business_id;
END $$

DELIMITER ;
