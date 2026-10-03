-- One row per order line. Renames, casts and light cleaning only.
with source as (

    select * from {{ source('raw', 'superstore') }}

),

cleaned as (

    select
        cast(row_id as integer)                       as row_id,
        order_id,
        cast(order_date as date)                      as order_date,
        cast(ship_date as date)                       as ship_date,
        ship_mode,
        customer_id,
        customer_name,
        segment,
        country,
        city,
        state,
        -- Excel stored zip codes as numbers, which drops leading zeros (06512 -> 6512)
        lpad(cast(postal_code as varchar), 5, '0')    as postal_code,
        region,
        product_id,
        category,
        sub_category,
        product_name,
        cast(sales as decimal(18, 4))                 as sales,
        cast(quantity as integer)                     as quantity,
        cast(discount as decimal(5, 4))               as discount,
        cast(profit as decimal(18, 4))                as profit
    from source

)

select
    *,
    md5(concat_ws('|', country, state, city, postal_code)) as geography_key
from cleaned
