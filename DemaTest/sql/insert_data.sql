-- Description: This script inserts data into the data warehouse tables and also validates the data before insertion.
-- Version: 1.0

---delete from logs table
Delete from validation_logs;

-- Validate data in staging_orders
-- Check for null values in critical columns
INSERT INTO validation_logs (table_name, validation_type, validation_result, validation_date)
SELECT 'staging_orders', 'NULL Check', 
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END, 
       NOW()
FROM staging_orders
WHERE order_id IS NULL OR product_id IS NULL OR currency IS NULL OR quantity IS NULL OR amount IS NULL OR date_time IS NULL;

-- Validate data in staging_inventory
-- -- Check for duplicate product_id
INSERT INTO validation_logs (table_name, validation_type, validation_result, validation_date)
SELECT 'staging_orders', 'Duplicate Check', 
       CASE WHEN COUNT(product_id) = COUNT(DISTINCT product_id) THEN 'PASS' ELSE 'FAIL' END, 
       NOW()
FROM staging_inventory;

-- Check for null values in critical columns
INSERT INTO validation_logs (table_name, validation_type, validation_result, validation_date)
SELECT 'staging_inventory', 'NULL Check', 
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END, 
       NOW()
FROM staging_inventory
WHERE product_id IS NULL OR product_name IS NULL OR quantity IS NULL;

-- Check if there are any validation error

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM validation_logs WHERE validation_result = 'FAIL') THEN
        RAISE NOTICE 'Validation failed. Data insertion aborted.';
        RETURN;
    END IF;
END $$;

-- Insert data into dimension tables
-- Insert data into dim_product
INSERT INTO dim_product (product_id, product_name, category, sub_category) SELECT staging_inventory.product_id, staging_inventory.product_name, staging_inventory.category, staging_inventory.sub_category FROM staging_inventory ON CONFLICT (product_id) DO NOTHING;

-- Insert data into dim_time
INSERT INTO dim_time (date, year, quarter, month, day, week, day_of_week) SELECT DISTINCT date(o.date_time), EXTRACT(YEAR FROM date(o.date_time)), EXTRACT(QUARTER FROM date(o.date_time)), EXTRACT(MONTH FROM date(o.date_time)), EXTRACT(DAY FROM date(o.date_time)), EXTRACT(WEEK FROM date(o.date_time)), EXTRACT(DOW FROM date(o.date_time)) FROM staging_orders o;

-- Insert data into dim_channel
INSERT INTO dim_channel (channel, channel_group, campaign) SELECT DISTINCT channel, channel_group, campaign FROM staging_orders;

-- Insert data into fact_sales
INSERT INTO fact_sales (order_id, product_id, time_id, channel_id, quantity, amount, shipping_cost, currency)
SELECT o.order_id, p.product_id, t.time_id, c.channel_id, o.quantity, o.amount, o.shipping_cost, o.currency
FROM staging_orders o
LEFT JOIN dim_time t ON date(o.date_time) = t.date
LEFT JOIN dim_channel c ON o.channel = c.channel AND o.channel_group = c.channel_group AND o.campaign = c.campaign
LEFT JOIN dim_product p ON o.product_id = p.product_id;
