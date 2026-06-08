from pathlib import Path

import numpy as np
import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parent

OLIST_DIR = PROJECT_ROOT / "Olist E-Commerce Dataset"
ESTABLISH_DIR = PROJECT_ROOT / "Establish_source_codes_and_target_weights"
SYNTHETIC_DIR = PROJECT_ROOT / "Synthetic_Customers_and_Orders"
TEXAS_GEO_DIR = PROJECT_ROOT / "Texas_ZIP_Geo"

OLIST_CUSTOMERS_CSV = OLIST_DIR / "olist_customers_dataset.csv"
OLIST_ORDERS_CSV = OLIST_DIR / "olist_orders_dataset.csv"
OLIST_CUSTOMERS_WITH_SOURCE_CSV = OLIST_DIR / "olist_customers_with_source_code.csv"
OLIST_UNIQUE_CUSTOMERS_WITH_SOURCE_CSV = OLIST_DIR / "olist_unique_customers_with_source_code.csv"

SOURCE_CODE_SUMMARY_CSV = ESTABLISH_DIR / "source_code_summary.csv"
TEXAS_TARGET_WEIGHTS_CSV = ESTABLISH_DIR / "texas_target_weights.csv"
SOURCE_CODE_TO_TEXAS_ZIP_MAPPING_CSV = ESTABLISH_DIR / "source_code_to_texas_zip_mapping.csv"

TEXAS_ZIP_CENTROIDS_CSV = TEXAS_GEO_DIR / "texas_zip_centroids.csv"
POSTAL_CUSTOMERS_CSV = SYNTHETIC_DIR / "postal_customers.csv"
POSTAL_CUSTOMER_ORDERS_CSV = SYNTHETIC_DIR / "postal_customer_orders.csv"


def load_olist_customers() -> pd.DataFrame:
    customers = pd.read_csv(
        OLIST_CUSTOMERS_CSV,
        dtype={"customer_zip_code_prefix": "string"},
    )
    customers["customer_zip_code_prefix"] = customers["customer_zip_code_prefix"].str.zfill(5)
    customers["_row_order"] = np.arange(len(customers))
    return customers


def build_unique_customers(customers: pd.DataFrame) -> pd.DataFrame:
    location_counts = (
        customers.groupby(
            [
                "customer_unique_id",
                "customer_zip_code_prefix",
                "customer_city",
                "customer_state",
            ],
            dropna=False,
        )
        .agg(
            location_order_count=("customer_id", "count"),
            first_row_order=("_row_order", "min"),
        )
        .reset_index()
        .sort_values(
            ["customer_unique_id", "location_order_count", "first_row_order"],
            ascending=[True, False, True],
            kind="mergesort",
        )
    )

    canonical_location = (
        location_counts.drop_duplicates("customer_unique_id", keep="first")
        .rename(
            columns={
                "customer_zip_code_prefix": "canonical_customer_zip_code_prefix",
                "customer_city": "canonical_customer_city",
                "customer_state": "canonical_customer_state",
            }
        )
        .drop(columns=["location_order_count", "first_row_order"])
    )

    customer_order_stats = (
        customers.groupby("customer_unique_id", as_index=False)
        .agg(
            order_count=("customer_id", "count"),
            first_customer_id=("customer_id", "first"),
            first_row_order=("_row_order", "min"),
        )
    )

    unique_customers = customer_order_stats.merge(
        canonical_location,
        on="customer_unique_id",
        how="left",
        validate="one_to_one",
    ).sort_values("first_row_order", kind="mergesort")

    unique_customers["zip_group_4"] = unique_customers["canonical_customer_zip_code_prefix"].str[:4]
    unique_customers["zip_group_3"] = unique_customers["canonical_customer_zip_code_prefix"].str[:3]
    unique_customers["zip_group_2"] = unique_customers["canonical_customer_zip_code_prefix"].str[:2]
    unique_customers["source_code"] = (
        unique_customers["canonical_customer_state"].astype("string").str.strip().str.upper()
        + "-"
        + unique_customers["zip_group_4"]
    )

    source_counts = unique_customers["source_code"].value_counts(dropna=False)
    unique_customers["source_code_count"] = unique_customers["source_code"].map(source_counts).astype("int64")
    unique_customers["source_code_proportion"] = unique_customers["source_code_count"] / len(unique_customers)
    unique_customers["source_code_percentage"] = unique_customers["source_code_proportion"] * 100

    return unique_customers[
        [
            "customer_unique_id",
            "order_count",
            "first_customer_id",
            "canonical_customer_zip_code_prefix",
            "canonical_customer_city",
            "canonical_customer_state",
            "zip_group_4",
            "zip_group_3",
            "zip_group_2",
            "source_code",
            "source_code_count",
            "source_code_proportion",
            "source_code_percentage",
        ]
    ].reset_index(drop=True)


def build_source_outputs(customers: pd.DataFrame, unique_customers: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame]:
    source_code_summary = (
        unique_customers["source_code"]
        .value_counts(dropna=False)
        .rename_axis("source_code")
        .reset_index(name="count")
        .sort_values(["count", "source_code"], ascending=[False, True], kind="mergesort")
        .reset_index(drop=True)
    )
    source_code_summary["proportion"] = source_code_summary["count"] / len(unique_customers)
    source_code_summary["percentage"] = source_code_summary["proportion"] * 100

    customer_orders_with_source = customers.drop(columns=["_row_order"]).merge(
        unique_customers[
            [
                "customer_unique_id",
                "order_count",
                "canonical_customer_zip_code_prefix",
                "canonical_customer_city",
                "canonical_customer_state",
                "zip_group_4",
                "zip_group_3",
                "zip_group_2",
                "source_code",
                "source_code_count",
                "source_code_proportion",
                "source_code_percentage",
            ]
        ],
        on="customer_unique_id",
        how="left",
        validate="many_to_one",
    )

    return source_code_summary, customer_orders_with_source


def build_texas_target_weights(unique_customer_count: int) -> pd.DataFrame:
    texas = pd.read_csv(TEXAS_ZIP_CENTROIDS_CSV, dtype={"zip": "string", "county_geoid": "string"})
    texas["zip"] = texas["zip"].str.zfill(5)
    texas["population"] = pd.to_numeric(texas["population"], errors="coerce")
    texas["density"] = pd.to_numeric(texas["density"], errors="coerce")
    texas = texas[(texas["population"] > 0) & (texas["density"] > 0)].copy()

    median_density = texas["density"].median()
    density_modifier = texas["density"].div(median_density).clip(lower=0).pow(0.25)
    texas["target_weight"] = texas["population"] * density_modifier
    texas["target_zip_proportion"] = texas["target_weight"] / texas["target_weight"].sum()
    texas["target_zip_capacity"] = texas["target_zip_proportion"] * unique_customer_count

    return texas.sort_values(["target_zip_capacity", "zip"], ascending=[False, True], kind="mergesort")


def build_mapping_table(source_code_summary: pd.DataFrame, texas_target_weights: pd.DataFrame) -> pd.DataFrame:
    source = source_code_summary.rename(columns={"count": "source_code_count"}).copy()
    source["source_code_count"] = pd.to_numeric(source["source_code_count"], errors="raise")

    texas = texas_target_weights.copy()
    texas["target_zip_capacity"] = pd.to_numeric(texas["target_zip_capacity"], errors="raise")

    source = source.sort_values(
        ["source_code_count", "source_code"],
        ascending=[False, True],
        kind="mergesort",
    ).reset_index(drop=True)
    texas = texas.sort_values(
        ["target_zip_capacity", "zip"],
        ascending=[False, True],
        kind="mergesort",
    ).reset_index(drop=True)

    source["source_start"] = source["source_code_count"].cumsum().shift(fill_value=0)
    source["source_end"] = source["source_code_count"].cumsum()
    source["source_midpoint"] = (source["source_start"] + source["source_end"]) / 2

    texas["target_start"] = texas["target_zip_capacity"].cumsum().shift(fill_value=0)
    texas["target_end"] = texas["target_zip_capacity"].cumsum()

    target_positions = np.searchsorted(
        texas["target_end"].to_numpy(),
        source["source_midpoint"].to_numpy(),
        side="left",
    )
    target_positions = np.clip(target_positions, 0, len(texas) - 1)
    assigned_texas = texas.iloc[target_positions].reset_index(drop=True)

    return pd.DataFrame(
        {
            "source_code": source["source_code"].to_numpy(),
            "source_customer_count": source["source_code_count"].to_numpy(),
            "source_start": source["source_start"].to_numpy(),
            "source_end": source["source_end"].to_numpy(),
            "source_midpoint": source["source_midpoint"].to_numpy(),
            "assigned_texas_zip": assigned_texas["zip"].to_numpy(),
            "assigned_texas_city": assigned_texas.get("city", pd.Series([pd.NA] * len(assigned_texas))).to_numpy(),
            "assigned_texas_county": assigned_texas.get("county_name", pd.Series([pd.NA] * len(assigned_texas))).to_numpy(),
            "target_zip_capacity": assigned_texas["target_zip_capacity"].to_numpy(),
            "target_start": assigned_texas["target_start"].to_numpy(),
            "target_end": assigned_texas["target_end"].to_numpy(),
        }
    )


def build_final_outputs(
    unique_customers: pd.DataFrame,
    customers: pd.DataFrame,
    mapping_table: pd.DataFrame,
) -> tuple[pd.DataFrame, pd.DataFrame]:
    assignment_cols = ["source_code", "assigned_texas_zip", "assigned_texas_city", "assigned_texas_county"]
    postal_customers = unique_customers.merge(
        mapping_table[assignment_cols],
        on="source_code",
        how="left",
        validate="many_to_one",
    )

    missing_unique_assignments = postal_customers["assigned_texas_zip"].isna().sum()
    if missing_unique_assignments:
        raise ValueError(f"{missing_unique_assignments:,} unique customers did not receive a Texas ZIP.")

    postal_customer_orders = customers.drop(columns=["_row_order"]).merge(
        postal_customers[
            [
                "customer_unique_id",
                "assigned_texas_zip",
                "assigned_texas_city",
                "assigned_texas_county",
                "canonical_customer_zip_code_prefix",
                "canonical_customer_city",
                "canonical_customer_state",
                "source_code",
                "order_count",
            ]
        ],
        on="customer_unique_id",
        how="left",
        validate="many_to_one",
    )

    if OLIST_ORDERS_CSV.exists():
        orders = pd.read_csv(OLIST_ORDERS_CSV)
        postal_customer_orders = orders.merge(
            postal_customer_orders,
            on="customer_id",
            how="right",
            validate="one_to_one",
        )

    missing_order_assignments = postal_customer_orders["assigned_texas_zip"].isna().sum()
    if missing_order_assignments:
        raise ValueError(f"{missing_order_assignments:,} order rows did not receive a Texas ZIP.")

    return postal_customers, postal_customer_orders


def validate_outputs(
    customers: pd.DataFrame,
    unique_customers: pd.DataFrame,
    source_code_summary: pd.DataFrame,
    texas_target_weights: pd.DataFrame,
    postal_customers: pd.DataFrame,
    postal_customer_orders: pd.DataFrame,
) -> pd.DataFrame:
    split_zip_customers = (
        postal_customer_orders.groupby("customer_unique_id")["assigned_texas_zip"].nunique(dropna=False) > 1
    ).sum()

    checks = {
        "raw_customer_order_rows": len(customers),
        "unique_customer_rows": len(unique_customers),
        "source_summary_total": int(source_code_summary["count"].sum()),
        "texas_capacity_total": float(texas_target_weights["target_zip_capacity"].sum()),
        "postal_customers_rows": len(postal_customers),
        "postal_customer_orders_rows": len(postal_customer_orders),
        "postal_customers_unique_ids": postal_customers["customer_unique_id"].nunique(),
        "postal_customer_orders_unique_ids": postal_customer_orders["customer_unique_id"].nunique(),
        "customers_with_multiple_assigned_zips": int(split_zip_customers),
        "missing_customer_assignments": int(postal_customers["assigned_texas_zip"].isna().sum()),
        "missing_order_assignments": int(postal_customer_orders["assigned_texas_zip"].isna().sum()),
    }
    return pd.DataFrame({"check": checks.keys(), "value": checks.values()})


def main() -> None:
    customers = load_olist_customers()
    unique_customers = build_unique_customers(customers)
    source_code_summary, customer_orders_with_source = build_source_outputs(customers, unique_customers)
    texas_target_weights = build_texas_target_weights(len(unique_customers))
    mapping_table = build_mapping_table(source_code_summary, texas_target_weights)
    postal_customers, postal_customer_orders = build_final_outputs(
        unique_customers,
        customers,
        mapping_table,
    )
    validation = validate_outputs(
        customers,
        unique_customers,
        source_code_summary,
        texas_target_weights,
        postal_customers,
        postal_customer_orders,
    )

    OLIST_UNIQUE_CUSTOMERS_WITH_SOURCE_CSV.parent.mkdir(parents=True, exist_ok=True)
    SYNTHETIC_DIR.mkdir(parents=True, exist_ok=True)
    ESTABLISH_DIR.mkdir(parents=True, exist_ok=True)

    unique_customers.to_csv(OLIST_UNIQUE_CUSTOMERS_WITH_SOURCE_CSV, index=False)
    customer_orders_with_source.to_csv(OLIST_CUSTOMERS_WITH_SOURCE_CSV, index=False)
    source_code_summary.to_csv(SOURCE_CODE_SUMMARY_CSV, index=False)
    texas_target_weights.to_csv(TEXAS_TARGET_WEIGHTS_CSV, index=False)
    mapping_table.to_csv(SOURCE_CODE_TO_TEXAS_ZIP_MAPPING_CSV, index=False)
    postal_customers.to_csv(POSTAL_CUSTOMERS_CSV, index=False)
    postal_customer_orders.to_csv(POSTAL_CUSTOMER_ORDERS_CSV, index=False)

    print(validation.to_string(index=False))
    print()
    print(f"Wrote {OLIST_UNIQUE_CUSTOMERS_WITH_SOURCE_CSV.relative_to(PROJECT_ROOT)}")
    print(f"Wrote {OLIST_CUSTOMERS_WITH_SOURCE_CSV.relative_to(PROJECT_ROOT)}")
    print(f"Wrote {SOURCE_CODE_SUMMARY_CSV.relative_to(PROJECT_ROOT)}")
    print(f"Wrote {TEXAS_TARGET_WEIGHTS_CSV.relative_to(PROJECT_ROOT)}")
    print(f"Wrote {SOURCE_CODE_TO_TEXAS_ZIP_MAPPING_CSV.relative_to(PROJECT_ROOT)}")
    print(f"Wrote {POSTAL_CUSTOMERS_CSV.relative_to(PROJECT_ROOT)}")
    print(f"Wrote {POSTAL_CUSTOMER_ORDERS_CSV.relative_to(PROJECT_ROOT)}")


if __name__ == "__main__":
    main()
