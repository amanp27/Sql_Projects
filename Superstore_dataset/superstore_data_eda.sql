USE sql_tasks;
SET sql_mode = (SELECT REPLACE (@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));
-- EDA
-- SUPERSTORE DATASET
-- LAPTOP DATASET
SELECT * FROM superstore_data;
-- Head
SELECT * FROM superstore_data
ORDER BY `Row ID` LIMIT 5;

-- Tail
SELECT * FROM superstore_data
ORDER BY `Row ID` DESC LIMIT 5;

-- Sample
SELECT * FROM superstore_data
ORDER BY rand() LIMIT 5;

-- For Numerical Columns
-- 8 Number Summary
-- Sales Column
SELECT COUNT(Sales) AS count,
MIN(Sales) AS min_value, 
MAX(Sales) AS max_value,
AVG(Sales) AS avg_value,
STD(Sales) AS std_deviation
FROM superstore_data;

SELECT 
    MAX(CASE WHEN row_num = FLOOR(0.25 * total_count) THEN Sales END) AS Q1,
    MAX(CASE WHEN row_num = FLOOR(0.50 * total_count) THEN Sales END) AS Q2,
    MAX(CASE WHEN row_num = FLOOR(0.75 * total_count) THEN Sales END) AS Q3
FROM (
    SELECT Sales,
           ROW_NUMBER() OVER (ORDER BY Sales) AS row_num,
           COUNT(*) OVER () AS total_count
    FROM superstore_data
) AS ranked;

-- Missing values
SELECT COUNT(Sales) FROM superstore_data
WHERE Sales IS NULL;

-- Outliers
WITH quartiles AS (
    SELECT 
        MAX(CASE WHEN row_num = FLOOR(0.25 * total_count) THEN Sales END) AS Q1,
        MAX(CASE WHEN row_num = FLOOR(0.75 * total_count) THEN Sales END) AS Q3
    FROM (
        SELECT Sales,
               ROW_NUMBER() OVER (ORDER BY Sales) AS row_num,
               COUNT(*) OVER () AS total_count
        FROM superstore_data
    ) AS ranked
),
bounds AS (
    SELECT 
        Q1, Q3,
        (Q3 - Q1) AS IQR,
        (Q1 - 1.5 * (Q3 - Q1)) AS lower_bound,
        (Q3 + 1.5 * (Q3 - Q1)) AS upper_bound
    FROM quartiles
)
SELECT * 
FROM superstore_data, bounds
WHERE Sales < lower_bound OR Sales > upper_bound;

-- For Numerical Columns
-- 8 Number Summary
-- Profit Column
SELECT COUNT(Profit) AS count,
MIN(Profit) AS min_value, 
MAX(Profit) AS max_value,
AVG(Profit) AS avg_value,
STD(Profit) AS std_deviation
FROM superstore_data;

SELECT 
    MAX(CASE WHEN row_num = FLOOR(0.25 * total_count) THEN Profit END) AS Q1,
    MAX(CASE WHEN row_num = FLOOR(0.50 * total_count) THEN Profit END) AS Q2,
    MAX(CASE WHEN row_num = FLOOR(0.75 * total_count) THEN Profit END) AS Q3
FROM (
    SELECT Profit,
           ROW_NUMBER() OVER (ORDER BY Profit) AS row_num,
           COUNT(*) OVER () AS total_count
    FROM superstore_data
) AS ranked;

-- Missing values
SELECT COUNT(Profit) FROM superstore_data
WHERE Profit IS NULL;

-- Outliers
WITH quartiles AS (
    SELECT 
        MAX(CASE WHEN row_num = FLOOR(0.25 * total_count) THEN Profit END) AS Q1,
        MAX(CASE WHEN row_num = FLOOR(0.75 * total_count) THEN Profit END) AS Q3
    FROM (
        SELECT Profit,
               ROW_NUMBER() OVER (ORDER BY Profit) AS row_num,
               COUNT(*) OVER () AS total_count
        FROM superstore_data
    ) AS ranked
),
bounds AS (
    SELECT 
        Q1, Q3,
        (Q3 - Q1) AS IQR,
        (Q1 - 1.5 * (Q3 - Q1)) AS lower_bound,
        (Q3 + 1.5 * (Q3 - Q1)) AS upper_bound
    FROM quartiles
)
SELECT * 
FROM superstore_data, bounds
WHERE Profit < lower_bound OR Profit > upper_bound;

-- For Categorical Column 
-- Category Column
SELECT Category, COUNT(Category) AS count FROM superstore_data
GROUP BY Category;

-- Segment Column
SELECT Segment, COUNT(Segment) AS count FROM superstore_data
GROUP BY Segment;

-- Ship Mode Column
SELECT `Ship Mode`, COUNT(`Ship Mode`) AS count FROM superstore_data
GROUP BY `Ship Mode`;

-- Region Column
SELECT Region, COUNT(Region) AS count FROM superstore_data
GROUP BY Region;