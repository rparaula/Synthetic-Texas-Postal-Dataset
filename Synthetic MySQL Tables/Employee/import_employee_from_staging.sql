USE `postal_bi_system`;

-- ============================================================
-- import_employee_from_staging.sql
-- Purpose:
--   Load employee_import.csv into a persistent staging table,
--   validate the staged data, insert generated employees into
--   employee, map import keys to real employee IDs, and update
--   department/facility manager references.
--
-- How to use:
--   1. Update the LOAD DATA LOCAL INFILE path below.
--   2. Run through the staging load and validation sections.
--   3. Stop if any validation query returns problem rows.
--   4. Run the production transaction only after validation passes.
--
-- Important:
--   Do not use TRUNCATE TABLE employee for this workflow. DELETE
--   respects foreign-key actions such as ON DELETE SET NULL and
--   ON DELETE CASCADE.
-- ============================================================

-- ============================================================
-- 1. Recreate persistent staging table.
-- ============================================================

DROP TABLE IF EXISTS staging_employee_key_map;
DROP TABLE IF EXISTS staging_employee_import;

CREATE TABLE staging_employee_import (
    employee_import_key VARCHAR(80) NOT NULL,
    facility_id INT NOT NULL,
    facility_name VARCHAR(100) NOT NULL,
    facility_type_name VARCHAR(80) NOT NULL,

    department_id INT NOT NULL,
    department_name VARCHAR(80) NOT NULL,
    department_type_id INT NOT NULL,
    department_type_name VARCHAR(80) NOT NULL,

    is_department_manager TINYINT NOT NULL,
    is_facility_manager TINYINT NOT NULL,
    manager_import_key VARCHAR(80) NULL,

    full_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    email VARCHAR(100) NOT NULL,
    street_address VARCHAR(100) NOT NULL,
    job_title VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    hours_worked SMALLINT NULL,
    employment_status VARCHAR(20) NOT NULL,
    generated_source VARCHAR(100) NULL,

    loaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (employee_import_key),
    UNIQUE KEY uq_staging_employee_email (email),
    KEY idx_staging_manager_import_key (manager_import_key),
    KEY idx_staging_department_id (department_id),
    KEY idx_staging_facility_id (facility_id),
    KEY idx_staging_is_department_manager (is_department_manager),
    KEY idx_staging_is_facility_manager (is_facility_manager)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================
-- 2. Load employee_import.csv.
-- ============================================================

-- Change this placeholder path before running.
-- Example Windows path:
--   C:/Users/Ryan/path/to/employee_import.csv
--
-- MySQL client notes:
--   - LOCAL INFILE must be enabled by the client and server.
--   - In MySQL Workbench, enable "OPT_LOCAL_INFILE=1" if needed.
--   - Use forward slashes in the path.

LOAD DATA LOCAL INFILE 'C:/CHANGE/THIS/PATH/employee_import.csv'
INTO TABLE staging_employee_import
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    employee_import_key,
    @facility_id,
    facility_name,
    facility_type_name,
    @department_id,
    department_name,
    @department_type_id,
    department_type_name,
    @is_department_manager,
    @is_facility_manager,
    @manager_import_key,
    full_name,
    first_name,
    last_name,
    phone_number,
    email,
    street_address,
    job_title,
    @salary,
    @hours_worked,
    employment_status,
    @generated_source
)
SET
    facility_id = CAST(@facility_id AS UNSIGNED),
    department_id = CAST(@department_id AS UNSIGNED),
    department_type_id = CAST(@department_type_id AS UNSIGNED),

    is_department_manager =
        CASE
            WHEN LOWER(TRIM(@is_department_manager)) = 'true' THEN 1
            WHEN TRIM(@is_department_manager) = '1' THEN 1
            ELSE 0
        END,

    is_facility_manager =
        CASE
            WHEN LOWER(TRIM(@is_facility_manager)) = 'true' THEN 1
            WHEN TRIM(@is_facility_manager) = '1' THEN 1
            ELSE 0
        END,

    manager_import_key = NULLIF(TRIM(@manager_import_key), ''),
    salary = CAST(@salary AS DECIMAL(10,2)),
    hours_worked =
        CASE
            WHEN TRIM(@hours_worked) = '' THEN NULL
            ELSE CAST(@hours_worked AS UNSIGNED)
        END,
    generated_source = NULLIF(TRIM(TRAILING '\r' FROM TRIM(@generated_source)), '');

-- ============================================================
-- 3. Required staging validations.
-- ============================================================

-- Count check. Confirm this equals the expected generated row count.
SELECT '01 staging row count' AS check_name,
       COUNT(*) AS staged_rows
FROM staging_employee_import;

-- Should return zero rows. Every staged department_id must exist.
SELECT '02 missing department_id references' AS check_name,
       s.employee_import_key,
       s.department_id,
       s.department_name
FROM staging_employee_import s
LEFT JOIN departments d
    ON d.department_id = s.department_id
WHERE d.department_id IS NULL;

-- Should return zero rows. Every staged facility_id must exist.
SELECT '03 missing facility_id references' AS check_name,
       s.employee_import_key,
       s.facility_id,
       s.facility_name
FROM staging_employee_import s
LEFT JOIN facility f
    ON f.facility_id = s.facility_id
WHERE f.facility_id IS NULL;

-- Should return zero rows. Each staged department must belong to the staged facility.
SELECT '04 department/facility mismatches' AS check_name,
       s.employee_import_key,
       s.department_id,
       s.facility_id AS staged_facility_id,
       d.facility_id AS actual_department_facility_id
FROM staging_employee_import s
JOIN departments d
    ON d.department_id = s.department_id
WHERE s.facility_id <> d.facility_id;

-- Should return zero rows. The staging unique key should also prevent this.
SELECT '05 duplicate emails' AS check_name,
       email,
       COUNT(*) AS row_count
FROM staging_employee_import
GROUP BY email
HAVING COUNT(*) > 1;

-- Warning only. Shared phone numbers may be acceptable, but review them.
SELECT '06 duplicate phone numbers warning' AS check_name,
       phone_number,
       COUNT(*) AS row_count
FROM staging_employee_import
GROUP BY phone_number
HAVING COUNT(*) > 1;

-- Should return zero rows. Regular employees need manager_import_key.
SELECT '07 regular employees missing manager_import_key' AS check_name,
       employee_import_key,
       full_name,
       manager_import_key
FROM staging_employee_import
WHERE is_department_manager = 0
  AND (manager_import_key IS NULL OR TRIM(manager_import_key) = '');

-- Should return zero rows. Regular employees must reference a real staged manager row.
SELECT '08 regular employees with missing manager rows' AS check_name,
       e.employee_import_key,
       e.full_name,
       e.manager_import_key
FROM staging_employee_import e
LEFT JOIN staging_employee_import m
    ON m.employee_import_key = e.manager_import_key
WHERE e.is_department_manager = 0
  AND m.employee_import_key IS NULL;

-- Should return zero rows. Referenced managers must be department managers.
SELECT '09 manager_import_key does not point to department manager' AS check_name,
       e.employee_import_key,
       e.full_name,
       e.manager_import_key,
       m.full_name AS referenced_manager_name,
       m.is_department_manager
FROM staging_employee_import e
JOIN staging_employee_import m
    ON m.employee_import_key = e.manager_import_key
WHERE e.is_department_manager = 0
  AND m.is_department_manager <> 1;

-- Should return zero rows. Every staged department needs exactly one manager.
SELECT '10 departments without exactly one department manager' AS check_name,
       department_id,
       department_name,
       SUM(CASE WHEN is_department_manager = 1 THEN 1 ELSE 0 END) AS department_manager_count,
       COUNT(*) AS staged_employee_count
FROM staging_employee_import
GROUP BY department_id, department_name
HAVING SUM(CASE WHEN is_department_manager = 1 THEN 1 ELSE 0 END) <> 1;

-- Should return zero rows. Every staged facility needs exactly one facility manager.
SELECT '11 facilities without exactly one facility manager' AS check_name,
       facility_id,
       facility_name,
       SUM(CASE WHEN is_facility_manager = 1 THEN 1 ELSE 0 END) AS facility_manager_count,
       COUNT(*) AS staged_employee_count
FROM staging_employee_import
GROUP BY facility_id, facility_name
HAVING SUM(CASE WHEN is_facility_manager = 1 THEN 1 ELSE 0 END) <> 1;

-- Should return zero rows. The employee table has triggers for this rule too.
SELECT '12 regular employee salary exceeds assigned manager salary' AS check_name,
       e.employee_import_key,
       e.full_name,
       e.salary AS employee_salary,
       m.employee_import_key AS manager_import_key,
       m.full_name AS manager_name,
       m.salary AS manager_salary
FROM staging_employee_import e
JOIN staging_employee_import m
    ON m.employee_import_key = e.manager_import_key
WHERE e.is_department_manager = 0
  AND e.salary > m.salary;

-- Should return zero rows. These lengths match employee table limits.
SELECT '13 string length violations' AS check_name,
       employee_import_key,
       CHAR_LENGTH(full_name) AS full_name_length,
       CHAR_LENGTH(phone_number) AS phone_number_length,
       CHAR_LENGTH(email) AS email_length,
       CHAR_LENGTH(street_address) AS street_address_length,
       CHAR_LENGTH(job_title) AS job_title_length
FROM staging_employee_import
WHERE CHAR_LENGTH(full_name) > 50
   OR CHAR_LENGTH(phone_number) > 15
   OR CHAR_LENGTH(email) > 100
   OR CHAR_LENGTH(street_address) > 100
   OR CHAR_LENGTH(job_title) > 50;

-- Should return zero rows. Department type in CSV should match departments.
SELECT '14 department type mismatches' AS check_name,
       s.employee_import_key,
       s.department_id,
       s.department_type_id AS staged_department_type_id,
       d.department_type_id AS actual_department_type_id
FROM staging_employee_import s
JOIN departments d
    ON d.department_id = s.department_id
WHERE s.department_type_id <> d.department_type_id;

-- Should return zero rows. Facility managers should also be department managers.
SELECT '15 facility manager is not department manager' AS check_name,
       employee_import_key,
       facility_id,
       department_id,
       is_department_manager,
       is_facility_manager
FROM staging_employee_import
WHERE is_facility_manager = 1
  AND is_department_manager <> 1;

-- Optional extra preflight. Should return zero rows when importing into
-- an employee table that does not already contain these generated emails.
SELECT '16 staged emails already exist in employee' AS check_name,
       s.employee_import_key,
       s.email,
       e.employee_id
FROM staging_employee_import s
JOIN employee e
    ON e.email = s.email;

-- ============================================================
-- 4. Optional reset section.
-- ============================================================

-- Optional reset if employee_import.csv should become the new source of truth.
-- Do not run this if existing employees are tied to meaningful incidents or history.
--
-- incident.reported_by_employee_id uses ON DELETE RESTRICT. If incident_count
-- is greater than 0, deleting employees may fail and should not proceed until
-- incidents are reviewed and handled.

SELECT COUNT(*) AS incident_count
FROM incident;

SELECT 'WARNING: incident rows reference employees and may block reset' AS warning_name,
       i.incident_id,
       i.reported_by_employee_id,
       e.full_name,
       i.incident_date,
       i.description
FROM incident i
JOIN employee e
    ON e.employee_id = i.reported_by_employee_id
ORDER BY i.incident_id;

-- ===== START OPTIONAL RESET: uncomment only after reviewing incidents =====
-- START TRANSACTION;
-- DELETE FROM employee;
-- ALTER TABLE employee AUTO_INCREMENT = 1;
-- COMMIT;
-- ===== END OPTIONAL RESET =====

-- ============================================================
-- 5. Create persistent key map table.
-- ============================================================

DROP TABLE IF EXISTS staging_employee_key_map;

CREATE TABLE staging_employee_key_map (
    employee_import_key VARCHAR(80) NOT NULL,
    employee_id INT NOT NULL,
    facility_id INT NOT NULL,
    department_id INT NOT NULL,
    is_department_manager TINYINT NOT NULL,
    is_facility_manager TINYINT NOT NULL,

    PRIMARY KEY (employee_import_key),
    UNIQUE KEY uq_staging_employee_key_map_employee_id (employee_id),
    KEY idx_staging_employee_key_map_department_id (department_id),
    KEY idx_staging_employee_key_map_facility_id (facility_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================
-- 6. Production import transaction.
-- ============================================================

-- If any validation above returned problem rows, stop here and fix the data.
-- If testing manually, run ROLLBACK instead of COMMIT before leaving the session.

START TRANSACTION;

-- B. Insert department managers first. Their manager_employee_id is NULL
-- because regular employees need these rows to exist before they can reference them.
INSERT INTO employee (
    department_id,
    full_name,
    phone_number,
    email,
    street_address,
    job_title,
    salary,
    hours_worked,
    manager_employee_id,
    user_id
)
SELECT
    s.department_id,
    s.full_name,
    s.phone_number,
    s.email,
    s.street_address,
    s.job_title,
    s.salary,
    s.hours_worked,
    NULL AS manager_employee_id,
    NULL AS user_id
FROM staging_employee_import s
WHERE s.is_department_manager = 1
ORDER BY s.facility_id, s.department_id, s.employee_import_key;

-- C/D. Add department managers to the key map.
INSERT INTO staging_employee_key_map (
    employee_import_key,
    employee_id,
    facility_id,
    department_id,
    is_department_manager,
    is_facility_manager
)
SELECT
    s.employee_import_key,
    e.employee_id,
    s.facility_id,
    s.department_id,
    s.is_department_manager,
    s.is_facility_manager
FROM staging_employee_import s
JOIN employee e
    ON e.email = s.email
WHERE s.is_department_manager = 1;

-- E. Insert regular employees by resolving manager_import_key through the key map.
INSERT INTO employee (
    department_id,
    full_name,
    phone_number,
    email,
    street_address,
    job_title,
    salary,
    hours_worked,
    manager_employee_id,
    user_id
)
SELECT
    s.department_id,
    s.full_name,
    s.phone_number,
    s.email,
    s.street_address,
    s.job_title,
    s.salary,
    s.hours_worked,
    manager_map.employee_id AS manager_employee_id,
    NULL AS user_id
FROM staging_employee_import s
JOIN staging_employee_key_map manager_map
    ON s.manager_import_key = manager_map.employee_import_key
WHERE s.is_department_manager = 0
ORDER BY s.facility_id, s.department_id, s.employee_import_key;

-- F. Add regular employees to the key map.
INSERT INTO staging_employee_key_map (
    employee_import_key,
    employee_id,
    facility_id,
    department_id,
    is_department_manager,
    is_facility_manager
)
SELECT
    s.employee_import_key,
    e.employee_id,
    s.facility_id,
    s.department_id,
    s.is_department_manager,
    s.is_facility_manager
FROM staging_employee_import s
JOIN employee e
    ON e.email = s.email
WHERE s.is_department_manager = 0;

-- G. Validate map completeness before updating manager references.
SELECT 'mid-import staging rows vs mapped rows' AS check_name,
       (SELECT COUNT(*) FROM staging_employee_import) AS staging_rows,
       (SELECT COUNT(*) FROM staging_employee_key_map) AS mapped_rows;

-- H. Update department managers from inserted department manager rows.
UPDATE departments d
JOIN staging_employee_import s
    ON d.department_id = s.department_id
JOIN staging_employee_key_map m
    ON s.employee_import_key = m.employee_import_key
SET
    d.manager_employee_id = m.employee_id,
    d.manager_start_date = NOW()
WHERE s.is_department_manager = 1;

-- I. Update facility managers from inserted facility manager rows.
UPDATE facility f
JOIN staging_employee_import s
    ON f.facility_id = s.facility_id
JOIN staging_employee_key_map m
    ON s.employee_import_key = m.employee_import_key
SET
    f.manager_employee_id = m.employee_id
WHERE s.is_facility_manager = 1;

-- J. Optional: populate works_on for each generated employee.
-- The actual schema uses PRIMARY KEY (employee_id, department_id).
INSERT INTO works_on (
    employee_id,
    department_id,
    hours_worked
)
SELECT
    e.employee_id,
    e.department_id,
    e.hours_worked
FROM employee e
JOIN staging_employee_import s
    ON e.email = s.email
ON DUPLICATE KEY UPDATE
    hours_worked = VALUES(hours_worked);

-- K. Optional: reattach demo user_logins accounts to selected employees.
-- Do not delete user_logins. This only clears stale employee.user_id links
-- for the two demo users, then attaches them to generated employees.
UPDATE employee
SET user_id = NULL
WHERE user_id IN (2, 3);

SELECT @demo_manager_email := s.email
FROM staging_employee_import s
WHERE s.is_facility_manager = 1
ORDER BY s.facility_id
LIMIT 1;

UPDATE employee
SET user_id = 3
WHERE email = @demo_manager_email;

SELECT @demo_employee_email := s.email
FROM staging_employee_import s
WHERE s.is_department_manager = 0
ORDER BY s.facility_id, s.department_id
LIMIT 1;

UPDATE employee
SET user_id = 2
WHERE email = @demo_employee_email;

-- For a manual test run, use ROLLBACK instead of COMMIT.
-- ROLLBACK;
COMMIT;

-- ============================================================
-- 7. Post-import validation checks.
-- ============================================================

-- Informational count of all employees currently in production.
SELECT '01 total employee count' AS check_name,
       COUNT(*) AS employee_count
FROM employee;

-- Should return zero rows. Staged departments should have managers.
SELECT '02 staged departments without managers' AS check_name,
       d.department_id,
       d.department_name
FROM (
    SELECT DISTINCT department_id
    FROM staging_employee_import
) sd
JOIN departments d
    ON d.department_id = sd.department_id
WHERE d.manager_employee_id IS NULL;

-- Should return zero rows. Staged facilities should have managers.
SELECT '03 staged facilities without managers' AS check_name,
       f.facility_id,
       f.facility_name
FROM (
    SELECT DISTINCT facility_id
    FROM staging_employee_import
) sf
JOIN facility f
    ON f.facility_id = sf.facility_id
WHERE f.manager_employee_id IS NULL;

-- Should return zero rows. Generated regular employees should have managers.
SELECT '04 generated regular employees without managers' AS check_name,
       e.employee_id,
       e.full_name,
       e.email
FROM staging_employee_import s
JOIN employee e
    ON e.email = s.email
WHERE s.is_department_manager = 0
  AND e.manager_employee_id IS NULL;

-- Should return zero rows. Generated employees should reference valid departments.
SELECT '05 generated employees with invalid department references' AS check_name,
       e.employee_id,
       e.full_name,
       e.department_id
FROM staging_employee_import s
JOIN employee e
    ON e.email = s.email
LEFT JOIN departments d
    ON d.department_id = e.department_id
WHERE d.department_id IS NULL;

-- Should return zero rows. Regular employee salary must not exceed manager salary.
SELECT '06 generated salary exceeds manager salary' AS check_name,
       e.employee_id,
       e.full_name,
       e.salary AS employee_salary,
       m.employee_id AS manager_employee_id,
       m.full_name AS manager_name,
       m.salary AS manager_salary
FROM staging_employee_import s
JOIN employee e
    ON e.email = s.email
JOIN employee m
    ON m.employee_id = e.manager_employee_id
WHERE s.is_department_manager = 0
  AND e.salary > m.salary;

-- Informational count by department type.
SELECT '07 employee count by department type' AS check_name,
       s.department_type_id,
       s.department_type_name,
       COUNT(*) AS employee_count
FROM staging_employee_import s
JOIN employee e
    ON e.email = s.email
GROUP BY s.department_type_id, s.department_type_name
ORDER BY s.department_type_id;

-- Informational count by facility type.
SELECT '08 employee count by facility type' AS check_name,
       s.facility_type_name,
       COUNT(*) AS employee_count
FROM staging_employee_import s
JOIN employee e
    ON e.email = s.email
GROUP BY s.facility_type_name
ORDER BY s.facility_type_name;

-- Informational count. Expect 2 if both demo accounts were attached.
SELECT '09 generated employees attached to user accounts' AS check_name,
       COUNT(*) AS attached_generated_user_count
FROM staging_employee_import s
JOIN employee e
    ON e.email = s.email
WHERE e.user_id IS NOT NULL;

-- Should show equal counts.
SELECT '10 map completeness' AS check_name,
       (SELECT COUNT(*) FROM staging_employee_import) AS staging_rows,
       (SELECT COUNT(*) FROM staging_employee_key_map) AS mapped_rows,
       COUNT(e.employee_id) AS inserted_employee_rows
FROM staging_employee_import s
LEFT JOIN employee e
    ON e.email = s.email;

-- Optional detail. Useful when checking which demo employees received login access.
SELECT 'demo login attachment detail' AS check_name,
       ul.user_id,
       ul.email AS login_email,
       e.employee_id,
       e.full_name,
       e.email AS employee_email,
       e.job_title
FROM user_logins ul
LEFT JOIN employee e
    ON e.user_id = ul.user_id
WHERE ul.user_id IN (2, 3)
ORDER BY ul.user_id;

-- ============================================================
-- 8. Staging cleanup choices.
-- ============================================================

-- Default recommendation: archive staging tables after validation passes.
-- Replace YYYYMMDD with the date you ran the import, for example 20260608.
--
-- RENAME TABLE staging_employee_import TO staging_employee_import_archive_YYYYMMDD;
-- RENAME TABLE staging_employee_key_map TO staging_employee_key_map_archive_YYYYMMDD;

-- Alternative: drop staging tables if you do not need the audit trail.
--
-- DROP TABLE IF EXISTS staging_employee_key_map;
-- DROP TABLE IF EXISTS staging_employee_import;
