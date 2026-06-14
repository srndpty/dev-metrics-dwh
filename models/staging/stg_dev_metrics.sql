select
    project,
    cast(date as date) as metric_date,
    cast(commit_count as integer) as commit_count,
    cast(test_count as integer) as test_count,
    cast(coverage_percent as double) as coverage_percent,
    cast(build_size_mb as double) as build_size_mb
from read_csv_auto('data/raw/dev_metrics.csv')
