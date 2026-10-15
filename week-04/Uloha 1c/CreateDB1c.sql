CREATE TABLE retail_sales (
    invoice_no VARCHAR(20),
    stock_code VARCHAR(50),
    description TEXT,
    quantity INT,
    invoice_date TIMESTAMP,
    unit_price DECIMAL(10,2),
    customer_id INT,
    country VARCHAR(100)
);

SET datestyle = 'ISO, DMY';

copy public.retail_sales(invoice_no, stock_code, description, quantity, invoice_date, unit_price, customer_id, country) 
FROM 'E:/Downloads/online_retail.csv' 
WITH (FORMAT csv, DELIMITER ';', HEADER, QUOTE '"', ESCAPE '\');