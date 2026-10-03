-- Fails if any row has a negative shipping time
select * from {{ ref('fct_sales') }}
where ship_date < order_date
