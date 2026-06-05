#!/usr/bin/env python3
"""Generate ZIP centroid coordinates for all ZIPs in a Texas ZIP-county crosswalk.

Workflow:
1) Read ZIPs from ZIP-County Texas Crosswalk.csv.
2) Pull centroid lat/lon from uszips.csv where available.
3) For ZIPs missing in uszips.csv, compute weighted centroid from HUD zip->tract
   crosswalk (type=1) + Census tract centroids.

Output columns:
zip,latitude,longitude,city,state,county_geoid,county_name,centroid_source
"""

from __future__ import annotations

import argparse
import csv
import os
from collections import defaultdict
from pathlib import Path
from typing import Dict, Iterable, List, Tuple

import requests

HUD_BASE_URL = "https://www.huduser.gov/hudapi/public/usps"
TRACT_CENTROID_URL = (
    "https://tigerweb.geo.census.gov/arcgis/rest/services/"
    "Census2020/Tracts_Blocks/MapServer/0/query"
)
COUNTY_CENTROID_URL = (
    "https://tigerweb.geo.census.gov/arcgis/rest/services/"
    "TIGERweb/State_County/MapServer/1/query"
)


def response_preview(response: requests.Response, limit: int = 300) -> str:
    text = response.text or ""
    text = " ".join(text.split())
    return text[:limit]


def parse_json_response(response: requests.Response, source_name: str):
    try:
        return response.json()
    except ValueError as exc:
        content_type = response.headers.get("Content-Type", "unknown")
        raise RuntimeError(
            f"{source_name} returned invalid JSON (status {response.status_code}, "
            f"content-type: {content_type}). Response preview: {response_preview(response)!r}"
        ) from exc

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Generate ZIP centroids for all ZIPs present in ZIP-County Texas Crosswalk.csv, "
            "using uszips.csv plus HUD fallback for missing ZIPs."
        )
    )
    parser.add_argument(
        "--crosswalk",
        default="ZIP-County Texas Crosswalk.csv",
        help="Path to ZIP-County Texas Crosswalk.csv",
    )
    parser.add_argument(
        "--uszips",
        default="uszips.csv",
        help="Path to uszips.csv",
    )
    parser.add_argument(
        "--output",
        default="texas_zip_centroids.csv",
        help="Output centroid CSV path",
    )
    parser.add_argument(
        "--hud-token",
        default=os.getenv("HUD_API_TOKEN", ""),
        help="HUD API bearer token (or set HUD_API_TOKEN env var)",
    )
    parser.add_argument(
        "--timeout",
        type=int,
        default=120,
        help="HTTP timeout seconds",
    )
    return parser.parse_args()


def normalize_zip(raw: str) -> str:
    return (raw or "").strip().zfill(5)


def to_float(raw: str) -> float:
    return float((raw or "").strip())


def read_crosswalk(path: Path) -> Tuple[List[str], Dict[str, dict]]:
    by_zip: Dict[str, List[dict]] = defaultdict(list)

    with path.open("r", newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        required = {"zip", "city", "state", "county_geoid", "county_name", "tot_ratio"}
        missing = sorted(required - set(reader.fieldnames or []))
        if missing:
            raise ValueError(
                f"Missing required columns in {path.name}: {', '.join(missing)}"
            )

        for row in reader:
            zip_code = normalize_zip(row.get("zip", ""))
            if not zip_code:
                continue
            by_zip[zip_code].append(row)

    if not by_zip:
        raise RuntimeError(f"No ZIP rows found in {path}")

    zips = sorted(by_zip.keys())
    metadata: Dict[str, dict] = {}

    for zip_code, rows in by_zip.items():
        # Use highest tot_ratio row as representative metadata for the ZIP.
        chosen = max(rows, key=lambda r: float(r.get("tot_ratio") or 0.0))
        metadata[zip_code] = {
            "city": (chosen.get("city") or "").strip(),
            "state": (chosen.get("state") or "").strip(),
            "county_geoid": (chosen.get("county_geoid") or "").strip(),
            "county_name": (chosen.get("county_name") or "").strip(),
        }

    return zips, metadata


def read_uszips(path: Path) -> Dict[str, Tuple[float, float]]:
    zip_to_coord: Dict[str, Tuple[float, float]] = {}

    with path.open("r", newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        required = {"zip", "lat", "lng"}
        missing = sorted(required - set(reader.fieldnames or []))
        if missing:
            raise ValueError(
                f"Missing required columns in {path.name}: {', '.join(missing)}"
            )

        for row in reader:
            zip_code = normalize_zip(row.get("zip", ""))
            if not zip_code:
                continue
            try:
                lat = to_float(row.get("lat", ""))
                lon = to_float(row.get("lng", ""))
            except ValueError:
                continue
            zip_to_coord[zip_code] = (lat, lon)

    return zip_to_coord


def hud_zip_to_tract_rows_by_query(
    query: str,
    token: str,
    timeout: int,
    target_zips: set[str],
) -> Dict[str, List[dict]]:
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/json",
    }
    params = {
        "type": 1,  # zip-tract crosswalk
        "query": query,
    }

    response = requests.get(HUD_BASE_URL, params=params, headers=headers, timeout=timeout)
    if response.status_code != 200:
        raise RuntimeError(
            f"HUD bulk query failed for query={query} (status {response.status_code}). "
            f"Response preview: {response_preview(response)!r}"
        )

    payload = parse_json_response(response, "HUD zip-tract bulk API")
    data_section = payload.get("data", [])

    if isinstance(data_section, dict):
        blocks = [data_section]
    elif isinstance(data_section, list):
        blocks = [b for b in data_section if isinstance(b, dict)]
    else:
        raise RuntimeError(
            f"Unexpected HUD response shape for query={query}: "
            f"data is {type(data_section).__name__}"
        )

    zip_to_rows: Dict[str, List[dict]] = defaultdict(list)
    for block in blocks:
        for result in block.get("results", []):
            if isinstance(result, dict):
                zip_code = normalize_zip(result.get("zip", ""))
                if zip_code and zip_code in target_zips:
                    zip_to_rows[zip_code].append(result)

    return dict(zip_to_rows)


def hud_zip_to_tract_rows_by_zip(
    zip_code: str,
    token: str,
    timeout: int,
) -> List[dict]:
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/json",
    }
    params = {
        "type": 1,
        "query": zip_code,
    }

    response = requests.get(HUD_BASE_URL, params=params, headers=headers, timeout=timeout)
    if response.status_code != 200:
        return []

    payload = parse_json_response(response, f"HUD zip-tract API (query={zip_code})")
    data_section = payload.get("data", [])

    if isinstance(data_section, dict):
        blocks = [data_section]
    elif isinstance(data_section, list):
        blocks = [b for b in data_section if isinstance(b, dict)]
    else:
        return []

    rows: List[dict] = []
    for block in blocks:
        for result in block.get("results", []):
            if not isinstance(result, dict):
                continue
            result_zip = normalize_zip(result.get("zip", ""))
            if result_zip == zip_code:
                rows.append(result)

    return rows


def pick_hud_query_value(states: set[str]) -> str:
    if len(states) == 1:
        state = next(iter(states)).strip().upper()
        if len(state) == 2:
            return state
    return "All"


def fetch_tract_centroid(
    tract_geoid: str,
    timeout: int,
    centroid_cache: Dict[str, Tuple[float, float]],
) -> Tuple[float, float]:
    if tract_geoid in centroid_cache:
        return centroid_cache[tract_geoid]

    where_clause = f"GEOID='{tract_geoid}'"
    params = {
        "where": where_clause,
        "outFields": "GEOID,CENTLAT,CENTLON",
        "f": "json",
    }

    response = requests.get(TRACT_CENTROID_URL, params=params, timeout=timeout)
    if response.status_code != 200:
        raise RuntimeError(
            f"Census tract centroid query failed for GEOID {tract_geoid} "
            f"(status {response.status_code})"
        )

    payload = parse_json_response(response, f"Census tract centroid API (GEOID={tract_geoid})")
    features = payload.get("features") or []
    if not features:
        raise RuntimeError(f"No tract centroid found for GEOID {tract_geoid}")

    attrs = features[0].get("attributes") or {}
    lat_raw = str(attrs.get("CENTLAT", "")).replace("+", "")
    lon_raw = str(attrs.get("CENTLON", "")).replace("+", "")

    try:
        lat = float(lat_raw)
        lon = float(lon_raw)
    except ValueError as exc:
        raise RuntimeError(
            f"Invalid CENTLAT/CENTLON for GEOID {tract_geoid}: {attrs}"
        ) from exc

    centroid_cache[tract_geoid] = (lat, lon)
    return lat, lon


def fetch_county_centroid(
    county_geoid: str,
    timeout: int,
    county_centroid_cache: Dict[str, Tuple[float, float]],
) -> Tuple[float, float]:
    if county_geoid in county_centroid_cache:
        return county_centroid_cache[county_geoid]

    params = {
        "where": f"GEOID='{county_geoid}'",
        "outFields": "GEOID,INTPTLAT,INTPTLON",
        "f": "json",
    }

    response = requests.get(COUNTY_CENTROID_URL, params=params, timeout=timeout)
    if response.status_code != 200:
        raise RuntimeError(
            f"County centroid query failed for county GEOID {county_geoid} "
            f"(status {response.status_code})"
        )

    payload = parse_json_response(response, f"County centroid API (GEOID={county_geoid})")
    features = payload.get("features") or []
    if not features:
        raise RuntimeError(f"No county centroid found for GEOID {county_geoid}")

    attrs = features[0].get("attributes") or {}
    lat_raw = str(attrs.get("INTPTLAT", "")).replace("+", "")
    lon_raw = str(attrs.get("INTPTLON", "")).replace("+", "")

    try:
        lat = float(lat_raw)
        lon = float(lon_raw)
    except ValueError as exc:
        raise RuntimeError(
            f"Invalid INTPTLAT/INTPTLON for county GEOID {county_geoid}: {attrs}"
        ) from exc

    county_centroid_cache[county_geoid] = (lat, lon)
    return lat, lon


def weighted_zip_centroid(
    zip_code: str,
    zip_tract_rows: List[dict],
    centroid_cache: Dict[str, Tuple[float, float]],
    timeout: int,
) -> Tuple[float, float]:
    rows = zip_tract_rows

    weighted_lat = 0.0
    weighted_lon = 0.0
    weight_sum = 0.0

    # Prefer tot_ratio if available; fallback to res_ratio; fallback to equal weights.
    weights = []
    for row in rows:
        if row.get("tot_ratio") is not None:
            weights.append(float(row.get("tot_ratio") or 0.0))
        elif row.get("res_ratio") is not None:
            weights.append(float(row.get("res_ratio") or 0.0))
        else:
            weights.append(0.0)

    if sum(weights) == 0:
        weights = [1.0 for _ in rows]

    for row, weight in zip(rows, weights):
        tract_geoid = str(row.get("geoid") or "").strip()
        if len(tract_geoid) != 11 or not tract_geoid.isdigit():
            continue

        lat, lon = fetch_tract_centroid(
            tract_geoid=tract_geoid,
            timeout=timeout,
            centroid_cache=centroid_cache,
        )
        weighted_lat += lat * weight
        weighted_lon += lon * weight
        weight_sum += weight

    if weight_sum == 0:
        raise RuntimeError(f"Could not compute weighted centroid for ZIP {zip_code}")

    return weighted_lat / weight_sum, weighted_lon / weight_sum


def write_output(path: Path, rows: Iterable[dict]) -> None:
    fields = [
        "zip",
        "latitude",
        "longitude",
        "city",
        "state",
        "county_geoid",
        "county_name",
        "centroid_source",
    ]

    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    args = parse_args()

    crosswalk_path = Path(args.crosswalk)
    uszips_path = Path(args.uszips)
    output_path = Path(args.output)

    if not crosswalk_path.exists():
        raise FileNotFoundError(f"Missing crosswalk file: {crosswalk_path}")
    if not uszips_path.exists():
        raise FileNotFoundError(f"Missing uszips file: {uszips_path}")

    zip_codes, metadata = read_crosswalk(crosswalk_path)
    uszip_coords = read_uszips(uszips_path)

    missing_from_uszips = [z for z in zip_codes if z not in uszip_coords]
    if missing_from_uszips and not args.hud_token:
        print(
            "Warning: HUD token not provided. "
            "ZIPs missing from uszips.csv will use county centroid fallback. "
            f"Missing ZIP count: {len(missing_from_uszips)}"
        )

    hud_rows_by_zip: Dict[str, List[dict]] = {}
    if missing_from_uszips and args.hud_token:
        states = {metadata[z]["state"] for z in zip_codes if metadata[z]["state"]}
        hud_query = pick_hud_query_value(states)
        hud_rows_by_zip = hud_zip_to_tract_rows_by_query(
            query=hud_query,
            token=args.hud_token,
            timeout=args.timeout,
            target_zips=set(missing_from_uszips),
        )

        unresolved = sorted(z for z in missing_from_uszips if z not in hud_rows_by_zip)
        for zip_code in unresolved:
            zip_rows = hud_zip_to_tract_rows_by_zip(
                zip_code=zip_code,
                token=args.hud_token,
                timeout=args.timeout,
            )
            if zip_rows:
                hud_rows_by_zip[zip_code] = zip_rows

    centroid_cache: Dict[str, Tuple[float, float]] = {}
    county_centroid_cache: Dict[str, Tuple[float, float]] = {}
    output_rows: List[dict] = []

    for zip_code in zip_codes:
        if zip_code in uszip_coords:
            lat, lon = uszip_coords[zip_code]
            source = "uszips"
        else:
            zip_rows = hud_rows_by_zip.get(zip_code, [])
            if zip_rows:
                lat, lon = weighted_zip_centroid(
                    zip_code=zip_code,
                    zip_tract_rows=zip_rows,
                    centroid_cache=centroid_cache,
                    timeout=args.timeout,
                )
                source = "hud_zip_tract_weighted"
            else:
                county_geoid = metadata[zip_code].get("county_geoid", "")
                if not county_geoid:
                    raise RuntimeError(
                        f"No HUD zip-tract rows found for ZIP {zip_code}, and county GEOID is missing for fallback."
                    )
                lat, lon = fetch_county_centroid(
                    county_geoid=county_geoid,
                    timeout=args.timeout,
                    county_centroid_cache=county_centroid_cache,
                )
                source = "county_centroid_fallback"

        base = metadata[zip_code]
        output_rows.append(
            {
                "zip": zip_code,
                "latitude": f"{lat:.6f}",
                "longitude": f"{lon:.6f}",
                "city": base["city"],
                "state": base["state"],
                "county_geoid": base["county_geoid"],
                "county_name": base["county_name"],
                "centroid_source": source,
            }
        )

    write_output(output_path, output_rows)

    hud_fallback_count = sum(1 for row in output_rows if row["centroid_source"] == "hud_zip_tract_weighted")
    county_fallback_count = sum(1 for row in output_rows if row["centroid_source"] == "county_centroid_fallback")

    print(f"Saved {len(output_rows)} ZIP centroids to {output_path}")
    print(f"Centroids from uszips.csv: {len(output_rows) - hud_fallback_count - county_fallback_count}")
    print(f"Centroids from HUD fallback: {hud_fallback_count}")
    print(f"Centroids from county fallback: {county_fallback_count}")
    print(f"Unique counties represented: {len({row['county_geoid'] for row in output_rows if row['county_geoid']})}")


if __name__ == "__main__":
    main()
