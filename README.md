# Pizza Sales Report
![](https://github.com/chekebh/Pizza-Sales-Report/blob/main/pizza_shop.jpg)

## Introduction
This a project that uses SQL for the data analysis and Power BI for the data visualisation. The aim of the project is to give insight to the business performance of a fictitious pizzeria to help the business make data driven decisions. The project also served as a platform for me to acquire knowledge about MySQL database creation and successfully integrating it with Power BI. The relevant datasets can be found here : [Pizza Sales Dataset](https://www.kaggle.com/datasets/mysarahmadbhat/pizza-place-sales). This is just an overview of the project, and the relevant files have been attached for further review and access on GitHub.

## Tools used
* MySQL Workbench for Data Analysis
* Power BI for Data Visualisation

## Problems
1) **Sales Performance Analysis**

* What's the revenue of pizza sales across various categories?
* What is the pizza revenue distributed among the various size categories?

2) **Seasonal Analysis**

* On which days of the week do we observe the highest order volumes?
* During what time of day do most orders typically take place?
* In which month do we record the highest revenue?

3) **Customer Behaviour Analysis**

* What's the most ordered pizza?
* What are the top 5 pizzas by revenue?
* Which pizzas had the most orders?

4) **Pizza Analysis**

* What are the pizzas with the highest and lowest prices?
* How many pizzas are there in each size category?
* How many pizzas fall into each category?

## Additional KPIs required

* Total revenue
* Average order spend
* Total pizzas sold
* Total orders
* Average number of pizzas per order

## Data Analysis

To start with, I created a new database for this project called **pizza_database** and imported the following CSV's as tables: order_details, orders, pizza_types and pizzas.

First, I noticed that the orders table had columns that were incorrectly formatted so I reformatted them to the correct datype.

```sql
ALTER TABLE orders
MODIFY date DATE;

ALTER TABLE orders
MODIFY time TIME;
```

I then created a view to be used for later.

```sql
CREATE VIEW pizza_info AS
SELECT p.pizza_id, p.pizza_type_id, p.size, p.price, pt.name, pt.category, pt.ingredients
FROM pizzas p
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id;
```

I proceeded by working out the different KPIs first.

**Total revenue**
```sql
SELECT ROUND(SUM(od.quantity * p.price),2) AS total_revenue
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id;
```
**Total pizzas sold**
```sql
SELECT SUM(quantity) AS total_pizzas_sold
FROM order_details;
```

**Total orders**
```sql
SELECT COUNT(order_id) AS total_orders
FROM orders;
````

**Average order spend**
```sql
SELECT ROUND(SUM(od.quantity * p.price) / COUNT(DISTINCT(order_id)),2) AS avg_spend
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id;
```

**Average number of pizzas per order**
```sql
SELECT ROUND(SUM(quantity) / COUNT(DISTINCT(order_id)),2) AS avg_pizza_per_order
FROM order_details;
```

The results are as follows:

| KPI        | Result           | 
| ------------- |:-------------:|
| total_revenue      | 817860.05 | 
| total_pizzas_sold    | 49574      |  
| total_orders | 21350      |   
| avg_spend      | 38.31     | 
| avg_pizza_per_order | 2.32      |

### Sales Performance Analysis

Query to find the revenue across the different categories.
```sql
SELECT p.category, ROUND(SUM(od.quantity * p.price),2) AS total_revenue, COUNT(DISTINCT(od.order_id)) AS total_orders
FROM order_details od
JOIN pizza_info p -- Note that the view from before has price, pizza_id and category 
ON od.pizza_id = p.pizza_id
GROUP BY p.category;
```
This is the result:

| category | total_revenue | total_orders |
| --- | --- | --- |
| Chicken | 195919.5 | 8536 |
| Classic | 220053.1 | 10859 |
| Supreme | 208197 | 9085 |
| Veggie | 193690.45 | 8941 |

The following query will find the revenue of pizzas across the various sizes.

```sql
SELECT p.size, ROUND(SUM(od.quantity * p.price),2) AS total_revenue, COUNT(DISTINCT(od.order_id)) AS total_orders
FROM order_details od
JOIN pizza_info p  
ON od.pizza_id = p.pizza_id
GROUP BY p.size;
```
Result:

| size | total_revenue | total_orders |
| --- | --- | --- |
| L   | 375318.7 | 12736 |
| M   | 249382.25 | 11159 |
| S   | 178076.5 | 10490 |
| XL  | 14076 | 544 |
| XXL | 1006.6 | 28  |

### Seasonal Analysis

Query to find the number of orders made during particular times of day.

```sql
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
```
Result:

| order_time | total_orders |
| --- | --- |
| Afternoon | 6655 |
| Lunch | 5395 |
| Dinner | 4849 |
| Morning | 3760 |
| Night | 691 |

**Most orders occur in the afternoon.**

Query for orders made per day.

```sql
SELECT DAYNAME(o.date) AS day_name, COUNT(o.order_id) AS total_orders
FROM orders o
GROUP BY day_name
ORDER BY total_orders DESC;
```

Result:

| day_name | total_orders |
| --- | --- |
| Friday | 3538 |
| Thursday | 3239 |
| Saturday | 3158 |
| Wednesday | 3024 |
| Tuesday | 2973 |
| Monday | 2794 |
| Sunday | 2624 |

**Friday, Thursday and Saturday are the days with the most pizza orders.**

Query to find the monthly revenues to find the highest recorded revenue month.

```sql
SELECT MONTHNAME(o.date) AS month_name, ROUND(SUM(od.quantity * p.price),2) AS total_revenue
FROM orders o
JOIN order_details od
ON o.order_id = od.order_id
JOIN pizzas p -- 2 Joins so that I can combine all 3 tables to get monthly revenue
ON p.pizza_id = od.pizza_id
GROUP BY month_name
ORDER BY total_revenue DESC;
```

Result:

| month_name | total_revenue |
| --- | --- |
| July | 72557.9 |
| May | 71402.75 |
| March | 70397.1 |
| November | 70395.35 |
| January | 69793.3 |
| April | 68736.8 |
| August | 68278.25 |
| June | 68230.2 |
| February | 65159.6 |
| December | 64701.15 |
| September | 64180.05 |
| October | 64027.6 |

**July is the month that recorded the highest revenue.**

### Customer Behaviour Analysis

Query to find the most ordered pizza.

```sql
SELECT p.name, COUNT(od.order_id) AS pizza_count 
FROM order_details od
JOIN pizza_info p -- Join the view and order_details
ON od.pizza_id = p.pizza_id
GROUP BY p.name
ORDER BY pizza_count DESC
LIMIT 1;
```

Result:

| name | pizza_count |
| --- | --- |
| The Classic Deluxe Pizza | 2416 |

Query to find the top 5 pizzas by revenue.

```sql
SELECT p.name, ROUND(SUM(od.quantity * p.price),2) AS total_revenue -- Select pizza and size
FROM order_details od
JOIN pizza_info p -- Join the view and order_details
ON od.pizza_id = p.pizza_id
GROUP BY p.name
ORDER BY total_revenue DESC
LIMIT 5; 
```

Result:

| name | total_revenue |
| --- | --- |
| The Thai Chicken Pizza | 43434.25 |
| The Barbecue Chicken Pizza | 42768 |
| The California Chicken Pizza | 41409.5 |
| The Classic Deluxe Pizza | 38180.5 |
| The Spicy Italian Pizza | 34831.25 |

Query to find the top 5 pizzas by orders.

```sql
SELECT p.name, SUM(od.quantity) AS pizzas_sold 
FROM order_details od
JOIN pizza_info p 
ON od.pizza_id = p.pizza_id
GROUP BY p.name
ORDER BY pizzas_sold DESC
LIMIT 5;
```

Result:

| name | pizzas_sold |
| --- | --- |
| The Classic Deluxe Pizza | 2453 |
| The Barbecue Chicken Pizza | 2432 |
| The Hawaiian Pizza | 2422 |
| The Pepperoni Pizza | 2418 |
| The Thai Chicken Pizza | 2371 |

### Pizza Analysis

Query to find the cheapest and most expensive pizzas.

```sql
SELECT name, size,price -- Lowest and highest price pizza
FROM pizza_info
ORDER BY price ASC;
```
Taking the first row and last row, the result is as follows:

| name | size | price |
| --- | --- | --- |
| The Pepperoni Pizza   |  S|9.75  |
| The Greek Pizza   |XXL | 35.95|

Query to find the number of pizzas per category.

```sql
SELECT category, COUNT(DISTINCT(name)) AS total_pizza 
FROM pizza_types 
GROUP BY category;
```
Result:

|category| total_pizza
| --- | --- |
|Chicken	|6|
|Classic	|8|
|Supreme	|9|
|Veggie|	9|

Query to find the number of pizzas per size.

```sql
SELECT size, COUNT(pizza_id) AS total_pizza
FROM pizzas
GROUP BY size;
```

Result:

|size| total_pizza|
| --- | --- |
|S	|32|
|M	|31|
|L	|31|
|XL|	1|
|XXL	|1|

## Data Visualisation

I integrated the MySQL database with Power BI and used the SQL queries to get the relevant tables needed for the questions. I then proceeded to create a dashboard using some of these tables to provide the client with an improved insight into their sales performance.

![](https://github.com/chekebh/Pizza-Sales-Report/blob/main/dashboard1.jpg)

![](https://github.com/chekebh/Pizza-Sales-Report/blob/main/dashboard2.jpg)

## Conclusion

The project's objective was to assess the sales performance of a fictitious pizzeria and address their inquiries. Additionally, it served as a learning opportunity for me to gain insights into database creation and implementation using MySQL Workbench. I also aimed to experiment with Power BI for dashboard creation, which led me to acquire the skills needed to integrate a MySQL database with Power BI, enabling access to the necessary data for constructing the dashboards.
