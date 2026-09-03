# 📊 Customer Lifetime Value & Retention Analytics Dashboard

### An End-to-End Data Analytics Project using SQL, Python, Excel & Power BI

![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow?style=for-the-badge&logo=powerbi)
![Python](https://img.shields.io/badge/Python-Data%20Analysis-blue?style=for-the-badge&logo=python)
![MySQL](https://img.shields.io/badge/MySQL-Database-orange?style=for-the-badge&logo=mysql)
![Excel](https://img.shields.io/badge/Excel-Reporting-green?style=for-the-badge&logo=microsoft-excel)

---

## 🔗 Live Dashboard

📎 **Power BI Dashboard Link:** https://github.com/analyst-arbaz/Customer-Lifetime-Value-Retention-Analytics-Dashboard/blob/a98fb4c1f647dbe5cf2a5b8d18256e85fe3b22ac/Dashboard.pbix

*(Replace this with your actual Power BI Service publish link once available. If you haven't published it yet, go to Power BI Desktop → Home → Publish → select your workspace, then copy the report link from the Power BI Service.)*

---

## 📌 Project Overview

This project analyzes two years (2009–2011) of transactional data from a UK-based online retailer to understand customer purchasing behavior, calculate **Customer Lifetime Value (CLV)**, segment customers using **RFM (Recency, Frequency, Monetary) analysis**, and measure **customer retention** using cohort analysis.

The project follows a complete end-to-end analytics workflow — from raw data cleaning in Python, to relational database design and querying in SQL, to a summary report in Excel, and finally an interactive, multi-page dashboard in Power BI.

---

## 🎯 Objectives

- Clean and prepare raw transactional data for analysis
- Calculate Historical and Predicted Customer Lifetime Value (CLV)
- Segment customers into behavior-based groups (Champions, Loyal Customers, At Risk, Lost Customers, etc.) using RFM analysis
- Perform cohort analysis to measure month-over-month customer retention
- Answer real-world business questions using SQL (joins, aggregations, window functions)
- Build an interactive Power BI dashboard for business stakeholders to explore revenue trends, customer segments, and retention patterns

---

## 🗂️ Dataset

**Source:** [Online Retail II — UCI Machine Learning Repository / Kaggle](https://www.kaggle.com/datasets/mashlyn/online-retail-ii-uci)

**Description:** Transactional data containing all purchases made by a UK-based, registered, non-store online retailer between 01/12/2009 and 09/12/2011. The company primarily sells unique all-occasion gift-ware, and many of its customers are wholesalers.

**Original Columns:**

| Column | Description |
|---|---|
| Invoice | Unique invoice number (prefix 'C' indicates a cancellation) |
| StockCode | Unique product code |
| Description | Product name |
| Quantity | Quantity of each product per transaction |
| InvoiceDate | Date and time of the transaction |
| Price | Unit price (in GBP) |
| Customer ID | Unique customer identifier |
| Country | Customer's country of residence |

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| **Python** (Pandas, NumPy) | Data cleaning, feature engineering, RFM analysis, CLV calculation, cohort analysis |
| **MySQL Workbench** | Relational database design, bulk data import, business question queries |
| **Microsoft Excel** | Pivot table summary reporting for segment-wise CLV |
| **Power BI** | Interactive, multi-page dashboard with DAX measures, drill-through, and dynamic visuals |

---

## 🔄 Project Workflow

```
Raw Dataset (CSV)
      │
      ▼
Python — Data Cleaning & Feature Engineering
  • Removed missing Customer IDs
  • Flagged and separated cancelled transactions
  • Removed invalid prices and duplicate records
  • Engineered TotalPrice, InvoiceMonth columns
      │
      ▼
Python — RFM Analysis & CLV Calculation
  • Calculated Recency, Frequency, Monetary metrics per customer
  • Assigned RFM scores and customer segments (Champions, At Risk, Lost, etc.)
  • Calculated Historical CLV and Predicted CLV
      │
      ▼
Python — Cohort Analysis
  • Grouped customers by first purchase month (cohort)
  • Calculated month-over-month retention percentage
      │
      ▼
MySQL — Database & Business Questions
  • Loaded cleaned data into a MySQL database using bulk import
  • Answered 10 real-world business questions using SQL
      │
      ▼
Excel — Segment Summary Report
  • Pivot table summary of customer segments and CLV
      │
      ▼
Power BI — Interactive Dashboard
  • 3-page dashboard: Overview, Customer Segmentation, Cohort Retention
```

---

## 🐍 Python — Data Cleaning & Feature Engineering

Key steps performed in Python (Pandas):

1. **Cancellation Flagging** — Identified cancelled transactions (Invoice numbers starting with 'C') and created an `Is_Cancelled` flag.
2. **Missing Data Handling** — Removed transactions with missing Customer IDs, since customer-level analysis (RFM/CLV) requires a valid customer identifier.
3. **Invalid Data Removal** — Removed transactions with zero or negative prices (data entry errors).
4. **Duplicate Removal** — Identified and removed exact duplicate records.
5. **Feature Engineering** — Created a `TotalPrice` column (Quantity × Price) and extracted `InvoiceMonth` for time-based analysis.

### RFM Analysis
- **Recency:** Days since a customer's last purchase
- **Frequency:** Number of unique orders placed
- **Monetary:** Total amount spent
- Customers were scored on a 1–4 quartile scale for each metric and grouped into segments: **Champions, Loyal Customers, Potential Loyalist, At Risk, Lost Customers, Others**

### CLV Calculation
- **Historical CLV:** Total revenue generated by a customer to date
- **Predicted CLV:** Estimated future value, calculated using Average Order Value × Purchase Frequency (normalized per year of customer activity), capped at a realistic maximum purchase frequency to avoid outlier distortion

### Cohort Analysis
- Customers were grouped into monthly cohorts based on their first purchase date
- Retention percentage was calculated for each cohort across subsequent months to visualize customer retention trends over time

---

## 🗄️ SQL — Database & Business Questions

A MySQL database (`online_retail_analysis`) was created with two main tables:
- `cleaned_sales` — transaction-level data (~7.8 lakh rows)
- `rfm_clv` — customer-level RFM scores, segments, and CLV values

Data was bulk-loaded using `LOAD DATA INFILE` for efficient processing of large datasets.

### Business Questions Answered:
1. What is the overall business performance (orders, customers, revenue)?
2. Who are the top 10 customers generating the highest revenue?
3. How has revenue changed month by month over time?
4. Which are the top 5 countries contributing the most revenue?
5. Which products are the best-sellers by quantity sold?
6. What percentage of total orders were cancelled?
7. How much revenue does each customer segment contribute?
8. Which customers have the highest predicted future value?
9. Which day of the week generates the highest sales?
10. What is the cumulative (running total) revenue growth over time? *(using SQL window functions)*

📄 Full SQL script: [`Online_Retail_Analysis.sql`](./Online_Retail_Analysis.sql)

---

## 📊 Power BI — Interactive Dashboard

The Power BI dashboard consists of **three pages**, connected through relationships and synced filters:

### 1️⃣ Overview
- KPI cards: Total Revenue, Total Customers, Average Order Value, Total Predicted Revenue, Total Orders
- Revenue & Month-over-Month Growth Trend (combo chart)
- Top-selling products (bar chart)
- Geographic revenue contribution by country
- Revenue distribution by customer segment (donut chart)

### 2️⃣ Customer Segmentation & RFM Analytics
- Customer distribution by RFM segment
- Revenue contribution by segment
- Average Recency, Frequency, and Monetary value by segment
- Top customers ranked by Predicted CLV (with drill-through to customer-level detail)

### 3️⃣ Cohort Retention & Churn Analysis
- Month-over-month retention heatmap by cohort
- Key retention rate KPIs (Month 1, Month 3, Month 12 retention)
- Overall retention trend line across all cohorts

**Key DAX Measures Used:** Total Revenue, Total Customers, Average CLV, Cancellation Rate %, Month-over-Month Revenue Growth % (using time intelligence functions), and segment-level averages.

---

## 💡 Key Insights

- The business generated **£17.37M** in historical revenue from **~6,000 unique customers**, with a projected future revenue potential of **£49.26M** based on current purchasing patterns — indicating strong customer lifetime value upside if retention is improved.
- **United Kingdom** contributes the overwhelming majority of revenue (~14M out of ~17.37M), with EIRE, Netherlands, Germany, and France as smaller but notable international markets.
- **Champions** (the most recent, frequent, and high-spending customers) contribute the majority of total revenue despite being a smaller portion of the customer base — reinforcing the importance of retention strategies focused on top-tier customers.
- Customer retention drops sharply after the first month across nearly all cohorts, highlighting an opportunity for improved onboarding and early engagement strategies to reduce early-stage churn.
- The top-selling products by quantity are dominated by novelty and home décor gift items, consistent with the retailer's gift-ware business model.

---

## 📂 Repository Structure

```
Customer-Lifetime-Value-Retention-Analytics/
│
├── 📓 Analysis.ipynb                  # Python: data cleaning, RFM, CLV, cohort analysis
├── 🗄️ Online_Retail_Analysis.sql      # SQL: database setup, import, business questions
├── 📊 Customer_Lifetime_Value_Retention_Dashboard.pbix   # Power BI dashboard
├── 📈 RFM_Segment_Summary.xlsx        # Excel: segment-wise summary report
├── 🖼️ Dashboard_Screenshots/          # Dashboard preview images
└── 📄 README.md                       # Project documentation
```

---

## 🚀 Skills Demonstrated

- Data Cleaning & Preprocessing (Python/Pandas)
- Feature Engineering
- RFM Customer Segmentation
- Customer Lifetime Value (CLV) Modeling
- Cohort & Retention Analysis
- Relational Database Design (MySQL)
- SQL Querying (Joins, Aggregations, Window Functions, CASE statements)
- Bulk Data Import & Performance Optimization
- Excel Pivot Table Reporting
- Power BI Dashboard Design (DAX, Data Modeling, Drill-through, Time Intelligence)
- Business Insight Generation & Data Storytelling

---

## 👨‍💻 Author

**Arbaz Khan**
Data Analyst | Power BI Developer | SQL | Python | Business Intelligence

📧 Email: [arbazkhan21223@gmail.com](mailto:arbazkhan21223@gmail.com)
💼 LinkedIn: [Arbaz-Data-Analyst](https://www.linkedin.com/in/arbaz-data-analyst/)
🌐 Portfolio: [Developer Arbaz](https://developer-arbaz.github.io/developerarbaz.github.io/)
🐙 GitHub: [developer-arbaz](https://github.com/developer-arbaz)

---

### ⭐ If you found this project useful, please consider giving this repository a Star!
