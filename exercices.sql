
-- Exercise 1: Number of orders in 2023
SELECT COUNT(DISTINCT orders_id) AS total_orders_2023
FROM `challenge-astrafy.Astrafy.Orders`
WHERE EXTRACT(YEAR FROM DATE(date_date)) = 2023;

-- Exercise 2: Number of orders per month in 2023
SELECT
  FORMAT_DATE('%Y-%m', DATE(date_date)) AS month,
  COUNT(DISTINCT orders_id) AS orders_count
FROM `challenge-astrafy.Astrafy.Orders`
WHERE EXTRACT(YEAR FROM DATE(date_date)) = 2023
GROUP BY month
ORDER BY month;

-- Exercise 3: Average number of products per order for each month in 2023
SELECT
  FORMAT_DATE('%Y-%m', DATE(o.date_date)) AS month,
  AVG(s.product_count) AS avg_products_per_order
FROM (
  SELECT order_id, COUNT(*) AS product_count
  FROM `challenge-astrafy.Astrafy.Sales`
  GROUP BY order_id
) s
JOIN `challenge-astrafy.Astrafy.Orders` o ON o.orders_id = s.order_id
WHERE EXTRACT(YEAR FROM DATE(o.date_date)) = 2023
GROUP BY month
ORDER BY month;

-- Exercise 4: One line per order in 2022 and 2023 with total quantity of products
SELECT
  o.orders_id,
  o.customers_id,
  o.date_date,
  SUM(s.qty) AS qty_product
FROM `challenge-astrafy.Astrafy.Orders` o
JOIN `challenge-astrafy.Astrafy.Sales` s ON o.orders_id = s.order_id
WHERE EXTRACT(YEAR FROM DATE(o.date_date)) IN (2022, 2023)
GROUP BY o.orders_id, o.customers_id, o.date_date;

-- Exercise 5: Segmentation of orders in 2023
WITH all_orders AS (
  SELECT
    o.orders_id,
    o.customers_id,
    o.date_date
  FROM `challenge-astrafy.Astrafy.Orders` o
),
orders_2023 AS (
  SELECT * FROM all_orders
  WHERE EXTRACT(YEAR FROM DATE(date_date)) = 2023
),
past_orders AS (
  SELECT
    o2023.orders_id,
    o2023.customers_id,
    o2023.date_date,
    COUNT(p.orders_id) AS past_12_month_orders
  FROM orders_2023 o2023
  LEFT JOIN all_orders p
    ON o2023.customers_id = p.customers_id
    AND DATE(p.date_date) < DATE(o2023.date_date)
    AND DATE(p.date_date) >= DATE_SUB(DATE(o2023.date_date), INTERVAL 12 MONTH)
  GROUP BY o2023.orders_id, o2023.customers_id, o2023.date_date
)
SELECT *,
  CASE
    WHEN past_12_month_orders = 0 THEN 'New'
    WHEN past_12_month_orders BETWEEN 1 AND 3 THEN 'Returning'
    ELSE 'VIP'
  END AS order_segmentation
FROM past_orders;

-- Exercise 6: Final table with order and segmentation for 2023
WITH order_products AS (
  SELECT
    o.orders_id,
    o.customers_id,
    o.date_date,
    SUM(s.qty) AS qty_product
  FROM `challenge-astrafy.Astrafy.Orders` o
  JOIN `challenge-astrafy.Astrafy.Sales` s ON o.orders_id = s.order_id
  WHERE EXTRACT(YEAR FROM DATE(o.date_date)) = 2023
  GROUP BY o.orders_id, o.customers_id, o.date_date
),
segmentation AS (
  SELECT
    o.orders_id,
    o.customers_id,
    o.date_date,
    COUNT(*) OVER (
      PARTITION BY o.customers_id
      ORDER BY o.date_date
      RANGE BETWEEN INTERVAL 12 MONTH PRECEDING AND CURRENT ROW
    ) AS rolling_order_count
  FROM `challenge-astrafy.Astrafy.Orders` o
  WHERE EXTRACT(YEAR FROM DATE(o.date_date)) = 2023
)
SELECT
  op.*,
  CASE
    WHEN s.rolling_order_count = 1 THEN 'New'
    WHEN s.rolling_order_count BETWEEN 2 AND 4 THEN 'Returning'
    ELSE 'VIP'
  END AS order_segmentation
FROM order_products op
JOIN segmentation s ON op.orders_id = s.orders_id;
