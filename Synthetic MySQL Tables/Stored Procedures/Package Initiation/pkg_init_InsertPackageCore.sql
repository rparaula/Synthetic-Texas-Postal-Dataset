USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `pkg_init_InsertPackageCore`;
DELIMITER $$

CREATE PROCEDURE `pkg_init_InsertPackageCore`(

    IN p_package_flow_type_id INT,
    IN p_service_type_id INT,
    IN p_recipient_customer_id BINARY(16),
    IN p_sender_customer_id BINARY(16),
    IN p_sender_business_id BINARY(16),
    IN p_received_date DATETIME,
    IN p_contents VARCHAR(30),
    IN p_weight_oz DECIMAL(8,2),
    IN p_length_in DECIMAL(8,2),
    IN p_width_in DECIMAL(8,2),
    IN p_height_in DECIMAL(8,2),
    OUT p_package_id BINARY(16)
)
SQL SECURITY INVOKER
BEGIN
    DECLARE v_initial_event_type_id INT;
    DECLARE v_initial_status_name VARCHAR(30);
    DECLARE v_initial_status_id INT;
    DECLARE v_contents VARCHAR(30);

    SET p_package_id = UUID_TO_BIN(UUID());
    SET v_contents = NULLIF(TRIM(COALESCE(p_contents, '')), '');

    SELECT pmet.`package_movement_event_type_id`,
           pmet.`default_package_status_name`
    INTO v_initial_event_type_id,
         v_initial_status_name
    FROM `package_movement_event_type` pmet
    WHERE pmet.`event_type_name` = 'Received At Facility'
      AND pmet.`is_active` = 1
    LIMIT 1;

    IF v_initial_event_type_id IS NULL OR v_initial_status_name IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Initial movement event configuration for Received At Facility is missing.';
    END IF;

    SELECT ps.`package_status_id`
    INTO v_initial_status_id
    FROM `package_status` ps
    WHERE ps.`status_name` = v_initial_status_name
      AND ps.`is_active` = 1
      AND (ps.`allowed_service_type_id` IS NULL OR ps.`allowed_service_type_id` = p_service_type_id)
    LIMIT 1;

    IF v_initial_status_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Initial package status for Received At Facility could not be resolved.';
    END IF;

    INSERT INTO `package` (
        `package_id`,
        `package_status_id`,
        `service_type_id`,
        `received_date`,
        `contents`,
        `weight_oz`,
        `length_in`,
        `width_in`,
        `height_in`,
        `recipient_customer_id`,
        `package_flow_type_id`,
        `sender_customer_id`,
        `sender_business_id`
    )
    VALUES (
        p_package_id,
        v_initial_status_id,
        p_service_type_id,
        p_received_date,
        COALESCE(v_contents, 'Unknown'),
        p_weight_oz,
        p_length_in,
        p_width_in,
        p_height_in,
        p_recipient_customer_id,
        p_package_flow_type_id,
        p_sender_customer_id,
        p_sender_business_id
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
  AND `ROUTINE_NAME` = 'pkg_init_InsertPackageCore';