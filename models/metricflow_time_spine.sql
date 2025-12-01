{{
    config(
        materialized='table',
    )
}}

-- This time spine is used by MetricFlow for time-based queries
-- It generates a continuous series of dates for the semantic layer

with date_spine as (
    select
        dateadd(
            day,
            seq4(),
            '2020-01-01'::date
        ) as date_day
    from table(generator(rowcount => 3653)) -- ~10 years (2020-2030)
)

select
    cast(date_day as date) as date_day
from date_spine
where date_day <= '2030-12-31'::date

