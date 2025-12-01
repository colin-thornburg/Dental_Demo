with source as (
    select * from {{ ref('raw_services') }}
),

staged as (
    select
        service_id,
        brand_id,
        service_code,
        service_name,
        service_category,
        cast(standard_price as decimal(10,2)) as standard_price,
        cast(cost as decimal(10,2)) as cost,
        duration_minutes,
        is_active,
        cast(standard_price as decimal(10,2)) - cast(cost as decimal(10,2)) as gross_margin
    from source
)

select * from staged
