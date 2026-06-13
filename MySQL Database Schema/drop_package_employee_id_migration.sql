USE `postal_bi_system`;

/*
Migration: drop package.employee_id and remove dependent reporting columns/views.

This migration assumes:
  - package_movement.processed_by_employee_id remains the operational employee
    attribution field for package handling.
  - Reporting views should no longer expose package.employee_id-derived columns.
  - pkg_init_InsertPackageCore must be recreated without inserting employee_id.
*/

DROP VIEW IF EXISTS `vw_package_overview`;
DROP VIEW IF EXISTS `fact_delivery`;
DROP VIEW IF EXISTS `fact_shipping_revenue`;
DROP VIEW IF EXISTS `fact_package`;

ALTER TABLE `package`
    DROP FOREIGN KEY `fk_package_employee`,
    DROP INDEX `EmployeeID`,
    DROP COLUMN `employee_id`;

CREATE OR REPLACE VIEW `vw_package_overview` AS
SELECT
    p.`package_id` AS `package_id`,
    p.`recipient_customer_id` AS `recipient_customer_id`,
    TRIM(CONCAT(c.`first_name`, ' ', c.`last_name`)) AS `recipient_customer_name`,
    c.`email` AS `recipient_customer_email`,
    pft.`package_flow_type_name` AS `package_flow_type_name`,
    p.`sender_customer_id` AS `sender_customer_id`,
    TRIM(CONCAT(sc.`first_name`, ' ', sc.`last_name`)) AS `sender_customer_name`,
    p.`sender_business_id` AS `sender_business_id`,
    b.`business_name` AS `sender_business_name`,
    ps.`status_name` AS `package_status`,
    st.`service_type_name` AS `service_type_name`,
    p.`received_date` AS `received_date`,
    p.`contents` AS `contents`,
    p.`weight_oz` AS `weight_oz`,
    p.`length_in` AS `length_in`,
    p.`width_in` AS `width_in`,
    p.`height_in` AS `height_in`,
    p.`created_at` AS `created_at`,
    p.`updated_at` AS `updated_at`
FROM `package` p
JOIN `customer` c
    ON c.`customer_id` = p.`recipient_customer_id`
JOIN `package_flow_type` pft
    ON pft.`package_flow_type_id` = p.`package_flow_type_id`
JOIN `package_status` ps
    ON ps.`package_status_id` = p.`package_status_id`
LEFT JOIN `service_type` st
    ON st.`service_type_id` = p.`service_type_id`
LEFT JOIN `customer` sc
    ON sc.`customer_id` = p.`sender_customer_id`
LEFT JOIN `business` b
    ON b.`business_id` = p.`sender_business_id`;

CREATE OR REPLACE VIEW `fact_delivery` AS
SELECT
    sd.`package_id` AS `delivery_fact_key`,
    sd.`package_id` AS `package_id`,
    p.`recipient_customer_id` AS `package_customer_id`,
    p.`recipient_customer_id` AS `recipient_customer_id`,
    p.`package_flow_type_id` AS `package_flow_type_id`,
    pft.`package_flow_type_name` AS `package_flow_type_name`,
    p.`sender_customer_id` AS `sender_customer_id`,
    p.`sender_business_id` AS `sender_business_id`,
    p.`service_type_id` AS `service_type_id`,
    p.`package_status_id` AS `package_status_id`,
    p.`received_date` AS `package_received_datetime`,
    sd.`created_at` AS `shippingdetails_created_datetime`,
    sd.`expected_delivery_date` AS `expected_delivery_date`,
    sd.`delivered_date` AS `delivered_date`,
    sd.`updated_at` AS `shippingdetails_updated_datetime`,
    sd.`recipient_first_name` AS `recipient_first_name`,
    sd.`recipient_middle_initial` AS `recipient_middle_initial`,
    sd.`recipient_last_name` AS `recipient_last_name`,
    sd.`recipient_address` AS `recipient_address`,
    sd.`sender_address` AS `sender_address`,
    sd.`estimated_delivery_distance` AS `distance_traveled`,
    1 AS `delivery_count`
FROM `shippingdetails` sd
JOIN `package` p
    ON p.`package_id` = sd.`package_id`
JOIN `package_flow_type` pft
    ON pft.`package_flow_type_id` = p.`package_flow_type_id`;

CREATE OR REPLACE VIEW `fact_shipping_revenue` AS
SELECT
    sc.`package_id` AS `package_id`,
    p.`recipient_customer_id` AS `customer_id`,
    p.`recipient_customer_id` AS `recipient_customer_id`,
    p.`package_flow_type_id` AS `package_flow_type_id`,
    pft.`package_flow_type_name` AS `package_flow_type_name`,
    p.`sender_customer_id` AS `sender_customer_id`,
    p.`sender_business_id` AS `sender_business_id`,
    c.`territory_id` AS `customer_territory_id`,
    p.`service_type_id` AS `service_type_id`,
    p.`package_status_id` AS `package_status_id`,
    p.`received_date` AS `revenue_datetime`,
    sc.`actual_shipping_charge` AS `gross_shipping_revenue`,
    sc.`material_cost` AS `material_cost`,
    sc.`transportation_cost` AS `transportation_cost`,
    ROUND((COALESCE(sc.`material_cost`, 0) + COALESCE(sc.`transportation_cost`, 0)), 2) AS `total_internal_shipping_cost`,
    ROUND(((sc.`actual_shipping_charge` - COALESCE(sc.`material_cost`, 0)) - COALESCE(sc.`transportation_cost`, 0)), 2) AS `estimated_shipping_margin`,
    sc.`charge_source` AS `charge_source`,
    sc.`charge_recorded_at` AS `charge_recorded_at`,
    1 AS `shipping_charge_count`
FROM `shipping_cost` sc
JOIN `package` p
    ON p.`package_id` = sc.`package_id`
JOIN `package_flow_type` pft
    ON pft.`package_flow_type_id` = p.`package_flow_type_id`
LEFT JOIN `customer` c
    ON c.`customer_id` = p.`recipient_customer_id`;

CREATE OR REPLACE VIEW `fact_package` AS
SELECT
    p.`package_id` AS `package_id`,
    p.`recipient_customer_id` AS `customer_id`,
    p.`recipient_customer_id` AS `recipient_customer_id`,
    p.`package_flow_type_id` AS `package_flow_type_id`,
    pft.`package_flow_type_name` AS `package_flow_type_name`,
    p.`sender_customer_id` AS `sender_customer_id`,
    p.`sender_business_id` AS `sender_business_id`,
    p.`service_type_id` AS `service_type_id`,
    p.`package_status_id` AS `package_status_id`,
    p.`received_date` AS `received_datetime`,
    p.`weight_oz` AS `weight_oz`,
    p.`length_in` AS `length_in`,
    p.`width_in` AS `width_in`,
    p.`height_in` AS `height_in`,
    CASE
        WHEN p.`length_in` IS NOT NULL
         AND p.`width_in` IS NOT NULL
         AND p.`height_in` IS NOT NULL
            THEN p.`length_in` * p.`width_in` * p.`height_in`
        ELSE NULL
    END AS `package_volume_cubic_in`,
    1 AS `package_count`
FROM `package` p
JOIN `package_flow_type` pft
    ON pft.`package_flow_type_id` = p.`package_flow_type_id`;

DELIMITER $$

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

DELIMITER ;

SELECT
    c.`table_schema`,
    c.`table_name`,
    c.`column_name`
FROM `information_schema`.`columns` c
WHERE c.`table_schema` = DATABASE()
  AND c.`table_name` = 'package'
  AND c.`column_name` = 'employee_id';

SELECT
    kcu.`constraint_name`,
    kcu.`table_name`,
    kcu.`column_name`,
    kcu.`referenced_table_name`,
    kcu.`referenced_column_name`
FROM `information_schema`.`key_column_usage` kcu
WHERE kcu.`table_schema` = DATABASE()
  AND kcu.`table_name` = 'package'
  AND kcu.`constraint_name` = 'fk_package_employee';

SELECT * FROM `vw_package_overview` LIMIT 1;
SELECT * FROM `fact_delivery` LIMIT 1;
SELECT * FROM `fact_shipping_revenue` LIMIT 1;
SELECT * FROM `fact_package` LIMIT 1;
