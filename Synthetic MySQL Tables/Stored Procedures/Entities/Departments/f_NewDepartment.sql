USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `f_NewDepartment`;
DELIMITER $$

CREATE PROCEDURE `f_NewDepartment`(
    IN p_department_name VARCHAR(40),
    IN p_department_type_id INT,
    IN p_manager_employee_id INT,
    IN p_facility_id INT,
    OUT p_department_id INT
)
SQL SECURITY INVOKER
BEGIN
    DECLARE v_department_name VARCHAR(40);
    DECLARE v_facility_type_id INT;
    DECLARE v_department_type_name VARCHAR(50);
    DECLARE v_facility_prefix VARCHAR(30);
    DECLARE v_department_type_is_active INT DEFAULT 0;
    DECLARE v_rule_exists INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SET v_department_name = NULLIF(TRIM(p_department_name), '');

    IF p_facility_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Facility ID is required.';
    END IF;

    IF p_department_type_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Department type ID is required.';
    END IF;

    START TRANSACTION;

    CALL `f_ValidateFacilityExists`(p_facility_id, NULL);

    SELECT COUNT(*)
    INTO v_department_type_is_active
    FROM `department_type`
    WHERE `department_type_id` = p_department_type_id
      AND `is_active` = 1;

    IF v_department_type_is_active = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Department type does not exist or is inactive.';
    END IF;

    SELECT f.`facility_type_id`,
           f.`facility_department_prefix`
    INTO v_facility_type_id,
         v_facility_prefix
    FROM `facility` f
    WHERE f.`facility_id` = p_facility_id;

    SELECT dt.`department_type_name`
    INTO v_department_type_name
    FROM `department_type` dt
    WHERE dt.`department_type_id` = p_department_type_id;

    SELECT COUNT(*)
    INTO v_rule_exists
    FROM `facility_type_department_rule`
    WHERE `facility_type_id` = v_facility_type_id
      AND `department_type_id` = p_department_type_id;

    IF v_rule_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Department type is not allowed for this facility type.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM `departments`
        WHERE `facility_id` = p_facility_id
          AND `department_type_id` = p_department_type_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Facility already has a department of this type.';
    END IF;

    IF p_manager_employee_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'New departments must be created with manager_employee_id set to NULL.';
    END IF;

    IF v_department_name IS NULL THEN
        SET v_department_name = CONCAT(v_facility_prefix, '_', v_department_type_name);
    END IF;

    INSERT INTO `departments` (
        `department_name`,
        `department_type_id`,
        `manager_employee_id`,
        `facility_id`
    )
    VALUES (
        v_department_name,
        p_department_type_id,
        NULL,
        p_facility_id
    );

    SET p_department_id = LAST_INSERT_ID();

    COMMIT;
END $$

DELIMITER ;
