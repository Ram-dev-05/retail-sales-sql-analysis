set search_path to retail;

--Rank products by total sales within each category

SELECT p.product_category, p.product_name, SUM(oi.sales) AS total_sales,
       RANK() OVER (PARTITION BY p.product_category ORDER BY SUM(oi.sales) DESC) AS sales_rank
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.product_category, p.product_name
ORDER BY p.product_category, sales_rank;


--Find the top 3 products in each category by sales
WITH RankedProducts AS (
  SELECT p.product_category, p.product_name, SUM(oi.sales) AS total_sales,
         RANK() OVER (PARTITION BY p.product_category ORDER BY SUM(oi.sales) DESC) AS sales_rank
  FROM Order_Items oi
  JOIN Products p ON oi.product_id = p.product_id
  GROUP BY p.product_category, p.product_name
)
SELECT product_category, product_name, total_sales, sales_rank
FROM RankedProducts
WHERE sales_rank <= 3
ORDER BY product_category, sales_rank;

--Dense rank customers by total profit

SELECT c.customer_name, SUM(oi.profit) AS total_profit,
       DENSE_RANK() OVER (ORDER BY SUM(oi.profit) DESC) AS profit_rank
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Order_Items oi ON o.order_unique_id = oi.order_unique_id
GROUP BY c.customer_name
ORDER BY total_profit DESC;

-- Calculate running total of sales over time (monthly)

SELECT DATE_TRUNC('month', o.order_date) AS month,
       SUM(oi.sales) AS monthly_sales,
       SUM(SUM(oi.sales)) OVER (ORDER BY DATE_TRUNC('month', o.order_date)) AS running_total_sales
FROM Orders o
JOIN Order_Items oi ON o.order_unique_id = oi.order_unique_id
GROUP BY month
ORDER BY month;

--Show lag of sales amount compared to previous order for each customer

SELECT o.customer_id, o.order_date, SUM(oi.sales) AS order_sales,
       LAG(SUM(oi.sales)) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS previous_order_sales
FROM Orders o
JOIN Order_Items oi ON o.order_unique_id = oi.order_unique_id
GROUP BY o.customer_id, o.order_id, o.order_date
ORDER BY o.customer_id, o.order_date;
