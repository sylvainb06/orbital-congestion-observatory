import pandas as pd
import csv
from pathlib import Path

# Nom du fichier Excel
excel_file = "ucs.xlsx"

# Dossier de sortie
output_dir = Path("data/raw")
output_dir.mkdir(exist_ok=True)

# Ouvre le classeur
xls = pd.ExcelFile(excel_file)

print("Sheets found:")
print(xls.sheet_names)

# Export de chaque feuille
for sheet in xls.sheet_names:

    df = pd.read_excel(
        xls,
        sheet_name=sheet,
        dtype=str,
        engine="openpyxl"
    )

    if df.empty:
        print(f"Skipping {sheet} (empty)")
        continue

    print(f"Exporting {sheet} ({len(df)} rows)")

    df.to_csv(
        output_dir / f"{sheet}.csv",
        index=False,
        encoding="utf-8"
    )

print("Done!")
