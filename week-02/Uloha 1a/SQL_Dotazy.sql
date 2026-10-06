/*Uloha 1*/
CREATE VIEW high_value_customers AS
SELECT c.customer_id,
       c.customer_name,
       SUM(o.sales) AS total_sales
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(o.sales) > 2000;
/*Potom na zobrazenie*/
SELECT *
FROM high_value_customers;

/*Uloha 2*/
CREATE VIEW regional_monthly_sales  AS
SELECT c.region,
       o.order_date(MONTH),
       SUM(o.sales) AS monthly_sales
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(o.sales) > 2000;
/*Potom na zobrazenie*/
SELECT *
FROM high_value_customers;