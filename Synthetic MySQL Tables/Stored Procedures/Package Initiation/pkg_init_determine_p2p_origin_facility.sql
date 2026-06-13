USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `pkg_init_determine_p2p_origin_facility`;
DELIMITER $$

CREATE PROCEDURE `pkg_init_determine_p2p_origin_facility`(
    IN p_sender_customer_id BINARY(16),
    IN p_requested_origin_facility_id INT,
    OUT p_origin_facility_id INT
)
SQL SECURITY INVOKER
BEGIN
    DECLARE v_post_office_type_id INT;
    DECLARE v_customer_preferred_facility_id INT;
    DECLARE v_sender_territory_id INT;
    DECLARE v_sender_zip5 CHAR(5);
    DECLARE v_requested_facility_type_id INT;
    DECLARE v_preferred_facility_type_id INT;
    DECLARE v_source_has_geo TINYINT(1) DEFAULT 0;
    DECLARE v_source_lat DECIMAL(10,6);
    DECLARE v_source_lon DECIMAL(10,6);

    SET p_origin_facility_id = NULL;

    IF p_sender_customer_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sender customer ID is required for P2P origin resolution.';
    END IF;

    SELECT ft.`facility_type_id`
    INTO v_post_office_type_id
    FROM `facility_type` ft
    WHERE ft.`is_active` = 1
      AND (
          ft.`facility_type_code` = 'POST'
          OR ft.`facility_type_name` = 'Post Office'
      )
    ORDER BY (ft.`facility_type_code` = 'POST') DESC, ft.`facility_type_id`
    LIMIT 1;

    IF v_post_office_type_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Post Office facility type could not be resolved.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM `customer`
        WHERE `customer_id` = p_sender_customer_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sender customer does not exist.';
    END IF;

    SELECT
        c.`preferred_facility_id`,
        LEFT(TRIM(c.`zip_code`), 5)
    INTO
        v_customer_preferred_facility_id,
        v_sender_zip5
    FROM `customer` c
    WHERE c.`customer_id` = p_sender_customer_id;

    IF p_requested_origin_facility_id IS NOT NULL THEN
        SELECT f.`facility_type_id`
        INTO v_requested_facility_type_id
        FROM `facility` f
        WHERE f.`facility_id` = p_requested_origin_facility_id;

        IF v_requested_facility_type_id IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Requested P2P origin facility does not exist.';
        END IF;

        IF v_requested_facility_type_id <> v_post_office_type_id THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Requested P2P origin facility must be a Post Office.';
        END IF;

        SET p_origin_facility_id = p_requested_origin_facility_id;
    END IF;

    IF p_origin_facility_id IS NULL AND v_customer_preferred_facility_id IS NOT NULL THEN
        SELECT f.`facility_type_id`
        INTO v_preferred_facility_type_id
        FROM `facility` f
        WHERE f.`facility_id` = v_customer_preferred_facility_id;

        IF v_preferred_facility_type_id IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Sender customer preferred facility reference is invalid.';
        END IF;

        IF v_preferred_facility_type_id <> v_post_office_type_id THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Sender customer preferred facility must be a Post Office for P2P origins.';
        END IF;

        SET p_origin_facility_id = v_customer_preferred_facility_id;
    END IF;

    IF p_origin_facility_id IS NULL THEN
        CALL `pkg_init_resolve_customer_territory`(p_sender_customer_id, v_sender_territory_id);

        IF v_sender_zip5 IS NOT NULL AND CHAR_LENGTH(v_sender_zip5) = 5 AND v_sender_zip5 NOT REGEXP '[^0-9]' THEN
            SELECT 1, zg.`latitude`, zg.`longitude`
            INTO v_source_has_geo, v_source_lat, v_source_lon
            FROM `zip_geo` zg
            WHERE zg.`zip_code` = v_sender_zip5
            LIMIT 1;
        END IF;

        -- Choose the nearest valid Post Office, preferring same-territory matches first.
        SELECT f.`facility_id`
        INTO p_origin_facility_id
        FROM `facility` f
        LEFT JOIN `zip_geo` fzg
            ON fzg.`zip_code` = LEFT(TRIM(f.`zip_code`), 5)
        WHERE f.`facility_type_id` = v_post_office_type_id
        ORDER BY
            CASE
                WHEN v_sender_territory_id IS NOT NULL AND f.`territory_id` = v_sender_territory_id THEN 0
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
            SET MESSAGE_TEXT = 'Unable to determine a Post Office origin facility for the P2P package.';
    END IF;
END $$

DELIMITER ;

SELECT
    `ROUTINE_SCHEMA`,
    `ROUTINE_NAME`,
    `ROUTINE_TYPE`
FROM `information_schema`.`ROUTINES`
WHERE `ROUTINE_SCHEMA` = 'postal_bi_system'
  AND `ROUTINE_NAME` = 'pkg_init_determine_p2p_origin_facility';
