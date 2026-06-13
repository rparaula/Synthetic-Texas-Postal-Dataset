USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `pkg_init_ResolveB2COriginFacility`;
DELIMITER $$

CREATE PROCEDURE `pkg_init_ResolveB2COriginFacility`(

    IN p_business_id BINARY(16),
    IN p_requested_origin_facility_id INT,
    OUT p_origin_facility_id INT
)
SQL SECURITY INVOKER
BEGIN
    CALL `pkg_init_determine_b2c_origin_facility`(
        p_business_id,
        p_requested_origin_facility_id,
        p_origin_facility_id
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
  AND `ROUTINE_NAME` = 'pkg_init_ResolveB2COriginFacility';