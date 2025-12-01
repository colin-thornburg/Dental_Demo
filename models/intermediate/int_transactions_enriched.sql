{{
    config(
        materialized='view'
    )
}}

with transactions as (
    select * from {{ ref('stg_transactions') }}
),

services as (
    select * from {{ ref('stg_services') }}
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
        -- Transaction info
        t.transaction_id,
        t.transaction_date,
        t.quantity,
        t.unit_price,
        t.discount_amount,
        t.insurance_paid,
        t.patient_paid,
        t.total_revenue,
        t.gross_amount,
        t.net_amount,
        t.payment_status,
        
        -- Service info
        t.service_id,
        s.service_code,
        s.service_name,
        s.service_category,
        s.standard_price,
        s.cost as service_cost,
        s.gross_margin as service_gross_margin,
        
        -- Calculated cost and profit
        s.cost * t.quantity as total_cost,
        t.total_revenue - (s.cost * t.quantity) as gross_profit,
        
        -- Appointment and treatment plan references
        t.appointment_id,
        t.treatment_plan_id,
        
        -- Patient info
        t.patient_id,
        p.full_name as patient_name,
        p.acquisition_source,
        
        -- Provider info
        t.provider_id,
        pr.full_name as provider_name,
        pr.specialty as provider_specialty,
        
        -- Facility info
        t.facility_id,
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
        extract(year from t.transaction_date) as transaction_year,
        extract(month from t.transaction_date) as transaction_month,
        extract(week from t.transaction_date) as transaction_week,
        extract(dow from t.transaction_date) as transaction_day_of_week
        
    from transactions t
    left join services s on t.service_id = s.service_id
    left join facilities f on t.facility_id = f.facility_id
    left join brands b on f.brand_id = b.brand_id
    left join patients p on t.patient_id = p.patient_id
    left join providers pr on t.provider_id = pr.provider_id
)

select * from enriched
