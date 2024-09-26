# Define the log file path dynamically based on the script location
$logFilePath = Join-Path -Path $PSScriptRoot -ChildPath "pipeline_log.txt"

# Function to log messages with timestamps
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    Write-Host $logEntry
    Add-Content -Path $logFilePath -Value $logEntry
}

function Run-Scripts {
    $containerId = docker ps -q -f name=dematest-db-1
    docker exec -it $containerId psql -U admin -d ecommerce -a -f /var/lib/postgresql/sql/insert_data.sql
}

# Function to run SQL queries in the PostgreSQL container
function Test-Run-Sql {
    param (
        [string]$query
    )
    $containerId = docker ps -q -f name=dematest-db-1
    docker exec -it $containerId psql -U admin -d ecommerce -c "$query" 
}


# Build the Docker image for the app service
docker build -t ecommerce_app .

# Wait for services to be up and running
Log-Message "Waiting for services to start..."
Start-Sleep -Seconds 10

# Run the app service
docker run --network="host" --name ecommerce_app_container ecommerce_app

# Run the insert and validation scripts
Run-Scripts

# Verify database content
Log-Message "Verifying database content..."

Log-Message "Checking the count of the staging_orders table..."
Test-Run-Sql "SELECT count(*) FROM staging_orders;"
Test-Run-Sql "SELECT * FROM staging_orders LIMIT 5;"

Log-Message "Checking the count of the staging_inventory table..."
Test-Run-Sql "SELECT count(*) FROM staging_inventory;"
Test-Run-Sql "SELECT * FROM staging_inventory LIMIT 5;"

# Check the content of the dim_product table
Log-Message "Checking the content of the dim_product table..."
Test-Run-Sql "SELECT * FROM dim_product LIMIT 5;"

# Check the content of the dim_time table
Log-Message "Checking the content of the dim_time table..."
Test-Run-Sql "SELECT * FROM dim_time LIMIT 5;"

# Check the content of the dim_channel table
Log-Message "Checking the content of the dim_time table..."
Test-Run-Sql "SELECT * FROM dim_channel LIMIT 5;"

# Check the content of the fact_sales table
Log-Message "Checking the content of the fact_sales table..."
Test-Run-Sql "SELECT * FROM fact_sales LIMIT 5;"

# Run Report Queries
Log-Message "Running report queries..."

# Total Sales by Product
Log-Message "Total Sales by Product:"
Test-Run-Sql "SELECT dp.product_name, ROUND(SUM(cast(amount as NUMERIC)),2) AS total_sales FROM fact_sales fs JOIN dim_product dp ON fs.product_id = dp.product_id GROUP BY dp.product_name ORDER BY total_sales DESC LIMIT 10;"

# Top Selling Products
Log-Message "Top Selling Products:"
Test-Run-Sql "SELECT dp.product_name, COUNT(fs.order_id) AS total_orders FROM fact_sales fs JOIN dim_product dp ON fs.product_id = dp.product_id GROUP BY dp.product_name ORDER BY total_orders DESC LIMIT 10;"

# Sales by Category
Log-Message "Sales by Category:"
Test-Run-Sql "SELECT dp.category, ROUND(SUM(cast(amount as NUMERIC)),2) AS total_sales FROM fact_sales fs JOIN dim_product dp ON fs.product_id = dp.product_id GROUP BY dp.category ORDER BY total_sales DESC;"


# Monthly Sales Trend
Log-Message "Monthly Sales Trend:"
Test-Run-Sql "SELECT month AS sales_month, ROUND(SUM(cast(amount as NUMERIC)),2) AS total_sales FROM fact_sales fs JOIN dim_time dt ON fs.time_id = dt.time_id GROUP BY month ORDER BY month LIMIT 10;;"

Log-Message "Pipeline test completed."

# Stop and remove the app container
Log-Message "Stopping and removing the app container..."
docker stop ecommerce_app_container
docker rm ecommerce_app_container

# Remove the app image
Log-Message "Removing the app image..."
docker rmi ecommerce_app

Log-Message "Containers stopped and removed."