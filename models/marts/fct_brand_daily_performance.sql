{{
    config(
        materialized='table',
        contract={
            'enforced': true
        }
    )
}}

with daily_metrics as (
    select * from {{ ref('fct_daily_facility_metrics') }}
),

brand_daily as (
    select
        metric_date,
        brand_id,
        brand_name,
        brand_code,
        brand_category,
        
        -- Aggregate across facilities
        sum(total_appointments) as total_appointments,
        sum(completed_appointments) as completed_appointments,
        sum(cancelled_appointments) as cancelled_appointments,
        sum(no_show_appointments) as no_show_appointments,
        sum(new_patient_visits) as new_patient_visits,
        sum(unique_patients) as unique_patients,
        sum(total_revenue) as total_revenue,
        sum(total_gross_profit) as total_gross_profit,
        sum(total_transactions) as total_transactions,
        count(distinct facility_id) as active_facilities
        
    from daily_metrics
    group by 1, 2, 3, 4, 5
),

brand_summary as (
    select
        metric_date,
        brand_id,
        brand_name,
        brand_code,
        brand_category,
        total_appointments,
        completed_appointments,
        cancelled_appointments,
        no_show_appointments,
        new_patient_visits,
        unique_patients,
        total_revenue,
        total_gross_profit,
        total_transactions,
        active_facilities,
        
        -- Calculate rates
        case 
            when total_appointments > 0 
            then round(cast(no_show_appointments as decimal) / total_appointments * 100, 2)
            else 0 
        end as no_show_rate,
        case 
            when total_appointments > 0 
            then round(cast(cancelled_appointments as decimal) / total_appointments * 100, 2)
            else 0 
        end as cancellation_rate,
        case 
            when completed_appointments > 0 
            then round(total_revenue / completed_appointments, 2)
            else 0 
        end as revenue_per_visit,
        case 
            when total_revenue > 0 
            then round(total_gross_profit / total_revenue * 100, 2)
            else 0 
        end as gross_margin_pct,
        
        -- Time dimensions for WoW, MoM, YoY comparisons
        extract(year from metric_date) as metric_year,
        extract(month from metric_date) as metric_month,
        extract(week from metric_date) as metric_week,
        extract(dow from metric_date) as metric_day_of_week
        
    from brand_daily
)

select 
    metric_date,
    brand_id,
    brand_name,
    brand_code,
    brand_category,
    total_appointments,
    completed_appointments,
    cancelled_appointments,
    no_show_appointments,
    new_patient_visits,
    unique_patients,
    total_revenue,
    total_gross_profit,
    total_transactions,
    active_facilities,
    no_show_rate,
    cancellation_rate,
    revenue_per_visit,
    gross_margin_pct,
    metric_year,
    metric_month,
    metric_week,
    metric_day_of_week
from brand_summary
