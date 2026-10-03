"""Load the Superstore Excel file into DuckDB (raw.superstore).

Idempotent: the table is fully replaced on every run.
"""
import os
import re
import sys

import duckdb
import pandas as pd

SOURCE_FILE = os.environ.get("SOURCE_FILE", "/opt/airflow/data/Superstore.xlsx")
DUCKDB_PATH = os.environ.get("DUCKDB_PATH", "/opt/airflow/warehouse/superstore.duckdb")


def snake(col: str) -> str:
    return re.sub(r"[^0-9a-z]+", "_", col.strip().lower()).strip("_")


def main() -> None:
    if not os.path.exists(SOURCE_FILE):
        sys.exit(f"Source file not found: {SOURCE_FILE}")

    df = pd.read_excel(SOURCE_FILE)
    df.columns = [snake(c) for c in df.columns]
    df["_loaded_at"] = pd.Timestamp.now()

    con = duckdb.connect(DUCKDB_PATH)
    try:
        con.execute("CREATE SCHEMA IF NOT EXISTS raw")
        con.register("src_df", df)
        con.execute("CREATE OR REPLACE TABLE raw.superstore AS SELECT * FROM src_df")
        rows = con.execute("SELECT count(*) FROM raw.superstore").fetchone()[0]
    finally:
        con.close()

    print(f"Loaded {rows} rows from {SOURCE_FILE} into {DUCKDB_PATH} (raw.superstore)")
    if rows != len(df):
        sys.exit("Row count mismatch after load")


if __name__ == "__main__":
    main()
