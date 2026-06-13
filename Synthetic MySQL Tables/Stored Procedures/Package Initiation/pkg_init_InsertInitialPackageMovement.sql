USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `pkg_init_InsertInitialPackageMovement`;
DELIMITER $$

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

DELIMITER ;

SELECT
    `ROUTINE_SCHEMA`,
    `ROUTINE_NAME`,
    `ROUTINE_TYPE`
FROM `information_schema`.`ROUTINES`
WHERE `ROUTINE_SCHEMA` = 'postal_bi_system'
  AND `ROUTINE_TYPE` = 'PROCEDURE'
  AND `ROUTINE_NAME` = 'pkg_init_InsertInitialPackageMovement';