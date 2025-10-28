--create database
--create database retail_sales;

--create schema
--create schema retail;

SET search_path TO retail;


--create stagging table
CREATE TABLE staging_raw (
    City VARCHAR(50),
    Customer_Age INT,
    Customer_Name VARCHAR(100),
    Customer_Segment VARCHAR(50),
    Discount DECIMAL(5,2),
    Number_of_Records INT,
    Order_Date DATE,
    Order_ID INT,
    Order_Priority VARCHAR(20),
    Order_Quantity INT,
    Product_Base_Margin DECIMAL(5,2),
    Product_Category VARCHAR(50),
    Product_Container VARCHAR(50),
    Product_Name VARCHAR(100),
    Product_Sub_Category VARCHAR(50),
    Profit DECIMAL(10,2),
    Region VARCHAR(50),
    Row_ID INT,
    Sales DECIMAL(10,2),
    Ship_Date DATE,
    Ship_Mode VARCHAR(50),
    Shipping_Cost DECIMAL(10,2),
    State VARCHAR(50),
    Unit_Price DECIMAL(10,2),
    Zip_Code VARCHAR(10)
);


--customers table

CREATE TABLE Customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    customer_age INT,
    customer_segment VARCHAR(50)
);

-- Regions table
CREATE TABLE Regions (
    region_id SERIAL PRIMARY KEY,
    region VARCHAR(50),
    state VARCHAR(50),
    city VARCHAR(50),
    zip_code VARCHAR(10)
);

-- Orders table
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    region_id INT,
    order_date DATE,
    order_priority VARCHAR(20),
    discount DECIMAL(5,2),
    ship_date DATE,
    ship_mode VARCHAR(50),
    shipping_cost DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (region_id) REFERENCES Regions(region_id)
);




--Products table
CREATE TABLE Products (
    product_id serial PRIMARY KEY,
    product_name VARCHAR(100),
    product_category VARCHAR(50),
    product_sub_category VARCHAR(50),
    product_container VARCHAR(50),
    unit_price DECIMAL(10,2),
    product_base_margin DECIMAL(5,2)
);

-- Order Items table
CREATE TABLE Order_Items (
    order_item_id serial PRIMARY KEY,
    order_id INT,
    product_id INT,
    order_quantity INT,
    sales DECIMAL(10,2),
    profit DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    foreign key (product_id) references Products(product_id)
);


--drop table customers, order_items, orders, products, regions;