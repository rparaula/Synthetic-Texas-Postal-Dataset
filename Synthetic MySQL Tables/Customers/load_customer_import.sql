-- Helper load script for Synthetic MySQL Tables/Customers/output/customer_import.csv
-- customer.customer_id is BINARY(16), so the CSV stores lowercase hex text
-- and this script converts it with UNHEX(customer_id) during insert.

DROP TABLE IF EXISTS staging_customer_import;

CREATE TABLE staging_customer_import (
    customer_id CHAR(32) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    middle_initial CHAR(1) NULL,
    last_name VARCHAR(50) NOT NULL,
    street_address VARCHAR(100) NOT NULL,
    county VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state_code CHAR(2) NOT NULL,
    zip_code VARCHAR(10) NOT NULL,
    territory_id VARCHAR(20) NULL,
    phone_number VARCHAR(15) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at VARCHAR(30) NULL,
    updated_at VARCHAR(30) NULL,
    user_id VARCHAR(20) NULL,
    preferred_facility_id VARCHAR(20) NULL,
    birth_date VARCHAR(20) NULL,
    marital_status CHAR(1) NULL,
    gender CHAR(1) NULL,
    email_address VARCHAR(150) NULL,
    annual_income VARCHAR(30) NULL,
    total_children VARCHAR(10) NULL,
    education_level VARCHAR(30) NULL,
    occupation VARCHAR(30) NULL,
    home_owner CHAR(1) NULL
);


-- Update this placeholder path before running. 
LOAD DATA LOCAL INFILE 'Z:/Computer Science/GitHub Repositories/Personal Projects/Synthetic-Texas-Postal-Dataset/Synthetic MySQL Tables/Customers/customer_import.csv'
INTO TABLE staging_customer_import
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '"'
LINES TERMINATED BY '
'
IGNORE 1 LINES
(
    customer_id,
    first_name,
    middle_initial,
    last_name,
    street_address,
    county,
    city,
    state_code,
    zip_code,
    territory_id,
    phone_number,
    email,
    created_at,
    updated_at,
    user_id,
    preferred_facility_id,
    birth_date,
    marital_status,
    gender,
    email_address,
    annual_income,
    total_children,
    education_level,
    occupation,
    home_owner
);

INSERT INTO customer (
    customer_id,
    first_name,
    middle_initial,
    last_name,
    street_address,
    county,
    city,
    state_code,
    zip_code,
    territory_id,
    phone_number,
    email,
    created_at,
    updated_at,
    user_id,
    preferred_facility_id,
    birth_date,
    marital_status,
    gender,
    email_address,
    annual_income,
    total_children,
    education_level,
    occupation,
    home_owner
)
SELECT
    UNHEX(customer_id),
    first_name,
    NULLIF(middle_initial, ''),
    last_name,
    street_address,
    city,
    state_code,
    zip_code,
    NULLIF(territory_id, ''),
    phone_number,
    email,
    NULLIF(created_at, ''),
    NULLIF(updated_at, ''),
    NULLIF(user_id, ''),
    NULLIF(preferred_facility_id, ''),
    NULLIF(birth_date, ''),
    NULLIF(marital_status, ''),
    NULLIF(gender, ''),
    NULLIF(email_address, ''),
    NULLIF(annual_income, ''),
    NULLIF(total_children, ''),
    NULLIF(education_level, ''),
    NULLIF(occupation, ''),
    NULLIF(home_owner, '')
FROM staging_customer_import;
