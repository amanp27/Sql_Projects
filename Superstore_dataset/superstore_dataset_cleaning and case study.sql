USE sql_tasks;
SET sql_mode = (SELECT REPLACE (@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));
-- DATA CLEANING
-- Super Store DATASET
SELECT * FROM `sample - superstore`;

-- Rename the table if required*
RENAME TABLE `sample - superstore` TO superstore_data;
SELECT * FROM superstore_data;

-- Create backup of the original table
CREATE TABLE superstore_backup_data LIKE superstore_data;
INSERT INTO superstore_backup_data
SELECT * FROM superstore_data;

-- Check the Number of rows
SELECT COUNT(*) FROM superstore_data;

-- Check memory consumption for reference
SELECT DATA_LENGTH/1024 FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'sql_tasks'
AND TABLE_NAME = 'superstore_data';

-- Drop non-important columns
-- Order ID, Customer ID, Country, City, Postal Code, Product ID, Sub-Category, Product Name
ALTER TABLE superstore_data DROP `Product Name`;

SELECT * FROM superstore_data;

-- Handle NULL Values
SELECT * FROM superstore_data
WHERE `Order Date` IS NULL AND `Ship Date` IS NULL AND `Ship Mode` IS NULL AND 
`Customer Name` IS NULL AND Segment IS NULL AND State IS NULL AND Region IS NULL AND 
Category IS NULL AND  Sales IS NULL AND Quantity IS NULL AND Discount IS NULL AND 
Profit IS NULL;

-- Drop Dupliacte
-- Step-1: Create a temporary table with distinct values of original data
CREATE TABLE temp_df AS
SELECT DISTINCT * FROM superstore_data;

-- Step-2: Drop original table
DROP TABLE superstore_data;

-- Step-3: Rename the temporary table to orignal name
ALTER TABLE temp_df RENAME superstore_data;

SELECT * FROM superstore_data;
-- No Dupliactes and Null values are present in data.
-- -------------------------------------------------------------------------------
-- Some Common Questions on this dataset:

-- Q1. Find the total sales and total profit for each Category.
SELECT Category, ROUND(SUM(Sales)) AS 'total_sales',
ROUND(SUM(Profit)) AS 'total_profit'
FROM superstore_data
GROUP BY Category;

-- Q2. Calculate the average discount provided across different Ship Modes.
SELECT `Ship Mode`, ROUND(AVG(Discount),5)*100 AS 'avg_discount' FROM superstore_data
GROUP BY `Ship Mode`;

-- Q3. Identify the total quantity of items sold for each Segment.
SELECT Segment, SUM(Quantity) AS 'total_quantity_sold' FROM superstore_data
GROUP BY Segment;

-- Q4. Find the top 5 states by total sales.
SELECT State, ROUND(SUM(Sales),3) AS 'total_sales' FROM superstore_data
GROUP BY State
ORDER BY total_sales DESC LIMIT 5; 

-- Q5. List the unique ship modes used in orders placed in each Region.
SELECT Region, GROUP_CONCAT(DISTINCT `Ship Mode`) AS 'unique_ship_mode' FROM superstore_data
GROUP BY Region;

-- Q6. Get the total profit for each Region, and filter for only the Region with profits over a certain amount, e.g., $10,000.
SELECT Region, SUM(CAST(Profit AS DECIMAL(10,2))) AS 'total_profit' FROM superstore_data
GROUP BY Region
HAVING total_profit > 10000;

-- Q7. Find categories with an average profit over $500:
SELECT Category, AVG(Profit)*100 AS avg_Profit
FROM superstore_data
GROUP BY Category
HAVING avg_Profit > 500;

-- Q8. Use a ranking function to rank orders by Sales within each Category:
SELECT * FROM (SELECT Category, Sales,
RANK() OVER (PARTITION BY Category ORDER BY Sales DESC) AS sales_Rank
FROM superstore_data) t
WHERE sales_Rank <= 10
ORDER BY Category, sales_Rank;

-- Q9. Find the cumulative total of sales for each Region sorted by Order Date:
SELECT Region, `Order Date`, Sales,
    SUM(Sales) OVER (PARTITION BY Region ORDER BY `Order Date`) AS Cumulative_Sales
FROM superstore_data;

-- Q10. Get the first and last order dates for each customer
SELECT `Customer Name`, 
MIN(`Order Date`) AS First_Order_Date,
MAX(`Order Date`) AS Last_Order_Date
FROM superstore_data
GROUP BY `Customer Name`;

-- Q11. Total Sales and Profit by Region and Category (with ROLLUP)
SELECT Region, Category,
SUM(Sales) AS Total_Sales,
SUM(Profit) AS Total_Profit
FROM superstore_data
GROUP BY Region, Category WITH ROLLUP;
    
-- Q12. Total Sales, Quantity, and Profit by State and Segment (with ROLLUP)
SELECT State, Segment,
SUM(Sales) AS Total_Sales,
SUM(Quantity) AS Total_Quantity,
SUM(Profit) AS Total_Profit
FROM superstore_data
GROUP BY State, Segment WITH ROLLUP;
