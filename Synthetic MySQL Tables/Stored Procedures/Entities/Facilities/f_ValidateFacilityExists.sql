USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `f_ValidateFacilityExists`;
DELIMITER $$

CREATE PROCEDURE `f_ValidateFacilityExists`(
    IN p_facility_id INT,
    IN p_required_facility_type_name VARCHAR(80)
)
SQL SECURITY INVOKER
BEGIN
    IF p_facility_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Facility ID is required.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM `facility`
        WHERE `facility_id` = p_facility_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Facility does not exist.';
    END IF;

    IF p_required_facility_type_name IS NOT NULL
       AND NOT EXISTS (
           SELECT 1
           FROM `facility` f
           JOIN `facility_type` ft
               ON ft.`facility_type_id` = f.`facility_type_id`
           WHERE f.`facility_id` = p_facility_id
             AND UPPER(ft.`facility_type_name`) = UPPER(TRIM(p_required_facility_type_name))
       ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Facility does not match the required facility type.';
    END IF;
END $$

DELIMITER ;
