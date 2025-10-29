set search_path to retail;

-- customer table

CREATE INDEX idx_customers_name_segment ON Customers(customer_name, customer_segment);

CREATE INDEX idx_customers_segment ON Customers(customer_segment);


--Regions Table (Filtering and joining by region details)

CREATE INDEX idx_regions_location ON Regions(region, state, city, zip_code);


--Orders Table (Join keys)

CREATE INDEX idx_orders_customer_id ON Orders(customer_id);

CREATE INDEX idx_orders_region_id ON Orders(region_id);

--Query filtering and ordering by order_date for fast date-based analyses

CREATE INDEX idx_orders_order_date ON Orders(order_date);


--Common grouping and filtering on order_priority
CREATE INDEX idx_orders_order_priority ON Orders(order_priority);


--products table (Filtering by product category, subcategory and name for aggregation queries)

CREATE INDEX idx_products_category_subcategory_name 
ON Products(product_category, product_sub_category, product_name);


--Order_Items Table (join keys)
CREATE INDEX idx_orderitems_order_unique_id ON Order_Items(order_unique_id);

CREATE INDEX idx_orderitems_product_id ON Order_Items(product_id);

--Composite index to support combined lookups
CREATE INDEX idx_orderitems_order_product ON Order_Items(order_unique_id, product_id);


EXPLAIN ANALYZE
SELECT DATE_TRUNC('month', o.order_date) AS month,
       SUM(oi.sales) AS total_sales
FROM Orders o
JOIN Order_Items oi ON o.order_unique_id = oi.order_unique_id
GROUP BY month
ORDER BY month;


