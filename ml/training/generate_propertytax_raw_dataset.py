import json
from datetime import datetime
from pathlib import Path
import random

import numpy as np
import pandas as pd


SEED = 42
OWNER_COUNT = 2000
PROPERTY_COUNT = 2500
UNIQUE_ROW_COUNT = PROPERTY_COUNT * 2
RAW_ROW_COUNT = 5280
DUPLICATE_ROW_COUNT = RAW_ROW_COUNT - UNIQUE_ROW_COUNT
OUTPUT_FILE = "PropertyTax.csv"
POSITIVE_RATE = 0.39

PROPERTY_CLASS_CONFIGS = [
    {
        "property_type": "Residential",
        "class_code": "RES-01",
        "weight": 0.40,
        "preferred_owner_type": "Individual",
        "assessment_level": 0.20,
        "tax_rate_range": (0.0105, 0.0145),
        "lot_area_range": (60, 320),
        "value_multiplier_range": (3800, 8500),
        "risk": 0.41,
        "zoning": "Residential Zone",
        "land_use": "Single Detached Housing",
    },
    {
        "property_type": "Residential Condo",
        "class_code": "RES-02",
        "weight": 0.08,
        "preferred_owner_type": "Individual",
        "assessment_level": 0.25,
        "tax_rate_range": (0.0115, 0.0155),
        "lot_area_range": (28, 115),
        "value_multiplier_range": (9000, 18500),
        "risk": 0.38,
        "zoning": "Residential High Density",
        "land_use": "Condominium Residential",
    },
    {
        "property_type": "Commercial",
        "class_code": "COM-01",
        "weight": 0.17,
        "preferred_owner_type": "Company",
        "assessment_level": 0.50,
        "tax_rate_range": (0.0130, 0.0185),
        "lot_area_range": (90, 650),
        "value_multiplier_range": (9000, 23500),
        "risk": 0.60,
        "zoning": "Commercial Zone",
        "land_use": "Retail / Office",
    },
    {
        "property_type": "Mixed Use",
        "class_code": "MIX-01",
        "weight": 0.06,
        "preferred_owner_type": "Company",
        "assessment_level": 0.45,
        "tax_rate_range": (0.0125, 0.0175),
        "lot_area_range": (100, 520),
        "value_multiplier_range": (7000, 18500),
        "risk": 0.56,
        "zoning": "Mixed Use Corridor",
        "land_use": "Residential-Commercial",
    },
    {
        "property_type": "Agricultural",
        "class_code": "AGR-01",
        "weight": 0.12,
        "preferred_owner_type": "Individual",
        "assessment_level": 0.40,
        "tax_rate_range": (0.0100, 0.0135),
        "lot_area_range": (500, 5000),
        "value_multiplier_range": (450, 2400),
        "risk": 0.48,
        "zoning": "Agricultural Zone",
        "land_use": "Crop / Orchard Land",
    },
    {
        "property_type": "Industrial",
        "class_code": "IND-01",
        "weight": 0.05,
        "preferred_owner_type": "Company",
        "assessment_level": 0.50,
        "tax_rate_range": (0.0140, 0.0195),
        "lot_area_range": (450, 2200),
        "value_multiplier_range": (5500, 13500),
        "risk": 0.63,
        "zoning": "Industrial Zone",
        "land_use": "Warehouse / Light Manufacturing",
    },
    {
        "property_type": "Residential Vacant Land",
        "class_code": "RVL-01",
        "weight": 0.08,
        "preferred_owner_type": "Individual",
        "assessment_level": 0.20,
        "tax_rate_range": (0.0100, 0.0130),
        "lot_area_range": (90, 900),
        "value_multiplier_range": (1800, 5200),
        "risk": 0.46,
        "zoning": "Residential Expansion Zone",
        "land_use": "Idle Residential Land",
    },
    {
        "property_type": "Commercial Vacant Land",
        "class_code": "CVL-01",
        "weight": 0.04,
        "preferred_owner_type": "Company",
        "assessment_level": 0.40,
        "tax_rate_range": (0.0125, 0.0165),
        "lot_area_range": (120, 1200),
        "value_multiplier_range": (2500, 7600),
        "risk": 0.58,
        "zoning": "Commercial Expansion Zone",
        "land_use": "Idle Commercial Land",
    },
]

FIRST_NAMES = [
    "Juan", "Jose", "Maria", "Ana", "Mark", "Paolo", "Miguel", "Carla", "Angel", "Rafael",
    "Danica", "Kristine", "John Paul", "Mary Grace", "Jessa", "Christian", "Rica", "Jerome",
    "Ella", "Nathan", "Bianca", "Lea", "Adrian", "Camille", "Patrick", "Louise", "Joshua",
    "Sophia", "Trisha", "Vincent", "Katrina", "Pauline", "Ian", "Mikaela", "Noel", "Hazel",
    "Clarence", "Alyssa", "Ramon", "Liza", "Catherine", "Dominic", "Nina", "Francis",
    "Therese", "Althea", "Rommel", "Shaira", "Emman", "Dianne",
]

LAST_NAMES = [
    "Santos", "Reyes", "Cruz", "Bautista", "Garcia", "Mendoza", "Torres", "Flores", "Ramos",
    "Gonzales", "Aquino", "Navarro", "Castro", "Dela Cruz", "Fernandez", "Villanueva", "Mercado",
    "Soriano", "Rosales", "Padilla", "Domingo", "Pascual", "Valdez", "De Leon", "Salazar",
    "Serrano", "Ocampo", "Tolentino", "David", "Malabanan", "Luna", "Manalo", "Bernardo",
    "Samson", "Abad", "Natividad", "Galang", "Macapagal", "Carreon", "Panganiban",
]

COMPANY_PREFIXES = [
    "Davao", "Mindanao", "Apo", "Lanang", "Matina", "Samal", "Tagum", "Panabo", "Toril",
    "Buhangin", "Catalunan", "Maa", "AgriNova", "Durian", "Maharlika", "Rizal", "Malagos",
]

COMPANY_NOUNS = [
    "Holdings", "Realty", "Landholdings", "Developers", "Prime Estates", "Agri Ventures",
    "Industrial Park", "Logistics", "Resources", "Properties", "Business Center", "Farms",
    "Builders", "Urban Homes", "Township", "Commercial Hub",
]

COMPANY_SUFFIXES = ["Inc.", "Corp.", "LLC", "Co.", "Enterprises", "Partners"]

STREET_NAMES = [
    "J.P. Laurel Ave", "R. Castillo St", "McArthur Highway", "Quimpo Blvd", "Buhangin Road",
    "Maa Road", "Diversion Road", "Torres St", "Bonifacio St", "Lacson St", "Matina Aplaya Road",
    "Catalunan Grande Road", "Lanang Road", "Cabaguio Ave", "Bajada Road", "Agdao Road",
]

BUILDING_NAMES = [
    "Avida Towers Davao", "Abreeza Place", "Verdon Parc", "Camella Northpoint", "One Oasis Davao",
    "Matina Enclaves", "Seawind Residences", "Durian Heights", "Apo View Residences", "Lanang Suites",
]

DUE_DATE_SCHEDULE = [(3, 31), (6, 30), (9, 30), (12, 31)]

CORE_NUMERIC_COLUMNS = [
    "lot_area_sqm",
    "market_value",
    "assessed_value",
    "tax_rate",
    "tax_amount",
    "years_as_owner",
    "prior_assessments",
    "prior_late_payments",
    "prior_unpaid_payments",
    "avg_previous_delay_days",
    "outstanding_balance",
    "payment_compliance_score",
]


def set_random_seed() -> None:
    random.seed(SEED)
    np.random.seed(SEED)


def normalize_text(value: str) -> str:
    return " ".join(str(value).strip().lower().split())


def load_region_locations() -> tuple[list[dict[str, str]], list[float], dict[str, set[str]]]:
    json_path = Path(__file__).resolve().parents[2] / "backend" / "PropertyTax.API" / "Data" / "region-xi-locations.json"
    seed_data = json.loads(json_path.read_text(encoding="utf-8-sig"))

    locations: list[dict[str, str]] = []
    weights: list[float] = []

    for province in seed_data["provinces"]:
        for city in province["citiesMunicipalities"]:
            city_weight = 4.5 if city["name"] == "City of Davao" else 1.75 if city["type"] == "City" else 1.0
            province_weight = 1.15 if province["name"] == "Davao Del Sur" else 1.0

            for barangay in city["barangays"]:
                locations.append(
                    {
                        "province": province["name"],
                        "province_code": province["code"],
                        "city_municipality": city["name"],
                        "city_code": city["code"],
                        "city_type": city["type"],
                        "barangay": barangay["name"],
                        "barangay_code": barangay["code"],
                    }
                )
                weights.append(city_weight * province_weight)

    canonical_values = {
        "province": {normalize_text(location["province"]) for location in locations},
        "city_municipality": {normalize_text(location["city_municipality"]) for location in locations},
        "barangay": {normalize_text(location["barangay"]) for location in locations},
    }
    return locations, weights, canonical_values


def choose_location(locations: list[dict[str, str]], weights: list[float]) -> dict[str, str]:
    return random.choices(locations, weights=weights, k=1)[0]


def build_company_name(used_names: set[str]) -> str:
    while True:
        company_name = f"{random.choice(COMPANY_PREFIXES)} {random.choice(COMPANY_NOUNS)} {random.choice(COMPANY_SUFFIXES)}"
        if company_name not in used_names:
            used_names.add(company_name)
            return company_name


def build_individual_name(used_names: set[str]) -> str:
    middle_initials = list("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    while True:
        owner_name = f"{random.choice(FIRST_NAMES)} {random.choice(middle_initials)}. {random.choice(LAST_NAMES)}"
        if owner_name not in used_names:
            used_names.add(owner_name)
            return owner_name


def build_tin(owner_id: int) -> str:
    return f"{(100 + owner_id) % 1000:03d}-{(400 + owner_id * 3) % 1000:03d}-{(700 + owner_id * 7) % 1000:03d}-000"


def build_address(location: dict[str, str], building_type: str, unit_no: str = "") -> str:
    if "Vacant Land" in building_type:
        return f"Lot {random.randint(1, 220)}, Purok {random.randint(1, 12)}, {location['barangay']}, {location['city_municipality']}"

    if "Condo" in building_type:
        building_name = random.choice(BUILDING_NAMES)
        unit_label = unit_no or f"Unit {random.randint(1, 25):02d}{random.choice(['A', 'B', 'C'])}"
        return f"{unit_label}, {building_name}, {location['barangay']}, {location['city_municipality']}"

    house_number = random.randint(8, 980)
    return f"{house_number} {random.choice(STREET_NAMES)}, {location['barangay']}, {location['city_municipality']}"


def build_owner_records(
    locations: list[dict[str, str]], weights: list[float]
) -> tuple[dict[int, dict[str, object]], list[int], list[int]]:
    owner_records: dict[int, dict[str, object]] = {}
    used_names: set[str] = set()
    individual_owner_ids: list[int] = []
    company_owner_ids: list[int] = []

    for owner_id in range(1, OWNER_COUNT + 1):
        taxpayer_type = random.choices(["Individual", "Company"], weights=[0.76, 0.24], k=1)[0]
        owner_name = build_individual_name(used_names) if taxpayer_type == "Individual" else build_company_name(used_names)
        mailing_location = choose_location(locations, weights)

        risk_band = random.choices(["low", "moderate", "high"], weights=[0.38, 0.39, 0.23], k=1)[0]
        if risk_band == "low":
            compliance_anchor = int(np.random.randint(80, 97))
            late_propensity = float(np.random.uniform(0.05, 0.16))
            unpaid_propensity = float(np.random.uniform(0.01, 0.05))
            base_delay_days = int(np.random.randint(4, 16))
        elif risk_band == "moderate":
            compliance_anchor = int(np.random.randint(61, 81))
            late_propensity = float(np.random.uniform(0.16, 0.32))
            unpaid_propensity = float(np.random.uniform(0.04, 0.10))
            base_delay_days = int(np.random.randint(12, 32))
        else:
            compliance_anchor = int(np.random.randint(38, 61))
            late_propensity = float(np.random.uniform(0.30, 0.54))
            unpaid_propensity = float(np.random.uniform(0.10, 0.22))
            base_delay_days = int(np.random.randint(24, 58))

        mailing_address = build_address(mailing_location, "Mailing Address")
        owner_records[owner_id] = {
            "owner_id": owner_id,
            "owner_name": owner_name,
            "taxpayer_type": taxpayer_type,
            "tin": build_tin(owner_id),
            "mailing_address": mailing_address,
            "mailing_city": mailing_location["city_municipality"],
            "mailing_province": mailing_location["province"],
            "compliance_anchor": compliance_anchor,
            "late_propensity": late_propensity,
            "unpaid_propensity": unpaid_propensity,
            "base_delay_days": base_delay_days,
            "ownership_start_year": random.randint(2004, 2021),
        }

        if taxpayer_type == "Individual":
            individual_owner_ids.append(owner_id)
        else:
            company_owner_ids.append(owner_id)

    return owner_records, individual_owner_ids, company_owner_ids


def choose_owner_id(config: dict[str, object], individual_owner_ids: list[int], company_owner_ids: list[int]) -> int:
    if config["preferred_owner_type"] == "Company":
        pool = company_owner_ids if random.random() < 0.78 else individual_owner_ids
    else:
        pool = individual_owner_ids if random.random() < 0.88 else company_owner_ids
    return random.choice(pool)


def build_pin(location: dict[str, str], property_id: int) -> str:
    return f"11-{location['province_code'][-3:]}-{location['city_code'][-3:]}-{property_id:06d}"


def build_property_records(
    owner_records: dict[int, dict[str, object]],
    individual_owner_ids: list[int],
    company_owner_ids: list[int],
    locations: list[dict[str, str]],
    weights: list[float],
) -> list[dict[str, object]]:
    config_weights = [float(config["weight"]) for config in PROPERTY_CLASS_CONFIGS]
    property_records: list[dict[str, object]] = []

    for property_id in range(1, PROPERTY_COUNT + 1):
        config = random.choices(PROPERTY_CLASS_CONFIGS, weights=config_weights, k=1)[0]
        owner_id = choose_owner_id(config, individual_owner_ids, company_owner_ids)
        owner_record = owner_records[owner_id]
        location = choose_location(locations, weights)

        lot_area = int(np.random.randint(int(config["lot_area_range"][0]), int(config["lot_area_range"][1]) + 1))
        location_multiplier = 1.18 if location["city_municipality"] == "City of Davao" else 1.03 if location["city_type"] == "City" else 0.92
        value_multiplier = float(np.random.uniform(config["value_multiplier_range"][0], config["value_multiplier_range"][1]))
        market_value = round(lot_area * value_multiplier * location_multiplier, 2)
        unit_no = ""
        if "Condo" in str(config["property_type"]):
            unit_no = f"Unit {random.randint(1, 28):02d}{random.choice(['A', 'B', 'C', 'D'])}"

        lot_number = f"LOT-{property_id:05d}"
        property_address = build_address(location, str(config["property_type"]), unit_no)
        location_risk = min(
            0.78,
            0.36
            + (0.12 if location["city_municipality"] == "City of Davao" else 0.05 if location["city_type"] == "City" else 0.0)
            + ((int(location["barangay_code"][-2:]) % 10) * 0.014),
        )

        property_records.append(
            {
                "property_id": property_id,
                "owner_id": owner_id,
                "owner_record": owner_record,
                "pin": build_pin(location, property_id),
                "tax_declaration_no": f"TD-11-2024-{property_id:06d}",
                "province": location["province"],
                "city_municipality": location["city_municipality"],
                "barangay": location["barangay"],
                "property_address": property_address,
                "property_type": config["property_type"],
                "class_code": config["class_code"],
                "zoning_classification": config["zoning"],
                "land_use": config["land_use"],
                "lot_number": lot_number,
                "unit_no": unit_no,
                "lot_area_sqm": lot_area,
                "market_value": market_value,
                "assessment_level": float(config["assessment_level"]),
                "tax_rate_range": config["tax_rate_range"],
                "location_risk": location_risk,
                "base_property_risk": float(config["risk"]),
            }
        )

    return property_records


def build_due_date(assessment_year: int, property_id: int) -> datetime:
    month, day = DUE_DATE_SCHEDULE[(property_id + assessment_year) % len(DUE_DATE_SCHEDULE)]
    return datetime(assessment_year, month, day)


def clamp(value: float, lower_bound: float, upper_bound: float) -> float:
    return max(lower_bound, min(value, upper_bound))


def build_history_features(property_record: dict[str, object], assessment_year: int, tax_amount: float) -> dict[str, float | int]:
    owner_record = property_record["owner_record"]
    years_as_owner = max(1, assessment_year - int(owner_record["ownership_start_year"]) + 1)
    prior_assessments = min(8, max(1, years_as_owner - 1 + random.randint(0, 2)))

    late_signal = prior_assessments * float(owner_record["late_propensity"]) + np.random.uniform(0.0, 1.1)
    prior_late_payments = min(prior_assessments, max(0, int(round(late_signal))))

    unpaid_signal = prior_assessments * float(owner_record["unpaid_propensity"]) + np.random.uniform(0.0, 0.7)
    prior_unpaid_payments = min(prior_late_payments, max(0, int(round(unpaid_signal))))

    if prior_late_payments + prior_unpaid_payments == 0:
        avg_previous_delay_days = 0.0
    else:
        avg_previous_delay_days = round(
            float(owner_record["base_delay_days"])
            + (prior_late_payments * 4.2)
            + (prior_unpaid_payments * 15.0)
            + float(np.random.uniform(-3.0, 7.0)),
            1,
        )

    outstanding_multiplier = clamp(
        (prior_unpaid_payments * 0.30) + (prior_late_payments * 0.10) + float(np.random.uniform(0.0, 0.24)),
        0.0,
        2.5,
    )
    outstanding_balance = round(tax_amount * outstanding_multiplier, 2)
    payment_compliance_score = round(
        clamp(
            float(owner_record["compliance_anchor"])
            + (years_as_owner * 0.40)
            - (prior_late_payments * 7.2)
            - (prior_unpaid_payments * 11.5)
            - ((outstanding_balance / max(tax_amount, 1.0)) * 7.5)
            + float(np.random.uniform(-4.0, 4.0)),
            5.0,
            98.0,
        ),
        2,
    )

    return {
        "years_as_owner": years_as_owner,
        "prior_assessments": prior_assessments,
        "prior_late_payments": prior_late_payments,
        "prior_unpaid_payments": prior_unpaid_payments,
        "avg_previous_delay_days": avg_previous_delay_days,
        "outstanding_balance": outstanding_balance,
        "payment_compliance_score": payment_compliance_score,
    }


def build_risk_score(row: dict[str, object], property_record: dict[str, object]) -> float:
    prior_assessments = max(1, int(row["prior_assessments"]))
    prior_late_ratio = float(row["prior_late_payments"]) / prior_assessments
    prior_unpaid_ratio = float(row["prior_unpaid_payments"]) / prior_assessments
    tax_burden_ratio = float(row["tax_amount"]) / max(float(row["market_value"]), 1.0)
    outstanding_ratio = float(row["outstanding_balance"]) / max(float(row["tax_amount"]), 1.0)

    risk_score = (
        float(property_record["base_property_risk"]) * 1.9
        + float(property_record["location_risk"]) * 1.6
        + prior_late_ratio * 2.5
        + prior_unpaid_ratio * 3.0
        + (float(row["avg_previous_delay_days"]) / 120.0) * 1.1
        + outstanding_ratio * 1.9
        + (1.0 - (float(row["payment_compliance_score"]) / 100.0)) * 3.2
        + min(tax_burden_ratio * 50.0, 1.0) * 0.8
        - min(float(row["years_as_owner"]) / 25.0, 1.0) * 0.35
        + float(np.random.uniform(-0.20, 0.20))
    )
    return round(risk_score, 6)


def build_clean_dataset(property_records: list[dict[str, object]]) -> pd.DataFrame:
    assessment_years = [2021, 2022, 2023, 2024]
    positive_count = int(round(UNIQUE_ROW_COUNT * POSITIVE_RATE))
    dataset_rows: list[dict[str, object]] = []

    for property_record in property_records:
        selected_years = sorted(random.sample(assessment_years, 2))
        for assessment_year in selected_years:
            due_date = build_due_date(assessment_year, int(property_record["property_id"]))
            market_growth = float(np.random.uniform(0.96 + ((assessment_year - 2021) * 0.015), 1.05 + ((assessment_year - 2021) * 0.02)))
            market_value = round(float(property_record["market_value"]) * market_growth, 2)
            assessed_value = round(market_value * float(property_record["assessment_level"]), 2)
            tax_rate = round(float(np.random.uniform(property_record["tax_rate_range"][0], property_record["tax_rate_range"][1])), 4)
            tax_amount = round(assessed_value * tax_rate, 2)
            history_features = build_history_features(property_record, assessment_year, tax_amount)
            owner_record = property_record["owner_record"]

            row = {
                "record_id": len(dataset_rows) + 1,
                "owner_id": owner_record["owner_id"],
                "taxpayer_type": owner_record["taxpayer_type"],
                "owner_name": owner_record["owner_name"],
                "tin": owner_record["tin"],
                "mailing_address": owner_record["mailing_address"],
                "mailing_city": owner_record["mailing_city"],
                "mailing_province": owner_record["mailing_province"],
                "property_id": property_record["property_id"],
                "pin": property_record["pin"],
                "tax_declaration_no": property_record["tax_declaration_no"],
                "province": property_record["province"],
                "city_municipality": property_record["city_municipality"],
                "barangay": property_record["barangay"],
                "property_address": property_record["property_address"],
                "property_type": property_record["property_type"],
                "class_code": property_record["class_code"],
                "zoning_classification": property_record["zoning_classification"],
                "land_use": property_record["land_use"],
                "lot_number": property_record["lot_number"],
                "unit_no": property_record["unit_no"],
                "lot_area_sqm": property_record["lot_area_sqm"],
                "market_value": market_value,
                "assessment_level": property_record["assessment_level"],
                "assessed_value": assessed_value,
                "tax_rate": tax_rate,
                "tax_amount": tax_amount,
                "assessment_year": assessment_year,
                "due_date": due_date.strftime("%Y-%m-%d"),
            }
            row.update(history_features)
            row["risk_score"] = build_risk_score(row, property_record)
            dataset_rows.append(row)

    ranked_rows = sorted(dataset_rows, key=lambda item: float(item["risk_score"]), reverse=True)
    for index, row in enumerate(ranked_rows):
        row["is_late_payment"] = 1 if index < positive_count else 0
        row.pop("risk_score", None)

    return pd.DataFrame(dataset_rows)


def validate_clean_dataset(dataset: pd.DataFrame, canonical_values: dict[str, set[str]]) -> None:
    if dataset.shape[0] != UNIQUE_ROW_COUNT:
        raise ValueError(f"Expected {UNIQUE_ROW_COUNT} clean rows, found {dataset.shape[0]}.")

    if dataset[["property_id", "assessment_year"]].duplicated().any():
        raise ValueError("Clean dataset should not contain duplicate property-year pairs.")

    if dataset["property_id"].nunique() != PROPERTY_COUNT:
        raise ValueError("Clean dataset property count mismatch.")

    if not (dataset["property_id"].value_counts() == 2).all():
        raise ValueError("Each property must appear exactly twice in the clean dataset.")

    if dataset[CORE_NUMERIC_COLUMNS].isna().any().any():
        raise ValueError("Core numeric columns contain missing values in the clean dataset.")

    if (dataset[["lot_area_sqm", "market_value", "assessed_value", "tax_rate", "tax_amount"]] <= 0).any().any():
        raise ValueError("Core valuation columns contain non-positive values.")

    if not dataset["is_late_payment"].isin([0, 1]).all():
        raise ValueError("Target variable contains unexpected values.")

    if pd.to_datetime(dataset["due_date"], errors="coerce").isna().any():
        raise ValueError("Clean dataset due dates are not parseable.")

    for column_name in ("province", "city_municipality", "barangay"):
        normalized_values = {normalize_text(value) for value in dataset[column_name].unique()}
        if not normalized_values.issubset(canonical_values[column_name]):
            raise ValueError(f"Unexpected {column_name} values found in the clean dataset.")


def sample_index_slice(dataset: pd.DataFrame, size: int) -> pd.Index:
    return dataset.sample(n=size, random_state=random.randint(1, 1_000_000)).index


def introduce_text_noise(dataset: pd.DataFrame) -> pd.DataFrame:
    raw_dataset = dataset.copy()

    owner_upper_idx = sample_index_slice(raw_dataset, 180)
    raw_dataset.loc[owner_upper_idx, "owner_name"] = raw_dataset.loc[owner_upper_idx, "owner_name"].str.upper()

    owner_lower_idx = sample_index_slice(raw_dataset, 140)
    raw_dataset.loc[owner_lower_idx, "owner_name"] = raw_dataset.loc[owner_lower_idx, "owner_name"].str.lower()

    barangay_space_idx = sample_index_slice(raw_dataset, 200)
    raw_dataset.loc[barangay_space_idx, "barangay"] = "  " + raw_dataset.loc[barangay_space_idx, "barangay"] + " "

    city_case_idx = sample_index_slice(raw_dataset, 150)
    raw_dataset.loc[city_case_idx, "city_municipality"] = raw_dataset.loc[city_case_idx, "city_municipality"].str.upper()

    province_case_idx = sample_index_slice(raw_dataset, 120)
    raw_dataset.loc[province_case_idx, "province"] = raw_dataset.loc[province_case_idx, "province"].str.lower()

    property_type_idx = sample_index_slice(raw_dataset, 160)
    property_type_variants = {
        "Residential": "residential",
        "Residential Condo": "Residential condo",
        "Mixed Use": "Mixed-Use",
        "Residential Vacant Land": "Residential vacant land",
        "Commercial Vacant Land": "commercial vacant land",
    }
    raw_dataset.loc[property_type_idx, "property_type"] = raw_dataset.loc[property_type_idx, "property_type"].replace(property_type_variants)

    mailing_space_idx = sample_index_slice(raw_dataset, 180)
    raw_dataset.loc[mailing_space_idx, "mailing_address"] = raw_dataset.loc[mailing_space_idx, "mailing_address"].apply(lambda value: f" {value}  ")

    pin_space_idx = sample_index_slice(raw_dataset, 120)
    raw_dataset.loc[pin_space_idx, "pin"] = raw_dataset.loc[pin_space_idx, "pin"].apply(lambda value: f" {value}")

    tax_decl_idx = sample_index_slice(raw_dataset, 120)
    raw_dataset.loc[tax_decl_idx, "tax_declaration_no"] = raw_dataset.loc[tax_decl_idx, "tax_declaration_no"].str.replace("-", "/", regex=False)

    us_date_idx = sample_index_slice(raw_dataset, 180)
    raw_dataset.loc[us_date_idx, "due_date"] = pd.to_datetime(raw_dataset.loc[us_date_idx, "due_date"]).dt.strftime("%m/%d/%Y")

    slash_date_idx = sample_index_slice(raw_dataset, 160)
    raw_dataset.loc[slash_date_idx, "due_date"] = pd.to_datetime(
        raw_dataset.loc[slash_date_idx, "due_date"],
        format="mixed",
        errors="coerce",
    ).dt.strftime("%Y/%m/%d")

    return raw_dataset


def append_exact_duplicates(dataset: pd.DataFrame) -> pd.DataFrame:
    duplicate_rows = dataset.sample(n=DUPLICATE_ROW_COUNT, random_state=SEED).copy()
    return pd.concat([dataset, duplicate_rows], ignore_index=True)


def validate_raw_dataset(dataset: pd.DataFrame, canonical_values: dict[str, set[str]]) -> None:
    if dataset.shape[0] != RAW_ROW_COUNT:
        raise ValueError(f"Expected {RAW_ROW_COUNT} raw rows, found {dataset.shape[0]}.")

    exact_duplicate_count = int(dataset.duplicated().sum())
    if exact_duplicate_count != DUPLICATE_ROW_COUNT:
        raise ValueError(f"Expected {DUPLICATE_ROW_COUNT} exact duplicate rows, found {exact_duplicate_count}.")

    if dataset[["record_id", "owner_id", "property_id", "assessment_year", "tax_amount", "is_late_payment"]].isna().any().any():
        raise ValueError("Critical columns contain missing values in the raw dataset.")

    if not dataset["is_late_payment"].isin([0, 1]).all():
        raise ValueError("Raw dataset target variable contains unexpected values.")

    if pd.to_datetime(dataset["due_date"], format="mixed", errors="coerce").isna().any():
        raise ValueError("Raw dataset due dates are not parseable.")

    if (dataset[["lot_area_sqm", "market_value", "assessed_value", "tax_rate", "tax_amount"]] <= 0).any().any():
        raise ValueError("Raw dataset contains invalid core valuation values.")

    if (dataset[["prior_assessments", "prior_late_payments", "prior_unpaid_payments"]] < 0).any().any():
        raise ValueError("Historical delinquency metrics contain negative values.")

    if not (dataset["prior_late_payments"] <= dataset["prior_assessments"]).all():
        raise ValueError("Prior late payments exceed prior assessments in the raw dataset.")

    if not (dataset["prior_unpaid_payments"] <= dataset["prior_late_payments"]).all():
        raise ValueError("Prior unpaid payments exceed prior late payments in the raw dataset.")

    if not dataset["payment_compliance_score"].between(5, 98).all():
        raise ValueError("Payment compliance scores are outside the expected range.")

    if (dataset["outstanding_balance"] < 0).any():
        raise ValueError("Outstanding balance contains negative values.")

    for column_name in ("province", "city_municipality", "barangay"):
        normalized_values = {normalize_text(value) for value in dataset[column_name].unique()}
        if not normalized_values.issubset(canonical_values[column_name]):
            raise ValueError(f"Unexpected {column_name} values found in the raw dataset.")

    positive_rate = float(dataset["is_late_payment"].mean())
    if not 0.25 <= positive_rate <= 0.55:
        raise ValueError(f"Raw dataset target distribution is too extreme: {positive_rate:.4f}")


def main() -> None:
    set_random_seed()
    locations, location_weights, canonical_values = load_region_locations()
    owner_records, individual_owner_ids, company_owner_ids = build_owner_records(locations, location_weights)
    property_records = build_property_records(owner_records, individual_owner_ids, company_owner_ids, locations, location_weights)

    clean_dataset = build_clean_dataset(property_records)
    validate_clean_dataset(clean_dataset, canonical_values)

    raw_dataset = introduce_text_noise(clean_dataset)
    raw_dataset = append_exact_duplicates(raw_dataset)
    raw_dataset = raw_dataset.sample(frac=1, random_state=SEED).reset_index(drop=True)
    validate_raw_dataset(raw_dataset, canonical_values)

    output_path = Path(__file__).resolve().parents[1] / "datasets" / OUTPUT_FILE
    raw_dataset.to_csv(output_path, index=False)

    print(f"Saved dataset to: {output_path}")
    print(f"Dataset shape: {raw_dataset.shape}")
    print(f"Exact duplicate rows: {int(raw_dataset.duplicated().sum())}")
    print("Target distribution:")
    print(raw_dataset["is_late_payment"].value_counts().sort_index().to_string())
    print("First 10 rows:")
    print(raw_dataset.head(10).to_string(index=False))


if __name__ == "__main__":
    main()
