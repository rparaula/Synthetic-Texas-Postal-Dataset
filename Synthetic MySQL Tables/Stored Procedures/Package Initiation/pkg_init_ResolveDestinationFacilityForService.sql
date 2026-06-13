USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `pkg_init_ResolveDestinationFacilityForService`;
DELIMITER $$

CREATE PROCEDURE `pkg_init_ResolveDestinationFacilityForService`(

    IN p_service_type_id INT,
    IN p_recipient_customer_id BINARY(16),
    IN p_recipient_territory_id INT,
    IN p_recipient_zip_code VARCHAR(10),
    IN p_requested_destination_facility_id INT,
    OUT p_destination_facility_id INT
)
SQL SECURITY INVOKER
BEGIN
    CALL `pkg_init_determine_destination_facility`(
        p_service_type_id,
        p_recipient_customer_id,
        p_recipient_territory_id,
        p_recipient_zip_code,
        p_requested_destination_facility_id,
        p_destination_facility_id
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
  AND `ROUTINE_NAME` = 'pkg_init_ResolveDestinationFacilityForService';