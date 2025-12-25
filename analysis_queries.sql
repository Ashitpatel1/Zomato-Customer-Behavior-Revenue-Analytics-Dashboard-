-- Monthly Orders & Revenue Trend

SELECT
    YEAR(order_date)  AS order_year,
    MONTH(order_date) AS order_month,
   count(*)          AS total_orders,
    SUM(sales_amount) AS total_revenue
FROM orders
WHERE order_date IS NOT NULL
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    order_year,
    order_month;
    
    
    
-- 2 Month-over-Month (MoM) Growth %
    
WITH monthly_data AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS order_month,
        COUNT(*) AS orders,
        SUM(sales_amount) AS revenue
    FROM orders
    WHERE order_date IS NOT NULL
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
    )
SELECT
    order_month,
    orders,
    revenue,
    LAG(revenue) OVER (ORDER BY order_month) AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY order_month))
        / LAG(revenue) OVER (ORDER BY order_month) * 100, 2
    ) AS mom_growth_pct
FROM monthly_data;

-- 3 Year-over-Year (YoY) Growth

WITH yearly_data AS (
    SELECT
        YEAR(order_date) AS order_year,
        SUM(sales_amount) AS revenue
    FROM orders
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date)
)
SELECT
    order_year,
    revenue,
    LAG(revenue) OVER (ORDER BY order_year) AS prev_year_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY order_year))
        / LAG(revenue) OVER (ORDER BY order_year) * 100, 2
    ) AS yoy_growth_pct
FROM yearly_data;

--------------------------------------------------------------------------------

-- CUSTOMER ANALYTICS

-- Validate customer data

SELECT 
    COUNT(DISTINCT user_id) AS total_customers,
    COUNT(*) AS total_orders
FROM orders;

-- Orders per customer

SELECT 
    user_id,
    COUNT(order_id) AS total_orders,
    SUM(sales_amount) AS total_spent
FROM orders
GROUP BY user_id;

-- New vs Repeat Customers

SELECT user_id,
    CASE 
        WHEN COUNT(user_id) = 1 THEN 'New'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS customer_count
FROM orders
GROUP BY user_id;

-- % of repeat customers

WITH customer_orders AS (
SELECT user_id,
	COUNT(order_id) AS order_count
    FROM orders
    GROUP BY user_id
)
SELECT
    ROUND( SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS repeat_customer_percentage
FROM customer_orders;


-- Top 10 High-Value Customers

SELECT 
    user_id, COUNT(order_id) AS total_orders,
    SUM(sales_amount) AS lifetime_spend
FROM orders
GROUP BY user_id
ORDER BY lifetime_spend DESC
LIMIT 10;


-- Customer Lifetime Value

SELECT 
    user_id,
    ROUND(AVG(sales_amount), 2) AS avg_order_value,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(sales_amount), 2) AS lifetime_value
FROM orders
GROUP BY user_id;


 -- RESTAURANT ANALYTICS
 
 -- Orders & revenue per restaurant
 
 SELECT
    r_id,
    COUNT(order_id) AS total_orders,
    SUM(sales_amount) AS total_revenue
FROM orders
GROUP BY r_id
ORDER BY total_revenue DESC;

-- Top 5 cities with most revenue 

select r.city, sum(o.sales_amount) as Total_revenue
from restaurant r join orders o
on r.r_id= o.r_id
group by city 
order by Total_revenue desc
limit 5;


select r.r_id,r.name,r.city,
count(o.order_id), sum(o.sales_amount) as revenue
from orders o join restaurant r
ON o.r_id = r.r_id 
group by r.r_id, name, city
ORDER BY revenue DESC
;

-- Average Order Value per restaurant

select r.r_id as restaurant_id , r.name , round(avg(o.sales_amount),2) as avg_order_value
from orders o join restaurant r
on o.r_id =r.r_id
group by r.r_id,r.name
order by avg_order_value DESC;


-- Top 10 restaurants by revenue

select r.name ,count(o.order_id) as Total_orders ,sum(o.sales_amount) as revenue
from orders o join restaurant r 
on o.r_id = r.r_id 
group by r.name
order by revenue desc 
limit 10;

-- Low performing restaurants

SELECT
    r.name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.sales_amount) AS revenue
FROM restaurant r
left JOIN orders o 
    ON r.r_id = o.r_id
GROUP BY r.name
HAVING COUNT(o.order_id) < 10
   OR SUM(o.sales_amount) < 5000;
   
-- Yearly performance per restaurant

SELECT
    r.name,
    YEAR(o.order_date) AS order_year,
    COUNT(o.order_id) AS total_orders,
    SUM(o.sales_amount) AS revenue
FROM orders o
JOIN restaurant r 
    ON o.r_id = r.r_id
GROUP BY r.name, YEAR(o.order_date)
ORDER BY r.name, order_year;

-- City-level restaurant revenue

SELECT
    r.city,
    COUNT(DISTINCT r.r_id) AS restaurant_count,
    SUM(o.sales_amount) AS city_revenue
FROM orders o
JOIN restaurant r 
ON o.r_id = r.r_id
GROUP BY r.city
ORDER BY city_revenue DESC
limit 5;

-- Bottom restaurants by revenue

SELECT
    r_id,
    SUM(sales_amount) AS revenue
FROM orders
where sales_amount>1 
GROUP BY r_id
ORDER BY revenue
LIMIT 5;


-- FOOD / PRODUCT ANALYTICS 

SELECT
    f.veg_or_non_veg,
    COUNT(o.order_id) AS total_orders,
    SUM(o.sales_amount) AS total_revenue
FROM orders o
JOIN menu m 
    ON o.r_id = m.r_id
JOIN food f 
    ON m.f_id = f.f_id
GROUP BY f.veg_or_non_veg;



SELECT
    MONTH(order_date) AS order_month,
    COUNT(order_id)   AS total_orders,
    SUM(sales_amount) AS total_revenue
FROM orders
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
ORDER BY order_month;

 
 SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    COUNT(order_id) AS total_orders,
    SUM(sales_amount) AS revenue
FROM orders
WHERE order_date IS NOT NULL
  AND MONTH(order_date) IN (3, 10, 11)
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY order_year, order_month;

-- monday to sunday total order and revenue 
SELECT
    DAYNAME(order_date) AS day_name,
    COUNT(order_id) AS total_orders,
        SUM(sales_amount) AS total_revenue
FROM orders
WHERE order_date IS NOT NULL
GROUP BY DAYNAME(order_date)
ORDER BY total_orders DESC;


-- Top Restaurants by Revenue

SELECT
    r.name,
    SUM(o.sales_amount) AS total_revenue,
    RANK() OVER (ORDER BY SUM(o.sales_amount) DESC) AS revenue_rank
FROM orders o
JOIN restaurant r ON o.r_id = r.r_id
GROUP BY r.name
limit 10;


