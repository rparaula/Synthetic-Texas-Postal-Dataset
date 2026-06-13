USE `postal_bi_system`;

/*
Package initiation procedure layer for clean B2C and P2P package creation.

This script intentionally recreates only the new package-initiation helpers and
wrappers listed below. It reuses the existing resolver/determine procedures and
does not overwrite them.

Existing procedures intentionally reused:
  - CalculateDistEstimate (not called here because it still expects INT package_id)
  - pkg_init_resolve_sender_territory
  - pkg_init_resolve_recipient_territory
  - pkg_init_resolve_customer_territory
  - pkg_init_resolve_business_territory
  - pkg_init_determine_smartlocker_destination_facility
  - pkg_init_determine_post_office_destination_facility
  - pkg_init_determine_p2p_origin_facility
  - pkg_init_determine_origin_facility
  - pkg_init_determine_destination_facility
  - pkg_init_determine_b2c_origin_facility

Notes:
  - package rows are created without a direct employee_id column.
  - The initial movement inserted is only "Received At Facility".
  - Estimated distance is derived directly from territory/zip_geo coordinates when
    available; otherwise it is left NULL.
*/

DELIMITER $$

DROP PROCEDURE IF EXISTS `pkg_init_ValidateB2CPackageInputs` $$
CREATE PROCEDURE `pkg_init_ValidateB2CPackageInputs`(
    IN p_recipient_customer_id BINARY(16),
    IN p_sender_business_id BINARY(16),
    IN p_service_type_id INT,
    IN p_weight_oz DECIMAL(8,2),
    IN p_length_in DECIMAL(8,2),
    IN p_width_in DECIMAL(8,2),
    IN p_height_in DECIMAL(8,2),
    IN p_received_date DATETIME,
    IN p_expected_delivery_date DATETIME
)
SQL SECURITY INVOKER
BEGIN
    IF p_recipient_customer_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Recipient customer ID is required for B2C package creation.';
    END IF;

    IF p_sender_business_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sender business ID is required for B2C package creation.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM `customer` c
        WHERE c.`customer_id` = p_recipient_customer_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Recipient customer does not exist.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM `business` b
        WHERE b.`business_id` = p_sender_business_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sender business does not exist.';
    END IF;

    IF p_service_type_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Service type ID is required.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM `service_type` st
        WHERE st.`service_type_id` = p_service_type_id
          AND st.`is_active` = 1
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Service type is invalid or inactive.';
    END IF;

    IF p_weight_oz IS NULL OR p_weight_oz <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Package weight_oz must be greater than 0.';
    END IF;

    IF p_length_in IS NULL OR p_length_in <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Package length_in must be greater than 0.';
    END IF;

    IF p_width_in IS NULL OR p_width_in <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Package width_in must be greater than 0.';
    END IF;

    IF p_height_in IS NULL OR p_height_in <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Package height_in must be greater than 0.';
    END IF;

    IF p_received_date IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Received timestamp is required.';
    END IF;

    IF p_expected_delivery_date IS NOT NULL
       AND p_expected_delivery_date < p_received_date THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Expected delivery timestamp must be greater than or equal to received timestamp.';
    END IF;
END $$

DROP PROCEDURE IF EXISTS `pkg_init_ValidateP2PPackageInputs` $$
CREATE PROCEDURE `pkg_init_ValidateP2PPackageInputs`(
    IN p_sender_customer_id BINARY(16),
    IN p_recipient_customer_id BINARY(16),
    IN p_service_type_id INT,
    IN p_weight_oz DECIMAL(8,2),
    IN p_length_in DECIMAL(8,2),
    IN p_width_in DECIMAL(8,2),
    IN p_height_in DECIMAL(8,2),
    IN p_received_date DATETIME,
    IN p_expected_delivery_date DATETIME
)
SQL SECURITY INVOKER
BEGIN
    IF p_sender_customer_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sender customer ID is required for P2P package creation.';
    END IF;

    IF p_recipient_customer_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Recipient customer ID is required for P2P package creation.';
    END IF;

    IF p_sender_customer_id = p_recipient_customer_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sender customer and recipient customer cannot be the same for a P2P package.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM `customer` c
        WHERE c.`customer_id` = p_sender_customer_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sender customer does not exist.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM `customer` c
        WHERE c.`customer_id` = p_recipient_customer_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Recipient customer does not exist.';
    END IF;

    IF p_service_type_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Service type ID is required.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM `service_type` st
        WHERE st.`service_type_id` = p_service_type_id
          AND st.`is_active` = 1
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Service type is invalid or inactive.';
    END IF;

    IF p_weight_oz IS NULL OR p_weight_oz <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Package weight_oz must be greater than 0.';
    END IF;

    IF p_length_in IS NULL OR p_length_in <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Package length_in must be greater than 0.';
    END IF;

    IF p_width_in IS NULL OR p_width_in <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Package width_in must be greater than 0.';
    END IF;

    IF p_height_in IS NULL OR p_height_in <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Package height_in must be greater than 0.';
    END IF;

    IF p_received_date IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Received timestamp is required.';
    END IF;

    IF p_expected_delivery_date IS NOT NULL
       AND p_expected_delivery_date < p_received_date THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Expected delivery timestamp must be greater than or equal to received timestamp.';
    END IF;

    /*
    Optional P2P minimum-distance rule intentionally not enforced here.
    The current package-initiation layer uses existing schema geography only for
    safe distance estimation in shippingdetails. If a stricter P2P separation
    rule is desired later, it can be added after business approval.
    */
END $$

DROP PROCEDURE IF EXISTS `pkg_init_ResolveB2COriginFacility` $$
CREATE PROCEDURE `pkg_init_ResolveB2COriginFacility`(
    IN p_business_id BINARY(16),
    IN p_requested_origin_facility_id INT,
    OUT p_origin_facility_id INT
)
SQL SECURITY INVOKER
BEGIN
    CALL `pkg_init_determine_b2c_origin_facility`(
        p_business_id,
        p_requested_origin_facility_id,
        p_origin_facility_id
    );
END $$

DROP PROCEDURE IF EXISTS `pkg_init_ResolveP2POriginFacility` $$
CREATE PROCEDURE `pkg_init_ResolveP2POriginFacility`(
    IN p_sender_customer_id BINARY(16),
    IN p_requested_origin_facility_id INT,
    OUT p_origin_facility_id INT
)
SQL SECURITY INVOKER
BEGIN
    CALL `pkg_init_determine_p2p_origin_facility`(
        p_sender_customer_id,
        p_requested_origin_facility_id,
        p_origin_facility_id
    );
END $$

DROP PROCEDURE IF EXISTS `pkg_init_ResolveDestinationFacilityForService` $$
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

DROP PROCEDURE IF EXISTS `pkg_init_InsertPackageCore` $$
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

DROP PROCEDURE IF EXISTS `pkg_init_InsertShippingDetailsForPackage` $$
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

DROP PROCEDURE IF EXISTS `pkg_init_CreateInitialPackageRoutePlan` $$
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

DROP PROCEDURE IF EXISTS `pkg_init_CreateInitialShippingCost` $$
CREATE PROCEDURE `pkg_init_CreateInitialShippingCost`(
    IN p_package_id BINARY(16)
)
SQL SECURITY INVOKER
BEGIN
    DECLARE v_weight_oz DECIMAL(8,2);
    DECLARE v_service_type_name VARCHAR(30);
    DECLARE v_estimated_distance DECIMAL(10,2);
    DECLARE v_weight_lbs DECIMAL(10,4);
    DECLARE v_actual_shipping_charge DECIMAL(8,2);

    SELECT
        p.`weight_oz`,
        st.`service_type_name`,
        sd.`estimated_delivery_distance`
    INTO
        v_weight_oz,
        v_service_type_name,
        v_estimated_distance
    FROM `package` p
    LEFT JOIN `service_type` st
        ON st.`service_type_id` = p.`service_type_id`
    LEFT JOIN `shippingdetails` sd
        ON sd.`package_id` = p.`package_id`
    WHERE p.`package_id` = p_package_id;

    IF v_weight_oz IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Shipping cost creation requires an existing package with weight_oz.';
    END IF;

    SET v_weight_lbs = v_weight_oz / 16.0;

    /*
    Safe initial charge formula based only on current schema fields.
    The shipping_cost triggers recompute material_cost and transportation_cost.
    */
    SET v_actual_shipping_charge = ROUND(
        4.00
        + (v_weight_lbs * 1.10)
        + (COALESCE(v_estimated_distance, 0.00) * 0.015)
        + CASE
            WHEN v_service_type_name = 'SmartLocker' THEN 1.25
            WHEN v_service_type_name = 'Pickup' THEN 0.75
            ELSE 0.00
          END,
        2
    );

    INSERT INTO `shipping_cost` (
        `package_id`,
        `actual_shipping_charge`,
        `material_cost`,
        `transportation_cost`,
        `charge_source`,
        `charge_recorded_at`
    )
    VALUES (
        p_package_id,
        GREATEST(v_actual_shipping_charge, 0.00),
        0.00,
        0.00,
        'pkg_init_CreateInitialShippingCost',
        CURRENT_TIMESTAMP
    );
END $$

DROP PROCEDURE IF EXISTS `pkg_init_InsertInitialPackageMovement` $$
CREATE PROCEDURE `pkg_init_InsertInitialPackageMovement`(
    IN p_package_id BINARY(16),
    IN p_package_flow_type_id INT,
    IN p_origin_facility_id INT,
    IN p_origin_employee_id INT,
    IN p_received_date DATETIME
)
SQL SECURITY INVOKER
BEGIN
    DECLARE v_event_type_id INT;
    DECLARE v_status_name VARCHAR(30);
    DECLARE v_status_id INT;
    DECLARE v_facility_type_id INT;
    DECLARE v_employee_department_id INT;
    DECLARE v_employee_facility_id INT;
    DECLARE v_employee_department_type_id INT;
    DECLARE v_required_department_type_id INT;
    DECLARE v_requires_employee TINYINT(1);

    IF p_origin_facility_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Origin facility ID is required for the initial package movement.';
    END IF;

    IF p_origin_employee_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'origin_employee_id is required for the initial package movement.';
    END IF;

    IF p_received_date IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Received timestamp is required for the initial package movement.';
    END IF;

    SELECT pmet.`package_movement_event_type_id`,
           pmet.`default_package_status_name`
    INTO v_event_type_id,
         v_status_name
    FROM `package_movement_event_type` pmet
    WHERE pmet.`event_type_name` = 'Received At Facility'
      AND pmet.`is_active` = 1
    LIMIT 1;

    IF v_event_type_id IS NULL OR v_status_name IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Initial movement event type for Received At Facility could not be resolved.';
    END IF;

    SELECT ps.`package_status_id`
    INTO v_status_id
    FROM `package_status` ps
    WHERE ps.`status_name` = v_status_name
      AND ps.`is_active` = 1
    LIMIT 1;

    IF v_status_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Initial movement status could not be resolved.';
    END IF;

    SELECT f.`facility_type_id`
    INTO v_facility_type_id
    FROM `facility` f
    WHERE f.`facility_id` = p_origin_facility_id;

    IF v_facility_type_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Origin facility does not exist.';
    END IF;

    SELECT
        e.`department_id`,
        d.`facility_id`,
        d.`department_type_id`
    INTO
        v_employee_department_id,
        v_employee_facility_id,
        v_employee_department_type_id
    FROM `employee` e
    JOIN `departments` d
        ON d.`department_id` = e.`department_id`
    WHERE e.`employee_id` = p_origin_employee_id;

    IF v_employee_department_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'origin_employee_id does not reference a staffed employee/department.';
    END IF;

    IF v_employee_facility_id <> p_origin_facility_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'origin_employee_id must belong to the resolved origin facility.';
    END IF;

    SELECT
        pmsr.`required_department_type_id`,
        pmsr.`requires_employee`
    INTO
        v_required_department_type_id,
        v_requires_employee
    FROM `package_movement_staffing_rule` pmsr
    WHERE pmsr.`package_flow_type_id` = p_package_flow_type_id
      AND pmsr.`package_movement_event_type_id` = v_event_type_id
      AND pmsr.`facility_type_id` = v_facility_type_id
    LIMIT 1;

    IF v_requires_employee IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No staffing rule exists for the initial movement at the origin facility type.';
    END IF;

    IF v_requires_employee = 1
       AND v_required_department_type_id IS NOT NULL
       AND v_employee_department_type_id <> v_required_department_type_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'origin_employee_id does not belong to the required department for the initial movement.';
    END IF;

    INSERT INTO `package_movement` (
        `package_id`,
        `package_movement_event_type_id`,
        `package_status_id`,
        `facility_id`,
        `from_facility_id`,
        `to_facility_id`,
        `processed_by_employee_id`,
        `event_timestamp`,
        `movement_note`
    )
    VALUES (
        p_package_id,
        v_event_type_id,
        v_status_id,
        p_origin_facility_id,
        NULL,
        NULL,
        p_origin_employee_id,
        p_received_date,
        'Initial package initiation movement: Received At Facility'
    );
END $$

DROP PROCEDURE IF EXISTS `pkg_init2_CreatePackageWithShippingDetailsCore` $$
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

DROP PROCEDURE IF EXISTS `pkg_init3_CreateB2CPackage` $$
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

DROP PROCEDURE IF EXISTS `pkg_init3_CreateP2PPackage` $$
CREATE PROCEDURE `pkg_init3_CreateP2PPackage`(
    IN p_sender_customer_id BINARY(16),
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
    WHERE pft.`package_flow_type_name` = 'P2P'
      AND pft.`is_active` = 1
    LIMIT 1;

    IF v_package_flow_type_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Active package flow type P2P could not be resolved.';
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

    CALL `pkg_init_ValidateP2PPackageInputs`(
        p_sender_customer_id,
        p_recipient_customer_id,
        v_service_type_id,
        p_weight_oz,
        p_length_in,
        p_width_in,
        p_height_in,
        p_received_date,
        p_expected_delivery_date
    );

    CALL `pkg_init_resolve_customer_territory`(
        p_sender_customer_id,
        v_sender_territory_id
    );

    CALL `pkg_init_resolve_customer_territory`(
        p_recipient_customer_id,
        v_recipient_territory_id
    );

    CALL `pkg_init_ResolveP2POriginFacility`(
        p_sender_customer_id,
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
        p_sender_customer_id,
        NULL,
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
    `ROUTINE_NAME`
FROM `information_schema`.`ROUTINES`
WHERE `ROUTINE_SCHEMA` = 'postal_bi_system'
  AND `ROUTINE_TYPE` = 'PROCEDURE'
  AND `ROUTINE_NAME` IN (
      'pkg_init_ValidateB2CPackageInputs',
      'pkg_init_ValidateP2PPackageInputs',
      'pkg_init_ResolveB2COriginFacility',
      'pkg_init_ResolveP2POriginFacility',
      'pkg_init_ResolveDestinationFacilityForService',
      'pkg_init_InsertPackageCore',
      'pkg_init_InsertShippingDetailsForPackage',
      'pkg_init_CreateInitialPackageRoutePlan',
      'pkg_init_CreateInitialShippingCost',
      'pkg_init_InsertInitialPackageMovement',
      'pkg_init2_CreatePackageWithShippingDetailsCore',
      'pkg_init3_CreateB2CPackage',
      'pkg_init3_CreateP2PPackage'
  )
ORDER BY `ROUTINE_NAME`;
