USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `pkg_init_CreateInitialShippingCost`;
DELIMITER $$

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

DELIMITER ;

SELECT
    `ROUTINE_SCHEMA`,
    `ROUTINE_NAME`,
    `ROUTINE_TYPE`
FROM `information_schema`.`ROUTINES`
WHERE `ROUTINE_SCHEMA` = 'postal_bi_system'
  AND `ROUTINE_TYPE` = 'PROCEDURE'
  AND `ROUTINE_NAME` = 'pkg_init_CreateInitialShippingCost';