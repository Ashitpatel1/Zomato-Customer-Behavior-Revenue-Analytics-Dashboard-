

SELECT 'users' , COUNT(*) FROM users
UNION ALL
SELECT 'restaurant', COUNT(*) FROM restaurant
UNION ALL
SELECT 'food', COUNT(*) FROM food
UNION ALL
SELECT 'menu', COUNT(*) FROM menu
UNION ALL
SELECT 'orders', COUNT(*) FROM orders;

alter table orders
modify order_date date; 

SELECT 
    COUNT(*) AS negative_sales
FROM orders
WHERE sales_amount <= 0;

select * from orders 
where sales_amount<=0;

 
SELECT rating, COUNT(*) 
FROM restaurant
GROUP BY rating;

SELECT rating_count, COUNT(*) 
FROM restaurant
GROUP BY rating_count;

SELECT *
FROM orders
WHERE sales_amount >
(
    SELECT AVG(sales_amount)
    FROM orders
);

---------------------------------------------------------------------------------
--  DATA SANITY CHECK

-- 1. Date range of orders
SELECT
    MIN(order_date) AS start_date,
    MAX(order_date) AS end_date
FROM orders;

-- 2. Total orders count
SELECT COUNT(*) AS total_orders
FROM orders;

-- 3. Total revenue
SELECT SUM(sales_amount) AS total_revenue
FROM orders;

-- 4. Orders per year
SELECT
    YEAR(order_date) AS order_year,
    COUNT(*) AS orders_count,
    SUM(sales_amount) AS revenue
FROM orders
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY order_year;

