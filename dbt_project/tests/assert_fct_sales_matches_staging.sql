-- Fails if the fact table loses or gains sales/rows versus staging
with s as (select count(*) as n, sum(sales) as total from {{ ref('stg_superstore') }}),
     f as (select count(*) as n, sum(sales) as total from {{ ref('fct_sales') }})
select s.n as stg_rows, f.n as fct_rows, s.total as stg_sales, f.total as fct_sales
from s, f
where s.n <> f.n or s.total <> f.total
