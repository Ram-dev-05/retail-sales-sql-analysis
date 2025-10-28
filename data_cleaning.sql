SET search_path TO retail;

--customer_table
--Removing duplicates
-- Define CTE to rank duplicates by customer_name and customer_segment
WITH ranked_customers AS (
  SELECT 
    customer_id,
    customer_name,
    customer_segment,
    ROW_NUMBER() OVER (
      PARTITION BY customer_name, customer_segment
      ORDER BY customer_id
    ) AS rn
  FROM Customers
),
-- Update Orders to point to retained customers (rn=1)
updated_orders AS (
  UPDATE Orders o
  SET customer_id = rc_keep.customer_id
  FROM ranked_customers rc_dup
  JOIN ranked_customers rc_keep
    ON rc_dup.customer_name = rc_keep.customer_name
   AND rc_dup.customer_segment = rc_keep.customer_segment
   AND rc_keep.rn = 1
  WHERE o.customer_id = rc_dup.customer_id
    AND rc_dup.rn > 1
  --RETURNING o.*
)
-- Delete duplicate customers (rn > 1)
DELETE FROM Customers
WHERE customer_id IN (SELECT customer_id FROM ranked_customers WHERE rn > 1);


--Products Table
-- Step 1: Identify duplicates by assigning row numbers partitioned by natural keys (name, category, sub-category)
WITH ranked_products AS (
  SELECT 
    product_id,
    product_name,
    product_category,
    product_sub_category,
    ROW_NUMBER() OVER (
      PARTITION BY product_name, product_category, product_sub_category
      ORDER BY product_id
    ) AS rn
  FROM Products
),
-- Step 2: Update Order_Items to point to retained product_id (row_number = 1),
-- for duplicates with rn > 1, fixing foreign key references
updated_order_items AS (
  UPDATE Order_Items oi
  SET product_id = rp_keep.product_id
  FROM ranked_products rp_dup
  JOIN ranked_products rp_keep
    ON rp_dup.product_name = rp_keep.product_name
   AND rp_dup.product_category = rp_keep.product_category
   AND rp_dup.product_sub_category = rp_keep.product_sub_category
   AND rp_keep.rn = 1
  WHERE oi.product_id = rp_dup.product_id
    AND rp_dup.rn > 1
)
-- Step 3: Delete duplicate products and invalid products (where unit_price is NULL or <= 0)
DELETE FROM Products
WHERE product_id IN (SELECT product_id FROM ranked_products WHERE rn > 1)
   OR unit_price IS NULL
   OR unit_price <= 0;


--Regions Tables
-- Step 1: Assign row numbers to identify duplicate regions based on region info columns
WITH ranked_regions AS (
  SELECT 
    region_id,
    region,
    state,
    city,
    zip_code,
    ROW_NUMBER() OVER (
      PARTITION BY region, state, city, zip_code
      ORDER BY region_id
    ) AS rn
  FROM Regions
),
-- Step 2: Update Orders to point to retained region_id (rn = 1), fixing duplicate FK references
updated_orders AS (
  UPDATE Orders o
  SET region_id = rr_keep.region_id
  FROM ranked_regions rr_dup
  JOIN ranked_regions rr_keep
    ON rr_dup.region = rr_keep.region
   AND rr_dup.state = rr_keep.state
   AND rr_dup.city = rr_keep.city
   AND rr_dup.zip_code = rr_keep.zip_code
   AND rr_keep.rn = 1
  WHERE o.region_id = rr_dup.region_id
    AND rr_dup.rn > 1
)
-- Step 3: Delete duplicate regions and rows with missing critical fields (region or city)
DELETE FROM Regions
WHERE region_id IN (SELECT region_id FROM ranked_regions WHERE rn > 1)
   OR region IS NULL
   OR city IS NULL;


--order_items
-- Step 1: Identify duplicate orders by natural keys, rank with ROW_NUMBER
WITH ranked_orders AS (
  SELECT 
    order_id,
    order_unique_id,
    customer_id,
    region_id,
    order_date,
    order_priority,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id, region_id, order_date, order_priority
      ORDER BY order_unique_id
    ) AS rn
  FROM Orders
),
-- Step 2: Update Order_Items to reference retained order_unique_id for duplicates (rn > 1)
updated_order_items AS (
  UPDATE Order_Items oi
  SET order_unique_id = ro_keep.order_unique_id
  FROM ranked_orders ro_dup
  JOIN ranked_orders ro_keep
    ON ro_dup.customer_id = ro_keep.customer_id
   AND ro_dup.region_id = ro_keep.region_id
   AND ro_dup.order_date = ro_keep.order_date
   AND ro_dup.order_priority = ro_keep.order_priority
   AND ro_keep.rn = 1
  WHERE oi.order_unique_id = ro_dup.order_unique_id
    AND ro_dup.rn > 1
)
-- Step 3: Delete duplicate Orders records (rn > 1)
DELETE FROM Orders
WHERE order_unique_id IN (SELECT order_unique_id FROM ranked_orders WHERE rn > 1);





