USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `pkg_init3_CreateB2CPackage`;
DELIMITER $$

CREATE PROCEDURE `pkg_init3_CreateB2CPackage`(

    IN p_sender_business_id BINARY(16),
    IN p_recipient_customer_id BINARY(16),
    IN p_service_type_name VARCHAR(30),
    IN p_contents VARCHAR(30),
    IN p_weight_oz DECIMAL(8,2),
    IN p_length_in DECIMAL(8,2),
    IN p_width_in DECIMAL(8,2),
    IN p_height_in DECIMAL(8,2),
    IN p_received_date DATETIME,
    IN p_expected_delivery_date DATETIME,
    IN p_origin_employee_id INT,
    IN p_requested_origin_facility_id INT,
    IN p_requested_destination_facility_id INT,
    OUT p_package_id BINARY(16)
)
SQL SECURITY INVOKER
BEGIN
    DECLARE v_package_flow_type_id INT;
    DECLARE v_service_type_id INT;
    DECLARE v_sender_territory_id INT;
    DECLARE v_recipient_territory_id INT;
    DECLARE v_origin_facility_id INT;
    DECLARE v_destination_facility_id INT;
    DECLARE v_recipient_zip_code VARCHAR(10);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SET p_package_id = NULL;

    START TRANSACTION;

    SELECT pft.`package_flow_type_id`
    INTO v_package_flow_type_id
    FROM `package_flow_type` pft
    WHERE pft.`package_flow_type_name` = 'B2C'
      AND pft.`is_active` = 1
    LIMIT 1;

    IF v_package_flow_type_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Active package flow type B2C could not be resolved.';
    END IF;

    SELECT st.`service_type_id`
    INTO v_service_type_id
    FROM `service_type` st
    WHERE st.`service_type_name` = p_service_type_name
      AND st.`is_active` = 1
    LIMIT 1;

    IF v_service_type_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Service type name is invalid or inactive.';
    END IF;

    CALL `pkg_init_ValidateB2CPackageInputs`(
        p_recipient_customer_id,
        p_sender_business_id,
        v_service_type_id,
        p_weight_oz,
        p_length_in,
        p_width_in,
        p_height_in,
        p_received_date,
        p_expected_delivery_date
    );

    CALL `pkg_init_resolve_customer_territory`(
        p_recipient_customer_id,
        v_recipient_territory_id
    );

    CALL `pkg_init_resolve_business_territory`(
        p_sender_business_id,
        v_sender_territory_id
    );

    CALL `pkg_init_ResolveB2COriginFacility`(
        p_sender_business_id,
        p_requested_origin_facility_id,
        v_origin_facility_id
    );

    SELECT c.`zip_code`
    INTO v_recipient_zip_code
    FROM `customer` c
    WHERE c.`customer_id` = p_recipient_customer_id;

    CALL `pkg_init_ResolveDestinationFacilityForService`(
        v_service_type_id,
        p_recipient_customer_id,
        v_recipient_territory_id,
        v_recipient_zip_code,
        p_requested_destination_facility_id,
        v_destination_facility_id
    );

    CALL `pkg_init2_CreatePackageWithShippingDetailsCore`(
        v_package_flow_type_id,
        v_service_type_id,
        p_recipient_customer_id,
        NULL,
        p_sender_business_id,
        p_received_date,
        p_expected_delivery_date,
        p_contents,
        p_weight_oz,
        p_length_in,
        p_width_in,
        p_height_in,
        v_sender_territory_id,
        v_recipient_territory_id,
        v_origin_facility_id,
        v_destination_facility_id,
        p_origin_employee_id,
        p_package_id
    );

    COMMIT;
END $$

DELIMITER ;

SELECT
    `ROUTINE_SCHEMA`,
    `ROUTINE_NAME`,
    `ROUTINE_TYPE`
FROM `information_schema`.`ROUTINES`
WHERE `ROUTINE_SCHEMA` = 'postal_bi_system'
  AND `ROUTINE_TYPE` = 'PROCEDURE'
  AND `ROUTINE_NAME` = 'pkg_init3_CreateB2CPackage';