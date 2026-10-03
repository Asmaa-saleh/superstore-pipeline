-- 32 product_ids appear with more than one product_name in the source.
-- We keep the name from the most recent order line so product_id stays unique.
select
    product_id,
    product_name,
    category,
    sub_category
from {{ ref('stg_superstore') }}
qualify row_number() over (partition by product_id order by order_date desc, row_id desc) = 1
