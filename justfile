debug:
    uv run dbt debug --profiles-dir .

run:
    uv run dbt run --profiles-dir .

build:
    uv run dbt build --profiles-dir .

test:
    uv run dbt test --profiles-dir .

clean:
    uv run dbt clean --profiles-dir .

duck:
    uv run python -c "import duckdb; con=duckdb.connect('data/warehouse/dev_metrics.duckdb'); print(con.sql('show tables').df())"
