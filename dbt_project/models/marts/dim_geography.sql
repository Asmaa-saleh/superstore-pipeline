select distinct
    geography_key,
    country,
    region,
    state,
    city,
    postal_code
from {{ ref('stg_superstore') }}
