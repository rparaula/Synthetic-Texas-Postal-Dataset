from __future__ import annotations

import json
import math
import re
import uuid
import zipfile
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path
from typing import Any

import numpy as np
import pandas as pd


RANDOM_SEED = 42
PACKAGE_UUID_NAMESPACE = uuid.UUID("f0c2a8be-f280-4e03-8f8c-8a13bcd2a458")

TARGET_P2P_FINAL_SHARE = 0.25
TARGET_P2P_PACKAGE_COUNT: int | None = None

GRAMS_PER_OUNCE = 28.349523125
CM_PER_INCH = 2.54

POSTAL_SCHEMA_ZIP = Path(r"C:\Users\Ryan\OneDrive\Documents\dumps\PostIngestionB2C.zip")

PROJECT_ROOT = Path(__file__).resolve().parents[3]
OUTPUT_DIR = Path(__file__).resolve().parent
OLIST_DIR = PROJECT_ROOT / "Olist E-Commerce Dataset"
CUSTOMER_IMPORT_AUDIT_CSV = PROJECT_ROOT / "Synthetic MySQL Tables" / "Customers" / "import file" / "customer_import_audit.csv"

STG_PACKAGE_CSV = OUTPUT_DIR / "stg_p2p_package.csv"
STG_SHIPPINGDETAILS_CSV = OUTPUT_DIR / "stg_p2p_shippingdetails.csv"
STG_MOVEMENT_CSV = OUTPUT_DIR / "stg_p2p_origin_movement.csv"
QUARANTINE_CSV = OUTPUT_DIR / "stg_p2p_package_quarantine.csv"
NOTEBOOK_PATH = OUTPUT_DIR / "build_p2p_olist_origin_ingestion.ipynb"
README_PATH = OUTPUT_DIR / "README.md"
SQL_PATH = OUTPUT_DIR / "load_p2p_olist_origin_ingestion.sql"

SERVICE_TYPE_DISTRIBUTION = {
    "Delivery": 0.764,
    "Pickup": 0.155,
    "SmartLocker": 0.081,
}

DISTANCE_BANDS = {
    "Local 0-10 miles": (0.0, 10.0),
    "Regional 10-50 miles": (10.0, 50.0),
    "Medium 50-150 miles": (50.0, 150.0),
    "Long Distance 150+ miles": (150.0, None),
}

DISTANCE_BAND_WEIGHTS = {
    "Local 0-10 miles": 0.05,
    "Regional 10-50 miles": 0.15,
    "Medium 50-150 miles": 0.30,
    "Long Distance 150+ miles": 0.50,
}

DISTANCE_BAND_FALLBACKS = {
    "Local 0-10 miles": ["Local 0-10 miles", "Regional 10-50 miles", "Medium 50-150 miles", "Long Distance 150+ miles"],
    "Regional 10-50 miles": ["Regional 10-50 miles", "Medium 50-150 miles", "Local 0-10 miles", "Long Distance 150+ miles"],
    "Medium 50-150 miles": ["Medium 50-150 miles", "Long Distance 150+ miles", "Regional 10-50 miles", "Local 0-10 miles"],
    "Long Distance 150+ miles": ["Long Distance 150+ miles", "Medium 50-150 miles", "Regional 10-50 miles", "Local 0-10 miles"],
}

FACILITY_EVENT_CONFIG = [
    ("Received At Facility", "origin_received_timestamp", "Received", False),
    ("Sorted At Facility", "origin_sorted_timestamp", "Processing", False),
    ("Departed Facility", "origin_departed_timestamp", "In Transit", True),
]

EXTREME_LENGTH_IN = 60.0
EXTREME_WIDTH_IN = 60.0
EXTREME_HEIGHT_IN = 60.0
EXTREME_WEIGHT_OZ = 1120.0

CUSTOMER_AUDIT_COLUMNS = [
    "customer_id",
    "first_name",
    "middle_initial",
    "last_name",
    "street_address",
    "assigned_texas_county",
    "city",
    "state_code",
    "zip_code",
    "territory_id",
    "phone_number",
    "email",
    "created_at",
    "updated_at",
    "user_id",
    "preferred_facility_id",
    "birth_date",
    "marital_status",
    "gender",
    "email_address",
    "annual_income",
    "total_children",
    "education_level",
    "occupation",
    "home_owner",
    "source_customer_unique_id",
    "source_first_customer_id",
    "source_order_count",
]

FACILITY_DUMP_COLUMNS = [
    "facility_id",
    "facility_type_id",
    "manager_employee_id",
    "facility_name",
    "street_address",
    "county",
    "city",
    "state_code",
    "zip_code",
    "facility_department_prefix",
    "territory_id",
    "created_at",
    "updated_at",
]

TERRITORY_DUMP_COLUMNS = [
    "territory_id",
    "state",
    "city",
    "county",
    "zip_code",
    "created_at",
    "updated_at",
]

ZIP_GEO_DUMP_COLUMNS = [
    "zip_code",
    "latitude",
    "longitude",
    "created_at",
    "updated_at",
]

FACILITY_TYPE_DUMP_COLUMNS = [
    "facility_type_id",
    "facility_type_code",
    "facility_type_name",
    "description",
    "is_customer_facing",
    "handles_retail",
    "handles_processing",
    "handles_distribution",
    "handles_local_delivery",
    "is_active",
    "created_at",
    "updated_at",
]

PACKAGE_DUMP_COLUMNS = [
    "package_id_raw",
    "package_status_id",
    "service_type_id",
    "received_date",
    "contents",
    "weight_oz",
    "length_in",
    "width_in",
    "height_in",
    "employee_id",
    "created_at",
    "updated_at",
    "recipient_customer_id_raw",
    "package_flow_type_id",
    "sender_customer_id_raw",
    "sender_business_id_raw",
]


@dataclass
class PipelineResult:
    package_stage: pd.DataFrame
    shippingdetails_stage: pd.DataFrame
    movement_stage: pd.DataFrame
    quarantine: pd.DataFrame
    validation_frames: dict[str, pd.DataFrame]
    summary: dict[str, Any]


def read_zip_entry_text(entry_name: str) -> str:
    if not POSTAL_SCHEMA_ZIP.exists():
        raise FileNotFoundError(f"Missing schema zip: {POSTAL_SCHEMA_ZIP}")
    with zipfile.ZipFile(POSTAL_SCHEMA_ZIP) as archive:
        with archive.open(entry_name, "r") as handle:
            return handle.read().decode("utf-8", errors="replace")


def extract_insert_values_sql_from_text(text: str, table_name: str) -> str:
    marker = f"INSERT INTO `{table_name}` VALUES"
    start = text.find(marker)
    if start == -1:
        raise ValueError(f"Could not find INSERT INTO `{table_name}`.")
    i = start + len(marker)
    while i < len(text) and text[i].isspace():
        i += 1

    value_start = i
    in_quote = False
    escaped = False
    while i < len(text):
        char = text[i]
        if in_quote:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == "'":
                in_quote = False
        else:
            if char == "'":
                in_quote = True
            elif char == ";":
                return text[value_start:i]
        i += 1

    raise ValueError(f"Could not find statement terminator for `{table_name}`.")


def mysql_unescape(value: str) -> str:
    result: list[str] = []
    i = 0
    while i < len(value):
        char = value[i]
        if char != "\\":
            result.append(char)
            i += 1
            continue
        if i + 1 >= len(value):
            result.append("\\")
            break

        nxt = value[i + 1]
        translation = {
            "0": "\x00",
            "b": "\b",
            "n": "\n",
            "r": "\r",
            "t": "\t",
            "Z": "\x1a",
            "\\": "\\",
            "'": "'",
            '"': '"',
        }
        result.append(translation.get(nxt, nxt))
        i += 2
    return "".join(result)


def parse_mysql_literal(token: str) -> Any:
    token = token.strip()
    if token == "NULL":
        return None
    if token.startswith("_binary '") and token.endswith("'"):
        return mysql_unescape(token[len("_binary '") : -1])
    if token.startswith("'") and token.endswith("'"):
        return mysql_unescape(token[1:-1])
    if re.fullmatch(r"-?\d+", token):
        return int(token)
    if re.fullmatch(r"-?\d+\.\d+", token):
        return float(token)
    return token


def parse_values_clause(values_sql: str) -> list[list[Any]]:
    rows: list[list[Any]] = []
    i = 0
    n = len(values_sql)
    while i < n:
        if values_sql[i] != "(":
            i += 1
            continue

        i += 1
        token_chars: list[str] = []
        row_tokens: list[str] = []
        in_quote = False
        escaped = False

        while i < n:
            char = values_sql[i]
            if in_quote:
                token_chars.append(char)
                if escaped:
                    escaped = False
                elif char == "\\":
                    escaped = True
                elif char == "'":
                    in_quote = False
                i += 1
                continue

            if char == "'":
                in_quote = True
                token_chars.append(char)
                i += 1
                continue

            if char == ",":
                row_tokens.append("".join(token_chars).strip())
                token_chars = []
                i += 1
                continue

            if char == ")":
                row_tokens.append("".join(token_chars).strip())
                rows.append([parse_mysql_literal(token) for token in row_tokens])
                i += 1
                break

            token_chars.append(char)
            i += 1

    return rows


def normalize_text(value: Any) -> str:
    if value is None or (isinstance(value, float) and math.isnan(value)):
        return ""
    return re.sub(r"\s+", " ", str(value).strip()).upper()


@lru_cache(maxsize=8)
def load_lookup_table(table_name: str, id_column: str, name_column: str) -> pd.DataFrame:
    text = read_zip_entry_text(f"PostIngestionB2C/postal_bi_system_{table_name}.sql")
    rows = parse_values_clause(extract_insert_values_sql_from_text(text, table_name))

    if table_name == "service_type":
        columns = ["service_type_id", "service_type_name", "is_active"]
    elif table_name == "package_flow_type":
        columns = ["package_flow_type_id", "package_flow_type_name", "is_active"]
    elif table_name == "package_status":
        columns = [
            "package_status_id",
            "status_name",
            "status_category",
            "sort_order",
            "is_final_status",
            "is_active",
            "allowed_service_type_id",
        ]
    elif table_name == "package_movement_event_type":
        columns = [
            "package_movement_event_type_id",
            "event_type_name",
            "description",
            "default_package_status_name",
            "is_entry_event",
            "is_exit_event",
            "is_processing_event",
            "is_delay_event",
            "is_final_event",
            "sort_order",
            "is_active",
        ]
    else:
        raise ValueError(f"Unsupported lookup table: {table_name}")

    frame = pd.DataFrame(rows, columns=columns)
    frame = frame.loc[frame["is_active"] == 1].copy()
    frame[id_column] = frame[id_column].astype(int)
    frame[name_column] = frame[name_column].astype("string")
    return frame


@lru_cache(maxsize=1)
def load_facility_lookup() -> pd.DataFrame:
    text = read_zip_entry_text("PostIngestionB2C/postal_bi_system_facility.sql")
    rows = parse_values_clause(extract_insert_values_sql_from_text(text, "facility"))
    frame = pd.DataFrame(rows, columns=FACILITY_DUMP_COLUMNS)
    frame["facility_id"] = frame["facility_id"].astype(int)
    frame["facility_type_id"] = frame["facility_type_id"].astype(int)
    frame["territory_id"] = pd.to_numeric(frame["territory_id"], errors="coerce").astype("Int64")
    frame["zip_code"] = frame["zip_code"].astype("string").str[:5]
    return frame


@lru_cache(maxsize=1)
def load_facility_type_lookup() -> pd.DataFrame:
    text = read_zip_entry_text("PostIngestionB2C/postal_bi_system_facility_type.sql")
    rows = parse_values_clause(extract_insert_values_sql_from_text(text, "facility_type"))
    frame = pd.DataFrame(rows, columns=FACILITY_TYPE_DUMP_COLUMNS)
    frame["facility_type_id"] = frame["facility_type_id"].astype(int)
    frame["facility_type_name"] = frame["facility_type_name"].astype("string")
    frame["is_active"] = frame["is_active"].astype(int)
    return frame


@lru_cache(maxsize=1)
def load_territory_lookup() -> pd.DataFrame:
    text = read_zip_entry_text("PostIngestionB2C/postal_bi_system_territory.sql")
    rows = parse_values_clause(extract_insert_values_sql_from_text(text, "territory"))
    frame = pd.DataFrame(rows, columns=TERRITORY_DUMP_COLUMNS)
    frame["territory_id"] = frame["territory_id"].astype(int)
    frame["territory_zip5"] = frame["zip_code"].astype("string").str[:5]
    frame["state_norm"] = frame["state"].map(normalize_text)
    frame["city_norm"] = frame["city"].map(normalize_text)
    frame["county_norm"] = frame["county"].map(normalize_text)
    return frame


@lru_cache(maxsize=1)
def load_zip_geo_lookup() -> pd.DataFrame:
    text = read_zip_entry_text("PostIngestionB2C/postal_bi_system_zip_geo.sql")
    rows = parse_values_clause(extract_insert_values_sql_from_text(text, "zip_geo"))
    frame = pd.DataFrame(rows, columns=ZIP_GEO_DUMP_COLUMNS)
    frame["zip_code"] = frame["zip_code"].astype("string").str[:5]
    frame["latitude"] = pd.to_numeric(frame["latitude"], errors="coerce")
    frame["longitude"] = pd.to_numeric(frame["longitude"], errors="coerce")
    return frame


def attach_territory(
    frame: pd.DataFrame,
    *,
    state_column: str,
    city_column: str,
    county_column: str,
    zip_column: str,
) -> pd.DataFrame:
    territory = load_territory_lookup()
    enriched = frame.copy()
    enriched["state_norm"] = enriched[state_column].map(normalize_text)
    enriched["city_norm"] = enriched[city_column].map(normalize_text)
    enriched["county_norm"] = enriched[county_column].map(normalize_text)
    enriched["zip_norm"] = enriched[zip_column].astype("string").str[:5]

    enriched = enriched.merge(
        territory[["territory_id", "state_norm", "city_norm", "county_norm", "territory_zip5"]],
        left_on=["state_norm", "city_norm", "county_norm", "zip_norm"],
        right_on=["state_norm", "city_norm", "county_norm", "territory_zip5"],
        how="left",
        validate="many_to_one",
        suffixes=("_audit", "_db"),
    )
    if "territory_id_db" in enriched.columns:
        return enriched.rename(columns={"territory_id_db": "db_territory_id"})
    return enriched.rename(columns={"territory_id": "db_territory_id"})


def haversine_miles(lat1: np.ndarray, lon1: np.ndarray, lat2: np.ndarray, lon2: np.ndarray) -> np.ndarray:
    radius_miles = 3958.7613
    lat1_rad = np.radians(lat1)
    lon1_rad = np.radians(lon1)
    lat2_rad = np.radians(lat2)
    lon2_rad = np.radians(lon2)
    dlat = lat2_rad - lat1_rad
    dlon = lon2_rad - lon1_rad
    a = np.sin(dlat / 2.0) ** 2 + np.cos(lat1_rad) * np.cos(lat2_rad) * np.sin(dlon / 2.0) ** 2
    c = 2.0 * np.arctan2(np.sqrt(a), np.sqrt(1.0 - a))
    return radius_miles * c


def format_timestamp(series: pd.Series) -> pd.Series:
    return pd.to_datetime(series, errors="coerce").dt.strftime("%Y-%m-%d %H:%M:%S")


def build_contents(categories: pd.Series) -> str:
    values = [str(value).strip() for value in categories.dropna().unique() if str(value).strip()]
    if not values:
        return "Unknown"
    return ("; ".join(sorted(values)[:3]))[:30] or "Unknown"


def resolve_lookup_maps() -> dict[str, dict[str, int]]:
    service_type = load_lookup_table("service_type", "service_type_id", "service_type_name")
    package_flow_type = load_lookup_table("package_flow_type", "package_flow_type_id", "package_flow_type_name")
    package_status = load_lookup_table("package_status", "package_status_id", "status_name")
    movement_event_type = load_lookup_table(
        "package_movement_event_type",
        "package_movement_event_type_id",
        "event_type_name",
    )
    return {
        "service_type": dict(zip(service_type["service_type_name"], service_type["service_type_id"])),
        "package_flow_type": dict(zip(package_flow_type["package_flow_type_name"], package_flow_type["package_flow_type_id"])),
        "package_status": dict(zip(package_status["status_name"], package_status["package_status_id"])),
        "movement_event_type": dict(zip(movement_event_type["event_type_name"], movement_event_type["package_movement_event_type_id"])),
    }


def load_customer_lookup() -> pd.DataFrame:
    frame = pd.read_csv(
        CUSTOMER_IMPORT_AUDIT_CSV,
        dtype={column: "string" for column in CUSTOMER_AUDIT_COLUMNS},
    )
    frame["customer_id"] = frame["customer_id"].astype("string").str.strip().str.lower()
    frame["source_customer_unique_id"] = frame["source_customer_unique_id"].astype("string").str.strip()
    frame["source_first_customer_id"] = frame["source_first_customer_id"].astype("string").str.strip().str.lower()
    frame["zip_code"] = frame["zip_code"].astype("string").str[:5]
    frame["territory_id"] = pd.to_numeric(frame["territory_id"], errors="coerce").astype("Int64")
    frame["preferred_facility_id"] = pd.to_numeric(frame["preferred_facility_id"], errors="coerce").astype("Int64")

    frame = attach_territory(
        frame,
        state_column="state_code",
        city_column="city",
        county_column="assigned_texas_county",
        zip_column="zip_code",
    )
    source_territory_column = "territory_id_audit" if "territory_id_audit" in frame.columns else "territory_id"
    frame[source_territory_column] = pd.to_numeric(frame[source_territory_column], errors="coerce").astype("Int64")
    frame["resolved_territory_id"] = frame[source_territory_column].fillna(frame["db_territory_id"]).astype("Int64")
    frame["recipient_customer_id_hex"] = frame["customer_id"]
    frame["customer_unique_id"] = frame["source_customer_unique_id"]
    return frame


def load_olist_inputs() -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    orders = pd.read_csv(
        OLIST_DIR / "olist_orders_dataset.csv",
        dtype={"order_id": "string", "customer_id": "string", "order_status": "string"},
        parse_dates=[
            "order_purchase_timestamp",
            "order_approved_at",
            "order_delivered_carrier_date",
            "order_delivered_customer_date",
            "order_estimated_delivery_date",
        ],
    )
    items = pd.read_csv(
        OLIST_DIR / "olist_order_items_dataset.csv",
        dtype={"order_id": "string", "product_id": "string", "seller_id": "string"},
        parse_dates=["shipping_limit_date"],
    )
    products = pd.read_csv(
        OLIST_DIR / "olist_products_dataset.csv",
        dtype={"product_id": "string", "product_category_name": "string"},
    )
    customers = pd.read_csv(
        OLIST_DIR / "olist_customers_dataset.csv",
        dtype={
            "customer_id": "string",
            "customer_unique_id": "string",
            "customer_zip_code_prefix": "string",
            "customer_city": "string",
            "customer_state": "string",
        },
    )
    category_translation = pd.read_csv(
        OLIST_DIR / "product_category_name_translation.csv",
        dtype={"product_category_name": "string", "product_category_name_english": "string"},
    )
    return orders, items, products, customers, category_translation


@lru_cache(maxsize=1)
def load_territory_geo() -> pd.DataFrame:
    territory = load_territory_lookup()
    zip_geo = load_zip_geo_lookup()
    frame = territory.merge(
        zip_geo[["zip_code", "latitude", "longitude"]],
        left_on="territory_zip5",
        right_on="zip_code",
        how="left",
        validate="many_to_one",
    )
    frame = frame.dropna(subset=["latitude", "longitude"]).copy()
    return frame[["territory_id", "territory_zip5", "latitude", "longitude"]]


@lru_cache(maxsize=1)
def derive_nearest_post_office_map() -> dict[int, int]:
    facility = load_facility_lookup()
    facility_type = load_facility_type_lookup()
    territory_geo = load_territory_geo()

    post_office_type_ids = set(
        facility_type.loc[
            facility_type["facility_type_name"].eq("Post Office") & facility_type["is_active"].eq(1),
            "facility_type_id",
        ].astype(int)
    )
    post_offices = facility.loc[facility["facility_type_id"].isin(post_office_type_ids)].copy()
    post_offices = post_offices.merge(
        territory_geo.rename(columns={"latitude": "facility_latitude", "longitude": "facility_longitude"}),
        on="territory_id",
        how="left",
        validate="many_to_one",
    )
    post_offices = post_offices.dropna(subset=["facility_latitude", "facility_longitude"]).copy()
    if post_offices.empty or territory_geo.empty:
        return {}

    facility_ids = post_offices["facility_id"].to_numpy(dtype=int)
    facility_lats = post_offices["facility_latitude"].to_numpy(dtype=float)
    facility_lons = post_offices["facility_longitude"].to_numpy(dtype=float)

    nearest: dict[int, int] = {}
    for row in territory_geo.itertuples(index=False):
        territory_id = int(row.territory_id)
        territory_lats = np.full(len(facility_lats), float(row.latitude))
        territory_lons = np.full(len(facility_lons), float(row.longitude))
        distances = haversine_miles(territory_lats, territory_lons, facility_lats, facility_lons)
        nearest[territory_id] = int(facility_ids[int(np.argmin(distances))])
    return nearest


def build_base_package_candidates() -> pd.DataFrame:
    orders, items, products, customers, category_translation = load_olist_inputs()
    customer_lookup = load_customer_lookup()

    translation_map = dict(
        zip(
            category_translation["product_category_name"].astype("string"),
            category_translation["product_category_name_english"].astype("string"),
        )
    )
    products = products.copy()
    products["translated_category_name"] = (
        products["product_category_name"].map(translation_map).fillna(products["product_category_name"]).fillna("Unknown")
    )

    item_counts = (
        items.groupby(["order_id", "seller_id", "product_id"], dropna=False, as_index=False)
        .agg(quantity=("order_item_id", "count"))
    )
    item_counts = item_counts.merge(products, on="product_id", how="left", validate="many_to_one")
    item_counts["line_weight_g"] = pd.to_numeric(item_counts["product_weight_g"], errors="coerce") * item_counts["quantity"]
    item_counts["line_height_cm"] = pd.to_numeric(item_counts["product_height_cm"], errors="coerce") * item_counts["quantity"]
    item_counts["product_length_cm"] = pd.to_numeric(item_counts["product_length_cm"], errors="coerce")
    item_counts["product_width_cm"] = pd.to_numeric(item_counts["product_width_cm"], errors="coerce")

    grouped = item_counts.groupby(["order_id", "seller_id"], dropna=False)
    package_items = grouped.agg(
        total_weight_g=("line_weight_g", lambda s: s.sum(min_count=1)),
        max_length_cm=("product_length_cm", "max"),
        max_width_cm=("product_width_cm", "max"),
        total_height_cm=("line_height_cm", lambda s: s.sum(min_count=1)),
        total_item_quantity=("quantity", "sum"),
        unique_product_count=("product_id", "nunique"),
    ).reset_index()
    contents = grouped["translated_category_name"].apply(build_contents).reset_index(name="contents")
    package_items = package_items.merge(contents, on=["order_id", "seller_id"], how="left", validate="one_to_one")

    orders = orders.merge(
        customers[["customer_id", "customer_unique_id"]],
        on="customer_id",
        how="left",
        validate="many_to_one",
    )

    frame = package_items.merge(
        orders[
            [
                "order_id",
                "customer_id",
                "customer_unique_id",
                "order_purchase_timestamp",
                "order_approved_at",
                "order_delivered_carrier_date",
                "order_delivered_customer_date",
                "order_estimated_delivery_date",
            ]
        ],
        on="order_id",
        how="left",
        validate="many_to_one",
    )
    frame = frame.merge(
        customer_lookup[
            [
                "customer_unique_id",
                "recipient_customer_id_hex",
                "first_name",
                "middle_initial",
                "last_name",
                "street_address",
                "city",
                "state_code",
                "zip_code",
                "resolved_territory_id",
            ]
        ],
        on="customer_unique_id",
        how="left",
        validate="many_to_one",
    )

    frame = frame.rename(
        columns={
            "order_id": "source_order_id",
            "seller_id": "source_seller_id",
            "customer_id": "olist_customer_id",
            "street_address": "recipient_street_address",
            "city": "recipient_city",
            "state_code": "recipient_state_code",
            "zip_code": "recipient_zip_code",
            "resolved_territory_id": "recipient_territory_id",
            "first_name": "recipient_first_name",
            "middle_initial": "recipient_middle_initial",
            "last_name": "recipient_last_name",
        }
    )

    frame["sender_business_id_hex"] = pd.Series([None] * len(frame), dtype="string")
    frame["weight_oz"] = frame["total_weight_g"] / GRAMS_PER_OUNCE
    frame["length_in"] = frame["max_length_cm"] / CM_PER_INCH
    frame["width_in"] = frame["max_width_cm"] / CM_PER_INCH
    frame["height_in"] = frame["total_height_cm"] / CM_PER_INCH
    frame["package_id_hex"] = frame.apply(
        lambda row: uuid.uuid5(
            PACKAGE_UUID_NAMESPACE,
            f"p2p-package:{row['source_order_id']}:{row['source_seller_id']}",
        ).hex,
        axis=1,
    )
    return frame


def assign_sender_customers(eligible: pd.DataFrame) -> pd.DataFrame:
    customer_lookup = load_customer_lookup()
    territory_geo = load_territory_geo()
    territory_geo_map = territory_geo.set_index("territory_id")[["latitude", "longitude"]]

    sender_pool = customer_lookup.loc[
        customer_lookup["customer_id"].astype("string").str.len().eq(32)
        & customer_lookup["resolved_territory_id"].notna()
    ].copy()
    sender_pool["resolved_territory_id"] = sender_pool["resolved_territory_id"].astype(int)

    sender_pool = sender_pool.loc[
        sender_pool["resolved_territory_id"].isin(territory_geo_map.index.astype(int))
    ].copy()
    if sender_pool.empty:
        result = eligible.copy()
        result["sender_customer_id_hex"] = pd.Series([None] * len(result), dtype="string")
        result["sender_customer_preferred_facility_id"] = pd.Series([pd.NA] * len(result), dtype="Int64")
        result["sender_street_address"] = pd.Series([None] * len(result), dtype="string")
        result["sender_city"] = pd.Series([None] * len(result), dtype="string")
        result["sender_state_code"] = pd.Series([None] * len(result), dtype="string")
        result["sender_zip_code"] = pd.Series([None] * len(result), dtype="string")
        result["sender_territory_id"] = pd.Series([pd.NA] * len(result), dtype="Int64")
        result["sender_recipient_distance_miles"] = np.nan
        result["sender_distance_band"] = pd.Series([None] * len(result), dtype="string")
        return result

    territory_records: dict[int, list[dict[str, Any]]] = {}
    territory_counts: dict[int, int] = {}
    sender_territories = []
    sender_counts = []
    sender_lats = []
    sender_lons = []

    for territory_id, group in sender_pool.groupby("resolved_territory_id", sort=False):
        territory_id_int = int(territory_id)
        if territory_id_int not in territory_geo_map.index:
            continue
        territory_records[territory_id_int] = group[
            [
                "customer_id",
                "preferred_facility_id",
                "street_address",
                "city",
                "state_code",
                "zip_code",
                "resolved_territory_id",
            ]
        ].to_dict("records")
        territory_counts[territory_id_int] = len(territory_records[territory_id_int])
        sender_territories.append(territory_id_int)
        sender_counts.append(len(territory_records[territory_id_int]))
        sender_lats.append(float(territory_geo_map.loc[territory_id_int, "latitude"]))
        sender_lons.append(float(territory_geo_map.loc[territory_id_int, "longitude"]))

    sender_territories_array = np.asarray(sender_territories, dtype=int)
    sender_counts_array = np.asarray(sender_counts, dtype=float)
    sender_lats_array = np.asarray(sender_lats, dtype=float)
    sender_lons_array = np.asarray(sender_lons, dtype=float)

    candidate_territories_by_recipient: dict[int, dict[str, dict[str, np.ndarray]]] = {}
    for territory_id in sorted(eligible["recipient_territory_id"].dropna().astype(int).unique()):
        if territory_id not in territory_geo_map.index:
            continue
        rec_lat = float(territory_geo_map.loc[territory_id, "latitude"])
        rec_lon = float(territory_geo_map.loc[territory_id, "longitude"])
        distances = haversine_miles(
            np.full(len(sender_territories_array), rec_lat),
            np.full(len(sender_territories_array), rec_lon),
            sender_lats_array,
            sender_lons_array,
        )
        band_payload: dict[str, dict[str, np.ndarray]] = {}
        for band_name, (lower, upper) in DISTANCE_BANDS.items():
            if upper is None:
                mask = distances >= lower
            else:
                mask = (distances >= lower) & (distances < upper)
            band_payload[band_name] = {
                "territory_ids": sender_territories_array[mask],
                "distances": distances[mask],
                "counts": sender_counts_array[mask],
            }
        candidate_territories_by_recipient[territory_id] = band_payload

    rng = np.random.default_rng(RANDOM_SEED)
    chosen_band_names = rng.choice(
        list(DISTANCE_BAND_WEIGHTS.keys()),
        size=len(eligible),
        p=list(DISTANCE_BAND_WEIGHTS.values()),
    )

    sender_ids: list[str | None] = []
    sender_pref_facilities: list[int | None] = []
    sender_addresses: list[str | None] = []
    sender_cities: list[str | None] = []
    sender_states: list[str | None] = []
    sender_zips: list[str | None] = []
    sender_territories_output: list[int | None] = []
    distance_values: list[float | None] = []
    distance_bands: list[str | None] = []

    for row, chosen_band_name in zip(eligible.itertuples(index=False), chosen_band_names, strict=False):
        recipient_id = str(row.recipient_customer_id_hex or "").lower()
        recipient_territory = int(row.recipient_territory_id) if pd.notna(row.recipient_territory_id) else None
        selected_sender: dict[str, Any] | None = None
        selected_distance: float | None = None
        selected_band: str | None = None

        if recipient_territory is not None and recipient_territory in candidate_territories_by_recipient:
            band_cache = candidate_territories_by_recipient[recipient_territory]
            for fallback_band in DISTANCE_BAND_FALLBACKS[str(chosen_band_name)]:
                territory_ids = band_cache[fallback_band]["territory_ids"]
                if len(territory_ids) == 0:
                    continue

                distances = band_cache[fallback_band]["distances"]
                counts = band_cache[fallback_band]["counts"]
                weights = counts * np.maximum(distances, 1.0)
                weights = weights / weights.sum()
                territory_order = rng.choice(
                    np.arange(len(territory_ids)),
                    size=len(territory_ids),
                    replace=False,
                    p=weights,
                )

                for idx in territory_order:
                    territory_id = int(territory_ids[idx])
                    candidates = territory_records.get(territory_id, [])
                    if not candidates:
                        continue
                    if territory_id == recipient_territory:
                        candidates = [candidate for candidate in candidates if str(candidate["customer_id"]).lower() != recipient_id]
                        if not candidates:
                            continue

                    selected_sender = candidates[int(rng.integers(0, len(candidates)))]
                    selected_distance = float(distances[idx])
                    selected_band = fallback_band
                    break
                if selected_sender is not None:
                    break

        if selected_sender is None:
            sender_ids.append(None)
            sender_pref_facilities.append(None)
            sender_addresses.append(None)
            sender_cities.append(None)
            sender_states.append(None)
            sender_zips.append(None)
            sender_territories_output.append(None)
            distance_values.append(None)
            distance_bands.append(None)
            continue

        sender_ids.append(str(selected_sender["customer_id"]).lower())
        sender_pref_facilities.append(
            int(selected_sender["preferred_facility_id"]) if pd.notna(selected_sender["preferred_facility_id"]) else None
        )
        sender_addresses.append(str(selected_sender["street_address"]).strip())
        sender_cities.append(str(selected_sender["city"]).strip())
        sender_states.append(str(selected_sender["state_code"]).strip())
        sender_zips.append(str(selected_sender["zip_code"]).strip())
        sender_territories_output.append(int(selected_sender["resolved_territory_id"]))
        distance_values.append(selected_distance)
        distance_bands.append(selected_band)

    result = eligible.copy()
    result["sender_customer_id_hex"] = pd.Series(sender_ids, index=result.index, dtype="string")
    result["sender_customer_preferred_facility_id"] = pd.Series(sender_pref_facilities, index=result.index, dtype="Int64")
    result["sender_street_address"] = pd.Series(sender_addresses, index=result.index, dtype="string")
    result["sender_city"] = pd.Series(sender_cities, index=result.index, dtype="string")
    result["sender_state_code"] = pd.Series(sender_states, index=result.index, dtype="string")
    result["sender_zip_code"] = pd.Series(sender_zips, index=result.index, dtype="string")
    result["sender_territory_id"] = pd.Series(sender_territories_output, index=result.index, dtype="Int64")
    result["sender_recipient_distance_miles"] = pd.to_numeric(pd.Series(distance_values, index=result.index), errors="coerce")
    result["sender_distance_band"] = pd.Series(distance_bands, index=result.index, dtype="string")
    return result


def assign_origin_facilities(frame: pd.DataFrame) -> pd.DataFrame:
    facility = load_facility_lookup()
    facility_type = load_facility_type_lookup()
    nearest_post_office_map = derive_nearest_post_office_map()

    post_office_type_ids = set(
        facility_type.loc[
            facility_type["facility_type_name"].eq("Post Office") & facility_type["is_active"].eq(1),
            "facility_type_id",
        ].astype(int)
    )
    post_office_facility_ids = set(
        facility.loc[facility["facility_type_id"].isin(post_office_type_ids), "facility_id"].astype(int)
    )

    origin_facility_ids: list[int | None] = []
    for row in frame.itertuples(index=False):
        preferred_facility_id = int(row.sender_customer_preferred_facility_id) if pd.notna(row.sender_customer_preferred_facility_id) else None
        sender_territory_id = int(row.sender_territory_id) if pd.notna(row.sender_territory_id) else None

        if preferred_facility_id is not None and preferred_facility_id in post_office_facility_ids:
            origin_facility_ids.append(preferred_facility_id)
            continue
        origin_facility_ids.append(nearest_post_office_map.get(sender_territory_id))

    result = frame.copy()
    result["origin_facility_id"] = pd.Series(origin_facility_ids, index=result.index, dtype="Int64")
    return result


def apply_service_type_and_timestamps(frame: pd.DataFrame) -> pd.DataFrame:
    lookup_maps = resolve_lookup_maps()
    rng = np.random.default_rng(RANDOM_SEED)

    service_names = rng.choice(
        list(SERVICE_TYPE_DISTRIBUTION.keys()),
        size=len(frame),
        p=list(SERVICE_TYPE_DISTRIBUTION.values()),
    )
    base_jitter_minutes = rng.integers(0, 181, size=len(frame))
    sorted_offsets = rng.integers(5, 91, size=len(frame))
    departed_offsets = rng.integers(60, 2161, size=len(frame))

    result = frame.copy()
    result["service_type_name"] = pd.Series(service_names, index=result.index, dtype="string")
    result["service_type_id"] = result["service_type_name"].map(lookup_maps["service_type"])

    raw_purchase = pd.to_datetime(result["order_purchase_timestamp"], errors="coerce")
    raw_approved = pd.to_datetime(result["order_approved_at"], errors="coerce")
    raw_departed = pd.to_datetime(result["order_delivered_carrier_date"], errors="coerce")

    origin_received = raw_purchase + pd.to_timedelta(base_jitter_minutes, unit="m")
    approved_base = raw_approved + pd.to_timedelta(base_jitter_minutes, unit="m")
    departed_base = raw_departed + pd.to_timedelta(base_jitter_minutes, unit="m")

    origin_sorted = pd.Series(index=result.index, dtype="datetime64[ns]")
    origin_departed = pd.Series(index=result.index, dtype="datetime64[ns]")
    for idx in result.index:
        received_at = origin_received.loc[idx]
        sorted_at = max(
            approved_base.loc[idx].to_pydatetime(),
            (received_at + pd.Timedelta(minutes=int(sorted_offsets[result.index.get_loc(idx)]))).to_pydatetime(),
        )
        departed_at = max(
            departed_base.loc[idx].to_pydatetime(),
            (pd.Timestamp(sorted_at) + pd.Timedelta(minutes=int(departed_offsets[result.index.get_loc(idx)]))).to_pydatetime(),
        )
        origin_sorted.loc[idx] = pd.Timestamp(sorted_at)
        origin_departed.loc[idx] = pd.Timestamp(departed_at)

    raw_timestamp_anomaly = (
        raw_approved.lt(raw_purchase)
        | raw_departed.lt(raw_approved)
        | raw_departed.lt(raw_purchase)
    ).fillna(False)

    result["package_flow_type_name"] = "P2P"
    result["package_flow_type_id"] = lookup_maps["package_flow_type"]["P2P"]
    result["origin_received_timestamp"] = origin_received
    result["origin_sorted_timestamp"] = origin_sorted
    result["origin_departed_timestamp"] = origin_departed
    result["timestamp_jitter_minutes"] = pd.Series(base_jitter_minutes, index=result.index, dtype="Int64")
    result["raw_timestamp_anomaly_flag"] = raw_timestamp_anomaly.astype(bool)
    result["initial_status_name"] = "In Transit"
    result["initial_package_status_id"] = lookup_maps["package_status"]["In Transit"]
    result["received_date"] = result["origin_received_timestamp"]
    return result


def count_current_b2c_package_rows() -> int | None:
    try:
        lookup_maps = resolve_lookup_maps()
        b2c_flow_type_id = lookup_maps["package_flow_type"]["B2C"]
        text = read_zip_entry_text("PostIngestionB2C/postal_bi_system_package.sql")
        rows = parse_values_clause(extract_insert_values_sql_from_text(text, "package"))
        return int(sum(1 for row in rows if len(row) > 13 and row[13] == b2c_flow_type_id))
    except Exception:
        return None


def determine_target_package_count(
    *,
    target_p2p_final_share: float,
    target_p2p_package_count: int | None,
) -> tuple[int | None, int | None]:
    if target_p2p_package_count is not None:
        return int(target_p2p_package_count), count_current_b2c_package_rows()

    b2c_count = count_current_b2c_package_rows()
    if b2c_count is None:
        return None, None

    raw_target = (target_p2p_final_share / (1.0 - target_p2p_final_share)) * b2c_count
    return int(round(raw_target)), b2c_count


def build_package_candidates(
    *,
    target_p2p_final_share: float,
    target_p2p_package_count: int | None,
) -> tuple[pd.DataFrame, dict[str, Any]]:
    base = build_base_package_candidates()
    target_count, current_b2c_count = determine_target_package_count(
        target_p2p_final_share=target_p2p_final_share,
        target_p2p_package_count=target_p2p_package_count,
    )

    recipient_missing = base["recipient_customer_id_hex"].isna() | base["recipient_customer_id_hex"].astype("string").str.len().ne(32)
    recipient_territory_missing = base["recipient_territory_id"].isna()
    raw_purchase = pd.to_datetime(base["order_purchase_timestamp"], errors="coerce")
    raw_approved = pd.to_datetime(base["order_approved_at"], errors="coerce")
    raw_departed = pd.to_datetime(base["order_delivered_carrier_date"], errors="coerce")
    incomplete_timeline = raw_purchase.isna() | raw_approved.isna() | raw_departed.isna()
    raw_timestamp_anomaly = (
        raw_approved.lt(raw_purchase)
        | raw_departed.lt(raw_approved)
        | raw_departed.lt(raw_purchase)
    ).fillna(False)

    numeric_metrics = base[["weight_oz", "length_in", "width_in", "height_in"]].apply(pd.to_numeric, errors="coerce")
    rounded_metrics = numeric_metrics.round(4)
    invalid_dimensions = (
        numeric_metrics.le(0).any(axis=1)
        | numeric_metrics.isna().any(axis=1)
        | rounded_metrics.le(0).any(axis=1)
    )
    extreme_dimensions = (
        (numeric_metrics["weight_oz"] > EXTREME_WEIGHT_OZ)
        | (numeric_metrics["length_in"] > EXTREME_LENGTH_IN)
        | (numeric_metrics["width_in"] > EXTREME_WIDTH_IN)
        | (numeric_metrics["height_in"] > EXTREME_HEIGHT_IN)
    )

    eligible = base.loc[~recipient_missing & ~recipient_territory_missing & ~invalid_dimensions & ~extreme_dimensions & ~incomplete_timeline].copy()
    eligible = assign_sender_customers(eligible)
    eligible = assign_origin_facilities(eligible)
    eligible = apply_service_type_and_timestamps(eligible)

    sender_missing = eligible["sender_customer_id_hex"].isna() | eligible["sender_customer_id_hex"].astype("string").str.len().ne(32)
    sender_equals_recipient = eligible["sender_customer_id_hex"].astype("string").str.lower().eq(
        eligible["recipient_customer_id_hex"].astype("string").str.lower()
    )
    missing_origin = eligible["origin_facility_id"].isna()
    sender_territory_missing = eligible["sender_territory_id"].isna()

    eligible["quarantine_reason"] = ""
    eligible.loc[sender_missing, "quarantine_reason"] = eligible["quarantine_reason"] + "missing_synthetic_sender_customer_id;"
    eligible.loc[sender_equals_recipient, "quarantine_reason"] = eligible["quarantine_reason"] + "sender_equals_recipient;"
    eligible.loc[sender_territory_missing, "quarantine_reason"] = eligible["quarantine_reason"] + "missing_sender_territory_id;"
    eligible.loc[missing_origin, "quarantine_reason"] = eligible["quarantine_reason"] + "missing_origin_post_office_facility_id;"
    eligible["quarantine_reason"] = eligible["quarantine_reason"].str.strip(";")

    ready = eligible.loc[eligible["quarantine_reason"].eq("")].copy()
    ready = ready.sort_values(
        ["origin_received_timestamp", "source_order_id", "source_seller_id", "sender_recipient_distance_miles"],
        ascending=[True, True, True, False],
        kind="mergesort",
    ).reset_index(drop=True)

    selected_target_count = len(ready) if target_count is None else min(int(target_count), len(ready))
    selected_stage = ready.head(selected_target_count).copy()
    overflow = ready.iloc[selected_target_count:].copy()
    if not overflow.empty:
        overflow["quarantine_reason"] = "excluded_above_target_package_count"

    selected_stage["weight_oz"] = selected_stage["weight_oz"].round(4)
    selected_stage["length_in"] = selected_stage["length_in"].round(4)
    selected_stage["width_in"] = selected_stage["width_in"].round(4)
    selected_stage["height_in"] = selected_stage["height_in"].round(4)
    selected_stage["sender_recipient_distance_miles"] = selected_stage["sender_recipient_distance_miles"].round(2)

    selected_stage["received_date"] = format_timestamp(selected_stage["received_date"])
    selected_stage["origin_received_timestamp"] = format_timestamp(selected_stage["origin_received_timestamp"])
    selected_stage["origin_sorted_timestamp"] = format_timestamp(selected_stage["origin_sorted_timestamp"])
    selected_stage["origin_departed_timestamp"] = format_timestamp(selected_stage["origin_departed_timestamp"])

    quarantine_rows: list[pd.DataFrame] = []

    early_quarantine = base.copy()
    early_quarantine["quarantine_reason"] = ""
    early_quarantine.loc[recipient_missing, "quarantine_reason"] = early_quarantine["quarantine_reason"] + "missing_recipient_customer_mapping;"
    early_quarantine.loc[recipient_territory_missing, "quarantine_reason"] = early_quarantine["quarantine_reason"] + "missing_recipient_territory_id;"
    early_quarantine.loc[invalid_dimensions, "quarantine_reason"] = early_quarantine["quarantine_reason"] + "invalid_dimensions_or_weight;"
    early_quarantine.loc[extreme_dimensions, "quarantine_reason"] = early_quarantine["quarantine_reason"] + "extreme_dimensions_flagged_for_review;"
    early_quarantine.loc[incomplete_timeline, "quarantine_reason"] = early_quarantine["quarantine_reason"] + "excluded_first_pass_incomplete_origin_timeline;"
    early_quarantine["quarantine_reason"] = early_quarantine["quarantine_reason"].str.strip(";")
    early_quarantine = early_quarantine.loc[early_quarantine["quarantine_reason"].ne("")].copy()

    quarantine_rows.append(early_quarantine)
    quarantine_rows.append(eligible.loc[eligible["quarantine_reason"].ne("")].copy())
    quarantine_rows.append(overflow)

    quarantine = pd.concat(quarantine_rows, ignore_index=True, sort=False)
    if not quarantine.empty:
        for column in [
            "received_date",
            "origin_received_timestamp",
            "origin_sorted_timestamp",
            "origin_departed_timestamp",
            "order_purchase_timestamp",
            "order_approved_at",
            "order_delivered_carrier_date",
        ]:
            if column in quarantine.columns:
                quarantine[column] = format_timestamp(quarantine[column])
        quarantine["sender_recipient_distance_miles"] = pd.to_numeric(
            quarantine.get("sender_recipient_distance_miles"), errors="coerce"
        ).round(2)

    metadata = {
        "target_p2p_final_share": target_p2p_final_share,
        "target_p2p_package_count_requested": target_p2p_package_count,
        "calculated_p2p_package_count": target_count,
        "current_b2c_package_count": current_b2c_count,
        "selected_p2p_package_count": selected_target_count,
        "raw_timestamp_anomaly_count": int(raw_timestamp_anomaly.sum()),
    }
    return selected_stage, {"quarantine": quarantine, "metadata": metadata}


def build_shippingdetails_stage(staged_packages: pd.DataFrame) -> pd.DataFrame:
    def build_address(street: Any, city: Any, state_code: Any, zip_code: Any) -> str:
        parts = [
            str(street or "").strip(),
            str(city or "").strip(),
            f"{str(state_code or '').strip()} {str(zip_code or '').strip()}".strip(),
        ]
        return ", ".join(part for part in parts if part).strip(", ")

    return pd.DataFrame(
        {
            "package_id_hex": staged_packages["package_id_hex"],
            "recipient_address": staged_packages.apply(
                lambda row: build_address(
                    row["recipient_street_address"],
                    row["recipient_city"],
                    row["recipient_state_code"],
                    row["recipient_zip_code"],
                ),
                axis=1,
            ),
            "recipient_territory_id": staged_packages["recipient_territory_id"],
            "sender_address": staged_packages.apply(
                lambda row: build_address(
                    row["sender_street_address"],
                    row["sender_city"],
                    row["sender_state_code"],
                    row["sender_zip_code"],
                ),
                axis=1,
            ),
            "sender_territory_id": staged_packages["sender_territory_id"],
            "estimated_delivery_distance": staged_packages["sender_recipient_distance_miles"].round(2),
            "recipient_first_name": staged_packages["recipient_first_name"],
            "recipient_middle_initial": staged_packages["recipient_middle_initial"],
            "recipient_last_name": staged_packages["recipient_last_name"],
            "expected_delivery_date": pd.Series([None] * len(staged_packages), dtype="object"),
            "delivered_date": pd.Series([None] * len(staged_packages), dtype="object"),
        }
    )


def build_movement_stage(staged_packages: pd.DataFrame) -> pd.DataFrame:
    lookup_maps = resolve_lookup_maps()
    movement_rows: list[dict[str, Any]] = []
    for package in staged_packages.to_dict("records"):
        for event_type_name, timestamp_column, status_name, uses_from_facility in FACILITY_EVENT_CONFIG:
            movement_rows.append(
                {
                    "package_id_hex": package["package_id_hex"],
                    "event_type_name": event_type_name,
                    "package_movement_event_type_id": lookup_maps["movement_event_type"][event_type_name],
                    "package_status_name": status_name,
                    "package_status_id": lookup_maps["package_status"][status_name],
                    "facility_id": package["origin_facility_id"],
                    "from_facility_id": package["origin_facility_id"] if uses_from_facility else None,
                    "to_facility_id": None,
                    "processed_by_employee_id": None,
                    "event_timestamp": package[timestamp_column],
                    "expected_event_at": None,
                    "delay_minutes": 0,
                    "delay_reason": None,
                    "movement_note": f"P2P origin lifecycle: {event_type_name}",
                }
            )
    movement = pd.DataFrame(movement_rows)
    movement = movement.sort_values(
        ["package_id_hex", "event_timestamp", "package_movement_event_type_id"],
        kind="mergesort",
    ).reset_index(drop=True)
    return movement


def stage_package_columns(staged_packages: pd.DataFrame) -> pd.DataFrame:
    columns = [
        "package_id_hex",
        "source_order_id",
        "source_seller_id",
        "olist_customer_id",
        "recipient_customer_id_hex",
        "sender_customer_id_hex",
        "sender_business_id_hex",
        "package_flow_type_id",
        "package_flow_type_name",
        "service_type_id",
        "service_type_name",
        "initial_package_status_id",
        "initial_status_name",
        "received_date",
        "contents",
        "weight_oz",
        "length_in",
        "width_in",
        "height_in",
        "origin_facility_id",
        "origin_received_timestamp",
        "origin_sorted_timestamp",
        "origin_departed_timestamp",
        "sender_recipient_distance_miles",
        "sender_distance_band",
        "timestamp_jitter_minutes",
    ]
    return staged_packages[columns].copy()


def quarantine_columns(quarantine: pd.DataFrame) -> pd.DataFrame:
    desired = [
        "package_id_hex",
        "source_order_id",
        "source_seller_id",
        "olist_customer_id",
        "customer_unique_id",
        "recipient_customer_id_hex",
        "sender_customer_id_hex",
        "sender_business_id_hex",
        "recipient_territory_id",
        "sender_territory_id",
        "contents",
        "weight_oz",
        "length_in",
        "width_in",
        "height_in",
        "origin_facility_id",
        "sender_recipient_distance_miles",
        "sender_distance_band",
        "quarantine_reason",
    ]
    available = [column for column in desired if column in quarantine.columns]
    return quarantine[available].copy()


def write_csv(frame: pd.DataFrame, path: Path) -> None:
    frame.to_csv(path, index=False, lineterminator="\n")


def build_validation_frames(
    package_stage: pd.DataFrame,
    movement_stage: pd.DataFrame,
    quarantine: pd.DataFrame,
    raw_timestamp_anomaly_count: int,
) -> dict[str, pd.DataFrame]:
    quarantine_reason_series = quarantine.get("quarantine_reason", pd.Series(dtype="string")).fillna("")

    def count_matches(fragment: str) -> int:
        if quarantine.empty:
            return 0
        return int(quarantine_reason_series.str.contains(fragment, regex=False).sum())

    return {
        "packages_by_service_type": package_stage["service_type_name"].value_counts(dropna=False).rename_axis("service_type_name").reset_index(name="package_count"),
        "packages_by_initial_status": package_stage["initial_status_name"].value_counts(dropna=False).rename_axis("initial_status_name").reset_index(name="package_count"),
        "packages_by_origin_facility": package_stage["origin_facility_id"].value_counts(dropna=False).rename_axis("origin_facility_id").reset_index(name="package_count"),
        "packages_by_distance_band": package_stage["sender_distance_band"].value_counts(dropna=False).rename_axis("sender_distance_band").reset_index(name="package_count"),
        "movement_events_by_type": movement_stage["event_type_name"].value_counts(dropna=False).rename_axis("event_type_name").reset_index(name="event_count"),
        "quarantine_summary": pd.DataFrame(
            {
                "metric": [
                    "missing recipient customer mappings",
                    "missing synthetic sender customer IDs",
                    "sender equals recipient violations",
                    "missing origin Post Office facility IDs",
                    "invalid dimensions",
                    "extreme dimensions flagged for review",
                    "invalid or out-of-order timestamps",
                    "excluded incomplete timelines for first pass",
                    "excluded above target package count",
                ],
                "count": [
                    count_matches("missing_recipient_customer_mapping"),
                    count_matches("missing_synthetic_sender_customer_id"),
                    count_matches("sender_equals_recipient"),
                    count_matches("missing_origin_post_office_facility_id"),
                    count_matches("invalid_dimensions_or_weight"),
                    count_matches("extreme_dimensions_flagged_for_review"),
                    int(raw_timestamp_anomaly_count),
                    count_matches("excluded_first_pass_incomplete_origin_timeline"),
                    count_matches("excluded_above_target_package_count"),
                ],
            }
        ),
    }


def build_summary(
    package_stage: pd.DataFrame,
    movement_stage: pd.DataFrame,
    quarantine: pd.DataFrame,
    metadata: dict[str, Any],
) -> dict[str, Any]:
    avg_distance = float(package_stage["sender_recipient_distance_miles"].mean()) if not package_stage.empty else 0.0
    return {
        "target_p2p_final_share": metadata["target_p2p_final_share"],
        "current_b2c_package_count": metadata["current_b2c_package_count"],
        "calculated_p2p_package_count": metadata["calculated_p2p_package_count"],
        "total_staged_p2p_packages": int(len(package_stage)),
        "quarantined_packages": int(len(quarantine)),
        "average_sender_recipient_distance_miles": round(avg_distance, 2),
        "invalid_or_out_of_order_timestamps": int(metadata["raw_timestamp_anomaly_count"]),
        "generated_movement_events": int(len(movement_stage)),
        "packages_eligible_for_later_middle_mile_simulation": int(len(package_stage)),
    }


def print_validation_report(result: PipelineResult) -> None:
    print("\nP2P Olist origin ingestion validation summary")
    print("=" * 48)
    for key, value in result.summary.items():
        print(f"{key}: {value}")

    print("\nPackages by service type")
    print(result.validation_frames["packages_by_service_type"].to_string(index=False))

    print("\nPackages by initial status")
    print(result.validation_frames["packages_by_initial_status"].to_string(index=False))

    print("\nPackages by origin facility")
    print(result.validation_frames["packages_by_origin_facility"].head(20).to_string(index=False))

    print("\nPackages by sender-recipient distance band")
    print(result.validation_frames["packages_by_distance_band"].to_string(index=False))

    print("\nQuarantine summary")
    print(result.validation_frames["quarantine_summary"].to_string(index=False))

    print("\nGenerated movement events by type")
    print(result.validation_frames["movement_events_by_type"].to_string(index=False))


def output_sql_path(path: Path) -> str:
    return str(path.resolve()).replace("\\", "/")


def build_load_sql() -> str:
    package_csv = output_sql_path(STG_PACKAGE_CSV)
    shipping_csv = output_sql_path(STG_SHIPPINGDETAILS_CSV)
    movement_csv = output_sql_path(STG_MOVEMENT_CSV)
    return f"""USE `postal_bi_system`;

DROP VIEW IF EXISTS `vw_p2p_packages_ready_for_middle_mile`;

DROP TABLE IF EXISTS `staging_p2p_origin_movement`;
DROP TABLE IF EXISTS `staging_p2p_shippingdetails`;
DROP TABLE IF EXISTS `staging_p2p_package`;

CREATE TABLE `staging_p2p_package` (
    `package_id_hex` CHAR(32) NOT NULL,
    `source_order_id` CHAR(32) NOT NULL,
    `source_seller_id` CHAR(32) NOT NULL,
    `olist_customer_id` CHAR(32) NOT NULL,
    `recipient_customer_id_hex` CHAR(32) NOT NULL,
    `sender_customer_id_hex` CHAR(32) NOT NULL,
    `sender_business_id_hex` CHAR(32) NULL,
    `package_flow_type_id` INT NOT NULL,
    `package_flow_type_name` VARCHAR(30) NOT NULL,
    `service_type_id` INT NOT NULL,
    `service_type_name` VARCHAR(30) NOT NULL,
    `initial_package_status_id` INT NOT NULL,
    `initial_status_name` VARCHAR(30) NOT NULL,
    `received_date` DATETIME NOT NULL,
    `contents` VARCHAR(255) NULL,
    `weight_oz` DECIMAL(10,4) NOT NULL,
    `length_in` DECIMAL(10,4) NOT NULL,
    `width_in` DECIMAL(10,4) NOT NULL,
    `height_in` DECIMAL(10,4) NOT NULL,
    `origin_facility_id` INT NOT NULL,
    `origin_received_timestamp` DATETIME NOT NULL,
    `origin_sorted_timestamp` DATETIME NOT NULL,
    `origin_departed_timestamp` DATETIME NOT NULL,
    `sender_recipient_distance_miles` DECIMAL(10,2) NULL,
    `sender_distance_band` VARCHAR(40) NULL,
    `timestamp_jitter_minutes` INT NULL,
    PRIMARY KEY (`package_id_hex`),
    KEY `idx_staging_p2p_package_seed` (`source_order_id`, `source_seller_id`)
);

LOAD DATA LOCAL INFILE '{package_csv}'
INTO TABLE `staging_p2p_package`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '"'
LINES TERMINATED BY '\\n'
IGNORE 1 LINES
(
    `package_id_hex`,
    `source_order_id`,
    `source_seller_id`,
    `olist_customer_id`,
    `recipient_customer_id_hex`,
    `sender_customer_id_hex`,
    @sender_business_id_hex,
    `package_flow_type_id`,
    `package_flow_type_name`,
    `service_type_id`,
    `service_type_name`,
    `initial_package_status_id`,
    `initial_status_name`,
    `received_date`,
    `contents`,
    `weight_oz`,
    `length_in`,
    `width_in`,
    `height_in`,
    `origin_facility_id`,
    `origin_received_timestamp`,
    `origin_sorted_timestamp`,
    `origin_departed_timestamp`,
    @sender_recipient_distance_miles,
    @sender_distance_band,
    @timestamp_jitter_minutes
)
SET
    `sender_business_id_hex` = NULLIF(@sender_business_id_hex, ''),
    `sender_recipient_distance_miles` = NULLIF(@sender_recipient_distance_miles, ''),
    `sender_distance_band` = NULLIF(@sender_distance_band, ''),
    `timestamp_jitter_minutes` = NULLIF(@timestamp_jitter_minutes, '');

INSERT INTO `package` (
    `package_id`,
    `package_status_id`,
    `service_type_id`,
    `received_date`,
    `contents`,
    `weight_oz`,
    `length_in`,
    `width_in`,
    `height_in`,
    `employee_id`,
    `recipient_customer_id`,
    `package_flow_type_id`,
    `sender_customer_id`,
    `sender_business_id`
)
SELECT
    UNHEX(`package_id_hex`),
    `initial_package_status_id`,
    `service_type_id`,
    `origin_received_timestamp`,
    LEFT(COALESCE(NULLIF(`contents`, ''), 'Unknown'), 30),
    ROUND(`weight_oz`, 2),
    ROUND(`length_in`, 2),
    ROUND(`width_in`, 2),
    ROUND(`height_in`, 2),
    NULL,
    UNHEX(`recipient_customer_id_hex`),
    `package_flow_type_id`,
    UNHEX(`sender_customer_id_hex`),
    NULL
FROM `staging_p2p_package`
ORDER BY `source_order_id`, `source_seller_id`;

CREATE TABLE `staging_p2p_shippingdetails` (
    `package_id_hex` CHAR(32) NOT NULL,
    `recipient_address` VARCHAR(150) NOT NULL,
    `recipient_territory_id` INT NOT NULL,
    `sender_address` VARCHAR(150) NOT NULL,
    `sender_territory_id` INT NOT NULL,
    `estimated_delivery_distance` VARCHAR(30) NULL,
    `recipient_first_name` VARCHAR(50) NULL,
    `recipient_middle_initial` CHAR(1) NULL,
    `recipient_last_name` VARCHAR(50) NULL,
    `expected_delivery_date` VARCHAR(30) NULL,
    `delivered_date` VARCHAR(30) NULL,
    PRIMARY KEY (`package_id_hex`)
);

LOAD DATA LOCAL INFILE '{shipping_csv}'
INTO TABLE `staging_p2p_shippingdetails`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '"'
LINES TERMINATED BY '\\n'
IGNORE 1 LINES
(
    `package_id_hex`,
    `recipient_address`,
    `recipient_territory_id`,
    `sender_address`,
    `sender_territory_id`,
    @estimated_delivery_distance,
    `recipient_first_name`,
    `recipient_middle_initial`,
    `recipient_last_name`,
    @expected_delivery_date,
    @delivered_date
)
SET
    `estimated_delivery_distance` = NULLIF(@estimated_delivery_distance, ''),
    `expected_delivery_date` = NULLIF(@expected_delivery_date, ''),
    `delivered_date` = NULLIF(@delivered_date, '');

INSERT INTO `shippingdetails` (
    `package_id`,
    `recipient_address`,
    `recipient_territory_id`,
    `sender_address`,
    `sender_territory_id`,
    `estimated_delivery_distance`,
    `recipient_first_name`,
    `recipient_middle_initial`,
    `recipient_last_name`,
    `expected_delivery_date`,
    `delivered_date`
)
SELECT
    UNHEX(`package_id_hex`),
    `recipient_address`,
    `recipient_territory_id`,
    `sender_address`,
    `sender_territory_id`,
    `estimated_delivery_distance`,
    `recipient_first_name`,
    NULLIF(`recipient_middle_initial`, ''),
    `recipient_last_name`,
    `expected_delivery_date`,
    `delivered_date`
FROM `staging_p2p_shippingdetails`
ORDER BY `package_id_hex`;

CREATE TABLE `staging_p2p_origin_movement` (
    `package_id_hex` CHAR(32) NOT NULL,
    `event_type_name` VARCHAR(80) NOT NULL,
    `package_movement_event_type_id` INT NOT NULL,
    `package_status_name` VARCHAR(30) NOT NULL,
    `package_status_id` INT NOT NULL,
    `facility_id` INT NOT NULL,
    `from_facility_id` INT NULL,
    `to_facility_id` INT NULL,
    `processed_by_employee_id` INT NULL,
    `event_timestamp` DATETIME NOT NULL,
    `expected_event_at` DATETIME NULL,
    `delay_minutes` INT NOT NULL,
    `delay_reason` VARCHAR(255) NULL,
    `movement_note` VARCHAR(500) NULL,
    KEY `idx_staging_p2p_origin_movement_ordering` (`package_id_hex`, `event_timestamp`)
);

LOAD DATA LOCAL INFILE '{movement_csv}'
INTO TABLE `staging_p2p_origin_movement`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '"'
LINES TERMINATED BY '\\n'
IGNORE 1 LINES
(
    `package_id_hex`,
    `event_type_name`,
    `package_movement_event_type_id`,
    `package_status_name`,
    `package_status_id`,
    `facility_id`,
    @from_facility_id,
    @to_facility_id,
    @processed_by_employee_id,
    `event_timestamp`,
    @expected_event_at,
    `delay_minutes`,
    @delay_reason,
    @movement_note
)
SET
    `from_facility_id` = NULLIF(@from_facility_id, ''),
    `to_facility_id` = NULLIF(@to_facility_id, ''),
    `processed_by_employee_id` = NULLIF(@processed_by_employee_id, ''),
    `expected_event_at` = NULLIF(@expected_event_at, ''),
    `delay_reason` = NULLIF(@delay_reason, ''),
    `movement_note` = NULLIF(@movement_note, '');

INSERT INTO `package_movement` (
    `package_id`,
    `package_movement_event_type_id`,
    `package_status_id`,
    `facility_id`,
    `from_facility_id`,
    `to_facility_id`,
    `processed_by_employee_id`,
    `event_timestamp`,
    `expected_event_at`,
    `delay_minutes`,
    `delay_reason`,
    `movement_note`
)
SELECT
    UNHEX(`package_id_hex`),
    `package_movement_event_type_id`,
    `package_status_id`,
    `facility_id`,
    `from_facility_id`,
    `to_facility_id`,
    `processed_by_employee_id`,
    `event_timestamp`,
    `expected_event_at`,
    `delay_minutes`,
    `delay_reason`,
    `movement_note`
FROM `staging_p2p_origin_movement`
ORDER BY `package_id_hex`, `event_timestamp`, `package_movement_event_type_id`;

CREATE VIEW `vw_p2p_packages_ready_for_middle_mile` AS
WITH latest_movement AS (
    SELECT
        pm.`package_id`,
        pm.`facility_id`,
        pm.`event_timestamp`,
        pm.`package_status_id`,
        met.`event_type_name`,
        ROW_NUMBER() OVER (
            PARTITION BY pm.`package_id`
            ORDER BY pm.`event_timestamp` DESC, pm.`package_movement_id` DESC
        ) AS `rn`
    FROM `package_movement` pm
    JOIN `package_movement_event_type` met
      ON met.`package_movement_event_type_id` = pm.`package_movement_event_type_id`
)
SELECT
    p.`package_id`,
    st.`service_type_name` AS `service_type`,
    p.`sender_customer_id`,
    p.`recipient_customer_id`,
    sd.`sender_territory_id`,
    sd.`recipient_territory_id`,
    lm.`facility_id` AS `current_or_origin_facility_id`,
    lm.`event_timestamp` AS `latest_movement_timestamp`,
    p.`weight_oz`,
    p.`length_in`,
    p.`width_in`,
    p.`height_in`,
    sd.`estimated_delivery_distance`
FROM `package` p
JOIN `package_flow_type` pft
  ON pft.`package_flow_type_id` = p.`package_flow_type_id`
LEFT JOIN `service_type` st
  ON st.`service_type_id` = p.`service_type_id`
LEFT JOIN `shippingdetails` sd
  ON sd.`package_id` = p.`package_id`
LEFT JOIN latest_movement lm
  ON lm.`package_id` = p.`package_id`
 AND lm.`rn` = 1
LEFT JOIN `package_status` ps
  ON ps.`package_status_id` = p.`package_status_id`
WHERE pft.`package_flow_type_name` = 'P2P'
  AND (
      lm.`event_type_name` = 'Departed Facility'
      OR ps.`status_name` = 'In Transit'
  );

-- Validation queries

SELECT COUNT(*) AS inserted_p2p_packages
FROM `package` p
JOIN `staging_p2p_package` spp
  ON spp.`package_id_hex` = HEX(p.`package_id`)
JOIN `package_flow_type` pft
  ON pft.`package_flow_type_id` = p.`package_flow_type_id`
WHERE pft.`package_flow_type_name` = 'P2P';

SELECT COUNT(*) AS inserted_p2p_shippingdetails_rows
FROM `shippingdetails` sd
JOIN `staging_p2p_shippingdetails` ssd
  ON ssd.`package_id_hex` = HEX(sd.`package_id`);

SELECT COUNT(*) AS inserted_p2p_movement_rows
FROM `package_movement` pm
JOIN `staging_p2p_origin_movement` sm
  ON sm.`package_id_hex` = HEX(pm.`package_id`)
 AND sm.`event_timestamp` = pm.`event_timestamp`
 AND sm.`package_movement_event_type_id` = pm.`package_movement_event_type_id`;

SELECT
    spp.`package_id_hex`,
    spp.`source_order_id`,
    spp.`source_seller_id`
FROM `staging_p2p_package` spp
LEFT JOIN `shippingdetails` sd
  ON sd.`package_id` = UNHEX(spp.`package_id_hex`)
WHERE sd.`package_id` IS NULL;

SELECT
    spp.`package_id_hex`,
    spp.`source_order_id`,
    spp.`source_seller_id`
FROM `staging_p2p_package` spp
LEFT JOIN `package_movement` pm
  ON pm.`package_id` = UNHEX(spp.`package_id_hex`)
WHERE pm.`package_id` IS NULL;

SELECT
    HEX(p.`package_id`) AS `package_id_hex`
FROM `package` p
JOIN `staging_p2p_package` spp
  ON spp.`package_id_hex` = HEX(p.`package_id`)
WHERE p.`sender_customer_id` IS NULL;

SELECT
    HEX(p.`package_id`) AS `package_id_hex`
FROM `package` p
JOIN `staging_p2p_package` spp
  ON spp.`package_id_hex` = HEX(p.`package_id`)
WHERE p.`sender_business_id` IS NOT NULL;

SELECT
    HEX(p.`package_id`) AS `package_id_hex`
FROM `package` p
JOIN `staging_p2p_package` spp
  ON spp.`package_id_hex` = HEX(p.`package_id`)
WHERE p.`sender_customer_id` = p.`recipient_customer_id`;

WITH latest_movement AS (
    SELECT
        pm.`package_id`,
        pm.`package_status_id`,
        ROW_NUMBER() OVER (
            PARTITION BY pm.`package_id`
            ORDER BY pm.`event_timestamp` DESC, pm.`package_movement_id` DESC
        ) AS `rn`
    FROM `package_movement` pm
)
SELECT
    HEX(p.`package_id`) AS `package_id_hex`,
    p.`package_status_id` AS `current_package_status_id`,
    lm.`package_status_id` AS `latest_movement_status_id`
FROM `package` p
JOIN `staging_p2p_package` spp
  ON spp.`package_id_hex` = HEX(p.`package_id`)
LEFT JOIN latest_movement lm
  ON lm.`package_id` = p.`package_id`
 AND lm.`rn` = 1
WHERE lm.`package_status_id` IS NOT NULL
  AND p.`package_status_id` <> lm.`package_status_id`;

SELECT
    spp.`package_id_hex`,
    spp.`origin_facility_id`,
    f.`facility_name`,
    ft.`facility_type_name`
FROM `staging_p2p_package` spp
LEFT JOIN `facility` f
  ON f.`facility_id` = spp.`origin_facility_id`
LEFT JOIN `facility_type` ft
  ON ft.`facility_type_id` = f.`facility_type_id`
WHERE COALESCE(ft.`facility_type_name`, '') <> 'Post Office';

SELECT COUNT(*) AS accidental_shipping_cost_rows
FROM `shipping_cost` sc
JOIN `staging_p2p_package` spp
  ON spp.`package_id_hex` = HEX(sc.`package_id`);

-- Optional corrective backstop if package status ever drifts from the latest movement row.
WITH latest_movement AS (
    SELECT
        pm.`package_id`,
        pm.`package_status_id`,
        ROW_NUMBER() OVER (
            PARTITION BY pm.`package_id`
            ORDER BY pm.`event_timestamp` DESC, pm.`package_movement_id` DESC
        ) AS `rn`
    FROM `package_movement` pm
)
UPDATE `package` p
JOIN latest_movement lm
  ON lm.`package_id` = p.`package_id`
 AND lm.`rn` = 1
JOIN `staging_p2p_package` spp
  ON spp.`package_id_hex` = HEX(p.`package_id`)
SET p.`package_status_id` = lm.`package_status_id`,
    p.`updated_at` = CURRENT_TIMESTAMP
WHERE p.`package_status_id` <> lm.`package_status_id`;
"""


def build_readme() -> str:
    return """# P2P Olist Origin Ingestion

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
"""


def generate_notebook() -> None:
    notebook = {
        "cells": [
            {
                "cell_type": "markdown",
                "metadata": {},
                "source": [
                    "# Build P2P Olist Origin Ingestion\n",
                    "\n",
                    "This notebook builds the first-pass P2P Olist origin ingestion artifacts for the beginning package lifecycle only.\n",
                ],
            },
            {
                "cell_type": "markdown",
                "metadata": {},
                "source": [
                    "## What This Produces\n",
                    "\n",
                    "- `stg_p2p_package.csv`\n",
                    "- `stg_p2p_shippingdetails.csv`\n",
                    "- `stg_p2p_origin_movement.csv`\n",
                    "- `stg_p2p_package_quarantine.csv`\n",
                    "\n",
                    "Package weight is staged in ounces to match the production `package.weight_oz` column.\n",
                ],
            },
            {
                "cell_type": "code",
                "execution_count": None,
                "metadata": {},
                "outputs": [],
                "source": [
                    "from p2p_olist_origin_pipeline import (\n",
                    "    OUTPUT_DIR,\n",
                    "    QUARANTINE_CSV,\n",
                    "    STG_MOVEMENT_CSV,\n",
                    "    STG_PACKAGE_CSV,\n",
                    "    STG_SHIPPINGDETAILS_CSV,\n",
                    "    TARGET_P2P_FINAL_SHARE,\n",
                    "    TARGET_P2P_PACKAGE_COUNT,\n",
                    "    build_all_outputs,\n",
                    "    print_validation_report,\n",
                    ")\n",
                ],
            },
            {
                "cell_type": "code",
                "execution_count": None,
                "metadata": {},
                "outputs": [],
                "source": [
                    "TARGET_P2P_FINAL_SHARE = 0.25\n",
                    "TARGET_P2P_PACKAGE_COUNT = None\n",
                ],
            },
            {
                "cell_type": "code",
                "execution_count": None,
                "metadata": {},
                "outputs": [],
                "source": [
                    "result = build_all_outputs(\n",
                    "    write_files=True,\n",
                    "    target_p2p_final_share=TARGET_P2P_FINAL_SHARE,\n",
                    "    target_p2p_package_count=TARGET_P2P_PACKAGE_COUNT,\n",
                    ")\n",
                    "print_validation_report(result)\n",
                ],
            },
            {
                "cell_type": "code",
                "execution_count": None,
                "metadata": {},
                "outputs": [],
                "source": [
                    "print(f'Output directory: {OUTPUT_DIR}')\n",
                    "print(f'Package staging CSV: {STG_PACKAGE_CSV.exists()} -> {STG_PACKAGE_CSV.name}')\n",
                    "print(f'Shippingdetails staging CSV: {STG_SHIPPINGDETAILS_CSV.exists()} -> {STG_SHIPPINGDETAILS_CSV.name}')\n",
                    "print(f'Movement staging CSV: {STG_MOVEMENT_CSV.exists()} -> {STG_MOVEMENT_CSV.name}')\n",
                    "print(f'Quarantine CSV: {QUARANTINE_CSV.exists()} -> {QUARANTINE_CSV.name}')\n",
                ],
            },
            {
                "cell_type": "code",
                "execution_count": None,
                "metadata": {},
                "outputs": [],
                "source": ["result.package_stage.head()\n"],
            },
            {
                "cell_type": "code",
                "execution_count": None,
                "metadata": {},
                "outputs": [],
                "source": ["result.shippingdetails_stage.head()\n"],
            },
            {
                "cell_type": "code",
                "execution_count": None,
                "metadata": {},
                "outputs": [],
                "source": ["result.movement_stage.head()\n"],
            },
            {
                "cell_type": "code",
                "execution_count": None,
                "metadata": {},
                "outputs": [],
                "source": ["result.quarantine.head()\n"],
            },
        ],
        "metadata": {
            "kernelspec": {
                "display_name": "Python 3",
                "language": "python",
                "name": "python3",
            },
            "language_info": {
                "name": "python",
                "version": "3.13",
            },
        },
        "nbformat": 4,
        "nbformat_minor": 5,
    }
    NOTEBOOK_PATH.write_text(json.dumps(notebook, indent=2), encoding="utf-8")


def write_supporting_files() -> None:
    SQL_PATH.write_text(build_load_sql(), encoding="utf-8")
    README_PATH.write_text(build_readme(), encoding="utf-8")
    generate_notebook()


def build_all_outputs(
    *,
    write_files: bool = True,
    target_p2p_final_share: float = TARGET_P2P_FINAL_SHARE,
    target_p2p_package_count: int | None = TARGET_P2P_PACKAGE_COUNT,
) -> PipelineResult:
    selected_stage, metadata = build_package_candidates(
        target_p2p_final_share=target_p2p_final_share,
        target_p2p_package_count=target_p2p_package_count,
    )
    package_stage = stage_package_columns(selected_stage)
    shippingdetails_stage = build_shippingdetails_stage(selected_stage)
    movement_stage = build_movement_stage(package_stage)
    quarantine = quarantine_columns(metadata["quarantine"])
    validation_frames = build_validation_frames(
        package_stage,
        movement_stage,
        quarantine,
        metadata["metadata"]["raw_timestamp_anomaly_count"],
    )
    summary = build_summary(package_stage, movement_stage, quarantine, metadata["metadata"])

    if write_files:
        OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
        write_csv(package_stage, STG_PACKAGE_CSV)
        write_csv(shippingdetails_stage, STG_SHIPPINGDETAILS_CSV)
        write_csv(movement_stage, STG_MOVEMENT_CSV)
        write_csv(quarantine, QUARANTINE_CSV)
        write_supporting_files()

    return PipelineResult(
        package_stage=package_stage,
        shippingdetails_stage=shippingdetails_stage,
        movement_stage=movement_stage,
        quarantine=quarantine,
        validation_frames=validation_frames,
        summary=summary,
    )


def main() -> None:
    result = build_all_outputs(write_files=True)
    print_validation_report(result)


if __name__ == "__main__":
    main()
