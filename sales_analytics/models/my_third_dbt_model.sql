select
    id,
    id * 10 as id_multiplied
from {{ ref('my_first_dbt_model') }}