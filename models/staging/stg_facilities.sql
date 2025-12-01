with source as (
    select * from {{ ref('raw_facilities') }}
),

staged as (
    select
        facility_id,
        brand_id,
        facility_name,
        facility_code,
        address,
        city,
        state,
        zip_code,
        region,
        cast(opened_date as date) as opened_date,
        is_active,
        capacity_per_day
    from source
)

select * from staged
