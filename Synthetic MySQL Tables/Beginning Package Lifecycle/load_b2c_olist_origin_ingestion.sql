USE `postal_bi_system`;

DROP VIEW IF EXISTS `vw_b2c_packages_ready_for_middle_mile`;

DROP TABLE IF EXISTS `staging_b2c_origin_movement`;
DROP TABLE IF EXISTS `staging_b2c_shippingdetails`;
DROP TABLE IF EXISTS `staging_b2c_package`;

CREATE TABLE `staging_b2c_package` (
    `package_id_hex` CHAR(32) NOT NULL,
    `order_id` CHAR(32) NOT NULL,
    `seller_id` CHAR(32) NOT NULL,
    `olist_customer_id` CHAR(32) NOT NULL,
    `recipient_customer_id_hex` CHAR(32) NOT NULL,
    `sender_business_id_hex` CHAR(32) NOT NULL,
    `package_flow_type_id` INT NOT NULL,
    `package_flow_type_name` VARCHAR(30) NOT NULL,
    `service_type_id` INT NOT NULL,
    `service_type_name` VARCHAR(30) NOT NULL,
    `initial_package_status_id` INT NOT NULL,
    `initial_status_name` VARCHAR(30) NOT NULL,
    `received_date` DATETIME NOT NULL,
    `contents` VARCHAR(255) NULL,
    `weight_oz` DECIMAL(10,4) NOT NULL,
    `length_in` DECIMAL(10,4) NOT NULL,
    `width_in` DECIMAL(10,4) NOT NULL,
    `height_in` DECIMAL(10,4) NOT NULL,
    `origin_facility_id` INT NOT NULL,
    `origin_received_timestamp` DATETIME NOT NULL,
    `origin_sorted_timestamp` DATETIME NOT NULL,
    `origin_departed_timestamp` DATETIME NOT NULL,
    PRIMARY KEY (`package_id_hex`),
    KEY `idx_staging_b2c_package_order_seller` (`order_id`, `seller_id`)
);

LOAD DATA LOCAL INFILE 'Z:/Computer Science/GitHub Repositories/Personal Projects/Synthetic-Texas-Postal-Dataset/Synthetic MySQL Tables/Beginning Package Lifecycle/stg_b2c_package.csv'
INTO TABLE `staging_b2c_package`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    `package_id_hex`,
    `order_id`,
    `seller_id`,
    `olist_customer_id`,
    `recipient_customer_id_hex`,
    `sender_business_id_hex`,
    `package_flow_type_id`,
    `package_flow_type_name`,
    `service_type_id`,
    `service_type_name`,
    `initial_package_status_id`,
    `initial_status_name`,
    `received_date`,
    `contents`,
    `weight_oz`,
    `length_in`,
    `width_in`,
    `height_in`,
    `origin_facility_id`,
    `origin_received_timestamp`,
    `origin_sorted_timestamp`,
    `origin_departed_timestamp`
);

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
    `employee_id`,
    `recipient_customer_id`,
    `package_flow_type_id`,
    `sender_customer_id`,
    `sender_business_id`
)
SELECT
    UNHEX(`package_id_hex`),
    `initial_package_status_id`,
    `service_type_id`,
    `origin_received_timestamp`,
    LEFT(COALESCE(NULLIF(`contents`, ''), 'Unknown'), 30),
    ROUND(`weight_oz`, 2),
    ROUND(`length_in`, 2),
    ROUND(`width_in`, 2),
    ROUND(`height_in`, 2),
    NULL,
    UNHEX(`recipient_customer_id_hex`),
    `package_flow_type_id`,
    NULL,
    UNHEX(`sender_business_id_hex`)
FROM `staging_b2c_package`
ORDER BY `order_id`, `seller_id`;

CREATE TABLE `staging_b2c_shippingdetails` (
    `package_id_hex` CHAR(32) NOT NULL,
    `recipient_address` VARCHAR(150) NOT NULL,
    `recipient_territory_id` INT NOT NULL,
    `sender_address` VARCHAR(150) NOT NULL,
    `sender_territory_id` INT NOT NULL,
    `estimated_delivery_distance` VARCHAR(30) NULL,
    `recipient_first_name` VARCHAR(50) NULL,
    `recipient_middle_initial` CHAR(1) NULL,
    `recipient_last_name` VARCHAR(50) NULL,
    `expected_delivery_date` VARCHAR(30) NULL,
    `delivered_date` VARCHAR(30) NULL,
    PRIMARY KEY (`package_id_hex`)
);

LOAD DATA LOCAL INFILE 'Z:/Computer Science/GitHub Repositories/Personal Projects/Synthetic-Texas-Postal-Dataset/Synthetic MySQL Tables/Beginning Package Lifecycle/stg_b2c_shippingdetails.csv'
INTO TABLE `staging_b2c_shippingdetails`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    `package_id_hex`,
    `recipient_address`,
    `recipient_territory_id`,
    `sender_address`,
    `sender_territory_id`,
    @estimated_delivery_distance,
    `recipient_first_name`,
    `recipient_middle_initial`,
    `recipient_last_name`,
    @expected_delivery_date,
    @delivered_date
)
SET
    `estimated_delivery_distance` = NULLIF(@estimated_delivery_distance, ''),
    `expected_delivery_date` = NULLIF(@expected_delivery_date, ''),
    `delivered_date` = NULLIF(@delivered_date, '');

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
    `expected_delivery_date`,
    `delivered_date`
)
SELECT
    UNHEX(`package_id_hex`),
    `recipient_address`,
    `recipient_territory_id`,
    `sender_address`,
    `sender_territory_id`,
    `estimated_delivery_distance`,
    `recipient_first_name`,
    NULLIF(`recipient_middle_initial`, ''),
    `recipient_last_name`,
    `expected_delivery_date`,
    `delivered_date`
FROM `staging_b2c_shippingdetails`
ORDER BY `package_id_hex`;

CREATE TABLE `staging_b2c_origin_movement` (
    `package_id_hex` CHAR(32) NOT NULL,
    `event_type_name` VARCHAR(80) NOT NULL,
    `package_movement_event_type_id` INT NOT NULL,
    `package_status_name` VARCHAR(30) NOT NULL,
    `package_status_id` INT NOT NULL,
    `facility_id` INT NOT NULL,
    `from_facility_id` INT NULL,
    `to_facility_id` INT NULL,
    `processed_by_employee_id` INT NULL,
    `event_timestamp` DATETIME NOT NULL,
    `expected_event_at` DATETIME NULL,
    `delay_minutes` INT NOT NULL,
    `delay_reason` VARCHAR(255) NULL,
    `movement_note` VARCHAR(500) NULL,
    KEY `idx_staging_b2c_origin_movement_ordering` (`package_id_hex`, `event_timestamp`)
);

LOAD DATA LOCAL INFILE 'Z:/Computer Science/GitHub Repositories/Personal Projects/Synthetic-Texas-Postal-Dataset/Synthetic MySQL Tables/Beginning Package Lifecycle/stg_b2c_origin_movement.csv'
INTO TABLE `staging_b2c_origin_movement`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    `package_id_hex`,
    `event_type_name`,
    `package_movement_event_type_id`,
    `package_status_name`,
    `package_status_id`,
    `facility_id`,
    @from_facility_id,
    @to_facility_id,
    @processed_by_employee_id,
    `event_timestamp`,
    @expected_event_at,
    `delay_minutes`,
    @delay_reason,
    @movement_note
)
SET
    `from_facility_id` = NULLIF(@from_facility_id, ''),
    `to_facility_id` = NULLIF(@to_facility_id, ''),
    `processed_by_employee_id` = NULLIF(@processed_by_employee_id, ''),
    `expected_event_at` = NULLIF(@expected_event_at, ''),
    `delay_reason` = NULLIF(@delay_reason, ''),
    `movement_note` = NULLIF(@movement_note, '');

INSERT INTO `package_movement` (
    `package_id`,
    `package_movement_event_type_id`,
    `package_status_id`,
    `facility_id`,
    `from_facility_id`,
    `to_facility_id`,
    `processed_by_employee_id`,
    `event_timestamp`,
    `expected_event_at`,
    `delay_minutes`,
    `delay_reason`,
    `movement_note`
)
SELECT
    UNHEX(`package_id_hex`),
    `package_movement_event_type_id`,
    `package_status_id`,
    `facility_id`,
    `from_facility_id`,
    `to_facility_id`,
    `processed_by_employee_id`,
    `event_timestamp`,
    `expected_event_at`,
    `delay_minutes`,
    `delay_reason`,
    `movement_note`
FROM `staging_b2c_origin_movement`
ORDER BY `package_id_hex`, `event_timestamp`, `package_movement_event_type_id`;

CREATE VIEW `vw_b2c_packages_ready_for_middle_mile` AS
WITH latest_movement AS (
    SELECT
        pm.`package_id`,
        pm.`facility_id`,
        pm.`event_timestamp`,
        pm.`package_status_id`,
        met.`event_type_name`,
        ROW_NUMBER() OVER (
            PARTITION BY pm.`package_id`
            ORDER BY pm.`event_timestamp` DESC, pm.`package_movement_id` DESC
        ) AS `rn`
    FROM `package_movement` pm
    JOIN `package_movement_event_type` met
      ON met.`package_movement_event_type_id` = pm.`package_movement_event_type_id`
)
SELECT
    p.`package_id`,
    st.`service_type_name` AS `service_type`,
    p.`sender_business_id`,
    p.`recipient_customer_id`,
    sd.`sender_territory_id`,
    sd.`recipient_territory_id`,
    COALESCE(lm.`facility_id`, b.`preferred_facility_id`) AS `current_or_origin_facility_id`,
    lm.`event_timestamp` AS `latest_movement_timestamp`,
    p.`weight_oz`,
    p.`length_in`,
    p.`width_in`,
    p.`height_in`
FROM `package` p
JOIN `package_flow_type` pft
  ON pft.`package_flow_type_id` = p.`package_flow_type_id`
LEFT JOIN `service_type` st
  ON st.`service_type_id` = p.`service_type_id`
LEFT JOIN `shippingdetails` sd
  ON sd.`package_id` = p.`package_id`
LEFT JOIN `business` b
  ON b.`business_id` = p.`sender_business_id`
LEFT JOIN latest_movement lm
  ON lm.`package_id` = p.`package_id`
 AND lm.`rn` = 1
LEFT JOIN `package_status` ps
  ON ps.`package_status_id` = p.`package_status_id`
WHERE pft.`package_flow_type_name` = 'B2C'
  AND (
      lm.`event_type_name` = 'Departed Facility'
      OR ps.`status_name` = 'In Transit'
  );

-- Validation queries

SELECT COUNT(*) AS inserted_b2c_packages
FROM `package` p
JOIN `staging_b2c_package` sbp
  ON sbp.`package_id_hex` = HEX(p.`package_id`);

SELECT COUNT(*) AS inserted_b2c_shippingdetails_rows
FROM `shippingdetails` sd
JOIN `staging_b2c_shippingdetails` ssd
  ON ssd.`package_id_hex` = HEX(sd.`package_id`);

SELECT COUNT(*) AS inserted_b2c_movement_rows
FROM `package_movement` pm
JOIN `staging_b2c_origin_movement` sm
  ON sm.`package_id_hex` = HEX(pm.`package_id`)
 AND sm.`event_timestamp` = pm.`event_timestamp`
 AND sm.`package_movement_event_type_id` = pm.`package_movement_event_type_id`;

SELECT
    sbp.`package_id_hex`,
    sbp.`order_id`,
    sbp.`seller_id`
FROM `staging_b2c_package` sbp
LEFT JOIN `shippingdetails` sd
  ON sd.`package_id` = UNHEX(sbp.`package_id_hex`)
WHERE sd.`package_id` IS NULL;

SELECT
    sbp.`package_id_hex`,
    sbp.`order_id`,
    sbp.`seller_id`
FROM `staging_b2c_package` sbp
LEFT JOIN `package_movement` pm
  ON pm.`package_id` = UNHEX(sbp.`package_id_hex`)
WHERE pm.`package_id` IS NULL;

WITH latest_movement AS (
    SELECT
        pm.`package_id`,
        pm.`package_status_id`,
        ROW_NUMBER() OVER (
            PARTITION BY pm.`package_id`
            ORDER BY pm.`event_timestamp` DESC, pm.`package_movement_id` DESC
        ) AS `rn`
    FROM `package_movement` pm
)
SELECT
    HEX(p.`package_id`) AS `package_id_hex`,
    p.`package_status_id` AS `current_package_status_id`,
    lm.`package_status_id` AS `latest_movement_status_id`
FROM `package` p
JOIN `staging_b2c_package` sbp
  ON sbp.`package_id_hex` = HEX(p.`package_id`)
LEFT JOIN latest_movement lm
  ON lm.`package_id` = p.`package_id`
 AND lm.`rn` = 1
WHERE lm.`package_status_id` IS NOT NULL
  AND p.`package_status_id` <> lm.`package_status_id`;

SELECT COUNT(*) AS accidental_shipping_cost_rows
FROM `shipping_cost` sc
JOIN `staging_b2c_package` sbp
  ON sbp.`package_id_hex` = HEX(sc.`package_id`);

-- Optional corrective backstop if package status ever drifts from the latest movement row.
WITH latest_movement AS (
    SELECT
        pm.`package_id`,
        pm.`package_status_id`,
        ROW_NUMBER() OVER (
            PARTITION BY pm.`package_id`
            ORDER BY pm.`event_timestamp` DESC, pm.`package_movement_id` DESC
        ) AS `rn`
    FROM `package_movement` pm
)
UPDATE `package` p
JOIN latest_movement lm
  ON lm.`package_id` = p.`package_id`
 AND lm.`rn` = 1
JOIN `staging_b2c_package` sbp
  ON sbp.`package_id_hex` = HEX(p.`package_id`)
SET p.`package_status_id` = lm.`package_status_id`,
    p.`updated_at` = CURRENT_TIMESTAMP
WHERE p.`package_status_id` <> lm.`package_status_id`;
