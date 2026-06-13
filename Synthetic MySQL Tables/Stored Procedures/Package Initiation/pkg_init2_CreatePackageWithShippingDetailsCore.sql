USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `pkg_init2_CreatePackageWithShippingDetailsCore`;
DELIMITER $$

CREATE PROCEDURE `pkg_init2_CreatePackageWithShippingDetailsCore`(

    IN p_package_flow_type_id INT,
    IN p_service_type_id INT,
    IN p_recipient_customer_id BINARY(16),
    IN p_sender_customer_id BINARY(16),
    IN p_sender_business_id BINARY(16),
    IN p_received_date DATETIME,
    IN p_expected_delivery_date DATETIME,
    IN p_contents VARCHAR(30),
    IN p_weight_oz DECIMAL(8,2),
    IN p_length_in DECIMAL(8,2),
    IN p_width_in DECIMAL(8,2),
    IN p_height_in DECIMAL(8,2),
    IN p_sender_territory_id INT,
    IN p_recipient_territory_id INT,
    IN p_origin_facility_id INT,
    IN p_destination_facility_id INT,
    IN p_origin_employee_id INT,
    OUT p_package_id BINARY(16)
)
SQL SECURITY INVOKER
BEGIN
    CALL `pkg_init_InsertPackageCore`(
        p_package_flow_type_id,
        p_service_type_id,
        p_recipient_customer_id,
        p_sender_customer_id,
        p_sender_business_id,
        p_received_date,
        p_contents,
        p_weight_oz,
        p_length_in,
        p_width_in,
        p_height_in,
        p_package_id
    );

    CALL `pkg_init_InsertShippingDetailsForPackage`(
        p_package_id,
        p_recipient_customer_id,
        p_sender_customer_id,
        p_sender_business_id,
        p_recipient_territory_id,
        p_sender_territory_id,
        p_expected_delivery_date
    );

    CALL `pkg_init_CreateInitialPackageRoutePlan`(
        p_package_id,
        p_origin_facility_id,
        p_destination_facility_id,
        p_service_type_id,
        p_received_date
    );

    CALL `pkg_init_CreateInitialShippingCost`(
        p_package_id
    );

    CALL `pkg_init_InsertInitialPackageMovement`(
        p_package_id,
        p_package_flow_type_id,
        p_origin_facility_id,
        p_origin_employee_id,
        p_received_date
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
  AND `ROUTINE_NAME` = 'pkg_init2_CreatePackageWithShippingDetailsCore';