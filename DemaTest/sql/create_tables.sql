-- Staging Tables
CREATE TABLE IF NOT EXISTS staging_orders (
    order_id VARCHAR PRIMARY KEY,
    product_id VARCHAR,
    currency VARCHAR,
    quantity INT,
    shipping_cost FLOAT,
    amount FLOAT,
    channel VARCHAR,
    channel_group VARCHAR,
    campaign VARCHAR,
    date_time TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging_inventory (
    product_id VARCHAR PRIMARY KEY,
    product_name VARCHAR,
    quantity INT,
    category VARCHAR,
    sub_category VARCHAR
);

-- Dimension Tables
CREATE TABLE IF NOT EXISTS dim_product (
    product_id VARCHAR PRIMARY KEY,
    product_name VARCHAR,
    category VARCHAR,
    sub_category VARCHAR
);

CREATE TABLE IF NOT EXISTS dim_time (
    time_id SERIAL PRIMARY KEY,
    date DATE,
    year INT,
    quarter INT,
    month INT,
    day INT,
    week INT,
    day_of_week INT
);

CREATE TABLE IF NOT EXISTS dim_channel (
    channel_id SERIAL PRIMARY KEY,
    channel VARCHAR,
    channel_group VARCHAR,
    campaign VARCHAR
);

-- Fact Table
CREATE TABLE IF NOT EXISTS fact_sales (
    sales_id SERIAL PRIMARY KEY,
    order_id VARCHAR,
    product_id VARCHAR,
    time_id INT,
    channel_id INT,
    quantity INT,
    amount FLOAT,
    shipping_cost FLOAT,
    currency VARCHAR,
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
    FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
    FOREIGN KEY (channel_id) REFERENCES dim_channel(channel_id)
);

-- Validation Logs
CREATE TABLE IF NOT EXISTS validation_logs (
    log_id SERIAL PRIMARY KEY,
    table_name VARCHAR(255),
    validation_type VARCHAR(255),
    validation_result VARCHAR(255),
    validation_date TIMESTAMP
);

--grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE on staging_orders TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE on staging_inventory TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE on dim_product TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE on dim_time TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE on dim_channel TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE on fact_sales TO "admin";