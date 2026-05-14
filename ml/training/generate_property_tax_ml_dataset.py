from datetime import datetime
from pathlib import Path
import random

import numpy as np
import pandas as pd


SEED = 42
OWNER_COUNT = 2000
PROPERTY_COUNT = 3000
ROW_COUNT = 6000
OUTPUT_FILE = "property_tax_ml_dataset.csv"
POSITIVE_TARGET_COUNT = ROW_COUNT // 2

PROPERTY_TYPES = ["Residential", "Commercial", "Agricultural"]
PROPERTY_TYPE_WEIGHTS = [0.58, 0.22, 0.20]
ASSESSMENT_LEVELS = {
    "Residential": 0.20,
    "Commercial": 0.50,
    "Agricultural": 0.40,
}
VALUE_MULTIPLIERS = {
    "Residential": (4500, 12500),
    "Commercial": (10000, 25000),
    "Agricultural": (1200, 4500),
}
LOT_AREA_RANGES = {
    "Residential": (50, 350),
    "Commercial": (80, 600),
    "Agricultural": (350, 1000),
}
PROPERTY_TYPE_RISK = {
    "Residential": 0.45,
    "Commercial": 0.62,
    "Agricultural": 0.50,
}

FIRST_NAMES = [
    "Juan",
    "Jose",
    "Maria",
    "Ana",
    "Mark",
    "Paolo",
    "Miguel",
    "Carla",
    "Angel",
    "Rafael",
    "Danica",
    "Kristine",
    "John Paul",
    "Mary Grace",
    "Jessa",
    "Christian",
    "Rica",
    "Jerome",
    "Ella",
    "Nathan",
    "Bianca",
    "Lea",
    "Adrian",
    "Camille",
    "Patrick",
    "Louise",
    "Joshua",
    "Sophia",
    "Trisha",
    "Vincent",
    "Katrina",
    "Pauline",
    "Ian",
    "Mikaela",
    "Noel",
    "Hazel",
    "Clarence",
    "Alyssa",
    "Ramon",
    "Liza",
    "Catherine",
    "Dominic",
    "Nina",
    "Francis",
    "Therese",
    "Althea",
    "Rommel",
    "Shaira",
    "Emman",
    "Dianne",
]

LAST_NAMES = [
    "Santos",
    "Reyes",
    "Cruz",
    "Bautista",
    "Garcia",
    "Mendoza",
    "Torres",
    "Flores",
    "Ramos",
    "Gonzales",
    "Aquino",
    "Navarro",
    "Castro",
    "Dela Cruz",
    "Fernandez",
    "Villanueva",
    "Mercado",
    "Soriano",
    "Rosales",
    "Padilla",
    "Domingo",
    "Pascual",
    "Valdez",
    "De Leon",
    "Salazar",
    "Serrano",
    "Ocampo",
    "Tolentino",
    "David",
    "Malabanan",
    "Luna",
    "Manalo",
    "Bernardo",
    "Samson",
    "Abad",
    "Natividad",
    "Galang",
    "Macapagal",
    "Carreon",
    "Panganiban",
]

BARANGAYS = [
    "Barangay San Isidro",
    "Barangay Poblacion",
    "Barangay Santo Nino",
    "Barangay San Roque",
    "Barangay San Jose",
    "Barangay Mabini",
    "Barangay Bagumbayan",
    "Barangay Rizal",
    "Barangay Maligaya",
    "Barangay San Antonio",
    "Barangay San Miguel",
    "Barangay Holy Spirit",
    "Barangay Kalayaan",
    "Barangay Pag-asa",
    "Barangay Maharlika",
    "Barangay Balintawak",
    "Barangay Santa Lucia",
    "Barangay San Pedro",
    "Barangay Concepcion",
    "Barangay Camachile",
    "Barangay Commonwealth",
    "Barangay Maybunga",
    "Barangay Guadalupe",
    "Barangay Dela Paz",
    "Barangay San Vicente",
    "Barangay Bangkal",
    "Barangay New Lower Bicutan",
    "Barangay Upper Bicutan",
    "Barangay Signal Village",
    "Barangay Talomo",
]

DUE_DATE_SCHEDULE = [
    (3, 31),
    (6, 30),
    (9, 30),
    (11, 30),
]

BARANGAY_RISK_FACTORS = {
    "Barangay San Isidro": 0.43,
    "Barangay Poblacion": 0.58,
    "Barangay Santo Nino": 0.46,
    "Barangay San Roque": 0.49,
    "Barangay San Jose": 0.45,
    "Barangay Mabini": 0.55,
    "Barangay Bagumbayan": 0.47,
    "Barangay Rizal": 0.44,
    "Barangay Maligaya": 0.42,
    "Barangay San Antonio": 0.48,
    "Barangay San Miguel": 0.46,
    "Barangay Holy Spirit": 0.41,
    "Barangay Kalayaan": 0.52,
    "Barangay Pag-asa": 0.50,
    "Barangay Maharlika": 0.54,
    "Barangay Balintawak": 0.53,
    "Barangay Santa Lucia": 0.44,
    "Barangay San Pedro": 0.48,
    "Barangay Concepcion": 0.45,
    "Barangay Camachile": 0.47,
    "Barangay Commonwealth": 0.57,
    "Barangay Maybunga": 0.51,
    "Barangay Guadalupe": 0.59,
    "Barangay Dela Paz": 0.49,
    "Barangay San Vicente": 0.46,
    "Barangay Bangkal": 0.52,
    "Barangay New Lower Bicutan": 0.61,
    "Barangay Upper Bicutan": 0.60,
    "Barangay Signal Village": 0.56,
    "Barangay Talomo": 0.50,
}

LEAKAGE_COLUMNS = {
    "payment_status",
    "payment_date",
    "amount_paid",
    "delay_days",
    "penalty",
}


def set_random_seed() -> None:
    random.seed(SEED)
    np.random.seed(SEED)


def build_owner_lookup() -> dict[int, str]:
    owner_lookup: dict[int, str] = {}
    used_names: set[str] = set()
    middle_initials = list("ABCDEFGHIJKLMNOPQRSTUVWXYZ")

    owner_id = 1
    while owner_id <= OWNER_COUNT:
        first_name = random.choice(FIRST_NAMES)
        last_name = random.choice(LAST_NAMES)
        middle_initial = random.choice(middle_initials)
        owner_name = f"{first_name} {middle_initial}. {last_name}"

        if owner_name in used_names:
            continue

        used_names.add(owner_name)
        owner_lookup[owner_id] = owner_name
        owner_id += 1

    return owner_lookup


def build_owner_profiles(owner_lookup: dict[int, str]) -> dict[int, dict[str, float | int]]:
    owner_profiles: dict[int, dict[str, float | int]] = {}

    for owner_id in owner_lookup:
        risk_band = random.choices(["low", "moderate", "high"], weights=[0.40, 0.37, 0.23], k=1)[0]

        if risk_band == "low":
            compliance_anchor = int(np.random.randint(82, 98))
            late_propensity = float(np.random.uniform(0.06, 0.18))
            unpaid_propensity = float(np.random.uniform(0.01, 0.05))
            base_delay_days = int(np.random.randint(4, 16))
        elif risk_band == "moderate":
            compliance_anchor = int(np.random.randint(62, 82))
            late_propensity = float(np.random.uniform(0.18, 0.34))
            unpaid_propensity = float(np.random.uniform(0.04, 0.10))
            base_delay_days = int(np.random.randint(12, 30))
        else:
            compliance_anchor = int(np.random.randint(38, 63))
            late_propensity = float(np.random.uniform(0.30, 0.55))
            unpaid_propensity = float(np.random.uniform(0.10, 0.22))
            base_delay_days = int(np.random.randint(24, 60))

        owner_profiles[owner_id] = {
            "compliance_anchor": compliance_anchor,
            "late_propensity": late_propensity,
            "unpaid_propensity": unpaid_propensity,
            "base_delay_days": base_delay_days,
        }

    return owner_profiles


def build_property_records(
    owner_lookup: dict[int, str], owner_profiles: dict[int, dict[str, float | int]]
) -> list[dict[str, object]]:
    owner_assignments = list(range(1, OWNER_COUNT + 1))
    owner_assignments.extend(random.sample(range(1, OWNER_COUNT + 1), PROPERTY_COUNT - OWNER_COUNT))
    random.shuffle(owner_assignments)

    property_records: list[dict[str, object]] = []

    for property_id in range(1, PROPERTY_COUNT + 1):
        owner_id = owner_assignments[property_id - 1]
        property_type = random.choices(PROPERTY_TYPES, weights=PROPERTY_TYPE_WEIGHTS, k=1)[0]
        lot_area_min, lot_area_max = LOT_AREA_RANGES[property_type]
        value_min, value_max = VALUE_MULTIPLIERS[property_type]
        lot_area = int(np.random.randint(lot_area_min, lot_area_max + 1))
        multiplier = float(np.random.uniform(value_min, value_max))
        property_value = round(lot_area * multiplier, 2)

        property_records.append(
            {
                "property_id": property_id,
                "owner_id": owner_id,
                "owner_name": owner_lookup[owner_id],
                "property_type": property_type,
                "barangay": random.choice(BARANGAYS),
                "lot_area": lot_area,
                "property_value": property_value,
                "ownership_start_year": random.randint(2005, 2019),
                "owner_profile": owner_profiles[owner_id],
            }
        )

    return property_records


def clamp(value: float, lower_bound: float, upper_bound: float) -> float:
    return max(lower_bound, min(value, upper_bound))


def build_due_date(assessment_year: int, property_id: int) -> datetime:
    month, day = DUE_DATE_SCHEDULE[(property_id + assessment_year) % len(DUE_DATE_SCHEDULE)]
    return datetime(assessment_year, month, day)


def build_history_features(
    property_record: dict[str, object], assessment_year: int, tax_amount: float
) -> dict[str, float | int]:
    owner_profile = property_record["owner_profile"]
    years_as_owner = max(1, assessment_year - int(property_record["ownership_start_year"]) + 1)
    prior_assessments = min(8, max(1, years_as_owner - 1 + random.randint(0, 2)))

    late_signal = prior_assessments * float(owner_profile["late_propensity"]) + np.random.uniform(0.0, 1.25)
    prior_late_payments = min(prior_assessments, max(0, int(round(late_signal))))

    unpaid_signal = prior_assessments * float(owner_profile["unpaid_propensity"]) + np.random.uniform(0.0, 0.65)
    prior_unpaid_payments = min(prior_late_payments, max(0, int(round(unpaid_signal))))

    prior_issue_count = prior_late_payments + prior_unpaid_payments
    if prior_issue_count == 0:
        avg_previous_delay_days = 0.0
    else:
        avg_previous_delay_days = round(
            float(owner_profile["base_delay_days"])
            + (prior_late_payments * 4.5)
            + (prior_unpaid_payments * 17.0)
            + float(np.random.uniform(-3.0, 6.0)),
            1,
        )

    outstanding_multiplier = clamp(
        (prior_unpaid_payments * 0.28) + (prior_late_payments * 0.11) + float(np.random.uniform(0.0, 0.22)),
        0.0,
        2.2,
    )
    outstanding_balance = round(tax_amount * outstanding_multiplier, 2)

    compliance_score = round(
        clamp(
            float(owner_profile["compliance_anchor"])
            + (years_as_owner * 0.45)
            - (prior_late_payments * 7.5)
            - (prior_unpaid_payments * 11.0)
            - ((outstanding_balance / max(tax_amount, 1.0)) * 8.0)
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
        "payment_compliance_score": compliance_score,
    }


def build_risk_score(row: dict[str, object]) -> float:
    prior_assessments = max(1, int(row["prior_assessments"]))
    tax_burden_ratio = float(row["tax_amount"]) / max(float(row["property_value"]), 1.0)
    outstanding_ratio = float(row["outstanding_balance"]) / max(float(row["tax_amount"]), 1.0)
    prior_late_ratio = float(row["prior_late_payments"]) / prior_assessments
    prior_unpaid_ratio = float(row["prior_unpaid_payments"]) / prior_assessments

    risk_score = (
        PROPERTY_TYPE_RISK[str(row["property_type"])] * 1.6
        + BARANGAY_RISK_FACTORS[str(row["barangay"])] * 1.4
        + prior_late_ratio * 2.4
        + prior_unpaid_ratio * 3.0
        + (float(row["avg_previous_delay_days"]) / 120.0) * 1.2
        + outstanding_ratio * 1.8
        + (1.0 - (float(row["payment_compliance_score"]) / 100.0)) * 3.1
        + min(tax_burden_ratio * 45.0, 1.0) * 0.8
        - min(float(row["years_as_owner"]) / 25.0, 1.0) * 0.35
        + float(np.random.uniform(-0.18, 0.18))
    )

    return round(risk_score, 6)


def assign_balanced_target(dataset_rows: list[dict[str, object]]) -> None:
    ranked_rows = sorted(dataset_rows, key=lambda row: float(row["risk_score"]), reverse=True)

    for index, row in enumerate(ranked_rows):
        row["is_late_payment"] = 1 if index < POSITIVE_TARGET_COUNT else 0
        row.pop("risk_score", None)


def build_dataset_rows(property_records: list[dict[str, object]]) -> list[dict[str, object]]:
    dataset_rows: list[dict[str, object]] = []
    assessment_years = list(range(2019, 2027))

    for property_record in property_records:
        selected_years = sorted(random.sample(assessment_years, 2))

        for assessment_year in selected_years:
            due_date = build_due_date(assessment_year, int(property_record["property_id"]))

            assessment_level = ASSESSMENT_LEVELS[property_record["property_type"]]
            growth_floor = 0.94 + ((assessment_year - 2019) * 0.015)
            growth_ceiling = 1.06 + ((assessment_year - 2019) * 0.02)
            growth_factor = float(np.random.uniform(growth_floor, growth_ceiling))
            assessed_value = round(property_record["property_value"] * assessment_level * growth_factor, 2)
            tax_rate = float(np.random.uniform(0.01, 0.02))
            tax_amount = round(assessed_value * tax_rate, 2)
            history_features = build_history_features(property_record, assessment_year, tax_amount)

            row = {
                "owner_id": property_record["owner_id"],
                "owner_name": property_record["owner_name"],
                "property_id": property_record["property_id"],
                "property_type": property_record["property_type"],
                "barangay": property_record["barangay"],
                "lot_area": property_record["lot_area"],
                "property_value": property_record["property_value"],
                "assessment_year": assessment_year,
                "assessed_value": assessed_value,
                "tax_amount": tax_amount,
                "due_date": due_date.strftime("%Y-%m-%d"),
            }
            row.update(history_features)
            row["risk_score"] = build_risk_score(row)
            dataset_rows.append(row)

    assign_balanced_target(dataset_rows)
    return dataset_rows


def validate_dataset(dataset: pd.DataFrame) -> None:
    if dataset.shape[0] != ROW_COUNT:
        raise ValueError(f"Expected {ROW_COUNT} rows, found {dataset.shape[0]}.")

    if dataset.isna().any().any():
        raise ValueError("Dataset contains missing values.")

    if LEAKAGE_COLUMNS.intersection(dataset.columns):
        raise ValueError("Dataset still contains target leakage columns.")

    if dataset[["property_id", "assessment_year"]].duplicated().any():
        raise ValueError("Duplicate property and assessment year combinations were generated.")

    if not dataset["owner_id"].between(1, OWNER_COUNT).all():
        raise ValueError("Owner IDs are outside the requested range.")

    if not dataset["property_id"].between(1, PROPERTY_COUNT).all():
        raise ValueError("Property IDs are outside the requested range.")

    if dataset["property_id"].nunique() != PROPERTY_COUNT:
        raise ValueError("Property count does not match the requested total.")

    property_row_counts = dataset["property_id"].value_counts()
    if not (property_row_counts == 2).all():
        raise ValueError("Each property must have exactly two assessment records.")

    if not (dataset["prior_late_payments"] <= dataset["prior_assessments"]).all():
        raise ValueError("Prior late payments exceed prior assessments for some rows.")

    if not (dataset["prior_unpaid_payments"] <= dataset["prior_late_payments"]).all():
        raise ValueError("Prior unpaid payments exceed prior late payments for some rows.")

    if not dataset["payment_compliance_score"].between(5, 98).all():
        raise ValueError("Payment compliance scores are outside the expected range.")

    if not (dataset["outstanding_balance"] >= 0).all():
        raise ValueError("Outstanding balance contains negative values.")

    target_distribution = dataset["is_late_payment"].value_counts().sort_index().to_dict()
    expected_target_distribution = {0: POSITIVE_TARGET_COUNT, 1: POSITIVE_TARGET_COUNT}

    if target_distribution != expected_target_distribution:
        raise ValueError(f"Unexpected target distribution: {target_distribution}")


def main() -> None:
    set_random_seed()

    owner_lookup = build_owner_lookup()
    owner_profiles = build_owner_profiles(owner_lookup)
    property_records = build_property_records(owner_lookup, owner_profiles)
    dataset_rows = build_dataset_rows(property_records)
    dataset = pd.DataFrame(dataset_rows)
    dataset = dataset.sample(frac=1, random_state=SEED).reset_index(drop=True)

    validate_dataset(dataset)

    output_path = Path(__file__).resolve().parents[1] / "datasets" / OUTPUT_FILE
    dataset.to_csv(output_path, index=False)

    print(f"Saved dataset to: {output_path}")
    print(f"Dataset shape: {dataset.shape}")
    print("First 10 rows:")
    print(dataset.head(10).to_string(index=False))
    print("Target variable distribution:")
    print(dataset["is_late_payment"].value_counts().sort_index().to_string())


if __name__ == "__main__":
    main()