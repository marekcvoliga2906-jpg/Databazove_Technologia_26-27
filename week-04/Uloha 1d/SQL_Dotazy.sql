/*ULOHA 1*/
WITH ranked_orders AS (
    SELECT 
        c.customer_name,
        o.order_id,
        o.order_date,
        ROW_NUMBER() OVER (
            PARTITION BY o.customer_id 
            ORDER BY o.order_date DESC
        ) AS order_rank
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
)
SELECT 
    customer_name,
    order_id,
    order_date
FROM ranked_orders
WHERE order_rank <= 2
ORDER BY customer_name ASC, order_rank ASC;

/*ULOHA 2*/
WITH customer_total_profit AS (
    SELECT 
        c.region,
        c.customer_name,
        SUM(o.profit) AS total_profit
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.region, c.customer_id, c.customer_name
),
ranked_customers AS (
    SELECT 
        region,
        customer_name,
        total_profit,
        RANK() OVER (
            PARTITION BY region 
            ORDER BY total_profit DESC
        ) AS rank_val,
        DENSE_RANK() OVER (
            PARTITION BY region 
            ORDER BY total_profit DESC
        ) AS dense_rank_val
    FROM customer_total_profit
)
SELECT 
    region,
    customer_name,
    total_profit,
    rank_val,
    dense_rank_val
FROM ranked_customers
ORDER BY region ASC, rank_val ASC, customer_name ASC;

/*ULOHA 3*/
WITH customer_total_sales AS (
    SELECT 
        c.customer_name,
        SUM(o.sales) AS total_sales
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name
),
quartile_ranking AS (
    SELECT 
        customer_name,
        total_sales,
        NTILE(4) OVER (ORDER BY total_sales DESC) AS quartile
    FROM customer_total_sales
)
SELECT 
    customer_name,
    total_sales,
    quartile
FROM quartile_ranking
WHERE customer_name LIKE '%Customer_26%'
   OR customer_name = 'Customer_26';

/*ULOHA 4*/
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS month,
        SUM(sales) AS monthly_sales
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT 
    month,
    monthly_sales,
    LAG(monthly_sales, 1) OVER (ORDER BY month) AS prev_month_sales,
    LEAD(monthly_sales, 1) OVER (ORDER BY month) AS next_month_sales
FROM monthly_sales
ORDER BY month ASC;

/*ULOHA 5*/
WITH product_sales_cte AS (
    SELECT 
        p.category,
        p.product_name,
        SUM(o.sales) AS product_sales
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY p.category, p.product_name
)
SELECT 
    category,
    product_name,
    product_sales,
    SUM(product_sales) OVER (PARTITION BY category) AS category_total,
    ROUND(
        product_sales * 100.0 / SUM(product_sales) OVER (PARTITION BY category),
        2
    ) AS pct_of_category
FROM product_sales_cte;

/*ULOHA 6*/
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        o.order_date,
        MAX(o.order_date) OVER (PARTITION BY c.customer_id) AS last_order_date,
        MAX(o.order_date) OVER () AS latest_order_date
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
),
distinct_customer_last_order AS (
    SELECT DISTINCT
        customer_id,
        customer_name,
        last_order_date,
        latest_order_date
    FROM customer_orders
)
SELECT 
    customer_id,
    customer_name,
    last_order_date
FROM distinct_customer_last_order
WHERE last_order_date < latest_order_date - INTERVAL '90 days'
ORDER BY last_order_date ASC;

/*ULOHA 7*/
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS month,
        SUM(sales) AS monthly_sales
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
),
sales_comparison AS (
    SELECT 
        month,
        monthly_sales,
        LAG(monthly_sales) OVER (ORDER BY month) AS prev_month_sales
    FROM monthly_sales
)
SELECT 
    month,
    monthly_sales,
    prev_month_sales,
    (monthly_sales - prev_month_sales) AS sales_change,
    ROUND(((monthly_sales - prev_month_sales) / prev_month_sales) * 100.0, 2) AS growth_percentage
FROM sales_comparison
ORDER BY month ASC;

/*ULOHA 8*/
WITH first_purchases AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', MIN(order_date)) AS first_order_month
    FROM orders
    GROUP BY customer_id
),
returning_customers AS (
    SELECT DISTINCT f.customer_id
    FROM first_purchases f
    JOIN orders o ON f.customer_id = o.customer_id
    WHERE f.first_order_month = '2024-06-01'
      AND DATE_TRUNC('month', o.order_date) > f.first_order_month
)
SELECT COUNT(*) 
FROM returning_customers;