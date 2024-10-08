USE pizza_sales;

-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;
    
-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(od.quantity * p.price)) AS total_revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;
    
-- Identify the highest-priced pizza. (Solution 1)
SELECT 
    pt.pizza_name, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Identify the highest-priced pizza. (Solution 2)
SELECT 
    pt.pizza_name, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
WHERE
    p.price = (SELECT 
            MAX(price)
        FROM
            pizzas);

-- Identify the most common pizza ordered.
SELECT 
    pt.pizza_name
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
WHERE
    od.order_id = (SELECT 
            MAX(order_id)
        FROM
            order_details);
            
-- Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(od.order_id) AS count_of_pizzas
FROM
    pizzas p
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY count_of_pizzas DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.pizza_name, SUM(od.quantity) AS count_of_pizza
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.pizza_name
ORDER BY count_of_pizza DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(od.quantity) AS count_of_pizza
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY count_of_pizza DESC
LIMIT 5;

-- Determine the quantity of pizzas sold by hour of the day.
SELECT 
    HOUR(o.order_time) AS order_hour,
    SUM(od.quantity) AS qunatity_sold
FROM
    orders o
        JOIN
    order_details od ON o.order_id = od.order_id
GROUP BY order_hour
ORDER BY order_hour ASC;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(pizza_name) AS count_of_pizzas
FROM
    pizza_types
GROUP BY category
ORDER BY count_of_pizzas DESC;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    CEIL(AVG(quantity_sold)) AS avg_orders
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS quantity_sold
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS sales_volume;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.pizza_name, ROUND(SUM(od.quantity * p.price)) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.pizza_name
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.pizza_name,
    ROUND((SUM(od.quantity * p.price) / (SELECT 
                    SUM(od.quantity * p.price)
                FROM
                    order_details od
                        JOIN
                    pizzas p ON p.pizza_id = od.pizza_id)) * 100,
            2) AS percentage_contribution
FROM
    order_details od
        JOIN
    pizzas p ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.pizza_name
ORDER BY percentage_contribution DESC;

-- Analyze the cumulative revenue generated over time.
   SELECT 
		order_date, 
        ROUND(SUM(revenue) OVER(ORDER BY order_date)) AS sales_value
    FROM
		(SELECT 
            o.order_date, SUM(od.quantity * p.price) AS revenue
        FROM
            order_details od
                JOIN
            orders o ON o.order_id = od.order_id
                JOIN
            pizzas p ON p.pizza_id = od.pizza_id
		GROUP BY order_date) AS sale_revenue;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT
	category, pizza_name, revenue
FROM
	(SELECT
		category,
		pizza_name,
		revenue, RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn
	FROM
		(SELECT 
			pt.category,
			pt.pizza_name,
			ROUND(SUM(od.quantity * p.price)) AS revenue
		FROM
			order_details od
				JOIN
			pizzas p ON p.pizza_id = od.pizza_id
				JOIN
			pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
		GROUP BY pt.category , pt.pizza_name) AS a) AS b
WHERE rn <= 3;