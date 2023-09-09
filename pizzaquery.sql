-- After importing the csv files, the orders table needs the date and time to be reformatted as they're currently formatted as text
ALTER TABLE orders
MODIFY date DATE;

ALTER TABLE orders
MODIFY time TIME;

-- Creating a view for data aggregation by joining pizzas and pizza_types tables
CREATE VIEW pizza_info AS
SELECT p.pizza_id, p.pizza_type_id, p.size, p.price, pt.name, pt.category, pt.ingredients
FROM pizzas p
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id;

SELECT * FROM pizza_info; -- Check to make sure the tables joined correctly

/*
Following queries to KPI's required
*/

-- Total revenue from pizza sales
SELECT ROUND(SUM(od.quantity * p.price),2) AS total_revenue
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id;

-- Total # of pizzas sold
SELECT SUM(quantity) AS total_pizzas_sold
FROM order_details;

-- Total orders made
SELECT COUNT(order_id) AS total_orders
FROM orders;

-- Average spend per order
SELECT ROUND(SUM(od.quantity * p.price) / COUNT(DISTINCT(order_id)),2) AS avg_spend
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id;

-- Average # of pizzas per order
SELECT ROUND(SUM(quantity) / COUNT(DISTINCT(order_id)),2) AS avg_pizza_per_order
FROM order_details;

/* 
Pizza Analysis
*/

-- Revenue of pizzas across the variety of pizza categories
SELECT p.category, ROUND(SUM(od.quantity * p.price),2) AS total_revenue, COUNT(DISTINCT(od.order_id)) AS total_orders
FROM order_details od
JOIN pizza_info p -- Note that the view from before has price, pizza_id and category 
ON od.pizza_id = p.pizza_id
GROUP BY p.category;

-- Revenue of pizzas across the different sizes of pizza
SELECT p.size, ROUND(SUM(od.quantity * p.price),2) AS total_revenue, COUNT(DISTINCT(od.order_id)) AS total_orders
FROM order_details od
JOIN pizza_info p  
ON od.pizza_id = p.pizza_id
GROUP BY p.size;

/*
Seasonal analysis
*/

-- Seasonal trends in orders and revenue
SELECT
	CASE -- Conditions for the different time frames
		WHEN HOUR(o.time) BETWEEN 9 AND 12 THEN 'Morning'
        WHEN HOUR(o.time) BETWEEN 12 AND 15 THEN 'Lunch'
		WHEN HOUR(o.time) BETWEEN 15 AND 18 THEN 'Afternoon'
        WHEN HOUR(o.time) BETWEEN 18 AND 21 THEN 'Dinner'
        WHEN HOUR(o.time) BETWEEN 21 AND 23 THEN 'Night'
        ELSE 'Other'
        END AS order_time, COUNT(o.order_id) AS total_orders -- Counts the number of orders in each category
FROM orders o
GROUP BY order_time -- Groups by the different time frames
ORDER BY total_orders DESC;

-- Weekly analysis
SELECT DAYNAME(o.date) AS day_name, COUNT(o.order_id) AS total_orders
FROM orders o
GROUP BY day_name
ORDER BY total_orders DESC;

-- Monthly revenue
SELECT MONTHNAME(o.date) AS month_name, ROUND(SUM(od.quantity * p.price),2) AS total_revenue
FROM orders o
JOIN order_details od
ON o.order_id = od.order_id
JOIN pizzas p -- 2 Joins so that I can combine all 3 tables to get monthly revenue
ON p.pizza_id = od.pizza_id
GROUP BY month_name
ORDER BY total_revenue DESC; 

/*
Customer Analysis
*/

-- Most ordered pizza
SELECT p.name, COUNT(od.order_id) AS pizza_count 
FROM order_details od
JOIN pizza_info p -- Join the view and order_details
ON od.pizza_id = p.pizza_id
GROUP BY p.name
ORDER BY pizza_count DESC
LIMIT 1;

-- Top 5 Pizzas by revenue
SELECT p.name, ROUND(SUM(od.quantity * p.price),2) AS total_revenue -- Select pizza and size
FROM order_details od
JOIN pizza_info p -- Join the view and order_details
ON od.pizza_id = p.pizza_id
GROUP BY p.name
ORDER BY total_revenue DESC
LIMIT 5; 

-- Most orders on pizzas
SELECT p.name, SUM(od.quantity) AS pizzas_sold 
FROM order_details od
JOIN pizza_info p 
ON od.pizza_id = p.pizza_id
GROUP BY p.name
ORDER BY pizzas_sold DESC
LIMIT 5;

/*
Pizza Analysis
*/

SELECT name, size,price -- Lowest and highest price pizza
FROM pizza_info
ORDER BY price ASC;

-- # of pizzas per category
SELECT category, COUNT(DISTINCT(name)) AS total_pizza 
FROM pizza_types 
GROUP BY category;

-- # of pizzas per size
SELECT size, COUNT(pizza_id) AS total_pizza
FROM pizzas
GROUP BY size;











