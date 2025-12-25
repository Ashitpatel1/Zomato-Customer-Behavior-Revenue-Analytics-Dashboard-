CREATE DATABASE zomato_analytics;
USE zomato_analytics;

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(150),
    age INT,
    gender VARCHAR(10),
    marital_status VARCHAR(20),
    occupation VARCHAR(50),
    monthly_income VARCHAR(50),
    educational_qualification VARCHAR(50),
    family_size INT
);

CREATE TABLE restaurant (
    r_id INT PRIMARY KEY,
    name VARCHAR(150),
    city VARCHAR(100),
    rating DECIMAL(3,1),
    rating_count VARCHAR(50),
    cost INT,
    cuisine VARCHAR(255),
    lic_no VARCHAR(50)
);

CREATE TABLE food (
    id INT PRIMARY KEY,
    f_id VARCHAR(20),
    item VARCHAR(250),
    veg_or_non_veg VARCHAR(20)
);

CREATE TABLE menu (
    id INT PRIMARY KEY,
    menu_id VARCHAR(20),
    r_id INT,
    f_id VARCHAR(20),
    cuisine VARCHAR(255),
    price INT,
    FOREIGN KEY (r_id) REFERENCES restaurant(r_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date varchar(20),
    sales_qty INT,
    sales_amount DECIMAL(10,2),
    currency VARCHAR(10),
    user_id INT,
    r_id INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (r_id) REFERENCES restaurant(r_id)
);



LOAD DATA INFILE 
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Zomato Data/users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Zomato Data/restaurant.csv'
INTO TABLE restaurant
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Zomato Data/food.csv'
INTO TABLE food
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


LOAD DATA INFILE 
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Zomato Data/menu.csv'
INTO TABLE menu
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Zomato Data/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, @order_date, sales_qty, sales_amount, currency, user_id, r_id)
SET order_date = STR_TO_DATE(@order_date, '%m/%d/%Y');



-- VIEWS	


CREATE VIEW viw_orders AS
SELECT order_id, order_date,sales_qty,sales_amount, currency, user_id, r_id AS restaurant_id
FROM orders 
WHERE sales_amount > 0;

CREATE VIEW viw_users AS
SELECT user_id, name,age,gender,Marital_Status,occupation,
monthly_income AS income_bucket,
educational_qualification AS education,
Family_size
FROM users;


CREATE VIEW viw_restaurants AS
SELECT r_id AS restaurant_id,name,city,rating,rating_count,cost,cuisine
FROM restaurant;

CREATE OR REPLACE VIEW viw_food AS
SELECT id,f_id,item,veg_or_non_veg
FROM food;

CREATE  VIEW viw_menu AS
SELECT id, menu_id, r_id, f_id, cuisine,price
FROM menu;

CREATE OR REPLACE VIEW viw_city_revenue AS
SELECT UPPER(TRIM(r.city)) AS city,
    SUM(o.sales_amount) AS revenue
FROM orders o
INNER JOIN restaurant r
    ON o.r_id = r.r_id
WHERE o.order_date IS NOT NULL AND o.sales_amount > 0
GROUP BY UPPER(TRIM(r.city));

CREATE VIEW vw_customer_metrics AS
SELECT user_id, COUNT(order_id) AS total_orders,
SUM(sales_amount) AS total_revenue,
ROUND(SUM(sales_amount) / COUNT(order_id), 2) AS avg_order_value
FROM orders
WHERE order_date IS NOT NULL
GROUP BY user_id;