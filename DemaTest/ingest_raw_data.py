import pandas as pd
import os
from sqlalchemy import create_engine
import logging

# Define file paths
orders_file_path = 'data/inputfiles/orders.csv'
inventory_file_path = 'data/inputfiles/inventory.csv'
raw_data_dir = 'data/raw_data'

# PostgreSQL connection details
db_host = 'localhost'
db_port = '5432'
db_name = 'ecommerce'
db_user = 'admin'
db_password = 'admin'

 
# Function to read datasets
def read_dataset(file_path, headers):
    return pd.read_csv(file_path, sep=',', header=None, names=headers, skiprows=1, encoding='utf-8')

# Function to validate data
def validate_data(df, required_columns):
    for column in required_columns:
        if column not in df.columns:
            raise ValueError(f"Missing required column: {column}")
        if df[column].isnull().values.any():
            raise ValueError("Data contains null values")
    return True

# Function to store raw data
def store_raw_data(df, file_name):
    if not os.path.exists(raw_data_dir):
        os.makedirs(raw_data_dir)
    df.to_csv(os.path.join(raw_data_dir, file_name), index=False)

# Function to ingest raw data into PostgreSQL
def ingest_raw_data(df, table_name):
    engine = create_engine(f'postgresql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}')
    df.to_sql(table_name, engine, if_exists='replace', index=False)

# Main function to run the pipeline
def run_pipeline():
    # Read datasets
    headers_orders = ['order_id', 'product_id', 'currency', 'quantity', 'shipping_cost', 'amount', 'channel', 'channel_group', 'campaign', 'date_time']
    orders_df = read_dataset(orders_file_path, headers_orders)
    headers_inventory = ['product_id', 'product_name', 'quantity', 'category' , 'sub_category']
    inventory_df = read_dataset(inventory_file_path, headers_inventory)

    # Validate datasets
    validate_data(orders_df, ['order_id', 'product_id', 'amount', 'date_time'])
    validate_data(inventory_df, ['product_id', 'product_name'])
    
    # Store raw data
    store_raw_data(orders_df, 'orders_raw.csv')
    store_raw_data(inventory_df, 'inventory_raw.csv')
    
    # Ingest raw data into PostgreSQL staging tables
    ingest_raw_data(orders_df, 'staging_orders')
    logging.info('Ingested raw data into staging_orders table')
    ingest_raw_data(inventory_df, 'staging_inventory')
    logging.info('Ingested raw data into staging_inventory table')

# Run the pipeline
if __name__ == "__main__":
    run_pipeline()