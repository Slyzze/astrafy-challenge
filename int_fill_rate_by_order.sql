SELECT
  FORMAT_DATE('%Y-%m', DATE(o.date_date)) AS month,
  s.products_id,
  SUM(s.qty) AS total_quantity,
  SUM(s.net_sales) AS total_net_sales
FROM {{ ref('stg_sales') }} s
JOIN {{ ref('stg_orders') }} o
  ON CAST(s.order_id AS STRING) = o.orders_id
GROUP BY
  month,
  s.products_id
