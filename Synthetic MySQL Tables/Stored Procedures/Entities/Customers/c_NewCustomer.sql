USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `c_NewCustomer`;
DELIMITER $$

CREATE PROCEDURE `c_NewCustomer`(
    IN p_first_name VARCHAR(50),
    IN p_middle_initial CHAR(1),
    IN p_last_name VARCHAR(50),
    IN p_street_address VARCHAR(100),
    IN p_county VARCHAR(50),
    IN p_city VARCHAR(50),
    IN p_state_code CHAR(2),
    IN p_zip_code VARCHAR(10),
    IN p_territory_id INT,
    IN p_phone_number VARCHAR(15),
    IN p_email VARCHAR(100),
    IN p_user_id INT,
    IN p_preferred_facility_id INT,
    IN p_birth_date DATE,
    IN p_marital_status CHAR(1),
    IN p_gender CHAR(1),
    IN p_email_address VARCHAR(150),
    IN p_annual_income DECIMAL(10,2),
    IN p_total_children TINYINT UNSIGNED,
    IN p_education_level VARCHAR(30),
    IN p_occupation VARCHAR(30),
    IN p_home_owner CHAR(1),
    OUT p_customer_id BINARY(16)
)
SQL SECURITY INVOKER
BEGIN
    DECLARE v_customer_id BINARY(16);
    DECLARE v_first_name VARCHAR(50);
    DECLARE v_middle_initial CHAR(1);
    DECLARE v_last_name VARCHAR(50);
    DECLARE v_street_address VARCHAR(100);
    DECLARE v_county VARCHAR(50);
    DECLARE v_city VARCHAR(50);
    DECLARE v_state_code CHAR(2);
    DECLARE v_zip_code VARCHAR(10);
    DECLARE v_phone_number VARCHAR(15);
    DECLARE v_email VARCHAR(100);
    DECLARE v_email_address VARCHAR(150);
    DECLARE v_gender CHAR(1);
    DECLARE v_marital_status CHAR(1);
    DECLARE v_home_owner CHAR(1);
    DECLARE v_territory_exists INT DEFAULT 0;
    DECLARE v_user_exists INT DEFAULT 0;
    DECLARE v_facility_is_post_office INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SET v_first_name = NULLIF(TRIM(p_first_name), '');
    SET v_middle_initial = NULLIF(UPPER(TRIM(p_middle_initial)), '');
    SET v_last_name = NULLIF(TRIM(p_last_name), '');
    SET v_street_address = NULLIF(TRIM(p_street_address), '');
    SET v_county = NULLIF(TRIM(p_county), '');
    SET v_city = NULLIF(TRIM(p_city), '');
    SET v_state_code = UPPER(TRIM(p_state_code));
    SET v_zip_code = NULLIF(TRIM(p_zip_code), '');
    SET v_phone_number = NULLIF(TRIM(p_phone_number), '');
    SET v_email = LOWER(NULLIF(TRIM(p_email), ''));
    SET v_email_address = LOWER(COALESCE(NULLIF(TRIM(p_email_address), ''), v_email));
    SET v_gender = NULLIF(UPPER(TRIM(p_gender)), '');
    SET v_marital_status = NULLIF(UPPER(TRIM(p_marital_status)), '');
    SET v_home_owner = NULLIF(UPPER(TRIM(p_home_owner)), '');

    IF v_first_name IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'First name is required.';
    END IF;

    IF v_last_name IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Last name is required.';
    END IF;

    IF v_street_address IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Street address is required.';
    END IF;

    IF v_city IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'City is required.';
    END IF;

    IF v_state_code IS NULL OR CHAR_LENGTH(v_state_code) <> 2 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'State code must be a 2-character value.';
    END IF;

    IF v_state_code <> 'TX' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Customer state code must be TX.';
    END IF;

    IF v_zip_code IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ZIP code is required.';
    END IF;

    IF CHAR_LENGTH(v_zip_code) NOT IN (5, 10) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ZIP code must be 5 or 10 characters.';
    END IF;

    IF v_phone_number IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Phone number is required.';
    END IF;

    IF v_email IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Email is required.';
    END IF;

    IF v_email NOT REGEXP '^[^[:space:]@]+@[^[:space:]@]+\\.[^[:space:]@]+$' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Customer email format is invalid.';
    END IF;

    IF v_email_address IS NOT NULL
       AND v_email_address NOT REGEXP '^[^[:space:]@]+@[^[:space:]@]+\\.[^[:space:]@]+$' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Customer email_address format is invalid.';
    END IF;

    IF v_gender IS NOT NULL AND v_gender NOT IN ('M', 'F') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Customer gender must be M, F, or NULL.';
    END IF;

    IF v_marital_status IS NOT NULL AND v_marital_status NOT IN ('M', 'S') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Customer marital status must be M, S, or NULL.';
    END IF;

    IF v_home_owner IS NOT NULL AND v_home_owner NOT IN ('Y', 'N') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Customer home owner must be Y, N, or NULL.';
    END IF;

    IF p_annual_income IS NOT NULL AND p_annual_income < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Customer annual income cannot be negative.';
    END IF;

    IF p_total_children IS NOT NULL AND p_total_children > 5 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Customer total children must be between 0 and 5.';
    END IF;

    START TRANSACTION;

    IF p_territory_id IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_territory_exists
        FROM `territory`
        WHERE `territory_id` = p_territory_id;

        IF v_territory_exists = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Customer territory does not exist.';
        END IF;
    END IF;

    IF p_user_id IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_user_exists
        FROM `user_logins`
        WHERE `user_id` = p_user_id;

        IF v_user_exists = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Customer user account does not exist.';
        END IF;
    END IF;

    IF p_preferred_facility_id IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_facility_is_post_office
        FROM `facility` f
        JOIN `facility_type` ft
            ON ft.`facility_type_id` = f.`facility_type_id`
        WHERE f.`facility_id` = p_preferred_facility_id
          AND UPPER(ft.`facility_type_name`) = 'POST OFFICE';

        IF v_facility_is_post_office = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Customer preferred facility must be an existing Post Office.';
        END IF;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM `customer`
        WHERE `email` = v_email
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Customer email already exists.';
    END IF;

    IF p_user_id IS NOT NULL AND EXISTS (
        SELECT 1
        FROM `customer`
        WHERE `user_id` = p_user_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Customer user account is already assigned.';
    END IF;

    SET v_customer_id = UUID_TO_BIN(UUID());

    INSERT INTO `customer` (
        `customer_id`,
        `first_name`,
        `middle_initial`,
        `last_name`,
        `street_address`,
        `county`,
        `city`,
        `state_code`,
        `zip_code`,
        `territory_id`,
        `phone_number`,
        `email`,
        `user_id`,
        `preferred_facility_id`,
        `birth_date`,
        `marital_status`,
        `gender`,
        `email_address`,
        `annual_income`,
        `total_children`,
        `education_level`,
        `occupation`,
        `home_owner`
    )
    VALUES (
        v_customer_id,
        v_first_name,
        v_middle_initial,
        v_last_name,
        v_street_address,
        v_county,
        v_city,
        v_state_code,
        v_zip_code,
        p_territory_id,
        v_phone_number,
        v_email,
        p_user_id,
        p_preferred_facility_id,
        p_birth_date,
        v_marital_status,
        v_gender,
        v_email_address,
        p_annual_income,
        p_total_children,
        p_education_level,
        p_occupation,
        v_home_owner
    );

    COMMIT;

    SET p_customer_id = v_customer_id;
END $$

DELIMITER ;
