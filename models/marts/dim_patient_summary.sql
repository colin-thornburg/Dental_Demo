{{
    config(
        materialized='table',
        contract={
            'enforced': true
        }
    )
}}

with patients as (
    select * from {{ ref('stg_patients') }}
),

appointments as (
    select * from {{ ref('int_appointments_enriched') }}
),

transactions as (
    select * from {{ ref('int_transactions_enriched') }}
),

brands as (
    select * from {{ ref('stg_brands') }}
),

patient_appointments as (
    select
        patient_id,
        count(*) as total_appointments,
        sum(is_completed) as completed_appointments,
        sum(is_cancelled) as cancelled_appointments,
        sum(is_no_show) as no_show_appointments,
        min(scheduled_date) as first_appointment_date,
        max(scheduled_date) as last_appointment_date,
        count(distinct facility_id) as facilities_visited,
        count(distinct brand_id) as brands_used
    from appointments
    group by 1
),

patient_revenue as (
    select
        patient_id,
        sum(total_revenue) as lifetime_revenue,
        sum(gross_profit) as lifetime_gross_profit,
        sum(insurance_paid) as lifetime_insurance_paid,
        sum(patient_paid) as lifetime_patient_paid,
        count(distinct transaction_id) as total_transactions,
        avg(total_revenue) as avg_transaction_value
    from transactions
    group by 1
),

patient_summary as (
    select
        p.patient_id,
        p.full_name,
        p.date_of_birth,
        p.gender,
        p.city,
        p.state,
        p.zip_code,
        p.acquisition_source,
        p.created_at as patient_created_at,
        p.is_active,
        p.primary_brand_id,
        b.brand_name as primary_brand_name,
        b.category as primary_brand_category,
        
        -- Age calculation (approximate)
        extract(year from current_date) - extract(year from p.date_of_birth) as age,
        
        -- Age group
        case 
            when extract(year from current_date) - extract(year from p.date_of_birth) < 18 then 'Under 18'
            when extract(year from current_date) - extract(year from p.date_of_birth) between 18 and 34 then '18-34'
            when extract(year from current_date) - extract(year from p.date_of_birth) between 35 and 54 then '35-54'
            when extract(year from current_date) - extract(year from p.date_of_birth) between 55 and 64 then '55-64'
            else '65+'
        end as age_group,
        
        -- Appointment metrics
        coalesce(pa.total_appointments, 0) as total_appointments,
        coalesce(pa.completed_appointments, 0) as completed_appointments,
        coalesce(pa.cancelled_appointments, 0) as cancelled_appointments,
        coalesce(pa.no_show_appointments, 0) as no_show_appointments,
        pa.first_appointment_date,
        pa.last_appointment_date,
        coalesce(pa.facilities_visited, 0) as facilities_visited,
        coalesce(pa.brands_used, 0) as brands_used,
        
        -- Revenue metrics
        coalesce(pr.lifetime_revenue, 0) as lifetime_revenue,
        coalesce(pr.lifetime_gross_profit, 0) as lifetime_gross_profit,
        coalesce(pr.lifetime_insurance_paid, 0) as lifetime_insurance_paid,
        coalesce(pr.lifetime_patient_paid, 0) as lifetime_patient_paid,
        coalesce(pr.total_transactions, 0) as total_transactions,
        coalesce(pr.avg_transaction_value, 0) as avg_transaction_value,
        
        -- Calculated fields
        case 
            when coalesce(pa.total_appointments, 0) > 0 
            then round(cast(coalesce(pa.no_show_appointments, 0) as decimal) / pa.total_appointments * 100, 2)
            else 0 
        end as patient_no_show_rate,
        case 
            when coalesce(pa.total_appointments, 0) > 0 
            then round(cast(coalesce(pa.cancelled_appointments, 0) as decimal) / pa.total_appointments * 100, 2)
            else 0 
        end as patient_cancellation_rate
        
    from patients p
    left join brands b on p.primary_brand_id = b.brand_id
    left join patient_appointments pa on p.patient_id = pa.patient_id
    left join patient_revenue pr on p.patient_id = pr.patient_id
)

select 
    patient_id,
    full_name,
    date_of_birth,
    gender,
    city,
    state,
    zip_code,
    acquisition_source,
    patient_created_at,
    is_active,
    primary_brand_id,
    primary_brand_name,
    primary_brand_category,
    age,
    age_group,
    total_appointments,
    completed_appointments,
    cancelled_appointments,
    no_show_appointments,
    first_appointment_date,
    last_appointment_date,
    facilities_visited,
    brands_used,
    lifetime_revenue,
    lifetime_gross_profit,
    lifetime_insurance_paid,
    lifetime_patient_paid,
    total_transactions,
    avg_transaction_value,
    patient_no_show_rate,
    patient_cancellation_rate
from patient_summary
