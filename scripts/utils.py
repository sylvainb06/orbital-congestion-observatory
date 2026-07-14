import re
from pathlib import Path

import pandas as pd


def clean_column_name(col):
    """
    Convertit un nom de colonne en snake_case compatible BigQuery.
    """

    col = str(col).strip().lower()

    replacements = {
        " ": "_",
        "/": "_",
        "-": "_",
        ",": "",
        ".": "",
        "(": "",
        ")": "",
        "%": "pct",
        "#": "num",
    }

    for old, new in replacements.items():
        col = col.replace(old, new)

    col = re.sub(r"[^a-z0-9_]", "", col)
    col = re.sub(r"_+", "_", col)
    col = col.strip("_")

    return col

def read_excel(filepath, sheet=0):

    df = pd.read_excel(
        filepath,
        sheet_name=sheet,
        dtype=str,
        engine="openpyxl"
    )

    df.columns = [clean_column_name(c) for c in df.columns]

    return df

def export_csv(df, filepath):

    filepath = Path(filepath)

    filepath.parent.mkdir(parents=True, exist_ok=True)

    df.to_csv(
        filepath,
        index=False,
        encoding="utf-8"
    )

    print(f"✔ Exported {len(df):,} rows -> {filepath}")
