# Employee CSV Import README

This folder contains a staging-based import script for loading the generated `employee_import.csv` file into the real `employee` table.

## Why staging is needed

The CSV is generated outside MySQL, so it should not be trusted blindly. The `staging_employee_import` table gives you a place to load the raw generated employees, inspect them, and run validation queries before touching production tables.

Staging also makes debugging much easier. If something looks wrong, you can query the staged rows directly instead of trying to infer what happened after an insert failed halfway through.

## Why managers are inserted first

Regular employees reference their manager through `employee.manager_employee_id`, which points back to another row in the same `employee` table.

Because `employee.employee_id` is auto-incremented, the manager's real ID does not exist until the manager row is inserted. The import therefore inserts department managers first, records their generated IDs in `staging_employee_key_map`, and then inserts regular employees by resolving `manager_import_key` through that map.

## Why import keys are needed

The CSV cannot know the final `employee.employee_id` values ahead of time, so it uses temporary stable keys:

- `employee_import_key` identifies each generated employee row inside the CSV.
- `manager_import_key` identifies which staged manager a regular employee should report to.

After managers and employees are inserted, `staging_employee_key_map` records the final relationship:

```text
employee_import_key -> employee.employee_id
```

Keep this map table until you are confident the import is correct. It is useful for auditing which CSV row became which real employee row.

## Why DELETE is safer than TRUNCATE

Do not use `TRUNCATE TABLE employee` for this workflow.

Other tables reference `employee`, including `departments`, `facility`, `works_on`, `package`, `package_movement`, and `incident`. A normal `DELETE FROM employee` allows row-level foreign-key actions to run, such as `ON DELETE SET NULL` and `ON DELETE CASCADE`.

`incident.reported_by_employee_id` uses `ON DELETE RESTRICT`, so existing incident rows can block an employee reset. The script includes:

```sql
SELECT COUNT(*) AS incident_count
FROM incident;
```

If that count is greater than zero, review incidents before attempting a reset.

## How user_logins is affected

The script does not delete from `user_logins`.

The optional login repair section clears stale `employee.user_id` links for demo users `2` and `3`, then attaches:

- `user_id = 2` to one generated regular employee.
- `user_id = 3` to one generated facility manager.

This keeps the demo login accounts but points them at generated employee records.

## How to run safely

1. Open `import_employee_from_staging.sql` in MySQL Workbench.
2. Update the `LOAD DATA LOCAL INFILE` path to the real `employee_import.csv` location.
3. Confirm MySQL Workbench and the MySQL server allow `LOCAL INFILE`.
4. Run the staging table creation and CSV load sections.
5. Run every staging validation query.
6. Stop if any required validation query returns rows.
7. Review the optional reset section before using it. Do not reset employees if incidents still reference employees.
8. Run the production transaction.
9. Run the post-import validations.
10. Archive staging tables by renaming them with the import date.

## What validation queries should return

The row count query should return the expected generated employee count.

Most validation queries should return zero rows. Rows returned from these checks mean something needs review before import:

- missing department references
- missing facility references
- department/facility mismatches
- duplicate emails
- missing manager keys
- manager keys that do not point to department managers
- departments without exactly one department manager
- facilities without exactly one facility manager
- regular employees whose salary exceeds their manager's salary
- string values that exceed the target `employee` schema limits

Duplicate phone numbers are reported as a warning. They may be acceptable in demo data, but they should still be reviewed.

After import, the post-import checks should show no missing managers, no invalid departments, no salary violations, and matching counts between staged rows, mapped rows, and inserted generated employee rows.
