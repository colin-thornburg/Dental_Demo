with source as (
    select * from {{ ref('raw_patients') }}
),

staged as (
    select
        patient_id,
        first_name,
        last_name,
        concat(first_name, ' ', last_name) as full_name,
        email,
        phone,
        cast(date_of_birth as date) as date_of_birth,
        gender,
        address,
        city,
        state,
        zip_code,
        primary_brand_id,
        acquisition_source,
        cast(created_at as timestamp) as created_at,
        is_active
    from source
)

select * from staged
