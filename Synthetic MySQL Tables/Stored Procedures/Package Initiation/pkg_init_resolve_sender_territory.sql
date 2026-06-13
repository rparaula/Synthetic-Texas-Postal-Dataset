USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `pkg_init_resolve_sender_territory`;
DELIMITER $$

CREATE PROCEDURE `pkg_init_resolve_sender_territory`(
    IN p_package_flow_type_id INT,
    IN p_sender_customer_id BINARY(16),
    IN p_sender_business_id BINARY(16),
    OUT p_sender_territory_id INT
)
SQL SECURITY INVOKER
BEGIN
    DECLARE v_flow_type_name VARCHAR(30);

    SET p_sender_territory_id = NULL;

    IF p_package_flow_type_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Package flow type ID is required.';
    END IF;

    SELECT pft.`package_flow_type_name`
    INTO v_flow_type_name
    FROM `package_flow_type` pft
    WHERE pft.`package_flow_type_id` = p_package_flow_type_id
      AND pft.`is_active` = 1;

    IF v_flow_type_name IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid or inactive package flow type ID.';
    END IF;

    IF v_flow_type_name = 'B2C' THEN
        IF p_sender_business_id IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'B2C packages require a sender business ID.';
        END IF;

        IF p_sender_customer_id IS NOT NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'B2C packages cannot include a sender customer ID.';
        END IF;

        CALL `pkg_init_resolve_business_territory`(
            p_sender_business_id,
            p_sender_territory_id
        );
    ELSEIF v_flow_type_name = 'P2P' THEN
        IF p_sender_customer_id IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'P2P packages require a sender customer ID.';
        END IF;

        IF p_sender_business_id IS NOT NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'P2P packages cannot include a sender business ID.';
        END IF;

        CALL `pkg_init_resolve_customer_territory`(
            p_sender_customer_id,
            p_sender_territory_id
        );
    ELSE
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Unsupported package flow type for sender territory resolution.';
    END IF;
END $$

DELIMITER ;

SELECT
    `ROUTINE_SCHEMA`,
    `ROUTINE_NAME`,
    `ROUTINE_TYPE`
FROM `information_schema`.`ROUTINES`
WHERE `ROUTINE_SCHEMA` = 'postal_bi_system'
  AND `ROUTINE_NAME` = 'pkg_init_resolve_sender_territory';
