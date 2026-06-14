select
    project,
    metric_date,
    commit_count,
    test_count,
    coverage_percent,
    build_size_mb,
    case
        when coverage_percent >= 80 then 'good'
        when coverage_percent >= 70 then 'watch'
        when coverage_percent is null then 'unknown'
        else 'risk'
    end as coverage_status
from {{ ref('stg_dev_metrics') }}
