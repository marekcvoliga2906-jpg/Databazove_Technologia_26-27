/*ULOHA 1*/
SELECT 
product_name,
total_amount
FROM flourmills_sales
WHERE total_amount > (
    SELECT AVG(total_amount)
    FROM flourmills_sales
)

/*ULOHA 2*/
SELECT
sales_id,sale_date,region,product_category
FROM flourmills_sales
WHERE product_category = (
    SELECT product_category
    FROM flourmills_sales
    GROUP BY product_category
    ORDER BY SUM(total_amount) DESC
    LIMIT 1
)
ORDER BY sales_id ASC;

/*ULOHA 3*/
SELECT
product_name,total_amount,
(SELECT AVG(total_amount) FROM flourmills_sales) as avg_amount
FROM flourmills_sales
/*WHERE total_amount = 9511208.41
pre rýchlejšie nájdenie produktu s presnou hodnotou do úlohy
*/

/*ULOHA 4*/
SELECT 
product_name,
total_amount,
total_amount / (SELECT SUM(total_amount) FROM flourmills_sales) as amount_share
FROM flourmills_sales
/*Správna odpoveď A ja som dal B... Nečítam desatinky v amount_share mb :( */

/*ULOHA 5*/
SELECT *
FROM (
    SELECT 
    EXTRACT(MONTH FROM sale_date) as month,
    SUM(total_amount) AS monthly_sales
    FROM flourmills_sales
    GROUP BY month
) AS t
ORDER BY monthly_sales DESC; 

/*ULOHA 6*/
SELECT *
FROM (
    SELECT product_category,SUM(total_amount) as total_sales
    FROM flourmills_sales
    GROUP BY product_category
) as t
WHERE total_sales > 50000000
ORDER BY total_sales DESC;

/*ULOHA 7*/
SELECT 
product_name,
product_category,
total_amount
FROM flourmills_sales t1
WHERE total_amount > (
    SELECT AVG(total_amount)
    FROM flourmills_sales t2
    WHERE t2.product_category = t1.product_category
);

/*ULOHA 8*/
SELECT
product_name,
region,
total_amount,
(
    SELECT MIN(t2.total_amount)
    FROM flourmills_sales t2
    WHERE t2.region = t1.region
) AS region_min_amount
FROM flourmills_sales t1;

/*ULOHA 9*/
/*vo viac ako jednom rôznom mesiaci*/
/*Nachádza sa aspoň v dvoch rôznych mesiacoch = PRAVDA*/ 
SELECT *
FROM flourmills_sales t1
WHERE EXISTS (
    SELECT 1
    FROM flourmills_sales t2
    WHERE t2.product_name = t1.product_name
    HAVING COUNT(DISTINCT EXTRACT(MONTH FROM t2.sale_date)) > 1
);

/*ULOHA 10*/
SELECT
product_category,
product_name,
total_amount
FROM flourmills_sales t1
WHERE EXISTS (
    SELECT 1
    FROM flourmills_sales t2
    WHERE t2.product_category = t1.product_category
    AND t2.total_amount > 200000
);

/*ULOHA 11*/
SELECT DISTINCT
product_category
FROM flourmills_sales t1
WHERE EXISTS (
    SELECT 1
    FROM flourmills_sales t2
    WHERE t2.product_category = t1.product_category
    HAVING COUNT(DISTINCT t2.region) > 3
);

/*ULOHA 12*/
SELECT *
FROM flourmills_sales t1
WHERE EXISTS (
    SELECT 1
    FROM flourmills_sales t2
    WHERE t2.region = t1.region
      AND EXTRACT(YEAR FROM t2.sale_date) = 2024
);

/*ULOHA 13*/
SELECT DISTINCT
product_category
FROM flourmills_sales t1
WHERE NOT EXISTS (
    SELECT 1
    FROM flourmills_sales t2
    WHERE t2.product_category = t1.product_category
    AND t2.total_amount >  500000
);

/*ULOHA 14*/
SELECT DISTINCT
region
FROM flourmills_sales t1
WHERE NOT EXISTS (
    SELECT 1
    FROM flourmills_sales t2
    WHERE t2.region = t1.region
      AND t2.product_category = 'Flour'
);