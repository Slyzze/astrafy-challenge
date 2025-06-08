SELECT
  CAST(orders_id AS STRING)       AS orders_id,
  CAST(customers_id AS STRING)   AS customers_id,
  CAST(date_date AS DATE)        AS date_date
FROM
  {{ source('astrafy', 'Orders') }}
