with source as (
    select * from {{ ref('raw_brands') }}
),

staged as (
    select
        brand_id,
        brand_name,
        brand_code,
        category,
        founded_year,
        is_active
    from source
)

select * from staged
