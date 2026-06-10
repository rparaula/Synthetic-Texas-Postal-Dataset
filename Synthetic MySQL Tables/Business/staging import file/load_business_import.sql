-- Helper load script for Synthetic MySQL Tables/Business/business_import.csv
-- business.business_id is BINARY(16), so the CSV stores lowercase hex text
-- and this script converts it with UNHEX(business_id) during insert.

DROP TABLE IF EXISTS staging_business_import;

CREATE TABLE staging_business_import (
    business_id CHAR(32) NOT NULL,
    business_name VARCHAR(150) NOT NULL,
    street_address VARCHAR(150) NULL,
    county VARCHAR(50) NULL,
    city VARCHAR(50) NULL,
    state_code CHAR(2) NOT NULL,
    zip_code VARCHAR(10) NULL,
    territory_id VARCHAR(20) NULL,
    phone_number VARCHAR(20) NULL,
    email VARCHAR(100) NULL,
    created_at VARCHAR(30) NULL,
    updated_at VARCHAR(30) NULL
);

LOAD DATA LOCAL INFILE 'Z:/Computer Science/GitHub Repositories/Personal Projects/Synthetic-Texas-Postal-Dataset/Synthetic MySQL Tables/Business/business_import.csv'
INTO TABLE staging_business_import
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    business_id,
    business_name,
    street_address,
    county,
    city,
    state_code,
    zip_code,
    territory_id,
    phone_number,
    email,
    created_at,
    updated_at
);

INSERT INTO business (
    business_id,
    business_name,
    street_address,
    county,
    city,
    state_code,
    zip_code,
    territory_id,
    phone_number,
    email,
    created_at,
    updated_at
)
SELECT
    UNHEX(business_id),
    business_name,
    NULLIF(street_address, ''),
    NULLIF(county, ''),
    NULLIF(city, ''),
    state_code,
    NULLIF(zip_code, ''),
    NULLIF(territory_id, ''),
    NULLIF(phone_number, ''),
    NULLIF(email, ''),
    NULLIF(created_at, ''),
    NULLIF(updated_at, '')
FROM staging_business_import;
