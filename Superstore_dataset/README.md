🏬 Superstore Sales Analysis and Data Cleaning:

Overview:
This project dives into the Superstore Sales dataset, focusing on data cleaning, exploratory data analysis (EDA), and case study insights. The dataset contains diverse information on orders, including dates, shipment modes, customer details, regions, product categories, and financial metrics. The primary goal was to uncover business trends, optimize data quality, and derive actionable insights from the data.

📂 Dataset Information:
Columns:
*  Order Date, Ship Date, Customer Name, Segment, Region, Category, Sales, Quantity, Discount, Profit
* Key Analysis Areas: Data consistency, categorical patterns, profitability trends, regional comparisons, and customer behavior.

🎯 Project Goals:
* Data Cleaning: Address data inconsistencies, handle null values, and standardize date formats to ensure accurate analysis.
* Exploratory Data Analysis (EDA): Gain insights into sales and profit distribution, regional performance, and category-based sales trends.
* Case Study: Address business-driven questions like high-profit categories, top regions by sales, and time-to-ship for orders.

📊 Key Findings:
* Profitability varies significantly across product categories and regions.
* Discount Patterns showed strong correlations with profit outcomes, particularly when exceeding 20%.
* Sales Trends were identified at monthly and quarterly intervals, helping to visualize seasonal demand.

⚙️ Challenges Faced:
* Data Type Issues: Columns like Order Date and Ship Date were set as text, leading to complications in date-based calculations. Conversion of these columns to a date format required thorough checks.
* Missing and Duplicated Data: Some rows had inconsistencies or redundancies, which needed careful handling to avoid skewing the analysis.
* Complex Aggregations: Conducting cumulative and conditional analyses on subsets of data required optimized SQL queries for efficiency.

🚀 Getting Started
Step 1: Load the dataset and perform initial inspections.
Step 2: Run data cleaning scripts to prepare the data for accurate EDA.
Step 3: Analyze case study questions and execute insights using SQL.
