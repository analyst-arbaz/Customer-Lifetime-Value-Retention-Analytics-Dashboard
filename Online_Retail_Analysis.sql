-- =====================================================================================
-- PROJECT: Online Retail Customer Lifetime Value (CLV) & Cohort Retention Analytics
-- AUTHOR:  Arbaz Khan
-- DATASET: Online Retail II (UCI / Kaggle) - UK-based Online Retailer (2009-2011)
-- TOOLS:   MySQL Workbench | Python (Pandas) | Excel | Power BI
-- =====================================================================================
-- DESCRIPTION:
-- This script sets up the database, imports cleaned transactional data (processed in
-- Python), and answers 10 real-world business questions using SQL (joins, aggregations,
-- window functions, and CASE statements).
-- =====================================================================================


-- =====================================================================================
-- SECTION 1: DATABASE SETUP
-- =====================================================================================

CREATE DATABASE IF NOT EXISTS online_retail_analysis;
USE online_retail_analysis;


-- =====================================================================================
-- SECTION 2: TABLE CREATION - CLEANED SALES DATA
-- =====================================================================================
-- This table stores transaction-level data after cleaning in Python:
--   - Missing Customer IDs removed
--   - Invalid prices removed
--   - Duplicates removed
--   - Cancelled orders flagged (Is_Cancelled)
--   - TotalPrice, InvoiceMonth, CohortMonth, CohortIndex engineered in Python
-- =====================================================================================

DROP TABLE IF EXISTS cleaned_sales;

CREATE TABLE cleaned_sales (
    Invoice         VARCHAR(20),
    StockCode       VARCHAR(20),
    Description     VARCHAR(255),
    Quantity        INT,
    InvoiceDate     DATETIME,
    Price           DECIMAL(10,2),
    `Customer ID`   DECIMAL(10,1),
    Country         VARCHAR(100),
    Is_Cancelled    TINYINT,
    TotalPrice      DECIMAL(12,2),
    InvoiceMonth    VARCHAR(10),
    CohortMonth     VARCHAR(10),
    CohortIndex     INT
);


-- =====================================================================================
-- SECTION 3: IMPORT CLEANED SALES DATA (Bulk Load - Fast Method)
-- =====================================================================================
-- LOAD DATA INFILE is used instead of the Table Import Wizard because the dataset has
-- ~7.8 lakh rows. This method loads bulk data directly, taking only ~15-20 seconds
-- compared to 1+ hour with the row-by-row Import Wizard.
--
-- NOTE: Before running this, check your secure file path using:
--       SHOW VARIABLES LIKE 'secure_file_priv';
-- Copy the CSV file into that exact folder before running LOAD DATA INFILE.
-- =====================================================================================

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cleaned_online_retail.csv'
INTO TABLE cleaned_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Invoice, StockCode, Description, Quantity, @InvoiceDate, Price, @CustomerID,
 Country, @IsCancelled, TotalPrice, InvoiceMonth, CohortMonth, CohortIndex)
SET
    InvoiceDate   = STR_TO_DATE(@InvoiceDate, '%Y-%m-%d %H:%i:%s'),
    `Customer ID` = NULLIF(@CustomerID, ''),
    Is_Cancelled  = CASE WHEN @IsCancelled = 'True' THEN 1 ELSE 0 END;


-- =====================================================================================
-- SECTION 4: TABLE CREATION - RFM & CLV DATA
-- =====================================================================================
-- This table stores customer-level RFM scores, segments, and CLV values,
-- pre-calculated in Python.
-- =====================================================================================

DROP TABLE IF EXISTS rfm_clv;

CREATE TABLE rfm_clv (
    CustomerID       DECIMAL(10,1),
    Recency          INT,
    Frequency        INT,
    Monetary         DECIMAL(12,2),
    R_Score          INT,
    F_Score          INT,
    M_Score          INT,
    RFM_Score        VARCHAR(10),
    Segment          VARCHAR(50),
    Historical_CLV   DECIMAL(12,2),
    AOV              DECIMAL(12,2),
    Predicted_CLV    DECIMAL(12,2)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/rfm_clv_table.csv'
INTO TABLE rfm_clv
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- =====================================================================================
-- SECTION 5: DATA VALIDATION
-- =====================================================================================
-- Sanity checks to confirm both tables imported correctly before running analysis.
-- =====================================================================================

SELECT COUNT(*) AS Total_Rows_Sales FROM cleaned_sales;
SELECT * FROM cleaned_sales LIMIT 10;
SELECT MIN(TotalPrice), MAX(TotalPrice), AVG(TotalPrice) FROM cleaned_sales;

SELECT COUNT(*) AS Total_Rows_RFM FROM rfm_clv;
SELECT * FROM rfm_clv LIMIT 10;


-- =====================================================================================
-- SECTION 6: BUSINESS QUESTIONS & ANALYSIS
-- =====================================================================================
-- NOTE: For revenue/sales/customer/product metrics, we filter "Is_Cancelled = 0" so
-- that cancelled orders (which are not real completed sales) don't inflate the numbers.
-- For cancellation-rate analysis itself, we intentionally do NOT filter it out, since
-- we need both cancelled and total orders to calculate the percentage.
-- =====================================================================================


-- -------------------------------------------------------------------------------------
-- Q1. What is the overall business performance in terms of total orders,
--     customers, and revenue?
-- -------------------------------------------------------------------------------------
SELECT 
    COUNT(DISTINCT Invoice) AS Total_Orders,
    COUNT(DISTINCT `Customer ID`) AS Total_Customers,
    SUM(TotalPrice) AS Total_Revenue,
    ROUND(AVG(TotalPrice), 2) AS Avg_Transaction_Value
FROM cleaned_sales
WHERE Is_Cancelled = 0;


-- -------------------------------------------------------------------------------------
-- Q2. Who are the top 10 customers generating the highest revenue?

-- -------------------------------------------------------------------------------------
SELECT 
    `Customer ID`,
    Country,
    SUM(TotalPrice) AS Total_Spent,
    COUNT(DISTINCT Invoice) AS Total_Orders
FROM cleaned_sales
WHERE Is_Cancelled = 0
GROUP BY `Customer ID`, Country
ORDER BY Total_Spent DESC
LIMIT 10;


-- -------------------------------------------------------------------------------------
-- Q3. How has revenue changed month by month over time?

-- -------------------------------------------------------------------------------------
SELECT 
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS Month,
    SUM(TotalPrice) AS Monthly_Revenue,
    COUNT(DISTINCT Invoice) AS Total_Orders
FROM cleaned_sales
WHERE Is_Cancelled = 0
GROUP BY Month
ORDER BY Month;


-- -------------------------------------------------------------------------------------
-- Q4. Which are the top 5 countries contributing the most revenue?

-- -------------------------------------------------------------------------------------
SELECT 
    Country,
    SUM(TotalPrice) AS Total_Revenue,
    COUNT(DISTINCT `Customer ID`) AS Total_Customers
FROM cleaned_sales
WHERE Is_Cancelled = 0
GROUP BY Country
ORDER BY Total_Revenue DESC
LIMIT 5;


-- -------------------------------------------------------------------------------------
-- Q5. Which products are the best-sellers by quantity sold?

-- -------------------------------------------------------------------------------------
SELECT 
    StockCode,
    Description,
    SUM(Quantity) AS Total_Quantity_Sold,
    SUM(TotalPrice) AS Total_Revenue
FROM cleaned_sales
WHERE Is_Cancelled = 0
GROUP BY StockCode, Description
ORDER BY Total_Quantity_Sold DESC
LIMIT 10;


-- -------------------------------------------------------------------------------------
-- Q6. What percentage of total orders were cancelled?
-- NOTE: No Is_Cancelled filter here - we need BOTH cancelled and total orders
--       to calculate the percentage correctly.
-- -------------------------------------------------------------------------------------
SELECT 
    COUNT(DISTINCT CASE WHEN Is_Cancelled = 1 THEN Invoice END) AS Cancelled_Orders,
    COUNT(DISTINCT Invoice) AS Total_Orders,
    ROUND(
        COUNT(DISTINCT CASE WHEN Is_Cancelled = 1 THEN Invoice END) * 100.0 
        / COUNT(DISTINCT Invoice), 2
    ) AS Cancellation_Rate_Percent
FROM cleaned_sales;


-- -------------------------------------------------------------------------------------
-- Q7. How much revenue does each customer segment (Champions, At Risk, etc.)
--     contribute?
-- -------------------------------------------------------------------------------------
SELECT 
    Segment,
    COUNT(*) AS Total_Customers,
    SUM(Historical_CLV) AS Total_Revenue,
    ROUND(AVG(Historical_CLV), 2) AS Avg_CLV_Per_Customer
FROM rfm_clv
GROUP BY Segment
ORDER BY Total_Revenue DESC;


-- -------------------------------------------------------------------------------------
-- Q8. Which customers have the highest predicted future value?
-- -------------------------------------------------------------------------------------
SELECT 
    CustomerID,
    Segment,
    Historical_CLV,
    Predicted_CLV
FROM rfm_clv
ORDER BY Predicted_CLV DESC
LIMIT 10;


-- -------------------------------------------------------------------------------------
-- Q9. Which day of the week generates the highest sales?
-- -------------------------------------------------------------------------------------
SELECT 
    DAYNAME(InvoiceDate) AS Day_Of_Week,
    SUM(TotalPrice) AS Total_Revenue,
    COUNT(DISTINCT Invoice) AS Total_Orders
FROM cleaned_sales
WHERE Is_Cancelled = 0
GROUP BY Day_Of_Week
ORDER BY Total_Revenue DESC;


-- -------------------------------------------------------------------------------------
-- Q10. What is the running total (cumulative) revenue growth over time?
-- -------------------------------------------------------------------------------------
SELECT 
    Month,
    Monthly_Revenue,
    SUM(Monthly_Revenue) OVER (ORDER BY Month) AS Cumulative_Revenue
FROM (
    SELECT 
        DATE_FORMAT(InvoiceDate, '%Y-%m') AS Month,
        SUM(TotalPrice) AS Monthly_Revenue
    FROM cleaned_sales
    WHERE Is_Cancelled = 0
    GROUP BY Month
) AS monthly_data
ORDER BY Month;


-- =====================================================================================
-- END OF SCRIPT
-- =====================================================================================
