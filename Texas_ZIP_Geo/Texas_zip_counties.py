#!/usr/bin/env python3
"""Generate a ZIP-county crosswalk for all Texas ZIPs from HUD USPS API.

Output columns:
zip,geoid,res_ratio,bus_ratio,oth_ratio,tot_ratio,city,state,year,quarter,crosswalk_type,input,county_geoid,county_name
"""

from __future__ import annotations

import argparse
import csv
import os
import re
from pathlib import Path
from typing import Dict, Iterable, List

import requests

HUD_BASE_URL = "https://www.huduser.gov/hudapi/public/usps"
CENSUS_COUNTY_URL = "https://api.census.gov/data/2020/dec/pl"
TIGER_COUNTY_URL = (
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
			f"content-type: {content_type}). This is often caused by an expired HUD token, "
			f"a temporary service error, or an HTML error page. "
			f"Response preview: {response_preview(response)!r}"
		) from exc


def parse_args() -> argparse.Namespace:
	parser = argparse.ArgumentParser(
		description="Generate a ZIP-county crosswalk for all Texas ZIPs from HUD USPS API."
	)
	parser.add_argument(
		"--query",
		default="TX",
		help="HUD USPS query value (default: TX)",
	)
	parser.add_argument(
		"--output",
		default="ZIP-County Texas Crosswalk.csv",
		help="Output CSV path (default: ZIP-County Texas Crosswalk.csv)",
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
		help="HTTP timeout seconds (default: 120)",
	)
	parser.add_argument(
		"--year",
		type=int,
		default=None,
		help="Optional HUD year override",
	)
	parser.add_argument(
		"--quarter",
		type=int,
		default=None,
		help="Optional HUD quarter override",
	)
	parser.add_argument(
		"--census-key",
		default=os.getenv("CENSUS_API_KEY", ""),
		help="Optional Census API key (or set CENSUS_API_KEY env var)",
	)
	return parser.parse_args()


def normalize_zip(raw: str) -> str:
	return (raw or "").strip().zfill(5)


def extract_county_geoid(row: dict) -> str:
	value = str(row.get("county") or row.get("geoid") or "")
	match = re.search(r"(\d{5})", value)
	return match.group(1) if match else ""


def fetch_texas_county_names_from_tiger(timeout: int) -> Dict[str, str]:
	params = {
		"where": "STATE='48'",
		"outFields": "GEOID,NAME",
		"f": "json",
	}
	response = requests.get(TIGER_COUNTY_URL, params=params, timeout=timeout)
	if response.status_code != 200:
		raise RuntimeError(
			f"Failed to load Texas county names from TIGERweb API (status {response.status_code}). "
			f"Response preview: {response_preview(response)!r}"
		)

	payload = parse_json_response(response, "TIGERweb county API")
	features = payload.get("features") if isinstance(payload, dict) else None
	if not isinstance(features, list):
		raise RuntimeError("Unexpected TIGERweb county response shape.")

	county_map: Dict[str, str] = {}
	for feature in features:
		if not isinstance(feature, dict):
			continue
		attrs = feature.get("attributes")
		if not isinstance(attrs, dict):
			continue
		geoid = str(attrs.get("GEOID") or "").strip()
		name = str(attrs.get("NAME") or "").strip()
		if not geoid or len(geoid) != 5:
			continue
		county_map[geoid] = name.replace(" County", "").strip()

	if not county_map:
		raise RuntimeError("No Texas county names were returned by TIGERweb API.")
	return county_map


def fetch_texas_county_names(timeout: int, census_key: str) -> Dict[str, str]:
	params = {
		"get": "NAME",
		"for": "county:*",
		"in": "state:48",
	}
	if census_key:
		params["key"] = census_key

	response = requests.get(CENSUS_COUNTY_URL, params=params, timeout=timeout)
	if response.status_code == 200:
		try:
			payload = parse_json_response(response, "Census county API")
			if not isinstance(payload, list) or len(payload) < 2:
				raise RuntimeError("Unexpected Census county response shape.")

			county_map: Dict[str, str] = {}
			for row in payload[1:]:
				if not isinstance(row, list) or len(row) < 3:
					continue
				name, state_fips, county_fips = row[0], row[1], row[2]
				if state_fips != "48":
					continue
				geoid = f"{state_fips}{county_fips}"
				county_name = str(name).replace(" County, Texas", "").strip()
				county_map[geoid] = county_name

			if county_map:
				return county_map
		except RuntimeError:
			# Fall through to TIGERweb fallback for key-required or malformed responses.
			pass

	print("Falling back to TIGERweb county names endpoint (no Census API key required).")
	return fetch_texas_county_names_from_tiger(timeout=timeout)


def fetch_hud_zip_county_rows(
	query: str,
	token: str,
	timeout: int,
	year: int | None,
	quarter: int | None,
	county_name_map: Dict[str, str],
) -> List[dict]:
	headers = {
		"Authorization": f"Bearer {token}",
		"Accept": "application/json",
	}
	params = {
		"type": 2,
		"query": query,
	}
	if year is not None:
		params["year"] = year
	if quarter is not None:
		params["quarter"] = quarter

	response = requests.get(HUD_BASE_URL, params=params, headers=headers, timeout=timeout)
	if response.status_code != 200:
		raise RuntimeError(
			f"HUD ZIP-county query failed (status {response.status_code}). "
			f"Response preview: {response_preview(response)!r}"
		)

	payload = parse_json_response(response, "HUD ZIP-county API")
	data_section = payload.get("data", [])
	if isinstance(data_section, dict):
		blocks = [data_section]
	elif isinstance(data_section, list):
		blocks = [block for block in data_section if isinstance(block, dict)]
	else:
		raise RuntimeError(
			f"Unexpected HUD response shape for data: {type(data_section).__name__}"
		)

	out: List[dict] = []
	for block in blocks:
		block_year = block.get("year")
		block_quarter = block.get("quarter")
		crosswalk_type = block.get("crosswalk_type", "zip-county")
		input_value = block.get("input", block.get("query", query))

		for result in block.get("results", []):
			if not isinstance(result, dict):
				continue
			zip_code = normalize_zip(result.get("zip", ""))
			if not zip_code:
				continue

			county_geoid = extract_county_geoid(result)
			county_name = county_name_map.get(county_geoid, "")

			out.append(
				{
					"zip": zip_code,
					"geoid": str(result.get("geoid") or county_geoid).strip(),
					"res_ratio": str(result.get("res_ratio") or ""),
					"bus_ratio": str(result.get("bus_ratio") or ""),
					"oth_ratio": str(result.get("oth_ratio") or ""),
					"tot_ratio": str(result.get("tot_ratio") or ""),
					"city": str(result.get("city") or "").strip(),
					"state": str(result.get("state") or "").strip(),
					"year": str(block_year or ""),
					"quarter": str(block_quarter or ""),
					"crosswalk_type": str(crosswalk_type or ""),
					"input": str(input_value or ""),
					"county_geoid": county_geoid,
					"county_name": county_name,
				}
			)

	if not out:
		raise RuntimeError("No rows returned from HUD API.")

	# De-duplicate exact repeated rows if any appear across returned blocks.
	unique = {
		(
			row["zip"],
			row["geoid"],
			row["res_ratio"],
			row["bus_ratio"],
			row["oth_ratio"],
			row["tot_ratio"],
			row["city"],
			row["state"],
			row["year"],
			row["quarter"],
			row["crosswalk_type"],
			row["input"],
			row["county_geoid"],
			row["county_name"],
		): row
		for row in out
	}
	deduped = list(unique.values())
	deduped.sort(key=lambda r: (r["zip"], r["county_geoid"], r["city"]))
	return deduped


def write_rows(path: Path, rows: Iterable[dict]) -> None:
	fields = [
		"zip",
		"geoid",
		"res_ratio",
		"bus_ratio",
		"oth_ratio",
		"tot_ratio",
		"city",
		"state",
		"year",
		"quarter",
		"crosswalk_type",
		"input",
		"county_geoid",
		"county_name",
	]
	path.parent.mkdir(parents=True, exist_ok=True)
	with path.open("w", newline="", encoding="utf-8") as f:
		writer = csv.DictWriter(f, fieldnames=fields)
		writer.writeheader()
		writer.writerows(rows)


def main() -> None:
	args = parse_args()

	if not args.hud_token:
		raise RuntimeError(
			"Missing HUD API token. Pass --hud-token or set HUD_API_TOKEN."
		)

	county_name_map = fetch_texas_county_names(timeout=args.timeout, census_key=args.census_key)
	rows = fetch_hud_zip_county_rows(
		query=args.query,
		token=args.hud_token,
		timeout=args.timeout,
		year=args.year,
		quarter=args.quarter,
		county_name_map=county_name_map,
	)

	output_path = Path(args.output)
	write_rows(output_path, rows)

	unique_zips = {row["zip"] for row in rows}
	unique_counties = {row["county_geoid"] for row in rows if row["county_geoid"]}
	print(f"Saved {len(rows):,} ZIP-county rows to {output_path}")
	print(f"Unique ZIPs: {len(unique_zips):,}")
	print(f"Unique counties: {len(unique_counties):,}")


if __name__ == "__main__":
	main()