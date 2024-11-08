USE sql_tasks;
SET sql_mode = (SELECT REPLACE (@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));
-- DATA CLEANING
-- LAPTOP DATASET
SELECT * FROM laptopdata;

-- Creating Backup of the original data
CREATE TABLE laptop_dataset_backup LIKE laptopdata;
INSERT INTO laptop_dataset_backup
SELECT * FROM laptopdata;

-- Chech the number of rows
SELECT COUNT(*) FROM laptopdata;

-- CHECK memory consumption for reference
SELECT * FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'sql_tasks' AND
TABLE_NAME = 'laptopdata';

-- Renaming the column
-- Drop the Non-Important column if necessary
SELECT * FROM laptopdata;
ALTER TABLE laptopdata RENAME COLUMN `Unnamed: 0` TO `index`;

-- Drop Null Values
SELECT * FROM laptopdata
WHERE Company IS NULL AND TypeName IS NULL AND Inches IS NULL AND
ScreenResolution IS NULL AND Cpu IS NULL AND Ram IS NULL AND Memory IS NULL
AND Gpu IS NULL AND OpSys IS NULL AND Weight IS NULL AND Price IS NULL;

-- Drop Duplicates
-- OPTION-1
DELETE FROM laptopdata
WHERE `index` NOT IN (SELECT MIN(`index`) FROM laptopdata
GROUP BY Company, TypeName, Inches, ScreenResolution, Cpu, Ram, Memory, Gpu, OpSys, Weight, Price);

-- OPTION-2 ----------------------------------
CREATE TABLE temp_df AS
SELECT DISTINCT * FROM laptopdata;

DROP TABLE laptopdata;

ALTER TABLE temp_df RENAME TO laptopdata;

SELECT * FROM laptopdata;
-- ------------------------------------------

-- Clean Ram -> Change column data types
-- For Categorical columns
SELECT DISTINCT(Company) FROM laptopdata;
SELECT DISTINCT(TypeName) FROM laptopdata;
-- Inches Column
ALTER TABLE laptopdata MODIFY COLUMN Inches DECIMAL(10,1);
SELECT * FROM laptopdata;
-- Ram Column
-- UPDATE laptopdata l1
-- SET Ram = (SELECT REPLACE(Ram, 'GB', '') FROM laptopdata l2 
-- 			WHERE l1.index = l2.index);
            
WITH updated_data AS
(SELECT `index`, REPLACE(Ram, 'GB', '') AS new_ram
FROM laptopdata)
    
UPDATE laptopdata l1
JOIN updated_data l2 ON l1.`index` = l2.`index`
SET l1.Ram = l2.new_ram;

ALTER TABLE laptopdata MODIFY COLUMN Ram INTEGER;

-- Weight Column
WITH updated_data AS 
(SELECT `index`, REPLACE(Weight, 'kg', '') AS new_weight 
FROM laptopdata)

UPDATE laptopdata l1
JOIN updated_data l2
ON l1.`index` = l2.`index`
SET l1.Weight = l2.new_weight;

-- Price Column
-- Step 1: Create a temporary table with the rounded prices
CREATE TEMPORARY TABLE temp_updated_data AS
SELECT `index`, ROUND(Price) AS new_price
FROM laptopdata;

-- Step 2: Use the temporary table to update the main table
UPDATE laptopdata l1
JOIN temp_updated_data l2 ON l1.`index` = l2.`index`
SET l1.Price = l2.new_price;

-- Step 3: Drop the temporary table (optional cleanup step)
DROP TEMPORARY TABLE temp_updated_data;

ALTER TABLE laptopdata MODIFY COLUMN Price INTEGER;

-- OpSys Column
SELECT OpSys,
CASE
	WHEN OpSys LIKE '%mac%' THEN 'macos'
    WHEN OpSys LIKE 'windows%' THEN 'windows'
    WHEN OpSys LIKE '%linux%' THEN 'linux'
    WHEN OpSys LIKE 'No OS' THEN 'N/A'
    ELSE 'others'
END AS 'os_brand'
FROM laptopdata;

UPDATE laptopdata
SET OpSys = CASE
	WHEN OpSys LIKE '%mac%' THEN 'macos'
    WHEN OpSys LIKE 'windows%' THEN 'windows'
    WHEN OpSys LIKE '%linux%' THEN 'linux'
    WHEN OpSys LIKE 'No OS' THEN 'N/A'
    ELSE 'others'
END;

SELECT * FROM laptopdata;

-- Gpu Column
ALTER TABLE laptopdata 
ADD COLUMN gpu_brand VARCHAR(255) AFTER Gpu,
ADD COLUMN gpu_name VARCHAR(255) AFTER gpu_brand;

SELECT * FROM laptopdata;

-- gpu_brand Column
-- UPDATE laptopdata l1
-- SET gpu_brand = (SELECT SUBSTRING_INDEX(Gpu, ' ', 1) FROM laptopdata l2 WHERE l2.`index` = l1.`index`)

-- Step 1: Create a temporary table to store `index` and the extracted `gpu_brand` value
CREATE TEMPORARY TABLE temp_gpu_brand AS
SELECT `index`, SUBSTRING_INDEX(Gpu, ' ', 1) AS new_gpu_brand
FROM laptopdata;

-- Step 2: Update the original table using the temporary table
UPDATE laptopdata l1
JOIN temp_gpu_brand l2 ON l1.`index` = l2.`index`
SET l1.gpu_brand = l2.new_gpu_brand;

-- Step 3: Drop the temporary table (optional cleanup)
DROP TEMPORARY TABLE temp_gpu_brand;

SELECT * FROM laptopdata;

-- gpu_name
-- Step 1: Create a temporary table to store `index` and the extracted `gpu_brand` value
CREATE TEMPORARY TABLE temp_gpu_name AS
SELECT `index`, REPLACE(Gpu, gpu_brand, '') AS new_gpu FROM laptopdata;

-- Step 2: Update the original table using the temporary table
UPDATE laptopdata l1
JOIN temp_gpu_name l2 ON l1.`index` = l2.`index`
SET l1.gpu_name = l2.new_gpu;

-- Step 3: Drop the temporary table (optional cleanup)
DROP TEMPORARY TABLE temp_gpu_name;
SELECT * FROM laptopdata;

-- Drop Gpu Column
ALTER TABLE laptopdata DROP COLUMN Gpu;
SELECT * FROM laptopdata;

-- Cpu Column
ALTER TABLE laptopdata 
ADD COLUMN cpu_brand VARCHAR(255) AFTER Cpu,
ADD COLUMN cpu_name VARCHAR(255) AFTER cpu_brand,
ADD COLUMN cpu_speed DECIMAL(10,1) AFTER cpu_name;
-- Step 1: Create a temporary table to store `index`
CREATE TEMPORARY TABLE cpu_temp_df AS
SELECT `index`, SUBSTRING_INDEX(Cpu, ' ', 1) AS new_cpu_brand FROM laptopdata;
-- Step 2: Update the original table using the temporary table
UPDATE laptopdata l1
JOIN cpu_temp_df l2 ON l1.`index` = l2.`index`
SET l1.cpu_brand = l2.new_cpu_brand;
-- Step 3: Drop the temporary table (optional cleanup)
DROP TEMPORARY TABLE cpu_temp_df;

SELECT * FROM laptopdata;
-- Step 1: Create a temporary table to store the extracted `cpu_speed`
CREATE TEMPORARY TABLE temp_cpu_speed AS
SELECT `index`, 
       CAST(REPLACE(SUBSTRING_INDEX(Cpu, ' ', -1), 'GHz', '') AS DECIMAL(10,2)) AS new_cpu_speed
FROM laptopdata;

-- Step 2: Update the original table using the temporary table
UPDATE laptopdata l1
JOIN temp_cpu_speed t ON l1.`index` = t.`index`
SET l1.cpu_speed = t.new_cpu_speed;

-- Step 3: Drop the temporary table (optional cleanup)
DROP TEMPORARY TABLE temp_cpu_speed;

-- cpu_name Column
-- Step 1: Create a temporary table to store the extracted `cpu_name`
CREATE TEMPORARY TABLE temp_cpu_name AS
SELECT `index`, 
       REPLACE(REPLACE(Cpu, cpu_brand, ''), SUBSTRING_INDEX(REPLACE(Cpu, cpu_brand, ''), ' ', -1), '') AS new_cpu_name
FROM laptopdata;

-- Step 2: Update the original table using the temporary table
UPDATE laptopdata l1
JOIN temp_cpu_name t ON l1.`index` = t.`index`
SET l1.cpu_name = t.new_cpu_name;

-- Step 3: Drop the temporary table (optional cleanup)
DROP TEMPORARY TABLE temp_cpu_name;

ALTER TABLE laptopdata DROP COLUMN Cpu;

SELECT * FROM laptopdata;


