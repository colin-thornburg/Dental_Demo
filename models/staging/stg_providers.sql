with source as (
    select * from {{ ref('raw_providers') }}
),

staged as (
    select
        provider_id,
        brand_id,
        facility_id,
        first_name,
        last_name,
        concat(first_name, ' ', last_name) as full_name,
        credential,
        specialty,
        cast(hire_date as date) as hire_date,
        is_active,
        cast(hourly_rate as decimal(10,2)) as hourly_rate
    from source
)

select * from staged
