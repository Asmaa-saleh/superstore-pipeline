# Superstore pipeline: Airflow + dbt + DuckDB (Docker)

```
Superstore.xlsx ──► load_raw.py ──► DuckDB raw.superstore
                                        │  dbt run
                                        ▼
                      staging.stg_superstore (view)
                                        ▼
        marts.dim_customers / dim_products / dim_geography / dim_date
        marts.fct_sales  ·  marts.mart_monthly_sales
                                        │  dbt test
                                        ▼
                                      done
```

Airflow DAG `superstore_pipeline`:
`check_source_file → load_raw_to_duckdb → dbt_run → dbt_test`

## Run it

```bash
# Linux only: set AIRFLOW_UID in .env to the output of `id -u`
docker compose up --build
```

Open http://localhost:8080 (login `admin` / `admin`), then trigger `superstore_pipeline`.
The warehouse is created at `warehouse/superstore.duckdb`.

## Look at the results

```bash
docker compose exec airflow /opt/airflow/dbt_venv/bin/python scripts/query.py \
  "select category, region, sum(total_sales) as sales from marts.mart_monthly_sales group by 1,2 order by 3 desc"
```

Or from your machine: `duckdb warehouse/superstore.duckdb -readonly`.
DuckDB allows one writer at a time, so don't open the file read-write while the DAG runs.

## Notes

- **Zip codes**: Excel stored them as numbers, so 449 rows lost leading zeros. Staging restores them to 5 digits.
- **Product names**: 32 `product_id`s have more than one name in the source. `dim_products` keeps the latest.
- **Fact grain**: `(order_id, product_id)` is not unique, so `fct_sales` is keyed on `row_id`.
- **Executor**: single container with SQLite + SequentialExecutor, which is enough for DuckDB (single writer).
  For production use Postgres + LocalExecutor/Celery and keep `max_active_runs=1`.
- **Run dbt manually**: `docker compose exec airflow /opt/airflow/dbt_venv/bin/dbt build --project-dir /opt/airflow/dbt_project --profiles-dir /opt/airflow/dbt_project`
