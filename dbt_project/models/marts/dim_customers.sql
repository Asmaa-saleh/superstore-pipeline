select
    customer_id,
    customer_name,
    segment
from {{ ref('stg_superstore') }}
qualify row_number() over (partition by customer_id order by order_date desc, row_id desc) = 1
