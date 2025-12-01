with source as (
    select * from {{ ref('raw_treatment_plans') }}
),

staged as (
    select
        treatment_plan_id,
        patient_id,
        facility_id,
        provider_id,
        plan_name,
        cast(total_estimated_cost as decimal(10,2)) as total_estimated_cost,
        cast(total_estimated_revenue as decimal(10,2)) as total_estimated_revenue,
        status,
        cast(created_at as timestamp) as created_at,
        cast(accepted_at as timestamp) as accepted_at,
        cast(completed_at as timestamp) as completed_at,
        
        -- Derived fields
        cast(total_estimated_revenue as decimal(10,2)) - cast(total_estimated_cost as decimal(10,2)) as estimated_gross_profit,
        case when status in ('accepted', 'in_progress', 'completed') then 1 else 0 end as is_accepted,
        case when status = 'completed' then 1 else 0 end as is_completed
        
    from source
)

select * from staged
