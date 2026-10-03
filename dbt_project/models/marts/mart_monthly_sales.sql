-- Monthly KPIs by category and region, ready for a BI tool.
select
    date_trunc('month', f.order_date)::date                  as order_month,
    p.category,
    g.region,
    count(distinct f.order_id)                               as orders,
    sum(f.quantity)                                          as units_sold,
    sum(f.sales)                                             as total_sales,
    sum(f.profit)                                            as total_profit,
    sum(f.profit) / nullif(sum(f.sales), 0)                  as profit_margin
from {{ ref('fct_sales') }} f
join {{ ref('dim_products') }}  p on f.product_id = p.product_id
join {{ ref('dim_geography') }} g on f.geography_key = g.geography_key
group by 1, 2, 3
