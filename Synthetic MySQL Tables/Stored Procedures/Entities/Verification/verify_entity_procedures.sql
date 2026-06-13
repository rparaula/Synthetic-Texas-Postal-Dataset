USE `postal_bi_system`;

SELECT
    expected_routines.routine_name,
    CASE
        WHEN routines.ROUTINE_NAME IS NULL THEN 'missing'
        ELSE 'present'
    END AS procedure_status
FROM (
    SELECT 'c_NewCustomer' AS routine_name
    UNION ALL SELECT 'c_ValidateCustomerExists'
    UNION ALL SELECT 'e_NewEmployee'
    UNION ALL SELECT 'e_ValidateEmployeeExists'
    UNION ALL SELECT 'b_NewBusiness'
    UNION ALL SELECT 'b_ValidateBusinessExists'
    UNION ALL SELECT 'f_NewFacility'
    UNION ALL SELECT 'f_ValidateFacilityExists'
    UNION ALL SELECT 'f_NewDepartment'
    UNION ALL SELECT 'f_ValidateDepartmentExists'
) AS expected_routines
LEFT JOIN `information_schema`.`ROUTINES` routines
    ON routines.`ROUTINE_SCHEMA` = DATABASE()
   AND routines.`ROUTINE_TYPE` = 'PROCEDURE'
   AND routines.`ROUTINE_NAME` = expected_routines.routine_name
ORDER BY expected_routines.routine_name;

SELECT
    `ROUTINE_NAME`,
    `CREATED`,
    `LAST_ALTERED`,
    `SQL_MODE`,
    `SECURITY_TYPE`
FROM `information_schema`.`ROUTINES`
WHERE `ROUTINE_SCHEMA` = DATABASE()
  AND `ROUTINE_TYPE` = 'PROCEDURE'
  AND (
      `ROUTINE_NAME` LIKE 'c\_%'
      OR `ROUTINE_NAME` LIKE 'e\_%'
      OR `ROUTINE_NAME` LIKE 'b\_%'
      OR `ROUTINE_NAME` LIKE 'f\_%'
  )
ORDER BY `ROUTINE_NAME`;
