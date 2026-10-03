FROM apache/airflow:2.10.5-python3.11

# dbt + DuckDB live in their own virtualenv so their dependencies never
# clash with Airflow's pinned dependencies.
COPY requirements-dbt.txt /tmp/requirements-dbt.txt
RUN python -m venv /opt/airflow/dbt_venv \
 && /opt/airflow/dbt_venv/bin/pip install --no-cache-dir -r /tmp/requirements-dbt.txt

# Directory for the Airflow metadata DB (backed by a named volume)
RUN mkdir -p /opt/airflow/db
