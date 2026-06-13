USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `pkg_init_CreateInitialPackageRoutePlan`;
DELIMITER $$

CREATE PROCEDURE `pkg_init_CreateInitialPackageRoutePlan`(

    IN p_package_id BINARY(16),
    IN p_origin_facility_id INT,
    IN p_destination_facility_id INT,
    IN p_service_type_id INT,
    IN p_received_date DATETIME
)
SQL SECURITY INVOKER
BEGIN
    DECLARE v_service_type_name VARCHAR(30);

    IF p_origin_facility_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Origin facility ID is required for package_route_plan creation.';
    END IF;

    IF p_destination_facility_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Destination facility ID is required for package_route_plan creation.';
    END IF;

    SELECT st.`service_type_name`
    INTO v_service_type_name
    FROM `service_type` st
    WHERE st.`service_type_id` = p_service_type_id
      AND st.`is_active` = 1
    LIMIT 1;

    IF v_service_type_name IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Route plan destination purpose could not be resolved from service type.';
    END IF;

    INSERT INTO `package_route_plan` (
        `package_id`,
        `planned_origin_facility_id`,
        `planned_destination_facility_id`,
        `destination_purpose`,
        `selection_source`,
        `selected_at`,
        `route_note`
    )
    VALUES (
        p_package_id,
        p_origin_facility_id,
        p_destination_facility_id,
        v_service_type_name,
        'Procedure',
        COALESCE(p_received_date, CURRENT_TIMESTAMP),
        'Initial route shell created during package initiation.'
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
  AND `ROUTINE_NAME` = 'pkg_init_CreateInitialPackageRoutePlan';