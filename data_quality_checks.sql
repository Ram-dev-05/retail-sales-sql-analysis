set search_path to retail;

-- Customers Table Data Quality Checks

-- Row count 
SELECT COUNT(*) AS total_customers FROM Customers;

--duplicate check by natural key
SELECT customer_name, customer_segment, COUNT(*) AS cnt
FROM Customers
GROUP BY customer_name, customer_segment HAVING COUNT(*) > 1;

-- Null check for important attributes
SELECT COUNT(*) AS missing_names FROM Customers WHERE customer_name IS NULL;
SELECT COUNT(*) AS missing_segments FROM Customers WHERE customer_segment IS NULL;

-- Unique PK check
SELECT COUNT(DISTINCT customer_id) AS unique_customer_ids FROM Customers;

---------------------------------------------------------------
-- Products Table Data Quality Checks

SELECT COUNT(*) AS total_products FROM Products;
-- Duplicates by natural key
SELECT product_name, product_category, product_sub_category, COUNT(*) AS cnt
FROM Products
GROUP BY product_name, product_category, product_sub_category HAVING COUNT(*) > 1;

-- Null or invalid attribute detection
SELECT COUNT(*) AS missing_price FROM Products WHERE unit_price IS NULL OR unit_price <= 0;

---------------------------------------------------------------
-- Regions Table Data Quality Checks

SELECT COUNT(*) AS total_regions FROM Regions;
SELECT region, state, city, zip_code, COUNT(*) AS cnt
FROM Regions
GROUP BY region, state, city, zip_code HAVING COUNT(*) > 1;

-- Missing critical attributes
SELECT COUNT(*) AS missing_region FROM Regions WHERE region IS NULL;
SELECT COUNT(*) AS missing_city FROM Regions WHERE city IS NULL;

---------------------------------------------------------------
-- Orders Table Data Quality Checks

SELECT COUNT(*) AS total_orders FROM Orders;
-- Duplicates based on natural keys
SELECT customer_id, region_id, order_date, order_priority, COUNT(*) AS cnt
FROM Orders
GROUP BY customer_id, region_id, order_date, order_priority HAVING COUNT(*) > 1;

-- Null FK references that may cause joins to fail
SELECT COUNT(*) AS null_customer_refs FROM Orders WHERE customer_id IS NULL;
SELECT COUNT(*) AS null_region_refs FROM Orders WHERE region_id IS NULL;

---------------------------------------------------------------
-- Referential Integrity Checks

-- Orphans in Orders that refer to nonexistent customers
SELECT COUNT(*) AS orphaned_orders_customer
FROM Orders o
LEFT JOIN Customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Orphans in Orders that refer to nonexistent regions
SELECT COUNT(*) AS orphaned_orders_region
FROM Orders o
LEFT JOIN Regions r ON o.region_id = r.region_id
WHERE r.region_id IS NULL;

-- Orphans in Order_Items that refer to nonexistent orders or products
SELECT COUNT(*) AS orphaned_order_items_order
FROM Order_Items oi
LEFT JOIN Orders o ON oi.order_unique_id = o.order_unique_id
WHERE o.order_unique_id IS NULL;

SELECT COUNT(*) AS orphaned_order_items_product
FROM Order_Items oi
LEFT JOIN Products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;
