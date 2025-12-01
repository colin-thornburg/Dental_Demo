{{
    config(
        materialized='view'
    )
}}

with appointments as (
    select * from {{ ref('stg_appointments') }}
),

facilities as (
    select * from {{ ref('stg_facilities') }}
),

brands as (
    select * from {{ ref('stg_brands') }}
),

patients as (
    select * from {{ ref('stg_patients') }}
),

providers as (
    select * from {{ ref('stg_providers') }}
),

enriched as (
    select
        -- Appointment info
        a.appointment_id,
        a.scheduled_date,
        a.scheduled_time,
        a.appointment_type,
        a.status,
        a.cancellation_reason,
        a.is_completed,
        a.is_cancelled,
        a.is_no_show,
        a.is_scheduled,
        a.created_at as appointment_created_at,
        a.confirmed_at,
        a.checked_in_at,
        
        -- Patient info
        a.patient_id,
        p.full_name as patient_name,
        p.date_of_birth as patient_dob,
        p.gender as patient_gender,
        p.city as patient_city,
        p.state as patient_state,
        p.acquisition_source,
        
        -- Provider info
        a.provider_id,
        pr.full_name as provider_name,
        pr.credential as provider_credential,
        pr.specialty as provider_specialty,
        
        -- Facility info
        a.facility_id,
        f.facility_name,
        f.facility_code,
        f.city as facility_city,
        f.state as facility_state,
        f.region,
        
        -- Brand info
        f.brand_id,
        b.brand_name,
        b.brand_code,
        b.category as brand_category,
        
        -- Time dimensions
        extract(year from a.scheduled_date) as appointment_year,
        extract(month from a.scheduled_date) as appointment_month,
        extract(week from a.scheduled_date) as appointment_week,
        extract(dow from a.scheduled_date) as appointment_day_of_week
        
    from appointments a
    left join facilities f on a.facility_id = f.facility_id
    left join brands b on f.brand_id = b.brand_id
    left join patients p on a.patient_id = p.patient_id
    left join providers pr on a.provider_id = pr.provider_id
)

select * from enriched
