USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `e_NewEmployee`;
DELIMITER $$

CREATE PROCEDURE `e_NewEmployee`(
    IN p_department_id INT,
    IN p_full_name VARCHAR(50),
    IN p_phone_number VARCHAR(15),
    IN p_email VARCHAR(100),
    IN p_street_address VARCHAR(100),
    IN p_job_title VARCHAR(50),
    IN p_salary DECIMAL(10,2),
    IN p_hours_worked SMALLINT,
    IN p_manager_employee_id INT,
    IN p_user_id INT,
    OUT p_employee_id INT
)
SQL SECURITY INVOKER
BEGIN
    DECLARE v_full_name VARCHAR(50);
    DECLARE v_phone_number VARCHAR(15);
    DECLARE v_email VARCHAR(100);
    DECLARE v_street_address VARCHAR(100);
    DECLARE v_job_title VARCHAR(50);
    DECLARE v_department_facility_id INT;
    DECLARE v_manager_facility_id INT;
    DECLARE v_manager_salary DECIMAL(10,2);
    DECLARE v_user_exists INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SET v_full_name = NULLIF(TRIM(p_full_name), '');
    SET v_phone_number = NULLIF(TRIM(p_phone_number), '');
    SET v_email = LOWER(NULLIF(TRIM(p_email), ''));
    SET v_street_address = NULLIF(TRIM(p_street_address), '');
    SET v_job_title = NULLIF(TRIM(p_job_title), '');

    IF p_department_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Department ID is required.';
    END IF;

    IF v_full_name IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Employee full name is required.';
    END IF;

    IF v_phone_number IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Employee phone number is required.';
    END IF;

    IF v_email IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Employee email is required.';
    END IF;

    IF v_email NOT REGEXP '^[^[:space:]@]+@[^[:space:]@]+\\.[^[:space:]@]+$' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Employee email format is invalid.';
    END IF;

    IF v_street_address IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Employee street address is required.';
    END IF;

    IF v_job_title IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Employee job title is required.';
    END IF;

    IF p_salary IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Employee salary is required.';
    END IF;

    IF p_salary < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Employee salary cannot be negative.';
    END IF;

    IF p_hours_worked IS NOT NULL AND p_hours_worked < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Employee hours worked cannot be negative.';
    END IF;

    START TRANSACTION;

    CALL `f_ValidateDepartmentExists`(p_department_id, NULL, NULL);

    IF EXISTS (
        SELECT 1
        FROM `employee`
        WHERE `email` = v_email
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Employee email already exists.';
    END IF;

    IF p_user_id IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_user_exists
        FROM `user_logins`
        WHERE `user_id` = p_user_id;

        IF v_user_exists = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Employee user account does not exist.';
        END IF;

        IF EXISTS (
            SELECT 1
            FROM `employee`
            WHERE `user_id` = p_user_id
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Employee user account is already assigned.';
        END IF;
    END IF;

    SELECT d.`facility_id`
    INTO v_department_facility_id
    FROM `departments` d
    WHERE d.`department_id` = p_department_id;

    IF p_manager_employee_id IS NOT NULL THEN
        CALL `e_ValidateEmployeeExists`(p_manager_employee_id);

        IF p_manager_employee_id = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Manager employee ID is invalid.';
        END IF;

        SELECT d.`facility_id`,
               e.`salary`
        INTO v_manager_facility_id,
             v_manager_salary
        FROM `employee` e
        JOIN `departments` d
            ON d.`department_id` = e.`department_id`
        WHERE e.`employee_id` = p_manager_employee_id;

        IF v_manager_facility_id <> v_department_facility_id THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Employee manager must work at the same facility.';
        END IF;

        IF p_salary > v_manager_salary THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Employee salary cannot exceed manager salary.';
        END IF;
    END IF;

    INSERT INTO `employee` (
        `department_id`,
        `full_name`,
        `phone_number`,
        `email`,
        `street_address`,
        `job_title`,
        `salary`,
        `hours_worked`,
        `manager_employee_id`,
        `user_id`
    )
    VALUES (
        p_department_id,
        v_full_name,
        v_phone_number,
        v_email,
        v_street_address,
        v_job_title,
        p_salary,
        p_hours_worked,
        p_manager_employee_id,
        p_user_id
    );

    SET p_employee_id = LAST_INSERT_ID();

    COMMIT;
END $$

DELIMITER ;
