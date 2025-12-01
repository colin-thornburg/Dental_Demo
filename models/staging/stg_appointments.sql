with source as (
    select * from {{ ref('raw_appointments') }}
),

staged as (
    select
        appointment_id,
        patient_id,
        facility_id,
        provider_id,
        cast(scheduled_date as date) as scheduled_date,
        scheduled_time,
        appointment_type,
        status,
        cancellation_reason,
        no_show_flag,
        cast(created_at as timestamp) as created_at,
        cast(confirmed_at as timestamp) as confirmed_at,
        cast(checked_in_at as timestamp) as checked_in_at,
        
        -- Derived fields for analysis
        case 
            when status = 'completed' then 1 
            else 0 
        end as is_completed,
        case 
            when status = 'cancelled' then 1 
            else 0 
        end as is_cancelled,
        case 
            when status = 'no_show' or no_show_flag = true then 1 
            else 0 
        end as is_no_show,
        case 
            when status = 'scheduled' then 1 
            else 0 
        end as is_scheduled
        
    from source
)

select * from staged
