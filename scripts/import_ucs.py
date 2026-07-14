from pathlib import Path

from utils import read_excel, export_csv


INPUT = Path("data/raw/ucs.xlsx")

OUTPUT = Path("data/raw/ucs.csv")


df = read_excel(INPUT)

export_csv(df, OUTPUT)
