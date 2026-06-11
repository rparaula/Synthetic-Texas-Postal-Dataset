# B2C Olist Origin Ingestion

This folder builds and loads the beginning lifecycle of B2C packages only. It stops at origin departure and intentionally does not create `shipping_cost`, middle-mile, final-mile, pickup completion, SmartLocker completion, or P2P package logic.

## Inputs Required

- `Olist E-Commerce Dataset/olist_orders_dataset.csv`
- `Olist E-Commerce Dataset/olist_order_items_dataset.csv`
- `Olist E-Commerce Dataset/olist_products_dataset.csv`
- `Olist E-Commerce Dataset/olist_customers_dataset.csv`
- `Olist E-Commerce Dataset/product_category_name_translation.csv`
- `Synthetic MySQL Tables/Business/staging import file/business_import_audit.csv`
- `Synthetic MySQL Tables/Customers/import file/customer_import_audit.csv`
- `MySQL Database Schema/postal_bi_system_business.sql`
- `MySQL Database Schema/postal_bi_system_customer.sql`
- `MySQL Database Schema/postal_bi_system_facility.sql`
- lookup SQL dumps for `service_type`, `package_flow_type`, `package_status`, and `package_movement_event_type`

## Outputs Produced

- `build_b2c_olist_origin_ingestion.ipynb`
- `b2c_olist_origin_pipeline.py`
- `stg_b2c_package.csv`
- `stg_b2c_shippingdetails.csv`
- `stg_b2c_origin_movement.csv`
- `stg_b2c_package_quarantine.csv`
- `load_b2c_olist_origin_ingestion.sql`

## Import Order

1. Run `build_b2c_olist_origin_ingestion.ipynb` or `b2c_olist_origin_pipeline.py`.
2. Review the printed validation summary and the quarantine CSV.
3. Run `load_b2c_olist_origin_ingestion.sql` in MySQL Workbench with `LOCAL INFILE` enabled.
4. Run the validation queries at the bottom of the SQL script.

## Assumptions

- One `(order_id, seller_id)` pair becomes one B2C package.
- `seller_id` is already aligned to the real `business.business_id` used by the project.
- Olist customers are mapped to postal customers through `customer_unique_id`.
- `business.preferred_facility_id` is the origin facility for B2C packages.
- The first-pass import only stages packages with all three origin timestamps present and ordered.
- `package_id_hex` is generated as a deterministic UUID5 hex string so reruns stay stable.
- `estimated_delivery_distance`, `expected_delivery_date`, and `delivered_date` are left blank in staging.

## Validation Checks

The notebook prints:

- total staged B2C packages
- packages by service type
- packages by initial status
- packages by origin facility
- missing recipient mappings
- missing seller/business mappings
- missing preferred facility IDs
- invalid dimensions
- invalid or out-of-order timestamps
- count of generated movement events by type
- packages eligible for later middle-mile simulation

The SQL script validates:

- inserted package count
- inserted shippingdetails count
- inserted movement count
- packages without shippingdetails
- packages without movement rows
- packages whose latest movement status does not match `package.package_status_id`
- accidental `shipping_cost` rows, which should return `0`

## Why `shipping_cost` Is Not Populated

`shipping_cost` is intentionally deferred because this ingestion only models origin intake, sorting, and departure. Full charge and transportation logic depends on later middle-mile and destination lifecycle events, so populating `shipping_cost` now would create incomplete or misleading financial rows.
