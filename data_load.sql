SET search_path TO retail;

--copying the data into staging raw table from csv file

/*
performed the data import using the psql command-line client's \copy command instead of pgAdmin's SQL COPY command because:

- The SQL COPY command runs on the PostgreSQL server and requires the CSV file to be accessible from the server's file system, which often causes file access or permission errors in client environments.
- The \copy command runs client-side in psql, allowing loading from files on the local client machine, avoiding server file permission issues.
- This approach ensures a smooth import of CSV data from local Windows directories without requiring server-side file access.
- Encoding issues were managed by converting the CSV file to UTF-8 or adjusting client encoding temporarily.


--\copy command
\copy retail.staging_raw (City, Customer_Age, Customer_Name, Customer_Segment, Discount, Number_of_Records, Order_Date, Order_ID, 
Order_Priority, Order_Quantity, Product_Base_Margin, Product_Category, Product_Container, Product_Name, Product_Sub_Category, 
Profit, Region, Row_ID, Sales, Ship_Date, Ship_Mode, Shipping_Cost, State, Unit_Price, Zip_Code) 
FROM 'your file path' DELIMITER ',' CSV HEADER


*/


COPY staging_raw (City, Customer_Age, Customer_Name, Customer_Segment, 
Discount, Number_of_Records, Order_Date, Order_ID, Order_Priority, Order_Quantity, 
Product_Base_Margin, Product_Category, Product_Container, Product_Name, 
Product_Sub_Category, Profit, Region, Row_ID, Sales, Ship_Date, 
Ship_Mode, Shipping_Cost, State, Unit_Price, Zip_Code)
FROM '‪C:/Users/Public/walmartRetailData.csv'
DELIMITER ',' CSV HEADER;

--to check the data
select * from staging_raw;


-- Insert into Customers
INSERT INTO Customers (customer_name, customer_age, customer_segment)
SELECT DISTINCT Customer_Name, Customer_Age, Customer_Segment
FROM staging_raw
WHERE Customer_Name IS NOT NULL;

select * from customers;


-- Insert into Products
INSERT INTO Products (product_name, product_category, product_sub_category, product_container, unit_price, product_base_margin)
SELECT DISTINCT Product_Name, Product_Category, Product_Sub_Category, Product_Container, Unit_Price, Product_Base_Margin
FROM staging_raw
WHERE Product_Name IS NOT NULL;


select * from products;


-- Insert into Regions
INSERT INTO Regions (region, state, city, zip_code)
SELECT DISTINCT Region, State, City, Zip_Code
FROM staging_raw
WHERE Region IS NOT NULL;

/*

--analyzing the regions table 


select --count(region_id),
distinct zip_code, count(distinct zip_code), count(region_id)
--count(distinct city) 
from regions
group by zip_code
having count(region_id)>1

select * from regions
where zip_code in ('2840','63129','15122','7060','68046','33063','98387','8360','55343','12306')

SELECT
    s.*,
    r.region_id
FROM
    staging_raw s
LEFT JOIN
    regions r
ON
    s.zip_code = r.zip_code
WHERE
    r.region_id IS NULL;

*/

--got duplicate check error while loading the data to orders table
select order_id, order_date, order_priority, discount, ship_date, ship_mode, shipping_cost  from staging_raw
where order_id in (
SELECT order_id
FROM staging_raw
GROUP BY order_id
HAVING COUNT(*) > 1)

--so adding another new column as primary key for orders table but for that I need to change foreign key in order_items table 
--because I used FKey references in the table.

drop table order_items;

ALTER TABLE Orders
ADD COLUMN order_unique_id BIGSERIAL;

ALTER TABLE Orders
DROP CONSTRAINT orders_pkey CASCADE;

ALTER TABLE Orders
ADD CONSTRAINT orders_pkey PRIMARY KEY (order_unique_id)

--I'm also updating ERD diagram
--adding table again with new FK constraint
CREATE TABLE Order_Items (
    order_item_id serial PRIMARY KEY,
    order_unique_id INT,
    product_id INT,
    order_quantity INT,
    sales DECIMAL(10,2),
    profit DECIMAL(10,2),
    FOREIGN KEY (order_unique_id) REFERENCES Orders(order_unique_id),
    foreign key (product_id) references Products(product_id)
);

-- Insert into Orders
INSERT INTO Orders (order_id, customer_id, region_id, order_date, order_priority, discount, ship_date, ship_mode, shipping_cost)
SELECT
    s.Order_ID,
    c.customer_id,
    r.region_id,
    s.Order_Date,
    s.Order_Priority,
    s.Discount,
    s.Ship_Date,
    s.Ship_Mode,
    s.Shipping_Cost
FROM staging_raw s
JOIN Customers c ON s.Customer_Name = c.customer_name
JOIN Regions r ON s.zip_code = r.zip_code AND s.city = r.city

select * from orders;


--insert into orders_items

INSERT INTO Order_Items (
    order_unique_id,
    product_id,
    order_quantity,
    sales,
    profit
)
SELECT
    o.order_unique_id,
    p.product_id,
    s.Order_Quantity,
    s.Sales,
    s.Profit
FROM staging_raw s
JOIN Orders o
    ON s.Order_ID = o.order_id
   AND s.Ship_Date = o.ship_date          -- distinguishing repeated order_id by extra attributes
   AND s.Discount = o.discount
JOIN Products p
    ON s.Product_Name = p.product_name;


select * from order_items;
