with bounds as (

    select
        min(order_date) as min_date,
        max(ship_date)  as max_date
    from {{ ref('stg_superstore') }}

),

days as (

    select cast(unnest(generate_series(min_date, max_date, interval 1 day)) as date) as date_day
    from bounds

)

select
    date_day,
    extract(year from date_day)            as year,
    extract(quarter from date_day)         as quarter,
    extract(month from date_day)           as month,
    strftime(date_day, '%B')               as month_name,
    strftime(date_day, '%Y-%m')            as year_month,
    extract(isodow from date_day)          as day_of_week,
    strftime(date_day, '%A')               as day_name,
    extract(isodow from date_day) >= 6     as is_weekend
from days
