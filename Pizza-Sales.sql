-- Basic:

-- 1. Retrieve the total number of orders placed.

    SELECT 
      COUNT(order_id) AS total_orders
    FROM
      orders;  

-- 2.Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id;


-- 3.Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    Pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- 4.Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- 5.List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(orders_details.quantity) AS Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;


-- Intermediate:

-- 6.Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    COUNT(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- 7.Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);

-- 8.Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(pizza_types.name)
FROM
    pizza_types
GROUP BY category;

-- 9.Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity_per_day), 0) AS Avg_pizzas_ordered_per_day
FROM
    (SELECT 
        orders.order_date,
            SUM(orders_details.quantity) AS quantity_per_day
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY order_date) AS orders_per_day; 

-- 10.Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;


-- Advanced:

-- 11.Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND(SUM(pizzas.price * orders_details.quantity) / (SELECT 
                    SUM(orders_details.quantity * pizzas.price) AS total_sales
                FROM
                    orders_details
                        JOIN
                    pizzas ON orders_details.pizza_id = pizzas.pizza_id) * 100,
            2) AS revenue_percentage
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue_percentage DESC;

-- 12.Analyze the cumulative revenue generated over time.

SELECT order_date,
SUM(revenue) OVER(ORDER BY order_date) AS cum_revenue
FROM 
(SELECT 
    orders.order_date,
    SUM(orders_details.quantity * pizzas.price) AS revenue
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id
        JOIN
    orders ON orders.order_id = orders_details.order_id
GROUP BY orders.order_date ) as sales ;


-- 13.Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category ,name,revenue, ranks
from
(select category, name, revenue,
rank() over(partition by category order by revenue) as ranks
from
(select pizza_types.category, pizza_types.name,
SUM(orders_details.quantity * pizzas.price) As revenue
from orders_details
join pizzas
on orders_details.pizza_id = pizzas.pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP by pizza_types.category, pizza_types.name) as a ) as b
where
ranks <= 3;
