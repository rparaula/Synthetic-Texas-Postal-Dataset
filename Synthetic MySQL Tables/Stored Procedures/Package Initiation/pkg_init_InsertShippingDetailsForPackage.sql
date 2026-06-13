USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `pkg_init_InsertShippingDetailsForPackage`;
DELIMITER $$

CREATE PROCEDURE `pkg_init_InsertShippingDetailsForPackage`(

    IN p_package_id BINARY(16),
    IN p_recipient_customer_id BINARY(16),
    IN p_sender_customer_id BINARY(16),
    IN p_sender_business_id BINARY(16),
    IN p_recipient_territory_id INT,
    IN p_sender_territory_id INT,
    IN p_expected_delivery_date DATETIME
)
SQL SECURITY INVOKER
BEGIN
    DECLARE v_recipient_first_name VARCHAR(20);
    DECLARE v_recipient_middle_initial CHAR(1);
    DECLARE v_recipient_last_name VARCHAR(20);
    DECLARE v_recipient_street_address VARCHAR(150);
    DECLARE v_recipient_city VARCHAR(50);
    DECLARE v_recipient_state_code CHAR(2);
    DECLARE v_recipient_zip_code VARCHAR(10);
    DECLARE v_sender_street_address VARCHAR(150);
    DECLARE v_sender_city VARCHAR(50);
    DECLARE v_sender_state_code CHAR(2);
    DECLARE v_sender_zip_code VARCHAR(10);
    DECLARE v_recipient_address VARCHAR(150);
    DECLARE v_sender_address VARCHAR(150);
    DECLARE v_sender_lat DECIMAL(10,6);
    DECLARE v_sender_lon DECIMAL(10,6);
    DECLARE v_recipient_lat DECIMAL(10,6);
    DECLARE v_recipient_lon DECIMAL(10,6);
    DECLARE v_estimated_distance DECIMAL(10,2);

    SELECT
        c.`first_name`,
        c.`middle_initial`,
        c.`last_name`,
        c.`street_address`,
        c.`city`,
        c.`state_code`,
        c.`zip_code`
    INTO
        v_recipient_first_name,
        v_recipient_middle_initial,
        v_recipient_last_name,
        v_recipient_street_address,
        v_recipient_city,
        v_recipient_state_code,
        v_recipient_zip_code
    FROM `customer` c
    WHERE c.`customer_id` = p_recipient_customer_id;

    IF p_sender_business_id IS NOT NULL THEN
        SELECT
            b.`street_address`,
            b.`city`,
            b.`state_code`,
            b.`zip_code`
        INTO
            v_sender_street_address,
            v_sender_city,
            v_sender_state_code,
            v_sender_zip_code
        FROM `business` b
        WHERE b.`business_id` = p_sender_business_id;
    ELSE
        SELECT
            c.`street_address`,
            c.`city`,
            c.`state_code`,
            c.`zip_code`
        INTO
            v_sender_street_address,
            v_sender_city,
            v_sender_state_code,
            v_sender_zip_code
        FROM `customer` c
        WHERE c.`customer_id` = p_sender_customer_id;
    END IF;

    SET v_recipient_address = CONCAT_WS(
        ', ',
        v_recipient_street_address,
        CONCAT(COALESCE(v_recipient_city, ''), ', ', COALESCE(v_recipient_state_code, ''), ' ', COALESCE(v_recipient_zip_code, ''))
    );

    SET v_sender_address = CONCAT_WS(
        ', ',
        v_sender_street_address,
        CONCAT(COALESCE(v_sender_city, ''), ', ', COALESCE(v_sender_state_code, ''), ' ', COALESCE(v_sender_zip_code, ''))
    );

    IF v_recipient_address IS NULL OR TRIM(v_recipient_address) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Recipient address could not be derived for shippingdetails.';
    END IF;

    IF v_sender_address IS NULL OR TRIM(v_sender_address) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sender address could not be derived for shippingdetails.';
    END IF;

    SET v_estimated_distance = NULL;

    IF p_sender_territory_id IS NOT NULL AND p_recipient_territory_id IS NOT NULL THEN
        SELECT zg.`latitude`, zg.`longitude`
        INTO v_sender_lat, v_sender_lon
        FROM `territory` t
        JOIN `zip_geo` zg
            ON zg.`zip_code` = t.`zip_code`
        WHERE t.`territory_id` = p_sender_territory_id
        LIMIT 1;

        SELECT zg.`latitude`, zg.`longitude`
        INTO v_recipient_lat, v_recipient_lon
        FROM `territory` t
        JOIN `zip_geo` zg
            ON zg.`zip_code` = t.`zip_code`
        WHERE t.`territory_id` = p_recipient_territory_id
        LIMIT 1;

        IF v_sender_lat IS NOT NULL
           AND v_sender_lon IS NOT NULL
           AND v_recipient_lat IS NOT NULL
           AND v_recipient_lon IS NOT NULL THEN
            SET v_estimated_distance = ROUND(
                ST_Distance_Sphere(
                    POINT(v_sender_lon, v_sender_lat),
                    POINT(v_recipient_lon, v_recipient_lat)
                ) / 1609.344,
                2
            );
        END IF;
    END IF;

    INSERT INTO `shippingdetails` (
        `package_id`,
        `recipient_address`,
        `recipient_territory_id`,
        `sender_address`,
        `sender_territory_id`,
        `estimated_delivery_distance`,
        `recipient_first_name`,
        `recipient_middle_initial`,
        `recipient_last_name`,
        `expected_delivery_date`
    )
    VALUES (
        p_package_id,
        v_recipient_address,
        p_recipient_territory_id,
        v_sender_address,
        p_sender_territory_id,
        v_estimated_distance,
        v_recipient_first_name,
        v_recipient_middle_initial,
        v_recipient_last_name,
        p_expected_delivery_date
    );
END $$

DELIMITER ;

SELECT
    `ROUTINE_SCHEMA`,
    `ROUTINE_NAME`,
    `ROUTINE_TYPE`
FROM `information_schema`.`ROUTINES`
WHERE `ROUTINE_SCHEMA` = 'postal_bi_system'
  AND `ROUTINE_TYPE` = 'PROCEDURE'
  AND `ROUTINE_NAME` = 'pkg_init_InsertShippingDetailsForPackage';