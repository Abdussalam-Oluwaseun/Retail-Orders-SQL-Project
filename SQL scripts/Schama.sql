-- SCHEMA --
CREATE TABLE orders(
	order_id INT PRIMARY KEY,
    order_date DATE NOT NULL,
    ship_mode VARCHAR(20),
    segment VARCHAR(20),
    country VARCHAR(20),
    city VARCHAR(20),
    state VARCHAR(20),
    postal_code VARCHAR(20),
    region VARCHAR(20),
    category VARCHAR(20),
    sub_category VARCHAR(20),
    product_id VARCHAR(20),
    list_price DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(10,2),
    sales_price DECIMAL(10,2),
    profit DECIMAL(10,2)
);
