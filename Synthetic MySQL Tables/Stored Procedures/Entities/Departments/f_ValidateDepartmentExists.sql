USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `f_ValidateDepartmentExists`;
DELIMITER $$

CREATE PROCEDURE `f_ValidateDepartmentExists`(
    IN p_department_id INT,
    IN p_required_facility_id INT,
    IN p_required_department_type_id INT
)
SQL SECURITY INVOKER
BEGIN
    IF p_department_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Department ID is required.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM `departments`
        WHERE `department_id` = p_department_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Department does not exist.';
    END IF;

    IF p_required_facility_id IS NOT NULL
       AND NOT EXISTS (
           SELECT 1
           FROM `departments`
           WHERE `department_id` = p_department_id
             AND `facility_id` = p_required_facility_id
       ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Department does not belong to the required facility.';
    END IF;

    IF p_required_department_type_id IS NOT NULL
       AND NOT EXISTS (
           SELECT 1
           FROM `departments`
           WHERE `department_id` = p_department_id
             AND `department_type_id` = p_required_department_type_id
       ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Department does not match the required department type.';
    END IF;
END $$

DELIMITER ;
