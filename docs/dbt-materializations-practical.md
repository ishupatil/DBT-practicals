# dbt Materializations — Practical Learning Notes

## 1. What is a materialization?

A materialization determines how dbt persists or represents a model in the target data platform.

The four common materializations are view, table, incremental, and ephemeral.

## 2. View

A view stores a query definition rather than a separate persisted copy of the query result.

Example:

```sql
{{ config(materialized='view') }}

select 1 as id
```

**Remember:** A view is not automatically faster than a table. Performance depends on the platform, query, and data.

## 3. Table

A table stores the model's result as a database table.

Example:

```sql
{{ config(materialized='table') }}

select 1 as id
```

A normal table model is generally rebuilt when dbt executes it. The exact behavior depends on the adapter and configuration.

## 4. Incremental

An incremental model processes a selected subset of records after its initial build instead of rebuilding the entire model each time.

A simplified example:

```sql
{{ config(
    materialized='incremental',
    unique_key='id'
) }}

select
    id,
    updated_at
from {{ ref('source_model') }}

{% if is_incremental() %}
where updated_at > (
    select max(updated_at) from {{ this }}
)
{% endif %}
```

This is an educational example, not a production-ready incremental strategy.

Important considerations:

- The first run generally processes the full source query.
- Later runs use the incremental condition.
- A `unique_key` helps dbt identify matching records for supported incremental strategies; it does not automatically deduplicate duplicate rows in the source.
- Timestamp ties, late-arriving records, updates, null timestamps, and source duplicates need deliberate handling.
- The incremental strategy and behavior depend on the adapter.

## 5. Ephemeral

An ephemeral model is not created as a standalone table or view. dbt incorporates its SQL into downstream model queries, typically as a common table expression.

Example:

```sql
{{ config(materialized='ephemeral') }}

select 1 as id
```

Ephemeral models can be useful for small reusable transformations, but they are not directly queryable as standalone database relations.

## 6. Starter model exercise

The original practice model:

```sql
{{ config(materialized='table') }}

with source_data as (

    select 1 as id
    union all
    select null as id

)

select *
from source_data
where id is not null
```

Expected result:

| id |
|---:|
| 1 |

The `where id is not null` filter removes the row containing `NULL`.

### Exercise

Change the materialization from `table` to `view` and compile the model:

```bash
dbt compile --select my_first_dbt_model
```

Inspect the compiled SQL:

```bash
find target/compiled -type f -name 'my_first_dbt_model.sql'
```

Changing the materialization changes how dbt represents the model when it is executed; it does not change the filtering logic or expected row returned by the query.

Compilation alone does not prove that a view or table was created in the target platform.

## 7. Useful commands

Run these from the directory containing `dbt_project.yml`.

```bash
dbt debug
dbt ls --resource-type model
dbt compile --select my_first_dbt_model
dbt run --select my_first_dbt_model
dbt test
```

- `dbt debug`: check profile configuration and connectivity.
- `dbt ls`: list project resources.
- `dbt compile`: compile model SQL.
- `dbt run`: execute selected models.
- `dbt test`: execute configured tests.

Use `dbt run` and other execution commands only after checking the active target and potential platform costs.

## 8. Current learning checklist

- [x] Understand the basic purpose of dbt models.
- [x] Learn the conceptual differences between view, table, incremental, and ephemeral materializations.
- [x] Understand that `unique_key` does not automatically deduplicate source records.
- [ ] Change the starter model from table to view and compile it.
- [ ] Inspect the compiled SQL.
- [ ] Practise `ref()` and model dependencies.
- [ ] Add and run data-quality tests.

Update this checklist as exercises are completed.
