# 📊 Telecom Customer Churn Analysis
### Revenue at Risk & Early Warning Intelligence Dashboard

![Dashboard](https://img.shields.io/badge/Tool-Power%20BI-yellow)
![Database](https://img.shields.io/badge/Database-PostgreSQL-blue)
![Status](https://img.shields.io/badge/Status-Completed-green)
![Domain](https://img.shields.io/badge/Domain-Telecom-orange)

---

## 🎯 Business Problem

A telecom company is losing customers every month — but doesn't know **who is leaving, why they are leaving, and how much revenue is being lost.**

Most churn analysis projects only answer: *"Who churned?"*

This project goes further and answers 3 critical business questions:

1. **Who is churning and why?** — Demographics, contract type, internet type, churn reasons
2. **How much revenue is at risk?** — Total revenue lost broken down by state, contract, internet type
3. **Who is about to churn next?** — An early warning system that flags current active customers before they leave

> 💡 The unique angle of combining **Revenue at Risk + Early Warning Intelligence** makes this project stand out from standard churn dashboards.

---

## 📁 Project Structure

```
Telecom-Churn-Analysis/
│
├── data/
│   └── Customer_Data.csv              # Raw dataset (6418 customers, 32 columns)
│
├── sql/
│   └── Churn_SQL_Queries.sql          # All 15 PostgreSQL analysis queries
│
├── dashboard/
│   └── Customer_Churn.pbix            # 3-page Power BI dashboard
│
├── screenshots/
│   ├── page1_executive_summary.png
│   ├── page2_revenue_at_risk.png
│   └── page3_early_warning.png
│
└── README.md
```

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|------|---------|
| PostgreSQL 18 | Data storage, cleaning, transformation |
| pgAdmin 4 | Database management and query execution |
| Power BI Desktop | Interactive dashboard and visualization |

---

## 📊 Dataset Overview

| Property | Detail |
|----------|--------|
| Total Rows | 6,418 customers |
| Total Columns | 32 features |
| Key Target Column | Customer_Status — Churned / Stayed / Joined |

### Key Columns Used
- Customer_ID — Unique identifier
- Gender, Age, Married, State — Demographics
- Tenure_in_Months — Customer loyalty duration
- Contract — Month-to-Month / One Year / Two Year
- Internet_Type — Fiber Optic / DSL / Cable / None
- Monthly_Charge, Total_Revenue — Financial data
- Churn_Category, Churn_Reason — Why customers left
- Number_of_Referrals — Engagement signal
- Customer_Status — Target variable

---

## 🔄 Project Workflow

```
Raw CSV Data (Customer_Data.csv)
            ↓
  Load into PostgreSQL → stg_Churn (staging table)
            ↓
  Check NULLs across 9 key columns
            ↓
  Replace NULLs using COALESCE → prod_Churn (clean table)
            ↓
  Create 3 Views:
  vw_ChurnData | vw_JoinData | vw_EarlyWarning
            ↓
  Run 15 SQL Analysis Queries
            ↓
  Export Views as CSV → Load into Power BI
            ↓
  Build 3-Page Interactive Dashboard
```

---

## 🗄️ Database Setup

### Step 1 — Create Staging Table
```sql
CREATE TABLE stg_Churn (
    Customer_ID                 VARCHAR(50) PRIMARY KEY,
    Gender                      VARCHAR(50),
    Age                         INT,
    Married                     VARCHAR(50),
    State                       VARCHAR(50),
    Number_of_Referrals         INT,
    Tenure_in_Months            INT,
    Value_Deal                  VARCHAR(50),
    Phone_Service               VARCHAR(50),
    Multiple_Lines              VARCHAR(50),
    Internet_Service            VARCHAR(50),
    Internet_Type               VARCHAR(50),
    Online_Security             VARCHAR(50),
    Online_Backup               VARCHAR(50),
    Device_Protection_Plan      VARCHAR(50),
    Premium_Support             VARCHAR(50),
    Streaming_TV                VARCHAR(50),
    Streaming_Movies            VARCHAR(50),
    Streaming_Music             VARCHAR(50),
    Unlimited_Data              VARCHAR(50),
    Contract                    VARCHAR(50),
    Paperless_Billing           VARCHAR(50),
    Payment_Method              VARCHAR(50),
    Monthly_Charge              NUMERIC(10,2),
    Total_Charges               NUMERIC(10,2),
    Total_Refunds               NUMERIC(10,2),
    Total_Extra_Data_Charges    NUMERIC(10,2),
    Total_Long_Distance_Charges NUMERIC(10,2),
    Total_Revenue               NUMERIC(10,2),
    Customer_Status             VARCHAR(50),
    Churn_Category              VARCHAR(50),
    Churn_Reason                VARCHAR(100)
);
```

### Step 2 — NULL Check
```sql
SELECT
    SUM(CASE WHEN Value_Deal IS NULL THEN 1 ELSE 0 END) AS Value_Deal_Nulls,
    SUM(CASE WHEN Multiple_Lines IS NULL THEN 1 ELSE 0 END) AS Multiple_Lines_Nulls,
    SUM(CASE WHEN Internet_Type IS NULL THEN 1 ELSE 0 END) AS Internet_Type_Nulls,
    SUM(CASE WHEN Churn_Category IS NULL THEN 1 ELSE 0 END) AS Churn_Category_Nulls,
    SUM(CASE WHEN Churn_Reason IS NULL THEN 1 ELSE 0 END) AS Churn_Reason_Nulls
FROM stg_Churn;
```

### Step 3 — Create Clean Production Table
```sql
CREATE TABLE prod_Churn AS
SELECT
    Customer_ID, Gender, Age, Married, State,
    Number_of_Referrals, Tenure_in_Months,
    COALESCE(Value_Deal, 'None')               AS Value_Deal,
    Phone_Service,
    COALESCE(Multiple_Lines, 'No')             AS Multiple_Lines,
    Internet_Service,
    COALESCE(Internet_Type, 'None')            AS Internet_Type,
    COALESCE(Online_Security, 'No')            AS Online_Security,
    COALESCE(Online_Backup, 'No')              AS Online_Backup,
    COALESCE(Device_Protection_Plan, 'No')     AS Device_Protection_Plan,
    COALESCE(Premium_Support, 'No')            AS Premium_Support,
    COALESCE(Streaming_TV, 'No')               AS Streaming_TV,
    COALESCE(Streaming_Movies, 'No')           AS Streaming_Movies,
    COALESCE(Streaming_Music, 'No')            AS Streaming_Music,
    COALESCE(Unlimited_Data, 'No')             AS Unlimited_Data,
    Contract, Paperless_Billing, Payment_Method,
    Monthly_Charge, Total_Charges, Total_Refunds,
    Total_Extra_Data_Charges, Total_Long_Distance_Charges,
    Total_Revenue, Customer_Status,
    COALESCE(Churn_Category, 'Others')         AS Churn_Category,
    COALESCE(Churn_Reason, 'Others')           AS Churn_Reason
FROM stg_Churn;
```

### Step 4 — Create Views for Power BI
```sql
CREATE VIEW vw_ChurnData AS
SELECT * FROM prod_Churn
WHERE Customer_Status IN ('Churned', 'Stayed');

CREATE VIEW vw_JoinData AS
SELECT * FROM prod_Churn
WHERE Customer_Status = 'Joined';

CREATE VIEW vw_EarlyWarning AS
SELECT
    Customer_ID, Age, State, Contract,
    Tenure_in_Months, Monthly_Charge, Total_Revenue,
    Internet_Type, Paperless_Billing, Customer_Status,
    CASE
        WHEN Contract = 'Month-to-Month'
             AND Tenure_in_Months < 12
             AND Monthly_Charge > 65
        THEN 'High Risk'
        WHEN Contract = 'Month-to-Month'
             AND Tenure_in_Months BETWEEN 12 AND 24
        THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS Risk_Level
FROM prod_Churn
WHERE Customer_Status = 'Stayed';
```

---

## 🔍 15 SQL Analysis Queries

### Page 1 — Executive Summary

**Q1 — Overall Churn Rate**
```sql
SELECT
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) AS Total_Churned,
    ROUND(SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Churn_Rate_Pct
FROM prod_Churn;
-- Result: 6418 total | 1732 churned | 26.99% churn rate
```

**Q2 — Churn Rate by Contract Type**
```sql
SELECT
    Contract,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) AS Churned,
    ROUND(SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Churn_Rate_Pct
FROM prod_Churn
GROUP BY Contract
ORDER BY Churn_Rate_Pct DESC;
```

**Q3 — Top 5 Churn Reasons**
```sql
SELECT
    Churn_Reason,
    COUNT(*) AS Total,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM prod_Churn WHERE Customer_Status = 'Churned'), 2) AS Pct
FROM prod_Churn
WHERE Customer_Status = 'Churned'
GROUP BY Churn_Reason
ORDER BY Total DESC
LIMIT 5;
```

### Page 2 — Revenue at Risk

**Q4 — Total Revenue Lost**
```sql
SELECT ROUND(SUM(Total_Revenue), 2) AS Revenue_Lost
FROM prod_Churn
WHERE Customer_Status = 'Churned';
```

**Q5 — Revenue Lost by Contract Type**
```sql
SELECT
    Contract,
    COUNT(*) AS Churned_Customers,
    ROUND(SUM(Total_Revenue), 2) AS Revenue_Lost,
    ROUND(AVG(Total_Revenue), 2) AS Avg_Revenue_Per_Churner
FROM prod_Churn
WHERE Customer_Status = 'Churned'
GROUP BY Contract
ORDER BY Revenue_Lost DESC;
```

**Q6 — Revenue Lost by State (Top 10)**
```sql
SELECT
    State,
    COUNT(*) AS Churned_Customers,
    ROUND(SUM(Total_Revenue), 2) AS Revenue_Lost
FROM prod_Churn
WHERE Customer_Status = 'Churned'
GROUP BY State
ORDER BY Revenue_Lost DESC
LIMIT 10;
```

**Q7 — Revenue Lost by Internet Type**
```sql
SELECT
    Internet_Type,
    COUNT(*) AS Churned_Customers,
    ROUND(SUM(Total_Revenue), 2) AS Revenue_Lost,
    ROUND(AVG(Monthly_Charge), 2) AS Avg_Monthly_Charge
FROM prod_Churn
WHERE Customer_Status = 'Churned'
GROUP BY Internet_Type
ORDER BY Revenue_Lost DESC;
```

**Q8 — High Value Churners (Top 20% by Revenue)**
```sql
SELECT
    Customer_ID, State, Contract,
    Tenure_in_Months, Total_Revenue, Churn_Reason
FROM prod_Churn
WHERE Customer_Status = 'Churned'
  AND Total_Revenue > (
      SELECT PERCENTILE_CONT(0.80) WITHIN GROUP (ORDER BY Total_Revenue)
      FROM prod_Churn WHERE Customer_Status = 'Churned'
  )
ORDER BY Total_Revenue DESC;
```

### Page 3 — Early Warning Signals

**Q9 — Churn Rate by Tenure Group**
```sql
SELECT
    CASE
        WHEN Tenure_in_Months < 6  THEN '0-6 Months'
        WHEN Tenure_in_Months < 12 THEN '6-12 Months'
        WHEN Tenure_in_Months < 24 THEN '12-24 Months'
        WHEN Tenure_in_Months < 48 THEN '24-48 Months'
        ELSE '48+ Months'
    END AS Tenure_Group,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) AS Churned,
    ROUND(SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Churn_Rate_Pct
FROM prod_Churn
GROUP BY Tenure_Group
ORDER BY Churn_Rate_Pct DESC;
```

**Q10 — Churn Rate by Age Group**
```sql
SELECT
    CASE
        WHEN Age < 30 THEN 'Under 30'
        WHEN Age < 45 THEN '30-44'
        WHEN Age < 60 THEN '45-59'
        ELSE '60+'
    END AS Age_Group,
    COUNT(*) AS Total,
    SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) AS Churned,
    ROUND(SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Churn_Rate_Pct
FROM prod_Churn
GROUP BY Age_Group
ORDER BY Churn_Rate_Pct DESC;
```

**Q11 — Churn Rate by Number of Referrals**
```sql
SELECT
    Number_of_Referrals,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) AS Churned,
    ROUND(SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Churn_Rate_Pct
FROM prod_Churn
GROUP BY Number_of_Referrals
ORDER BY Number_of_Referrals;
```

**Q12 — Danger Zone: Active Customers Matching Churner Profile**
```sql
SELECT
    Customer_ID, Age, State, Contract,
    Tenure_in_Months, Monthly_Charge, Total_Revenue, Internet_Type
FROM prod_Churn
WHERE Customer_Status = 'Stayed'
  AND Contract = 'Month-to-Month'
  AND Tenure_in_Months < 12
  AND Monthly_Charge > 65
ORDER BY Monthly_Charge DESC;
```

**Q13 — Paperless Billing + Contract Danger Combo**
```sql
SELECT
    Paperless_Billing, Contract,
    COUNT(*) AS Total,
    ROUND(SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Churn_Rate_Pct
FROM prod_Churn
GROUP BY Paperless_Billing, Contract
ORDER BY Churn_Rate_Pct DESC;
```

**Q14 — Churn Rate by Payment Method**
```sql
SELECT
    Payment_Method,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) AS Churned,
    ROUND(SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Churn_Rate_Pct
FROM prod_Churn
GROUP BY Payment_Method
ORDER BY Churn_Rate_Pct DESC;
```

**Q15 — Early Warning Risk Level Summary**
```sql
SELECT Risk_Level, COUNT(*) AS Total_Customers
FROM vw_EarlyWarning
GROUP BY Risk_Level
ORDER BY Total_Customers DESC;
```

---

## 📈 Power BI Dashboard — 3 Pages

### Page 1 — Executive Summary
| KPI | Value |
|-----|-------|
| Total Customers | 6,418 |
| Churn Rate | 26.99% |
| Total Churned | 1,732 |
| Total Revenue | 19.47M |

Visuals: Churn by contract, donut chart by internet type, top churn reasons bar chart, churn by state column chart
Slicers: State, Gender

### Page 2 — Revenue at Risk
| KPI | Value |
|-----|-------|
| Total Revenue Lost | 19.42M |
| Highest Loss State | Uttar Pradesh |
| Highest Loss Internet | Fiber Optic |

Visuals: Revenue by state, revenue by contract type, revenue by internet type
Slicers: State, Internet Type

### Page 3 — Early Warning
| KPI | Value |
|-----|-------|
| At Risk Customers | 4,300+ |
| Average Age | 47 years |
| High Risk Avg Monthly Charge | 86 |

Visuals: Risk level distribution, churn rate by tenure, monthly charge by risk level
Slicers: Contract type

---

## 💡 Key Business Insights & Recommendations

**Insight 1 — Month-to-Month Contracts are the Biggest Risk**
Month-to-Month customers churn at nearly 45% — almost double the overall average. Converting even 20% of these customers to annual contracts could dramatically reduce overall churn.

**Insight 2 — Fiber Optic Users Pay More but Leave More**
Fiber Optic customers generate the highest revenue but also have the highest churn rate. This signals a service quality or value perception issue that needs a business investigation.

**Insight 3 — New Customers are Most Vulnerable**
Customers in their first 6 months have the highest churn rate. A structured onboarding program with check-in calls and welcome offers in the first 90 days could significantly reduce early churn.

**Insight 4 — Zero Referrals Equals High Churn Risk**
Customers with no referrals churn significantly more than those with 3+ referrals. A referral incentive program would improve both retention and new customer acquisition simultaneously.

**Insight 5 — 4,300+ Customers Need Immediate Attention**
The early warning model identified 4,300+ active customers currently matching the high-risk churner profile. Proactive outreach to these customers — before they churn — could save millions in revenue.

**Insight 6 — Uttar Pradesh and Tamil Nadu are Priority States**
These two states account for the highest revenue loss from churn. Regional retention campaigns targeting these states would deliver the highest ROI.

---

## 🚀 How to Reproduce This Project

### PostgreSQL Setup
1. Install PostgreSQL 18 and pgAdmin 4
2. Create a new database named `db_Churn`
3. Open Query Tool inside `db_Churn`
4. Run the CREATE TABLE stg_Churn script
5. Right-click stg_Churn → Import/Export → Import Customer_Data.csv
6. Run the CREATE TABLE prod_Churn cleaning script
7. Run the 3 CREATE VIEW scripts
8. Run all 15 analysis queries

### Power BI Setup
1. Export views as CSV from pgAdmin using COPY command
2. Open Power BI Desktop
3. Get Data → Text/CSV → load all CSV files
4. Build visuals and add DAX measure for Churn Rate %
5. Add slicers for interactivity

---

## 📂 Files in This Repository

| File | Description |
|------|-------------|
| Customer_Data.csv | Raw telecom customer dataset (6418 rows) |
| Churn_SQL_Queries.sql | All 15 PostgreSQL analysis queries |
| Customer_Churn.pbix | Complete 3-page Power BI dashboard |
| README.md | Full project documentation |

---

## 🙋 About This Project

This project was built as a data analyst portfolio project targeting roles in telecom, BFSI, and e-commerce companies in India. The combination of revenue impact analysis and early warning intelligence makes it stand out from standard churn tutorials.

**Skills demonstrated:**
- PostgreSQL — DDL, DML, aggregations, CASE statements, CTEs, views, PERCENTILE_CONT
- Data cleaning — NULL handling with COALESCE, staging vs production tables
- Power BI — DAX measures, slicers, interactive multi-page dashboards
- Business thinking — translating raw data into actionable recommendations

---
