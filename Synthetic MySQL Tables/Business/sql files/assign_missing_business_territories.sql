USE `postal_bi_system`;

DROP PROCEDURE IF EXISTS `assign_missing_business_territories`;
DELIMITER $$

CREATE PROCEDURE `u_assign_missing_business_territories`()
BEGIN
    -- Assign missing business territories only when the full tracked location matches.
    UPDATE `business` b
    JOIN `territory` t
      ON UPPER(TRIM(b.`state_code`)) = UPPER(TRIM(t.`state`))
     AND UPPER(TRIM(b.`county`))     = UPPER(TRIM(t.`county`))
     AND UPPER(TRIM(b.`city`))       = UPPER(TRIM(t.`city`))
     AND LEFT(TRIM(b.`zip_code`), 5) = TRIM(t.`zip_code`)
    SET b.`territory_id` = t.`territory_id`
    WHERE b.`territory_id` IS NULL;

    -- Return unresolved businesses so missing or untracked locations are visible.
    SELECT
        b.`business_id`,
        b.`business_name`,
        b.`street_address`,
        b.`city`,
        b.`county`,
        b.`state_code`,
        b.`zip_code`,
        b.`territory_id`,
        CASE
            WHEN b.`state_code` IS NULL OR TRIM(b.`state_code`) = '' THEN 'Missing state'
            WHEN b.`county` IS NULL OR TRIM(b.`county`) = '' THEN 'Missing county'
            WHEN b.`city` IS NULL OR TRIM(b.`city`) = '' THEN 'Missing city'
            WHEN b.`zip_code` IS NULL OR TRIM(b.`zip_code`) = '' THEN 'Missing ZIP'
            ELSE 'Location not tracked in territory table'
        END AS `validation_issue`
    FROM `business` b
    LEFT JOIN `territory` t
      ON UPPER(TRIM(b.`state_code`)) = UPPER(TRIM(t.`state`))
     AND UPPER(TRIM(b.`county`))     = UPPER(TRIM(t.`county`))
     AND UPPER(TRIM(b.`city`))       = UPPER(TRIM(t.`city`))
     AND LEFT(TRIM(b.`zip_code`), 5) = TRIM(t.`zip_code`)
    WHERE b.`territory_id` IS NULL
      AND t.`territory_id` IS NULL
    ORDER BY
        `validation_issue`,
        b.`state_code`,
        LEFT(TRIM(b.`zip_code`), 5),
        b.`city`,
        b.`county`,
        b.`business_name`;
END$$

DELIMITER ;
