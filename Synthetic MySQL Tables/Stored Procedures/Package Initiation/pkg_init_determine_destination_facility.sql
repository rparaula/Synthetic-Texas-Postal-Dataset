USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `pkg_init_determine_destination_facility`;
DELIMITER $$

CREATE PROCEDURE `pkg_init_determine_destination_facility`(
    IN p_service_type_id INT,
    IN p_recipient_customer_id BINARY(16),
    IN p_recipient_territory_id INT,
    IN p_recipient_zip_code VARCHAR(10),
    IN p_requested_destination_facility_id INT,
    OUT p_destination_facility_id INT
)
SQL SECURITY INVOKER
BEGIN
    DECLARE v_service_type_name VARCHAR(30);

    SET p_destination_facility_id = NULL;

    IF p_service_type_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Service type ID is required.';
    END IF;

    SELECT st.`service_type_name`
    INTO v_service_type_name
    FROM `service_type` st
    WHERE st.`service_type_id` = p_service_type_id
      AND st.`is_active` = 1;

    IF v_service_type_name IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid or inactive service type ID.';
    END IF;

    IF v_service_type_name IN ('Delivery', 'Pickup') THEN
        CALL `pkg_init_determine_post_office_destination_facility`(
            p_recipient_customer_id,
            p_recipient_territory_id,
            p_recipient_zip_code,
            p_requested_destination_facility_id,
            p_destination_facility_id
        );
    ELSEIF v_service_type_name = 'SmartLocker' THEN
        CALL `pkg_init_determine_smartlocker_destination_facility`(
            p_recipient_customer_id,
            p_recipient_territory_id,
            p_recipient_zip_code,
            p_requested_destination_facility_id,
            p_destination_facility_id
        );
    ELSE
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Unsupported service type for destination facility resolution.';
    END IF;
END $$

DELIMITER ;

SELECT
    `ROUTINE_SCHEMA`,
    `ROUTINE_NAME`,
    `ROUTINE_TYPE`
FROM `information_schema`.`ROUTINES`
WHERE `ROUTINE_SCHEMA` = 'postal_bi_system'
  AND `ROUTINE_NAME` = 'pkg_init_determine_destination_facility';
