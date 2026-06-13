USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `pkg_init_determine_b2c_origin_facility`;
DELIMITER $$

CREATE PROCEDURE `pkg_init_determine_b2c_origin_facility`(
    IN p_business_id BINARY(16),
    IN p_requested_origin_facility_id INT,
    OUT p_origin_facility_id INT
)
SQL SECURITY INVOKER
BEGIN
    DECLARE v_mail_processing_type_id INT;
    DECLARE v_business_preferred_facility_id INT;
    DECLARE v_business_territory_id INT;
    DECLARE v_business_zip5 CHAR(5);
    DECLARE v_requested_facility_type_id INT;
    DECLARE v_preferred_facility_type_id INT;
    DECLARE v_source_has_geo TINYINT(1) DEFAULT 0;
    DECLARE v_source_lat DECIMAL(10,6);
    DECLARE v_source_lon DECIMAL(10,6);

    SET p_origin_facility_id = NULL;

    IF p_business_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Business ID is required for B2C origin resolution.';
    END IF;

    SELECT ft.`facility_type_id`
    INTO v_mail_processing_type_id
    FROM `facility_type` ft
    WHERE ft.`is_active` = 1
      AND (
          ft.`facility_type_code` = 'MAIL_PROC'
          OR ft.`facility_type_name` = 'Mail Processing'
      )
    ORDER BY (ft.`facility_type_code` = 'MAIL_PROC') DESC, ft.`facility_type_id`
    LIMIT 1;

    IF v_mail_processing_type_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mail Processing facility type could not be resolved.';
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
        b.`preferred_facility_id`,
        LEFT(TRIM(b.`zip_code`), 5)
    INTO
        v_business_preferred_facility_id,
        v_business_zip5
    FROM `business` b
    WHERE b.`business_id` = p_business_id;

    IF p_requested_origin_facility_id IS NOT NULL THEN
        SELECT f.`facility_type_id`
        INTO v_requested_facility_type_id
        FROM `facility` f
        WHERE f.`facility_id` = p_requested_origin_facility_id;

        IF v_requested_facility_type_id IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Requested B2C origin facility does not exist.';
        END IF;

        IF v_requested_facility_type_id <> v_mail_processing_type_id THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Requested B2C origin facility must be a Mail Processing facility.';
        END IF;

        SET p_origin_facility_id = p_requested_origin_facility_id;
    END IF;

    IF p_origin_facility_id IS NULL AND v_business_preferred_facility_id IS NOT NULL THEN
        SELECT f.`facility_type_id`
        INTO v_preferred_facility_type_id
        FROM `facility` f
        WHERE f.`facility_id` = v_business_preferred_facility_id;

        IF v_preferred_facility_type_id IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Business preferred facility reference is invalid.';
        END IF;

        IF v_preferred_facility_type_id <> v_mail_processing_type_id THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Business preferred facility must be a Mail Processing facility for B2C origins.';
        END IF;

        SET p_origin_facility_id = v_business_preferred_facility_id;
    END IF;

    IF p_origin_facility_id IS NULL THEN
        CALL `pkg_init_resolve_business_territory`(p_business_id, v_business_territory_id);

        IF v_business_zip5 IS NOT NULL AND CHAR_LENGTH(v_business_zip5) = 5 AND v_business_zip5 NOT REGEXP '[^0-9]' THEN
            SELECT 1, zg.`latitude`, zg.`longitude`
            INTO v_source_has_geo, v_source_lat, v_source_lon
            FROM `zip_geo` zg
            WHERE zg.`zip_code` = v_business_zip5
            LIMIT 1;
        END IF;

        -- Choose the nearest valid Mail Processing facility, preferring same-territory matches first.
        SELECT f.`facility_id`
        INTO p_origin_facility_id
        FROM `facility` f
        LEFT JOIN `zip_geo` fzg
            ON fzg.`zip_code` = LEFT(TRIM(f.`zip_code`), 5)
        WHERE f.`facility_type_id` = v_mail_processing_type_id
        ORDER BY
            CASE
                WHEN v_business_territory_id IS NOT NULL AND f.`territory_id` = v_business_territory_id THEN 0
                ELSE 1
            END,
            CASE
                WHEN v_source_has_geo = 1 AND fzg.`zip_code` IS NOT NULL THEN
                    ST_Distance_Sphere(
                        POINT(fzg.`longitude`, fzg.`latitude`),
                        POINT(v_source_lon, v_source_lat)
                    )
                ELSE NULL
            END,
            f.`facility_id`
        LIMIT 1;
    END IF;

    IF p_origin_facility_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Unable to determine a Mail Processing origin facility for the B2C package.';
    END IF;
END $$

DELIMITER ;

SELECT
    `ROUTINE_SCHEMA`,
    `ROUTINE_NAME`,
    `ROUTINE_TYPE`
FROM `information_schema`.`ROUTINES`
WHERE `ROUTINE_SCHEMA` = 'postal_bi_system'
  AND `ROUTINE_NAME` = 'pkg_init_determine_b2c_origin_facility';
