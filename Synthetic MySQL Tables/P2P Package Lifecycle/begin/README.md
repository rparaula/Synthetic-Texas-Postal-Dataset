# P2P Olist Origin Ingestion

This folder builds and loads the beginning lifecycle of P2P packages only. It stops at origin departure and intentionally does not create `shipping_cost`, middle-mile, final-mile, pickup completion, SmartLocker completion, or B2C package logic.

## Inputs Required

- `Olist E-Commerce Dataset/olist_orders_dataset.csv`
- `Olist E-Commerce Dataset/olist_order_items_dataset.csv`
- `Olist E-Commerce Dataset/olist_products_dataset.csv`
- `Olist E-Commerce Dataset/olist_customers_dataset.csv`
- `Olist E-Commerce Dataset/product_category_name_translation.csv`
- `Synthetic MySQL Tables/Customers/import file/customer_import_audit.csv`
- `C:/Users/Ryan/OneDrive/Documents/dumps/PostIngestionB2C.zip`

## Outputs Produced

- `build_p2p_olist_origin_ingestion.ipynb`
- `p2p_olist_origin_pipeline.py`
- `stg_p2p_package.csv`
- `stg_p2p_shippingdetails.csv`
- `stg_p2p_origin_movement.csv`
- `stg_p2p_package_quarantine.csv`
- `load_p2p_olist_origin_ingestion.sql`

## Import Order

1. Run `build_p2p_olist_origin_ingestion.ipynb` or `p2p_olist_origin_pipeline.py`.
2. Review the printed validation summary and `stg_p2p_package_quarantine.csv`.
3. Run `load_p2p_olist_origin_ingestion.sql` in MySQL Workbench with `LOCAL INFILE` enabled.
4. Run the validation queries at the bottom of the SQL script.

## Assumptions

- One `(order_id, seller_id)` pair becomes one synthetic P2P package seed.
- `seller_id` is preserved only as an audit/source column and is never used as the P2P sender.
- Recipient customers are mapped from Olist customers through `source_customer_unique_id`.
- Sender customers are drawn only from the postal customer population and are never businesses.
- Staging uses `weight_oz` because the production `package` table stores ounces; Olist grams are converted directly to ounces.
- The first pass stages only rows with all three required origin timestamps present.

## Synthetic Sender Logic

- The recipient is the mapped postal customer for the Olist order.
- The sender is selected from the existing postal customer population.
- The sender can never equal the recipient.
- Sender choice is distance-weighted by territory centroid:
  - Local 0-10 miles: 5%
  - Regional 10-50 miles: 15%
  - Medium 50-150 miles: 30%
  - Long distance 150+ miles: 50%
- If the requested band has no valid candidates, selection falls back to the nearest practical band.

## Why P2P Origins Use Post Offices

P2P packages represent a retail customer handing an item to USPS for origin intake. Because of that, the origin facility is the sender customer's nearest valid Post Office, not a Mail Processing facility. If no valid Post Office can be resolved, the package is quarantined instead of silently imported.

## Validation Checks

The notebook prints:

- target P2P final share
- current B2C package count if available
- calculated P2P package count
- total staged P2P packages
- packages by service type
- packages by initial status
- packages by origin facility
- packages by sender-recipient distance band
- average sender-recipient distance
- missing recipient customer mappings
- missing synthetic sender customer IDs
- sender equals recipient violations
- missing origin Post Office facility IDs
- invalid dimensions
- invalid or out-of-order timestamps
- generated movement events by type
- packages eligible for later middle-mile simulation

The SQL script validates:

- inserted package count
- inserted shippingdetails count
- inserted movement count
- packages without shippingdetails
- packages without movement rows
- packages where `sender_customer_id` is NULL
- packages where `sender_business_id` is not NULL
- packages where sender equals recipient
- packages whose latest movement status does not match `package.package_status_id`
- packages whose origin facility is not a Post Office
- accidental `shipping_cost` rows, which should return `0`

## Why `shipping_cost` Is Not Populated

`shipping_cost` is intentionally deferred because this ingestion only models origin intake, sorting, and departure. Full charge and transportation logic depends on later middle-mile and destination lifecycle events, so populating `shipping_cost` now would create incomplete or misleading financial rows.
