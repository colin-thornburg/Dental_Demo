{{
    config(
        materialized='table',
        contract={
            'enforced': true
        }
    )
}}

with appointments as (
    select * from {{ ref('int_appointments_enriched') }}
),

transactions as (
    select * from {{ ref('int_transactions_enriched') }}
),

appointment_metrics as (
    select
        scheduled_date as metric_date,
        facility_id,
        facility_name,
        facility_code,
        facility_city,
        facility_state,
        region,
        brand_id,
        brand_name,
        brand_code,
        brand_category,
        
        count(*) as total_appointments,
        sum(is_completed) as completed_appointments,
        sum(is_cancelled) as cancelled_appointments,
        sum(is_no_show) as no_show_appointments,
        sum(is_scheduled) as scheduled_appointments,
        
        count(distinct patient_id) as unique_patients,
        count(distinct provider_id) as active_providers,
        
        -- New patient visits (first appointment type = new_patient)
        sum(case when appointment_type = 'new_patient' and is_completed = 1 then 1 else 0 end) as new_patient_visits
        
    from appointments
    group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
),

revenue_metrics as (
    select
        transaction_date as metric_date,
        facility_id,
        
        sum(total_revenue) as total_revenue,
        sum(gross_profit) as total_gross_profit,
        sum(insurance_paid) as total_insurance_revenue,
        sum(patient_paid) as total_patient_revenue,
        sum(discount_amount) as total_discounts,
        count(distinct transaction_id) as total_transactions,
        count(distinct patient_id) as paying_patients
        
    from transactions
    group by 1, 2
),

combined as (
    select
        a.metric_date,
        a.facility_id,
        a.facility_name,
        a.facility_code,
        a.facility_city,
        a.facility_state,
        a.region,
        a.brand_id,
        a.brand_name,
        a.brand_code,
        a.brand_category,
        
        -- Appointment metrics
        a.total_appointments,
        a.completed_appointments,
        a.cancelled_appointments,
        a.no_show_appointments,
        a.scheduled_appointments,
        a.unique_patients,
        a.active_providers,
        a.new_patient_visits,
        
        -- Revenue metrics
        coalesce(r.total_revenue, 0) as total_revenue,
        coalesce(r.total_gross_profit, 0) as total_gross_profit,
        coalesce(r.total_insurance_revenue, 0) as total_insurance_revenue,
        coalesce(r.total_patient_revenue, 0) as total_patient_revenue,
        coalesce(r.total_discounts, 0) as total_discounts,
        coalesce(r.total_transactions, 0) as total_transactions,
        
        -- Calculated rates
        case 
            when a.total_appointments > 0 
            then round(cast(a.no_show_appointments as decimal) / a.total_appointments * 100, 2)
            else 0 
        end as no_show_rate,
        case 
            when a.total_appointments > 0 
            then round(cast(a.cancelled_appointments as decimal) / a.total_appointments * 100, 2)
            else 0 
        end as cancellation_rate,
        case 
            when a.completed_appointments > 0 
            then round(coalesce(r.total_revenue, 0) / a.completed_appointments, 2)
            else 0 
        end as revenue_per_visit
        
    from appointment_metrics a
    left join revenue_metrics r 
        on a.metric_date = r.metric_date 
        and a.facility_id = r.facility_id
)

select 
    metric_date,
    facility_id,
    facility_name,
    facility_code,
    facility_city,
    facility_state,
    region,
    brand_id,
    brand_name,
    brand_code,
    brand_category,
    total_appointments,
    completed_appointments,
    cancelled_appointments,
    no_show_appointments,
    scheduled_appointments,
    unique_patients,
    active_providers,
    new_patient_visits,
    total_revenue,
    total_gross_profit,
    total_insurance_revenue,
    total_patient_revenue,
    total_discounts,
    total_transactions,
    no_show_rate,
    cancellation_rate,
    revenue_per_visit
from combined
