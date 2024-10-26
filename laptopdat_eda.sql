USE sql_tasks;
SET sql_mode = (SELECT REPLACE (@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));
-- EDA
-- LAPTOP DATASET
SELECT * FROM laptopdata;
-- Head
SELECT * FROM laptopdata
ORDER BY `index` LIMIT 5;

-- Tail
SELECT * FROM laptopdata
ORDER BY `index` DESC LIMIT 5;

-- Sample
SELECT * FROM laptopdata
ORDER BY rand() LIMIT 5;

-- For Numerical Columns
-- 8 Number Summary
-- Price Column
SELECT COUNT(Price),
MIN(Price), 
MAX(Price),
AVG(Price),
STD(Price)
FROM laptopdata;

SELECT Price AS Q1 FROM (
	SELECT Price, 
	ROW_NUMBER() OVER (ORDER BY Price) AS row_num,
	COUNT(*) OVER () AS total_count
	FROM laptopdata
) AS ranked
WHERE row_num = FLOOR(0.25 * total_count);

SELECT 
    MAX(CASE WHEN row_num = FLOOR(0.25 * total_count) THEN Price END) AS Q1,
    MAX(CASE WHEN row_num = FLOOR(0.50 * total_count) THEN Price END) AS Q2,
    MAX(CASE WHEN row_num = FLOOR(0.75 * total_count) THEN Price END) AS Q3
FROM (
    SELECT Price,
           ROW_NUMBER() OVER (ORDER BY Price) AS row_num,
           COUNT(*) OVER () AS total_count
    FROM laptopdata
) AS ranked;

-- Missing values
SELECT COUNT(Price) FROM laptopdata
WHERE PRICE IS NULL;

-- Outliers
WITH quartiles AS (
    SELECT 
        MAX(CASE WHEN row_num = FLOOR(0.25 * total_count) THEN Price END) AS Q1,
        MAX(CASE WHEN row_num = FLOOR(0.75 * total_count) THEN Price END) AS Q3
    FROM (
        SELECT Price,
               ROW_NUMBER() OVER (ORDER BY Price) AS row_num,
               COUNT(*) OVER () AS total_count
        FROM laptopdata
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
FROM laptopdata, bounds
WHERE Price < lower_bound OR Price > upper_bound;

-- Histogram
SELECT t.buckets, REPEAT('*', COUNT(*)/5) FROM (SELECT Price,
CASE
	WHEN Price Between 0 AND 25000 THEN '0-25K'
    WHEN Price Between 25001 AND 50000 THEN '25-50K'
    WHEN Price Between 50001 AND 75000 THEN '50-75K'
    WHEN Price Between 75001 AND 100000 THEN '75-100K'
	ELSE '>100K'
END AS 'buckets'
FROM laptopdata) t
GROUP BY t.buckets;

-- Inches
-- Missing Values
SELECT COUNT(Inches) FROM laptopdata
WHERE Inches IS NULL;

-- For Categorical Column 
-- Company Column
SELECT Company, COUNT(Company) FROM laptopdata
GROUP BY Company;

-- OpSys Column
SELECT OpSys, COUNT(OpSys) FROM laptopdata
GROUP BY OpSys;

-- Ram Column
SELECT Ram, COUNT(Ram) FROM laptopdata
GROUP BY Ram;

-- Cpu_brand Column
SELECT cpu_brand, COUNT(cpu_brand) FROM laptopdata
GROUP BY cpu_brand;

-- Numerical - Numerical Columns
-- Cpu_speed and Price Column
SELECT cpu_speed, Price,
MIN(cpu_speed), MIN(Price),
MAX(cpu_speed), MAX(Price),
AVG(cpu_speed), AVG(Price),
STD(cpu_speed), STD(cpu_speed)
FROM laptopdata;

-- Categorical - Categorical
-- Contingency Table
SELECT Company, 
SUM(CASE WHEN cpu_brand = 'Intel' THEN 1 ELSE 0 END) AS 'Intel',
SUM(CASE WHEN cpu_brand = 'AMD' THEN 1 ELSE 0 END) AS 'AMD',
SUM(CASE WHEN cpu_brand = 'Samsung' THEN 1 ELSE 0 END) AS 'Samsung'
FROM laptopdata
GROUP BY Company;


