set search_path to retail;


---Total Number of order by each order priority

SELECT order_priority, COUNT(*) AS total_orders
FROM Orders
GROUP BY order_priority
ORDER BY total_orders DESC;


--Total sales and profit by product category

SELECT p.product_category, 
       SUM(oi.sales) AS total_sales, 
       SUM(oi.profit) AS total_profit
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.product_category
ORDER BY total_sales DESC;


--Count of customers by segment

SELECT customer_segment, COUNT(*) AS customer_count
FROM Customers
GROUP BY customer_segment
ORDER BY customer_count DESC;


--Average order quantity and sales by region

SELECT r.region, 
       AVG(oi.order_quantity) AS avg_order_quantity, 
       AVG(oi.sales) AS avg_sales
FROM Orders o
JOIN Order_Items oi ON o.order_unique_id = oi.order_unique_id
JOIN Regions r ON o.region_id = r.region_id
GROUP BY r.region
ORDER BY avg_sales DESC;

--Monthly sales trend (total sales per month)

SELECT DATE_TRUNC('month', o.order_date) AS month,
       SUM(oi.sales) AS total_sales
FROM Orders o
JOIN Order_Items oi ON o.order_unique_id = oi.order_unique_id
GROUP BY month
ORDER BY month;

-- Top 5 products by total sales

SELECT p.product_name, SUM(oi.sales) AS total_sales
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sales DESC
LIMIT 5;


--Number of orders and total sales by ship mode

SELECT o.ship_mode, 
       COUNT(*) AS number_of_orders, 
       SUM(oi.sales) AS total_sales
FROM Orders o
JOIN Order_Items oi ON o.order_unique_id = oi.order_unique_id
GROUP BY o.ship_mode
ORDER BY total_sales DESC;
