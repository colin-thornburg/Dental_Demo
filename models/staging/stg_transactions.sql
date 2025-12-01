with source as (
    select * from {{ ref('raw_transactions') }}
),

staged as (
    select
        transaction_id,
        appointment_id,
        patient_id,
        facility_id,
        service_id,
        provider_id,
        treatment_plan_id,
        quantity,
        cast(unit_price as decimal(10,2)) as unit_price,
        cast(discount_amount as decimal(10,2)) as discount_amount,
        cast(insurance_paid as decimal(10,2)) as insurance_paid,
        cast(patient_paid as decimal(10,2)) as patient_paid,
        cast(total_revenue as decimal(10,2)) as total_revenue,
        cast(transaction_date as date) as transaction_date,
        payment_status,
        
        -- Derived fields
        cast(unit_price as decimal(10,2)) * quantity as gross_amount,
        (cast(unit_price as decimal(10,2)) * quantity) - cast(discount_amount as decimal(10,2)) as net_amount
        
    from source
)

select * from staged
