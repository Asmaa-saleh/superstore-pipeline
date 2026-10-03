"""Run an ad-hoc SQL query against the warehouse (read-only).

Usage: python scripts/query.py "select * from marts.fct_sales limit 5"
"""
import os
import sys

import duckdb

path = os.environ.get("DUCKDB_PATH", "/opt/airflow/warehouse/superstore.duckdb")
con = duckdb.connect(path, read_only=True)
print(con.execute(sys.argv[1]).fetchdf().to_string(index=False))
