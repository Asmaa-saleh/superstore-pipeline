-- Grain: one row per order line (row_id).
-- (order_id, product_id) is NOT unique in the source, so row_id is the key.
select
    row_id                                        as sales_line_id,
    order_id,
    customer_id,
    product_id,
    geography_key,
    order_date,
    ship_date,
    ship_mode,
    date_diff('day', order_date, ship_date)       as days_to_ship,
    sales,
    quantity,
    discount,
    profit
from {{ ref('stg_superstore') }}
