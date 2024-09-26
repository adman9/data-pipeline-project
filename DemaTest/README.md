# Data Pipeline Project

This project is designed to ingest, validate, and process data into a PostgreSQL database using Docker and PowerShell. The pipeline includes data validation steps to ensure data integrity before inserting it into dimension and fact tables.

## Project Structure

- `deploy_compose.ps1`: PowerShell script to deploy the Docker containers and run the data pipeline.
- `create_tables.sql`: SQL script to create tables
- `insert_data.sql`: SQL script to validate and insert data into the PostgreSQL database.
- `ingest_raw_data.py`: Python script to read, validate, and ingest raw data into PostgreSQL staging tables.
- `pipeline_log.txt`: Log file generated during the pipeline execution.

## Prerequisites

- Docker
- Docker Compose
- VS Code
- PowerShell
- PostgreSQL
- Python 3.x
- `sqlalchemy` and `pandas` Python libraries

## DB Details used:
- db_host = 'localhost'
- db_port = '5432'
- db_name = 'ecommerce'
- db_user = 'admin'
- db_password = 'admin'

## Setup

1. **Clone the repository:**

   ```sh
   git clone https://github.com/your-repo/data-pipeline-project.git
   cd data-pipeline-project

2. **How to run:**

- Run this one by one in terminal 

    ```docker-compose up -d
    $containerId = docker ps -q -f name=dematest-db-1
    docker exec -it $containerId psql -U admin -d ecommerce -a -f /var/lib/postgresql/sql/create_tables.sql
    ./deploy_compose.ps1
    docker-compose down

- If you want to check the db do not run the docker-compose down command. Please execute the following command to get run the query in the DB

  ``` docker exec -it $containerId psql -U admin -d ecommerce

- For Reorts run the below query. For Dashboards we can us any kind of BI Tools:

  ``` # Total Sales by Product
   SELECT dp.product_name, ROUND(SUM(cast(amount as NUMERIC)),2) AS total_sales FROM fact_sales fs JOIN dim_product dp ON fs.product_id = dp.product_id GROUP BY dp.product_name ORDER BY total_sales DESC;
   # Top Selling Products
   SELECT dp.product_name, COUNT(fs.order_id) AS total_orders FROM fact_sales fs JOIN dim_product dp ON fs.product_id = dp.product_id GROUP BY dp.product_name ORDER BY total_orders DESC;
   # Sales by Category
   SELECT dp.category, ROUND(SUM(cast(amount as NUMERIC)),2) AS total_sales FROM fact_sales fs JOIN dim_product dp ON fs.product_id = dp.product_id GROUP BY dp.category ORDER BY total_sales DESC;"
   # Monthly Sales Trend
   SELECT month AS sales_month, ROUND(SUM(cast(amount as NUMERIC)),2) AS total_sales FROM fact_sales fs JOIN dim_time dt ON fs.time_id = dt.time_id GROUP BY month ORDER BY month LIMIT 10;
  
