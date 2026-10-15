/*Všetky úlohy v časti CTE riešte nad databázou datacraftinglab_db a 
tabuľkou flourmills_sales, ktoré ste vytvorili a naplnili dátami v úlohe Seminár 2 – Zadanie 1b.*/

/*Uloha 1*/
WITH daily_sales AS (
SELECT sale_date,
SUM(total_amount) AS total_daily_sales
FROM flourmills_sales
GROUP BY sale_date
)
SELECT sale_date, 
total_daily_sales
FROM daily_sales
WHERE total_daily_sales > 3000000
ORDER BY total_daily_sales DESC;

/*Uloha 2*/
WITH category_sales AS (
SELECT product_category,
SUM(total_amount) AS total_sales
FROM flourmills_sales
GROUP BY product_category
)
SELECT product_category, 
total_sales
FROM category_sales
ORDER BY total_sales DESC;

/*Uloha 3*/
WITH product_sales AS (
SELECT product_category,
product_name,
SUM(total_amount) AS total_product_sales
FROM flourmills_sales
GROUP BY product_category, product_name
),
ranked_products AS (
SELECT product_category,
product_name,
total_product_sales,
RANK() OVER(PARTITION BY product_category ORDER BY total_product_sales DESC) AS category_rank
FROM product_sales
)
SELECT product_category,
product_name,
total_product_sales,
category_rank
FROM ranked_products
WHERE category_rank <= 3
ORDER BY product_category ASC, category_rank ASC;

/*Uloha 4*/
WITH customer_revenue AS (
SELECT customer_type,
SUM(total_amount) AS revenue
FROM flourmills_sales
GROUP BY customer_type
),
percentage_calculation AS (
SELECT customer_type,
revenue,
 SUM(revenue) OVER () AS total_revenue,
ROUND((revenue / SUM(revenue) OVER ()) * 100, 2) AS revenue_percentage
FROM customer_revenue
)
SELECT customer_type,
revenue,
total_revenue,
revenue_percentage
FROM percentage_calculation
ORDER BY revenue DESC;

/*Uloha 5*/
WITH ranked_transactions AS (
SELECT customer_id,
product_name,
sale_date,
total_amount,
ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY sale_date DESC) AS row_num
FROM flourmills_sales
)
SELECT customer_id,
product_name,
sale_date,
total_amount
FROM ranked_transactions
WHERE row_num = 1
ORDER BY customer_id ASC;

/*Uloha 6*/
WITH RECURSIVE date_bounds AS (
SELECT MIN(sale_date) AS min_date,
MAX(sale_date) AS max_date
FROM flourmills_sales
),
date_sequence AS (
SELECT min_date AS sale_date
FROM date_bounds
UNION ALL
SELECT (sale_date + INTERVAL '1 day')::DATE
FROM date_sequence
WHERE sale_date < (SELECT max_date FROM date_bounds)
)
SELECT sale_date
FROM date_sequence
ORDER BY sale_date ASC;

/*Uloha 7*/
WITH RECURSIVE monthly_revenue AS (
SELECT DATE_TRUNC('month', sale_date) AS month,
SUM(total_amount) AS revenue
FROM flourmills_sales
GROUP BY DATE_TRUNC('month', sale_date)
),
ordered_months AS (
SELECT ROW_NUMBER() OVER (ORDER BY month) AS rn,
month,
revenue
FROM monthly_revenue
),
cumulative_target AS (
SELECT rn,
month,
revenue,
revenue AS cumulative_revenue
FROM ordered_months
WHERE rn = 1
UNION ALL
SELECT om.rn,
om.month,
om.revenue,
ct.cumulative_revenue + om.revenue AS cumulative_revenue
FROM ordered_months om
JOIN cumulative_target ct ON om.rn = ct.rn + 1
WHERE ct.cumulative_revenue < 500000000
)
SELECT rn,
month,
revenue,
cumulative_revenue
FROM cumulative_target
ORDER BY rn;