"""Superstore ELT: Excel -> DuckDB (raw) -> dbt (staging, marts) -> dbt tests."""
from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator

PY = "/opt/airflow/dbt_venv/bin/python"
DBT = "/opt/airflow/dbt_venv/bin/dbt"
DBT_ARGS = "--project-dir /opt/airflow/dbt_project --profiles-dir /opt/airflow/dbt_project"

default_args = {
    "owner": "data-eng",
    "retries": 1,
    "retry_delay": timedelta(minutes=2),
}

with DAG(
    dag_id="superstore_pipeline",
    description="Load Superstore.xlsx into DuckDB and transform it with dbt",
    start_date=datetime(2024, 1, 1),
    schedule="@daily",
    catchup=False,
    max_active_runs=1,  # DuckDB allows a single writer at a time
    default_args=default_args,
    tags=["superstore", "dbt", "duckdb"],
) as dag:

    check_source = BashOperator(
        task_id="check_source_file",
        bash_command="test -f /opt/airflow/data/Superstore.xlsx",
    )

    load_raw = BashOperator(
        task_id="load_raw_to_duckdb",
        bash_command=f"{PY} /opt/airflow/scripts/load_raw.py",
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=f"{DBT} run {DBT_ARGS}",
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=f"{DBT} test {DBT_ARGS}",
    )

    check_source >> load_raw >> dbt_run >> dbt_test
