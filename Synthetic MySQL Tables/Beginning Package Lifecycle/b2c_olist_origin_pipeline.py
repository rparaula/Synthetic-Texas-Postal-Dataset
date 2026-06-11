from __future__ import annotations

import json
import math
import re
import uuid
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path
from typing import Any

import numpy as np
import pandas as pd


RANDOM_SEED = 42
PACKAGE_UUID_NAMESPACE = uuid.UUID("6e65f6c8-ec2b-43bb-baad-b5d92478097b")

PROJECT_ROOT = Path(__file__).resolve().parents[2]
OUTPUT_DIR = Path(__file__).resolve().parent
SCHEMA_DIR = PROJECT_ROOT / "MySQL Database Schema"
OLIST_DIR = PROJECT_ROOT / "Olist E-Commerce Dataset"
CUSTOMER_IMPORT_AUDIT_CSV = PROJECT_ROOT / "Synthetic MySQL Tables" / "Customers" / "import file" / "customer_import_audit.csv"
BUSINESS_IMPORT_AUDIT_CSV = PROJECT_ROOT / "Synthetic MySQL Tables" / "Business" / "staging import file" / "business_import_audit.csv"

STG_PACKAGE_CSV = OUTPUT_DIR / "stg_b2c_package.csv"
STG_SHIPPINGDETAILS_CSV = OUTPUT_DIR / "stg_b2c_shippingdetails.csv"
STG_MOVEMENT_CSV = OUTPUT_DIR / "stg_b2c_origin_movement.csv"
QUARANTINE_CSV = OUTPUT_DIR / "stg_b2c_package_quarantine.csv"
NOTEBOOK_PATH = OUTPUT_DIR / "build_b2c_olist_origin_ingestion.ipynb"
README_PATH = OUTPUT_DIR / "README.md"
SQL_PATH = OUTPUT_DIR / "load_b2c_olist_origin_ingestion.sql"

SERVICE_TYPE_DISTRIBUTION = {
    "Delivery": 0.764,
    "Pickup": 0.155,
    "SmartLocker": 0.081,
}

FACILITY_EVENT_CONFIG = [
    ("Received At Facility", "origin_received_timestamp", "Received", False),
    ("Sorted At Facility", "origin_sorted_timestamp", "Processing", False),
    ("Departed Facility", "origin_departed_timestamp", "In Transit", True),
]

BUSINESS_DUMP_COLUMNS = [
    "business_id_raw",
    "business_name",
    "street_address",
    "county",
    "city",
    "state_code",
    "zip_code",
    "territory_id",
    "phone_number",
    "email",
    "created_at",
    "updated_at",
    "preferred_facility_id",
]

CUSTOMER_DUMP_COLUMNS = [
    "customer_id_raw",
    "first_name",
    "middle_initial",
    "last_name",
    "street_address",
    "county",
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


@dataclass
class PipelineResult:
    package_stage: pd.DataFrame
    shippingdetails_stage: pd.DataFrame
    movement_stage: pd.DataFrame
    quarantine: pd.DataFrame
    validation_frames: dict[str, pd.DataFrame]
    summary: dict[str, Any]


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def extract_insert_values_sql(path: Path, table_name: str) -> str:
    text = read_text(path)
    marker = f"INSERT INTO `{table_name}` VALUES"
    start = text.find(marker)
    if start == -1:
        raise ValueError(f"Could not find INSERT INTO `{table_name}` in {path}")
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

    raise ValueError(f"Could not find statement terminator for `{table_name}` in {path}")


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


@lru_cache(maxsize=8)
def load_lookup_table(table_name: str, id_column: str, name_column: str) -> pd.DataFrame:
    path = SCHEMA_DIR / f"postal_bi_system_{table_name}.sql"
    rows = parse_values_clause(extract_insert_values_sql(path, table_name))
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


def load_business_lookup() -> pd.DataFrame:
    business_audit = pd.read_csv(
        BUSINESS_IMPORT_AUDIT_CSV,
        dtype={"business_id": "string", "source_seller_id": "string", "email": "string"},
    )
    business_audit["email"] = business_audit["email"].astype("string").str.strip().str.lower()
    business_audit["source_seller_id"] = business_audit["source_seller_id"].astype("string").str.strip().str.lower()
    business_audit["business_id"] = business_audit["business_id"].astype("string").str.strip().str.lower()
    lookup = attach_territory(
        business_audit,
        state_column="state_code",
        city_column="city",
        county_column="county",
        zip_column="zip_code",
    ).rename(
        columns={
            "source_seller_id": "seller_id",
            "business_id": "sender_business_id_hex",
        }
    )

    territory_to_facility = derive_nearest_mail_processing_facility_map()
    lookup["preferred_facility_id"] = lookup["db_territory_id"].map(territory_to_facility)
    return lookup


def load_customer_lookup() -> pd.DataFrame:
    customer_audit = pd.read_csv(
        CUSTOMER_IMPORT_AUDIT_CSV,
        dtype={
            "customer_id": "string",
            "email": "string",
            "source_customer_unique_id": "string",
            "source_first_customer_id": "string",
        },
    )
    customer_audit["email"] = customer_audit["email"].astype("string").str.strip().str.lower()
    customer_audit["customer_id"] = customer_audit["customer_id"].astype("string").str.strip().str.lower()
    customer_audit["source_customer_unique_id"] = customer_audit["source_customer_unique_id"].astype("string").str.strip()
    customer_audit["source_first_customer_id"] = customer_audit["source_first_customer_id"].astype("string").str.strip().str.lower()
    lookup = attach_territory(
        customer_audit,
        state_column="state_code",
        city_column="city",
        county_column="assigned_texas_county",
        zip_column="zip_code",
    ).rename(
        columns={
            "customer_id": "recipient_customer_id_hex",
            "source_customer_unique_id": "customer_unique_id",
            "source_first_customer_id": "first_olist_customer_id",
        }
    )
    return lookup


@lru_cache(maxsize=1)
def load_facility_lookup() -> pd.DataFrame:
    rows = parse_values_clause(extract_insert_values_sql(SCHEMA_DIR / "postal_bi_system_facility.sql", "facility"))
    facility = pd.DataFrame(rows, columns=FACILITY_DUMP_COLUMNS)
    facility["facility_id"] = facility["facility_id"].astype(int)
    facility["territory_id"] = pd.to_numeric(facility["territory_id"], errors="coerce").astype("Int64")
    return facility


@lru_cache(maxsize=1)
def load_facility_type_lookup() -> pd.DataFrame:
    rows = parse_values_clause(extract_insert_values_sql(SCHEMA_DIR / "postal_bi_system_facility_type.sql", "facility_type"))
    facility_type = pd.DataFrame(rows, columns=FACILITY_TYPE_DUMP_COLUMNS)
    facility_type["facility_type_id"] = facility_type["facility_type_id"].astype(int)
    return facility_type


@lru_cache(maxsize=1)
def load_territory_lookup() -> pd.DataFrame:
    rows = parse_values_clause(extract_insert_values_sql(SCHEMA_DIR / "postal_bi_system_territory.sql", "territory"))
    territory = pd.DataFrame(rows, columns=TERRITORY_DUMP_COLUMNS)
    territory["territory_id"] = territory["territory_id"].astype(int)
    territory["territory_zip5"] = territory["zip_code"].astype("string").str[:5]
    territory["state_norm"] = territory["state"].map(normalize_text)
    territory["city_norm"] = territory["city"].map(normalize_text)
    territory["county_norm"] = territory["county"].map(normalize_text)
    return territory


@lru_cache(maxsize=1)
def load_zip_geo_lookup() -> pd.DataFrame:
    rows = parse_values_clause(extract_insert_values_sql(SCHEMA_DIR / "postal_bi_system_zip_geo.sql", "zip_geo"))
    zip_geo = pd.DataFrame(rows, columns=ZIP_GEO_DUMP_COLUMNS)
    zip_geo["zip_code"] = zip_geo["zip_code"].astype("string").str[:5]
    zip_geo["latitude"] = pd.to_numeric(zip_geo["latitude"], errors="coerce")
    zip_geo["longitude"] = pd.to_numeric(zip_geo["longitude"], errors="coerce")
    return zip_geo


def normalize_text(value: Any) -> str:
    if value is None or (isinstance(value, float) and math.isnan(value)):
        return ""
    return re.sub(r"\s+", " ", str(value).strip()).upper()


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


@lru_cache(maxsize=1)
def derive_nearest_mail_processing_facility_map() -> dict[int, int]:
    facility = load_facility_lookup()
    facility_type = load_facility_type_lookup()
    territory = load_territory_lookup()
    zip_geo = load_zip_geo_lookup()

    mail_processing_type_ids = set(
        facility_type.loc[facility_type["facility_type_name"].eq("Mail Processing"), "facility_type_id"].astype(int)
    )
    mail_processing = facility.loc[facility["facility_type_id"].isin(mail_processing_type_ids)].copy()
    mail_processing = mail_processing.merge(
        territory[["territory_id", "territory_zip5"]],
        on="territory_id",
        how="left",
        validate="many_to_one",
    ).merge(
        zip_geo[["zip_code", "latitude", "longitude"]],
        left_on="territory_zip5",
        right_on="zip_code",
        how="left",
        validate="many_to_one",
    )
    mail_processing = mail_processing.dropna(subset=["latitude", "longitude"]).copy()

    territory_geo = territory.merge(
        zip_geo[["zip_code", "latitude", "longitude"]],
        left_on="territory_zip5",
        right_on="zip_code",
        how="left",
        validate="many_to_one",
    )
    territory_geo = territory_geo.dropna(subset=["latitude", "longitude"]).copy()

    if mail_processing.empty or territory_geo.empty:
        return {}

    business_points = territory_geo[["territory_id", "latitude", "longitude"]].rename(
        columns={"latitude": "business_latitude", "longitude": "business_longitude"}
    )
    business_points["__key"] = 1
    facility_points = mail_processing[["facility_id", "latitude", "longitude"]].rename(
        columns={"latitude": "facility_latitude", "longitude": "facility_longitude"}
    )
    facility_points["__key"] = 1

    candidate_pairs = business_points.merge(facility_points, on="__key", how="inner").drop(columns="__key")
    candidate_pairs["distance_miles"] = haversine_miles(
        candidate_pairs["business_latitude"].to_numpy(dtype=float),
        candidate_pairs["business_longitude"].to_numpy(dtype=float),
        candidate_pairs["facility_latitude"].to_numpy(dtype=float),
        candidate_pairs["facility_longitude"].to_numpy(dtype=float),
    )
    nearest = (
        candidate_pairs.sort_values(["territory_id", "distance_miles", "facility_id"], kind="mergesort")
        .drop_duplicates("territory_id", keep="first")
    )
    return dict(zip(nearest["territory_id"], nearest["facility_id"]))


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


def build_contents(categories: pd.Series) -> str:
    values = [str(value).strip() for value in categories.dropna().unique() if str(value).strip()]
    if not values:
        return "Unknown"
    contents = "; ".join(sorted(values)[:3])
    return contents[:30] or "Unknown"


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


def format_timestamp(series: pd.Series) -> pd.Series:
    return pd.to_datetime(series, errors="coerce").dt.strftime("%Y-%m-%d %H:%M:%S")


def build_package_candidates() -> tuple[pd.DataFrame, dict[str, dict[str, int]]]:
    lookup_maps = resolve_lookup_maps()
    orders, items, products, customers, category_translation = load_olist_inputs()
    business_lookup = load_business_lookup()
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

    contents = (
        grouped["translated_category_name"]
        .apply(build_contents)
        .reset_index(name="contents")
    )
    package_items = package_items.merge(contents, on=["order_id", "seller_id"], how="left", validate="one_to_one")

    orders = orders.merge(customers[["customer_id", "customer_unique_id"]], on="customer_id", how="left", validate="many_to_one")
    package_candidates = package_items.merge(
        orders[
            [
                "order_id",
                "customer_id",
                "customer_unique_id",
                "order_status",
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

    package_candidates = package_candidates.merge(
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
                "db_territory_id",
            ]
        ],
        on="customer_unique_id",
        how="left",
        validate="many_to_one",
    )
    package_candidates = package_candidates.rename(
        columns={
            "customer_id": "olist_customer_id",
            "street_address": "recipient_street_address",
            "city": "recipient_city",
            "state_code": "recipient_state_code",
            "zip_code": "recipient_zip_code",
            "db_territory_id": "recipient_territory_id",
            "first_name": "recipient_first_name",
            "middle_initial": "recipient_middle_initial",
            "last_name": "recipient_last_name",
        }
    )

    package_candidates = package_candidates.merge(
        business_lookup[
            [
                "seller_id",
                "sender_business_id_hex",
                "business_name",
                "street_address",
                "city",
                "state_code",
                "zip_code",
                "db_territory_id",
                "preferred_facility_id",
            ]
        ].rename(
            columns={
                "street_address": "sender_street_address",
                "city": "sender_city",
                "state_code": "sender_state_code",
                "zip_code": "sender_zip_code",
                "db_territory_id": "sender_territory_id",
                "preferred_facility_id": "origin_facility_id",
            }
        ),
        on="seller_id",
        how="left",
        validate="many_to_one",
    )

    package_candidates["weight_oz"] = package_candidates["total_weight_g"] / 28.3495
    package_candidates["length_in"] = (package_candidates["max_length_cm"] / 2.54).clip(lower=1.0)
    package_candidates["width_in"] = (package_candidates["max_width_cm"] / 2.54).clip(lower=1.0)
    package_candidates["height_in"] = (package_candidates["total_height_cm"] / 2.54).clip(lower=1.0)

    package_candidates["origin_received_timestamp"] = pd.to_datetime(
        package_candidates["order_purchase_timestamp"], errors="coerce"
    )
    package_candidates["origin_sorted_timestamp"] = pd.to_datetime(
        package_candidates["order_approved_at"], errors="coerce"
    )
    package_candidates["origin_departed_timestamp"] = pd.to_datetime(
        package_candidates["order_delivered_carrier_date"], errors="coerce"
    )

    service_rng = np.random.default_rng(RANDOM_SEED)
    service_choices = service_rng.choice(
        list(SERVICE_TYPE_DISTRIBUTION.keys()),
        size=len(package_candidates),
        p=list(SERVICE_TYPE_DISTRIBUTION.values()),
    )
    package_candidates["service_type_name"] = pd.Series(service_choices, index=package_candidates.index, dtype="string")
    package_candidates["service_type_id"] = package_candidates["service_type_name"].map(lookup_maps["service_type"])

    package_candidates["package_flow_type_name"] = "B2C"
    package_candidates["package_flow_type_id"] = lookup_maps["package_flow_type"]["B2C"]

    package_candidates["timeline_stage_count"] = (
        package_candidates["origin_received_timestamp"].notna().astype(int)
        + package_candidates["origin_sorted_timestamp"].notna().astype(int)
        + package_candidates["origin_departed_timestamp"].notna().astype(int)
    )

    status_name = np.where(
        package_candidates["origin_departed_timestamp"].notna(),
        "In Transit",
        np.where(package_candidates["origin_sorted_timestamp"].notna(), "Processing", "Received"),
    )
    package_candidates["initial_status_name"] = pd.Series(status_name, index=package_candidates.index, dtype="string")
    package_candidates["initial_package_status_id"] = package_candidates["initial_status_name"].map(
        lookup_maps["package_status"]
    )

    package_candidates["package_id_hex"] = package_candidates.apply(
        lambda row: uuid.uuid5(
            PACKAGE_UUID_NAMESPACE,
            f"b2c-package:{row['order_id']}:{row['seller_id']}",
        ).hex,
        axis=1,
    )
    package_candidates["received_date"] = package_candidates["origin_received_timestamp"]

    return package_candidates, lookup_maps


def compute_quarantine_and_stage(package_candidates: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame]:
    frame = package_candidates.copy()

    missing_recipient = frame["recipient_customer_id_hex"].isna() | (frame["recipient_customer_id_hex"].astype("string").str.len() != 32)
    missing_sender = frame["sender_business_id_hex"].isna() | (frame["sender_business_id_hex"].astype("string").str.len() != 32)
    missing_origin_facility = frame["origin_facility_id"].isna()

    numeric_metrics = frame[["weight_oz", "length_in", "width_in", "height_in"]].apply(pd.to_numeric, errors="coerce")
    rounded_metrics = numeric_metrics.round(2)
    invalid_dimensions = (
        numeric_metrics.le(0).any(axis=1)
        | numeric_metrics.isna().any(axis=1)
        | rounded_metrics.le(0).any(axis=1)
    )

    missing_received = frame["origin_received_timestamp"].isna()
    has_sorted_without_received = frame["origin_sorted_timestamp"].notna() & frame["origin_received_timestamp"].isna()
    has_departed_without_sorted = frame["origin_departed_timestamp"].notna() & frame["origin_sorted_timestamp"].isna()
    out_of_order_sorted = (
        frame["origin_sorted_timestamp"].notna()
        & frame["origin_received_timestamp"].notna()
        & (frame["origin_sorted_timestamp"] < frame["origin_received_timestamp"])
    )
    out_of_order_departed = (
        frame["origin_departed_timestamp"].notna()
        & frame["origin_sorted_timestamp"].notna()
        & (frame["origin_departed_timestamp"] < frame["origin_sorted_timestamp"])
    )
    invalid_timestamps = (
        missing_received
        | has_sorted_without_received
        | has_departed_without_sorted
        | out_of_order_sorted
        | out_of_order_departed
    )

    incomplete_timeline = (
        frame["origin_received_timestamp"].isna()
        | frame["origin_sorted_timestamp"].isna()
        | frame["origin_departed_timestamp"].isna()
    )

    reason_columns = {
        "missing_recipient_customer_mapping": missing_recipient,
        "missing_sender_business_mapping": missing_sender,
        "missing_business_preferred_facility_id": missing_origin_facility,
        "invalid_dimensions_or_weight": invalid_dimensions,
        "invalid_or_out_of_order_timestamps": invalid_timestamps,
        "excluded_first_pass_incomplete_origin_timeline": incomplete_timeline & ~invalid_timestamps,
    }

    quarantine_reason = []
    for _, row in pd.DataFrame(reason_columns).iterrows():
        reasons = [name for name, is_hit in row.items() if bool(is_hit)]
        quarantine_reason.append("; ".join(reasons))
    frame["quarantine_reason"] = pd.Series(quarantine_reason, index=frame.index, dtype="string")

    staged_mask = frame["quarantine_reason"].fillna("").eq("")
    staged = frame.loc[staged_mask].copy()
    quarantine = frame.loc[~staged_mask].copy()

    staged["weight_oz"] = staged["weight_oz"].round(4)
    staged["length_in"] = staged["length_in"].round(4)
    staged["width_in"] = staged["width_in"].round(4)
    staged["height_in"] = staged["height_in"].round(4)

    staged["received_date"] = format_timestamp(staged["received_date"])
    staged["origin_received_timestamp"] = format_timestamp(staged["origin_received_timestamp"])
    staged["origin_sorted_timestamp"] = format_timestamp(staged["origin_sorted_timestamp"])
    staged["origin_departed_timestamp"] = format_timestamp(staged["origin_departed_timestamp"])

    if not quarantine.empty:
        for column in ["received_date", "origin_received_timestamp", "origin_sorted_timestamp", "origin_departed_timestamp"]:
            if column in quarantine.columns:
                quarantine[column] = format_timestamp(quarantine[column])

    stage_columns = [
        "package_id_hex",
        "order_id",
        "seller_id",
        "olist_customer_id",
        "recipient_customer_id_hex",
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
    ]

    quarantine_columns = stage_columns + [
        "customer_unique_id",
        "sender_territory_id",
        "recipient_territory_id",
        "quarantine_reason",
    ]

    return staged[stage_columns], quarantine[quarantine_columns]


def build_shippingdetails_stage(staged_packages: pd.DataFrame, package_candidates: pd.DataFrame) -> pd.DataFrame:
    source = staged_packages.merge(
        package_candidates[
            [
                "package_id_hex",
                "recipient_street_address",
                "recipient_city",
                "recipient_state_code",
                "recipient_zip_code",
                "recipient_territory_id",
                "recipient_first_name",
                "recipient_middle_initial",
                "recipient_last_name",
                "sender_street_address",
                "sender_city",
                "sender_state_code",
                "sender_zip_code",
                "sender_territory_id",
            ]
        ],
        on="package_id_hex",
        how="left",
        validate="one_to_one",
    )

    def build_address(street: Any, city: Any, state_code: Any, zip_code: Any) -> str:
        parts = [str(street or "").strip(), str(city or "").strip(), f"{str(state_code or '').strip()} {str(zip_code or '').strip()}".strip()]
        return ", ".join(part for part in parts if part).strip(", ")

    shippingdetails = pd.DataFrame(
        {
            "package_id_hex": source["package_id_hex"],
            "recipient_address": source.apply(
                lambda row: build_address(
                    row["recipient_street_address"],
                    row["recipient_city"],
                    row["recipient_state_code"],
                    row["recipient_zip_code"],
                ),
                axis=1,
            ),
            "recipient_territory_id": source["recipient_territory_id"],
            "sender_address": source.apply(
                lambda row: build_address(
                    row["sender_street_address"],
                    row["sender_city"],
                    row["sender_state_code"],
                    row["sender_zip_code"],
                ),
                axis=1,
            ),
            "sender_territory_id": source["sender_territory_id"],
            "estimated_delivery_distance": pd.Series([None] * len(source), dtype="object"),
            "recipient_first_name": source["recipient_first_name"],
            "recipient_middle_initial": source["recipient_middle_initial"],
            "recipient_last_name": source["recipient_last_name"],
            "expected_delivery_date": pd.Series([None] * len(source), dtype="object"),
            "delivered_date": pd.Series([None] * len(source), dtype="object"),
        }
    )

    return shippingdetails


def build_movement_stage(staged_packages: pd.DataFrame, lookup_maps: dict[str, dict[str, int]]) -> pd.DataFrame:
    movement_columns = [
        "package_id_hex",
        "event_type_name",
        "package_movement_event_type_id",
        "package_status_name",
        "package_status_id",
        "facility_id",
        "from_facility_id",
        "to_facility_id",
        "processed_by_employee_id",
        "event_timestamp",
        "expected_event_at",
        "delay_minutes",
        "delay_reason",
        "movement_note",
    ]
    movement_rows: list[dict[str, Any]] = []
    for package in staged_packages.to_dict("records"):
        for event_type_name, timestamp_column, status_name, uses_from_facility in FACILITY_EVENT_CONFIG:
            timestamp = package[timestamp_column]
            if not timestamp:
                continue
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
                    "event_timestamp": timestamp,
                    "expected_event_at": None,
                    "delay_minutes": 0,
                    "delay_reason": None,
                    "movement_note": f"Olist origin lifecycle: {event_type_name}",
                }
            )

    movement = pd.DataFrame(movement_rows, columns=movement_columns)
    if movement.empty:
        return movement

    for column in ["package_movement_event_type_id", "package_status_id", "facility_id", "from_facility_id", "to_facility_id", "processed_by_employee_id", "delay_minutes"]:
        movement[column] = pd.to_numeric(movement[column], errors="coerce").astype("Int64")

    movement = movement.sort_values(["package_id_hex", "event_timestamp", "event_type_name"], kind="mergesort").reset_index(drop=True)
    return movement


def write_csv(frame: pd.DataFrame, path: Path) -> None:
    frame.to_csv(path, index=False, lineterminator="\n")


def build_validation_frames(
    package_candidates: pd.DataFrame,
    staged_packages: pd.DataFrame,
    movement_stage: pd.DataFrame,
    quarantine: pd.DataFrame,
) -> dict[str, pd.DataFrame]:
    quarantine_reason_series = quarantine.get("quarantine_reason", pd.Series(dtype="string")).fillna("")

    def count_matches(fragment: str) -> int:
        if quarantine.empty:
            return 0
        return int(quarantine_reason_series.str.contains(fragment, regex=False).sum())

    frames: dict[str, pd.DataFrame] = {
        "packages_by_service_type": staged_packages["service_type_name"].value_counts(dropna=False).rename_axis("service_type_name").reset_index(name="package_count"),
        "packages_by_initial_status": staged_packages["initial_status_name"].value_counts(dropna=False).rename_axis("initial_status_name").reset_index(name="package_count"),
        "packages_by_origin_facility": staged_packages["origin_facility_id"].value_counts(dropna=False).rename_axis("origin_facility_id").reset_index(name="package_count"),
        "movement_events_by_type": movement_stage["event_type_name"].value_counts(dropna=False).rename_axis("event_type_name").reset_index(name="event_count"),
        "quarantine_summary": pd.DataFrame(
            {
                "metric": [
                    "missing recipient customer mappings",
                    "missing seller/business mappings",
                    "missing preferred facility IDs",
                    "invalid dimensions",
                    "invalid or out-of-order timestamps",
                    "excluded incomplete timelines for first pass",
                ],
                "count": [
                    count_matches("missing_recipient_customer_mapping"),
                    count_matches("missing_sender_business_mapping"),
                    count_matches("missing_business_preferred_facility_id"),
                    count_matches("invalid_dimensions_or_weight"),
                    count_matches("invalid_or_out_of_order_timestamps"),
                    count_matches("excluded_first_pass_incomplete_origin_timeline"),
                ],
            }
        ),
        "candidate_initial_status_counts": package_candidates["initial_status_name"].value_counts(dropna=False).rename_axis("initial_status_name").reset_index(name="candidate_count"),
    }

    return frames


def build_summary(
    package_candidates: pd.DataFrame,
    staged_packages: pd.DataFrame,
    movement_stage: pd.DataFrame,
    quarantine: pd.DataFrame,
) -> dict[str, Any]:
    return {
        "candidate_b2c_packages": int(len(package_candidates)),
        "staged_b2c_packages": int(len(staged_packages)),
        "quarantined_packages": int(len(quarantine)),
        "generated_movement_events": int(len(movement_stage)),
        "packages_ready_for_middle_mile": int(staged_packages["origin_departed_timestamp"].notna().sum()) if not staged_packages.empty else 0,
    }


def print_validation_report(result: PipelineResult) -> None:
    print("\nB2C Olist origin ingestion validation summary")
    print("=" * 48)
    for key, value in result.summary.items():
        print(f"{key}: {value:,}")

    print("\nPackages by service type")
    print(result.validation_frames["packages_by_service_type"].to_string(index=False))

    print("\nPackages by initial status")
    print(result.validation_frames["packages_by_initial_status"].to_string(index=False))

    print("\nPackages by origin facility")
    print(result.validation_frames["packages_by_origin_facility"].head(20).to_string(index=False))

    print("\nQuarantine summary")
    print(result.validation_frames["quarantine_summary"].to_string(index=False))

    print("\nGenerated movement events by type")
    print(result.validation_frames["movement_events_by_type"].to_string(index=False))

    print("\nCandidate initial status counts before first-pass filtering")
    print(result.validation_frames["candidate_initial_status_counts"].to_string(index=False))


def build_all_outputs(write_files: bool = True) -> PipelineResult:
    package_candidates, lookup_maps = build_package_candidates()
    staged_packages, quarantine = compute_quarantine_and_stage(package_candidates)
    shippingdetails_stage = build_shippingdetails_stage(staged_packages, package_candidates)
    movement_stage = build_movement_stage(staged_packages, lookup_maps)
    validation_frames = build_validation_frames(package_candidates, staged_packages, movement_stage, quarantine)
    summary = build_summary(package_candidates, staged_packages, movement_stage, quarantine)

    if write_files:
        OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
        write_csv(staged_packages, STG_PACKAGE_CSV)
        write_csv(shippingdetails_stage, STG_SHIPPINGDETAILS_CSV)
        write_csv(movement_stage, STG_MOVEMENT_CSV)
        write_csv(quarantine, QUARANTINE_CSV)

    return PipelineResult(
        package_stage=staged_packages,
        shippingdetails_stage=shippingdetails_stage,
        movement_stage=movement_stage,
        quarantine=quarantine,
        validation_frames=validation_frames,
        summary=summary,
    )


def generate_notebook() -> None:
    notebook = {
        "cells": [
            {
                "cell_type": "markdown",
                "metadata": {},
                "source": [
                    "# Build B2C Olist Origin Ingestion\n",
                    "\n",
                    "This notebook builds the first-pass B2C Olist origin ingestion artifacts for the beginning package lifecycle only.\n",
                ],
            },
            {
                "cell_type": "markdown",
                "metadata": {},
                "source": [
                    "## What This Produces\n",
                    "\n",
                    "- `stg_b2c_package.csv`\n",
                    "- `stg_b2c_shippingdetails.csv`\n",
                    "- `stg_b2c_origin_movement.csv`\n",
                    "- `stg_b2c_package_quarantine.csv`\n",
                    "\n",
                    "The production `shippingdetails` trigger auto-calculates `estimated_delivery_distance` when the staged value is `NULL`.\n",
                ],
            },
            {
                "cell_type": "code",
                "execution_count": None,
                "metadata": {},
                "outputs": [],
                "source": [
                    "from pathlib import Path\n",
                    "\n",
                    "from b2c_olist_origin_pipeline import (\n",
                    "    OUTPUT_DIR,\n",
                    "    QUARANTINE_CSV,\n",
                    "    STG_MOVEMENT_CSV,\n",
                    "    STG_PACKAGE_CSV,\n",
                    "    STG_SHIPPINGDETAILS_CSV,\n",
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
                    "result = build_all_outputs(write_files=True)\n",
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
                "source": [
                    "result.package_stage.head()\n",
                ],
            },
            {
                "cell_type": "code",
                "execution_count": None,
                "metadata": {},
                "outputs": [],
                "source": [
                    "result.shippingdetails_stage.head()\n",
                ],
            },
            {
                "cell_type": "code",
                "execution_count": None,
                "metadata": {},
                "outputs": [],
                "source": [
                    "result.movement_stage.head()\n",
                ],
            },
            {
                "cell_type": "code",
                "execution_count": None,
                "metadata": {},
                "outputs": [],
                "source": [
                    "result.quarantine.head()\n",
                ],
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


def main() -> None:
    generate_notebook()
    result = build_all_outputs(write_files=True)
    print_validation_report(result)


if __name__ == "__main__":
    main()
