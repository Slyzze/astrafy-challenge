SELECT
  CAST(order_id AS STRING)       AS order_id,
  CAST(products_id AS STRING)    AS products_id,
  CAST(customer_id AS STRING)    AS customer_id,
  CAST(net_sales AS FLOAT64)     AS net_sales,
  CAST(qty AS INT64)             AS qty,
  CAST(date_date AS DATE)        AS date_date
FROM
  {{ source('astrafy', 'Sales') }}
