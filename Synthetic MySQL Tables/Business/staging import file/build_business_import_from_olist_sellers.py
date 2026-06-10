from __future__ import annotations

import re
import sys
import unicodedata
from pathlib import Path

import numpy as np
import pandas as pd


RANDOM_SEED = 42
GENERATED_TIMESTAMP = "2026-01-01 00:00:00"

BUSINESS_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = BUSINESS_DIR.parents[1]

if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from rebuild_unique_customer_mapping import (  # noqa: E402
    build_mapping_table,
    build_texas_target_weights,
)


OLIST_SELLERS_CSV = PROJECT_ROOT / "Olist E-Commerce Dataset" / "olist_sellers_dataset.csv"
BUSINESS_IMPORT_CSV = BUSINESS_DIR / "business_import.csv"
BUSINESS_AUDIT_CSV = BUSINESS_DIR / "business_import_audit.csv"

MAIN_COLUMNS = [
    "business_id",
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
]

STREET_NAMES = [
    "Commerce",
    "Market",
    "Distribution",
    "Logistics",
    "Fulfillment",
    "Trade",
    "Merchant",
    "Warehouse",
    "Supply",
    "Depot",
    "Industry",
    "Harbor",
]

STREET_TYPES = ["St", "Ave", "Blvd", "Dr", "Ln", "Rd", "Way", "Pkwy"]

BUSINESS_SUFFIXES = [
    "Supply Co",
    "Market Group",
    "Trading Co",
    "Fulfillment",
    "Commerce",
    "Merchants",
    "Retail Group",
    "Distribution",
]

TEXAS_AREA_CODES_BY_ZIP_PREFIX = {
    "75": ["214", "469", "972", "945"],
    "76": ["254", "817", "682", "940"],
    "77": ["281", "346", "713", "832"],
    "78": ["210", "726", "830", "512", "737"],
    "79": ["806", "432", "915"],
    "88": ["915", "432"],
}

TEXAS_AREA_CODES = [
    "210",
    "214",
    "254",
    "281",
    "325",
    "346",
    "361",
    "409",
    "430",
    "432",
    "469",
    "512",
    "682",
    "713",
    "726",
    "737",
    "806",
    "817",
    "830",
    "832",
    "903",
    "915",
    "936",
    "940",
    "945",
    "956",
    "972",
    "979",
]


def normalize_ascii(value: object) -> str:
    text = "" if pd.isna(value) else str(value).strip()
    text = unicodedata.normalize("NFKD", text)
    text = text.encode("ascii", "ignore").decode("ascii")
    return re.sub(r"\s+", " ", text).strip()


def title_location(value: object) -> str:
    text = normalize_ascii(value)
    if not text:
        return "Texas"
    return " ".join(token.capitalize() for token in text.lower().split())


def safe_email_token(value: object) -> str:
    text = normalize_ascii(value).lower()
    text = re.sub(r"[^a-z0-9]+", ".", text).strip(".")
    return text or "business"


def load_olist_sellers() -> pd.DataFrame:
    sellers = pd.read_csv(
        OLIST_SELLERS_CSV,
        dtype={"seller_id": "string", "seller_zip_code_prefix": "string"},
    )
    sellers["seller_id"] = sellers["seller_id"].str.strip().str.lower()
    sellers["seller_zip_code_prefix"] = sellers["seller_zip_code_prefix"].str.zfill(5)
    sellers["_row_order"] = np.arange(len(sellers))
    return sellers


def build_unique_sellers(sellers: pd.DataFrame) -> pd.DataFrame:
    invalid_ids = sellers.loc[
        ~sellers["seller_id"].str.fullmatch(r"[0-9a-f]{32}", na=False),
        "seller_id",
    ]
    if not invalid_ids.empty:
        examples = ", ".join(invalid_ids.head(5).astype(str))
        raise ValueError(f"Found seller_id values that are not 32-character hex strings: {examples}")

    location_counts = (
        sellers.groupby(
            ["seller_id", "seller_zip_code_prefix", "seller_city", "seller_state"],
            dropna=False,
        )
        .agg(
            seller_record_count=("seller_id", "count"),
            first_row_order=("_row_order", "min"),
        )
        .reset_index()
        .sort_values(
            ["seller_id", "seller_record_count", "first_row_order"],
            ascending=[True, False, True],
            kind="mergesort",
        )
    )

    canonical_location = (
        location_counts.drop_duplicates("seller_id", keep="first")
        .rename(
            columns={
                "seller_zip_code_prefix": "canonical_seller_zip_code_prefix",
                "seller_city": "canonical_seller_city",
                "seller_state": "canonical_seller_state",
            }
        )
        .drop(columns=["seller_record_count", "first_row_order"])
    )

    seller_stats = (
        sellers.groupby("seller_id", as_index=False)
        .agg(
            source_row_count=("seller_id", "count"),
            first_row_order=("_row_order", "min"),
        )
    )

    unique_sellers = seller_stats.merge(
        canonical_location,
        on="seller_id",
        how="left",
        validate="one_to_one",
    ).sort_values("first_row_order", kind="mergesort")

    unique_sellers["zip_group_4"] = unique_sellers["canonical_seller_zip_code_prefix"].str[:4]
    unique_sellers["zip_group_3"] = unique_sellers["canonical_seller_zip_code_prefix"].str[:3]
    unique_sellers["zip_group_2"] = unique_sellers["canonical_seller_zip_code_prefix"].str[:2]
    unique_sellers["source_code"] = (
        unique_sellers["canonical_seller_state"].astype("string").str.strip().str.upper()
        + "-"
        + unique_sellers["zip_group_4"]
    )

    source_counts = unique_sellers["source_code"].value_counts(dropna=False)
    unique_sellers["source_code_seller_count"] = unique_sellers["source_code"].map(source_counts).astype("int64")
    unique_sellers["source_code_proportion"] = unique_sellers["source_code_seller_count"] / len(unique_sellers)
    unique_sellers["source_code_percentage"] = unique_sellers["source_code_proportion"] * 100

    return unique_sellers.reset_index(drop=True)


def build_source_code_summary(unique_sellers: pd.DataFrame) -> pd.DataFrame:
    summary = (
        unique_sellers["source_code"]
        .value_counts(dropna=False)
        .rename_axis("source_code")
        .reset_index(name="count")
        .sort_values(["count", "source_code"], ascending=[False, True], kind="mergesort")
        .reset_index(drop=True)
    )
    summary["proportion"] = summary["count"] / len(unique_sellers)
    summary["percentage"] = summary["proportion"] * 100
    return summary


def generate_street_address(rng: np.random.Generator) -> str:
    number = int(rng.integers(100, 9999))
    name = str(rng.choice(STREET_NAMES))
    street_type = str(rng.choice(STREET_TYPES))
    return f"{number} {name} {street_type}"


def generate_phone_number(zip_code: str, rng: np.random.Generator) -> str:
    area_codes = TEXAS_AREA_CODES_BY_ZIP_PREFIX.get(str(zip_code)[:2], TEXAS_AREA_CODES)
    area_code = str(rng.choice(area_codes))
    exchange = int(rng.integers(200, 999))
    line_number = int(rng.integers(0, 9999))
    return f"{area_code}-{exchange:03d}-{line_number:04d}"


def generate_business_name(row: pd.Series, rng: np.random.Generator) -> str:
    location = title_location(row["canonical_seller_city"])
    suffix = str(rng.choice(BUSINESS_SUFFIXES))
    short_id = str(row["seller_id"])[:8].upper()
    name = f"{location} {suffix} {short_id}"
    return name[:150]


def generate_email(row: pd.Series, business_name: str, existing_emails: set[str]) -> str:
    city_token = safe_email_token(row["canonical_seller_city"])
    name_token = safe_email_token(business_name)
    seller_token = str(row["seller_id"])[:8]
    base = f"{name_token[:42]}.{city_token[:18]}.{seller_token}"
    email = f"{base}@business.postal-demo.local"
    counter = 2
    while email in existing_emails:
        email = f"{base}.{counter}@business.postal-demo.local"
        counter += 1
    existing_emails.add(email)
    return email[:100]


def build_business_outputs(
    unique_sellers: pd.DataFrame,
    mapping_table: pd.DataFrame,
) -> tuple[pd.DataFrame, pd.DataFrame]:
    mapping = mapping_table.rename(columns={"source_customer_count": "source_code_mapping_count"})
    assignment_cols = ["source_code", "assigned_texas_zip", "assigned_texas_city", "assigned_texas_county"]
    mapped = unique_sellers.merge(
        mapping[assignment_cols],
        on="source_code",
        how="left",
        validate="many_to_one",
    )

    missing_assignments = mapped["assigned_texas_zip"].isna().sum()
    if missing_assignments:
        raise ValueError(f"{missing_assignments:,} sellers did not receive a Texas ZIP assignment.")

    rng = np.random.default_rng(RANDOM_SEED)
    existing_emails: set[str] = set()
    rows: list[dict[str, object]] = []
    audit_rows: list[dict[str, object]] = []

    for _, row in mapped.iterrows():
        business_name = generate_business_name(row, rng)
        email = generate_email(row, business_name, existing_emails)
        output_row = {
            "business_id": row["seller_id"],
            "business_name": business_name,
            "street_address": generate_street_address(rng),
            "county": row["assigned_texas_county"],
            "city": row["assigned_texas_city"],
            "state_code": "TX",
            "zip_code": row["assigned_texas_zip"],
            "territory_id": "",
            "phone_number": generate_phone_number(row["assigned_texas_zip"], rng),
            "email": email,
            "created_at": GENERATED_TIMESTAMP,
            "updated_at": GENERATED_TIMESTAMP,
        }
        rows.append(output_row)
        audit_rows.append(
            {
                **output_row,
                "source_seller_id": row["seller_id"],
                "source_seller_zip_code_prefix": row["canonical_seller_zip_code_prefix"],
                "source_seller_city": row["canonical_seller_city"],
                "source_seller_state": row["canonical_seller_state"],
                "source_row_count": row["source_row_count"],
                "zip_group_4": row["zip_group_4"],
                "zip_group_3": row["zip_group_3"],
                "zip_group_2": row["zip_group_2"],
                "source_code": row["source_code"],
                "source_code_seller_count": row["source_code_seller_count"],
                "source_code_proportion": row["source_code_proportion"],
                "source_code_percentage": row["source_code_percentage"],
            }
        )

    return pd.DataFrame(rows, columns=MAIN_COLUMNS), pd.DataFrame(audit_rows)


def validate_outputs(
    sellers: pd.DataFrame,
    unique_sellers: pd.DataFrame,
    business_import: pd.DataFrame,
) -> pd.DataFrame:
    seller_ids = set(unique_sellers["seller_id"])
    business_ids = set(business_import["business_id"])
    checks = {
        "raw_seller_rows": len(sellers),
        "unique_seller_ids": len(unique_sellers),
        "business_import_rows": len(business_import),
        "business_ids_match_seller_ids": business_ids == seller_ids,
        "duplicate_business_ids": int(business_import["business_id"].duplicated().sum()),
        "invalid_business_id_count": int((~business_import["business_id"].str.fullmatch(r"[0-9a-f]{32}")).sum()),
        "missing_required_business_names": int(business_import["business_name"].eq("").sum()),
        "missing_assigned_counties": int(business_import["county"].isna().sum()),
        "missing_assigned_cities": int(business_import["city"].isna().sum()),
        "missing_assigned_zips": int(business_import["zip_code"].isna().sum()),
        "non_tx_state_codes": int((business_import["state_code"] != "TX").sum()),
        "invalid_zip_lengths": int((~business_import["zip_code"].str.fullmatch(r"\d{5}|\d{5}-\d{4}")).sum()),
        "duplicate_emails": int(business_import["email"].duplicated().sum()),
    }
    return pd.DataFrame({"check": checks.keys(), "value": checks.values()})


def main() -> None:
    sellers = load_olist_sellers()
    unique_sellers = build_unique_sellers(sellers)
    source_code_summary = build_source_code_summary(unique_sellers)
    texas_target_weights = build_texas_target_weights(len(unique_sellers))
    mapping_table = build_mapping_table(source_code_summary, texas_target_weights)
    business_import, business_audit = build_business_outputs(unique_sellers, mapping_table)
    validation = validate_outputs(sellers, unique_sellers, business_import)

    BUSINESS_DIR.mkdir(parents=True, exist_ok=True)
    business_import.to_csv(BUSINESS_IMPORT_CSV, index=False, lineterminator="\n")
    business_audit.to_csv(BUSINESS_AUDIT_CSV, index=False, lineterminator="\n")

    print(validation.to_string(index=False))
    print()
    print(f"Wrote {BUSINESS_IMPORT_CSV.relative_to(PROJECT_ROOT)}")
    print(f"Wrote {BUSINESS_AUDIT_CSV.relative_to(PROJECT_ROOT)}")


if __name__ == "__main__":
    main()
