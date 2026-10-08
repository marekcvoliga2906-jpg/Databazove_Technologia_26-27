/*Uloha 1*/
CREATE VIEW high_value_customers AS
SELECT c.customer_id,
c.customer_name,
SUM(o.sales) AS total_sales
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(o.sales) > 2000;

SELECT *
FROM high_value_customers;

/*Uloha 2*/
CREATE VIEW regional_monthly_sales AS
SELECT c.region,
DATE_TRUNC('month', o.order_date) AS month,
SUM(o.sales) AS monthly_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.region, DATE_TRUNC('month', o.order_date);
/*Potom na zobrazenie*/
SELECT * FROM regional_monthly_sales
WHERE region = 'West'

/*Uloha 3*/
CREATE VIEW analyst_orders AS
SELECT order_id,customer_id,product_id,sales,quantity,discount
FROM orders
/*Potom na zobrazenie*/
SELECT *
FROM analyst_orders;

/*Uloha 4*/
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
/*Potom na zobrazenie*/
SELECT *
FROM orders
WHERE customer_id = 'C001';

/*Uloha 5*/
CREATE INDEX idx_orders_order_date ON orders(order_date);
/*Potom na zobrazenie*/
SELECT DATE_TRUNC('month', order_date) AS order_month,
SUM(sales) AS total_sales
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY order_month ASC;

/*Uloha 6*/
CREATE INDEX idx_orders_region_category ON orders(customer_id, order_date);
/*Potom na zobrazenie*/
SELECT o.profit
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE c.region = 'West'
AND o.order_date >= '2024-01-01'
AND c.customer_name = 'Customer_25';

/*Uloha 8*/
CREATE OR REPLACE PROCEDURE get_customer_sales(p_customer_id VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
v_total_sales DECIMAL(10,2); 
BEGIN
SELECT COALESCE(SUM(sales), 0) INTO v_total_sales
FROM orders
WHERE customer_id = p_customer_id;
RAISE NOTICE 'Celkový predaj pre zákazníka % je: %', p_customer_id, v_total_sales;
END;
$$;
/*Potom na zobrazenie*/
CALL get_customer_sales('C001');
/*retail_sales.csv má customer_id ako "CUST00100" a nie "C001" takže výsledok je "C001" je 0.00*/
/*Pre CUST00100 je to napríklad 14897.42*/

/*Uloha 9*/
CREATE OR REPLACE PROCEDURE apply_regional_discount(p_region_name VARCHAR, p_discount_rate DECIMAL)
LANGUAGE plpgsql
AS $$
BEGIN
UPDATE orders
SET sales = sales * (1 - p_discount_rate)
 WHERE customer_id IN (
SELECT customer_id
FROM customers
WHERE region = p_region_name
 );
RAISE NOTICE 'Aplikovaná zľava % na objednávky zákazníkov z regiónu %.', p_discount_rate, p_region_name;
END;
$$;
/*Potom na zobrazenie*/
CALL apply_regional_discount('West', 0.10);

/*Uloha 10*/
CREATE OR REPLACE PROCEDURE get_sales_between(p_start_date DATE, p_end_date DATE)
LANGUAGE plpgsql
AS $$
DECLARE
v_total_sales DECIMAL(15,2); 
BEGIN
SELECT COALESCE(SUM(sales), 0) INTO v_total_sales
FROM orders
WHERE order_date BETWEEN p_start_date AND p_end_date;
RAISE NOTICE 'Predaj od % do % je: %', p_start_date, p_end_date, v_total_sales;
END;
$$;
/*Potom na zobrazenie*/
CALL get_sales_between('2024-01-01', '2024-03-31');