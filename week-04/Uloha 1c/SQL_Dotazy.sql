/*ULOHA 2*/
WITH calculated_sales AS (
    SELECT 
        customer_id,
        invoice_no,
        invoice_date,
        quantity,
        unit_price,
        (quantity * unit_price) AS revenue
    FROM retail_sales
    WHERE customer_id IS NOT NULL
)
SELECT 
    customer_id,
    invoice_no,
    invoice_date,
    quantity,
    unit_price,
    revenue,
    SUM(revenue) OVER (
        PARTITION BY customer_id 
        ORDER BY invoice_date 
        RANGE BETWEEN INTERVAL '14 days' PRECEDING AND CURRENT ROW
    ) AS revenue_last_14_days
FROM calculated_sales
ORDER BY customer_id ASC, invoice_date ASC;

/*ULOHA 3*/
WITH filtered_sales AS (
    SELECT 
        stock_code,
        country,
        invoice_date,
        quantity
    FROM retail_sales
    WHERE quantity > 1
)
SELECT 
    stock_code,
    country,
    invoice_date,
    quantity,
    ROUND(
        AVG(quantity) OVER (
            PARTITION BY stock_code, country 
            ORDER BY invoice_date 
            RANGE BETWEEN INTERVAL '7 days' PRECEDING AND CURRENT ROW
        ), 2
    ) AS avg_quantity_7_days
FROM filtered_sales
ORDER BY stock_code ASC, country ASC, invoice_date ASC;

/*ULOHA 4*/
WITH unique_invoices AS(
    SELECT
        customer_id,
        invoice_no,
        invoice_date
        FROM retail_sales
        WHERE customer_id IS NOT NULL
        Group BY customer_id, invoice_no, invoice_date
),
lead_invoices AS (
    SELECT
        customer_id,
        invoice_no,
        invoice_date,
        LEAD(invoice_date, 1) OVER (PARTITION BY customer_id ORDER BY invoice_date) AS next_invoice_date
    FROM unique_invoices
)
SELECT 
    customer_id,
    invoice_no,
    invoice_date,
    next_invoice_date,
    EXTRACT(DAY FROM (next_invoice_date - invoice_date)) AS days_to_next_invoice
FROM lead_invoices
WHERE next_invoice_date IS NOT NULL
ORDER BY days_to_next_invoice DESC

/*ULOHA 5*/
WITH price_history AS (
    SELECT 
        stock_code,
        invoice_no,
        invoice_date,
        unit_price AS current_price,
        LAG(unit_price) OVER (
            PARTITION BY stock_code 
            ORDER BY invoice_date
        ) AS previous_price
    FROM retail_sales
)
SELECT 
    stock_code,
    invoice_no,
    invoice_date,
    previous_price,
    current_price,
    (current_price - previous_price) AS price_difference
FROM price_history
WHERE previous_price IS NOT NULL
  AND current_price <> previous_price
ORDER BY invoice_date ASC;

/*ULOHA 6*/
WITH customer_total_sales AS (
    SELECT 
        customer_id,
        SUM(quantity * unit_price) AS total_amount
    FROM retail_sales
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
),
quartile_ranking AS (
    SELECT 
        customer_id,
        total_amount,
        NTILE(4) OVER (ORDER BY total_amount DESC) AS sales_quartile
    FROM customer_total_sales
)
SELECT 
    customer_id,
    total_amount,
    sales_quartile
FROM quartile_ranking
ORDER BY total_amount DESC;

/*ULOHA 7*/
WITH monthly_country_sales AS(
    SELECT
        country,
        DATE_TRUNC('month', invoice_date) AS month,
        SUM(quantity * unit_price) AS total_amount
    FROM retail_sales
    WHERE country IS NOT NULL
    GROUP BY country, DATE_TRUNC('month', invoice_date)
),
quartile_ranking AS (
    SELECT
        country,
        month,
        total_amount,
        -- OPRAVA: PARTITION BY musí byť podľa krajiny (country), nie mesiaca (month)
        NTILE(4) OVER (PARTITION BY country ORDER BY total_amount DESC) AS sales_quartile
    FROM monthly_country_sales
)
SELECT
    country,
    month,
    total_amount,
    sales_quartile
FROM quartile_ranking
ORDER BY country ASC, month ASC;

/*ULOHA 8*/
WITH ranked_sales AS (
    SELECT 
        customer_id,
        invoice_no,
        invoice_date,
        stock_code,
        description,
        quantity,
        unit_price,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id 
            ORDER BY invoice_date ASC
        ) AS rn
    FROM retail_sales
    WHERE customer_id IS NOT NULL
)
SELECT 
    customer_id,
    invoice_no,
    invoice_date,
    stock_code,
    description,
    quantity,
    unit_price
FROM ranked_sales
WHERE rn = 1
ORDER BY customer_id ASC;

/*ULOHA 9*/
WITH item_sales AS (
    SELECT 
        invoice_no,
        stock_code,
        description,
        quantity,
        unit_price,
        (quantity * unit_price) AS amount,
        ROW_NUMBER() OVER (
            PARTITION BY invoice_no 
            ORDER BY (quantity * unit_price) DESC
        ) AS row_num
    FROM retail_sales
)
SELECT 
    invoice_no,
    stock_code,
    description,
    quantity,
    unit_price,
    amount,
    row_num
FROM item_sales
WHERE row_num <= 3
ORDER BY invoice_no ASC, row_num ASC;

/*ULOHA 10*/
WITH customer_monthly_sales AS (
    SELECT 
        country,
        DATE_TRUNC('month', invoice_date) AS month,
        customer_id,
        SUM(quantity * unit_price) AS total_amount
    FROM retail_sales
    WHERE customer_id IS NOT NULL 
      AND country IS NOT NULL
    GROUP BY country, DATE_TRUNC('month', invoice_date), customer_id
),
ranked_customers AS (
    SELECT 
        country,
        month,
        customer_id,
        total_amount,
        DENSE_RANK() OVER (
            PARTITION BY country, month 
            ORDER BY total_amount DESC
        ) AS sales_rank
    FROM customer_monthly_sales
)
SELECT 
    country,
    month,
    customer_id,
    total_amount,
    sales_rank
FROM ranked_customers
WHERE sales_rank <= 5
ORDER BY country ASC, month ASC, sales_rank ASC, customer_id ASC;

/*ULOHA 11*/
WITH ranked_items AS (
    SELECT 
        invoice_no,
        stock_code,
        description,
        quantity,
        unit_price,
        DENSE_RANK() OVER (
            PARTITION BY invoice_no 
            ORDER BY unit_price DESC
        ) AS price_rank
    FROM retail_sales
)
SELECT 
    invoice_no,
    stock_code,
    description,
    quantity,
    unit_price,
    price_rank
FROM ranked_items
WHERE price_rank <= 5
ORDER BY invoice_no ASC, price_rank ASC, stock_code ASC;