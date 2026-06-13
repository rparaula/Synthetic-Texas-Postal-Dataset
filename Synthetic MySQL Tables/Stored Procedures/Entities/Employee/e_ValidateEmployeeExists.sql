USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `e_ValidateEmployeeExists`;
DELIMITER $$

CREATE PROCEDURE `e_ValidateEmployeeExists`(
    IN p_employee_id INT
)
SQL SECURITY INVOKER
BEGIN
    IF p_employee_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Employee ID is required.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM `employee`
        WHERE `employee_id` = p_employee_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Employee does not exist.';
    END IF;
END $$

DELIMITER ;
