🗄️ Database Setup

Step 1 —#Create Staging Table

sqlCREATE TABLE stg_Churn (
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
    Churn_Reason                VARCHAR(100));

Step 2 — NULL Check

sqlSELECT
    SUM(CASE WHEN Value_Deal IS NULL THEN 1 ELSE 0 END) AS Value_Deal_Nulls,
    SUM(CASE WHEN Multiple_Lines IS NULL THEN 1 ELSE 0 END) AS Multiple_Lines_Nulls,
    SUM(CASE WHEN Internet_Type IS NULL THEN 1 ELSE 0 END) AS Internet_Type_Nulls,
    SUM(CASE WHEN Churn_Category IS NULL THEN 1 ELSE 0 END) AS Churn_Category_Nulls,
    SUM(CASE WHEN Churn_Reason IS NULL THEN 1 ELSE 0 END) AS Churn_Reason_Nulls
	FROM stg_Churn;

Step 3 — Create Clean Production Table

sqlCREATE TABLE prod_Churn AS
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

Step 4 — Create Views for Power BI

	sqlCREATE VIEW vw_ChurnData AS
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


🔍 15 SQL Analysis Queries

Page 1 — Executive Summary

Q1 — Overall Churn Rate

sqlSELECT
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) AS Total_Churned,
    ROUND(SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Churn_Rate_Pct
    FROM prod_Churn;

-- Result: 6418 total | 1732 churned | 26.99% churn rate


Q2 — Churn Rate by Contract Type

sqlSELECT
    Contract,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) AS Churned,
    ROUND(SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Churn_Rate_Pct
	FROM prod_Churn
	GROUP BY Contract
	ORDER BY Churn_Rate_Pct DESC;
	
Q3 — Top 5 Churn Reasons

sqlSELECT
    Churn_Reason,
    COUNT(*) AS Total,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM prod_Churn WHERE Customer_Status = 'Churned'), 2) AS Pct
	FROM prod_Churn
	WHERE Customer_Status = 'Churned'
	GROUP BY Churn_Reason
	ORDER BY Total DESC
	LIMIT 5;
	
Page 2 — Revenue at Risk

Q4 — Total Revenue Lost

	sqlSELECT ROUND(SUM(Total_Revenue), 2) AS Revenue_Lost
	FROM prod_Churn
	WHERE Customer_Status = 'Churned';
	
Q5 — Revenue Lost by Contract Type
sqlSELECT
    Contract,
    COUNT(*) AS Churned_Customers,
    ROUND(SUM(Total_Revenue), 2) AS Revenue_Lost,
    ROUND(AVG(Total_Revenue), 2) AS Avg_Revenue_Per_Churner
	FROM prod_Churn
	WHERE Customer_Status = 'Churned'
	GROUP BY Contract
	ORDER BY Revenue_Lost DESC;
	
Q6 — Revenue Lost by State (Top 10)

sqlSELECT
    State,
    COUNT(*) AS Churned_Customers,
    ROUND(SUM(Total_Revenue), 2) AS Revenue_Lost
	FROM prod_Churn
	WHERE Customer_Status = 'Churned'
	GROUP BY State
	ORDER BY Revenue_Lost DESC
	LIMIT 10;
	
Q7 — Revenue Lost by Internet Type

sqlSELECT
    Internet_Type,
    COUNT(*) AS Churned_Customers,
    ROUND(SUM(Total_Revenue), 2) AS Revenue_Lost,
    ROUND(AVG(Monthly_Charge), 2) AS Avg_Monthly_Charge
	FROM prod_Churn
	WHERE Customer_Status = 'Churned'
	GROUP BY Internet_Type
	ORDER BY Revenue_Lost DESC;
	
Q8 — High Value Churners (Top 20% by Revenue)

sqlSELECT
    Customer_ID, State, Contract,
    Tenure_in_Months, Total_Revenue, Churn_Reason
	FROM prod_Churn
	WHERE Customer_Status = 'Churned'
	AND Total_Revenue > (
	SELECT PERCENTILE_CONT(0.80) WITHIN GROUP (ORDER BY Total_Revenue)
	FROM prod_Churn WHERE Customer_Status = 'Churned')
	ORDER BY Total_Revenue DESC;
	
Page 3 — Early Warning Signals

Q9 — Churn Rate by Tenure Group

sqlSELECT
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
		
Q10 — Churn Rate by Age Group

sqlSELECT
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
		
Q11 — Churn Rate by Number of Referrals

sqlSELECT
    Number_of_Referrals,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) AS Churned,
    ROUND(SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Churn_Rate_Pct
	FROM prod_Churn
	GROUP BY Number_of_Referrals
	ORDER BY Number_of_Referrals;
	
Q12 — Danger Zone: Active Customers Matching Churner Profile

sqlSELECT
    Customer_ID, Age, State, Contract,
    Tenure_in_Months, Monthly_Charge, Total_Revenue, Internet_Type
	FROM prod_Churn
	WHERE Customer_Status = 'Stayed'
	AND Contract = 'Month-to-Month'
    AND Tenure_in_Months < 12
    AND Monthly_Charge > 65
	ORDER BY Monthly_Charge DESC;
	
Q13 — Paperless Billing + Contract Danger Combo

sqlSELECT
    Paperless_Billing, Contract,
    COUNT(*) AS Total,
    ROUND(SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Churn_Rate_Pct
	FROM prod_Churn
	GROUP BY Paperless_Billing, Contract
	ORDER BY Churn_Rate_Pct DESC;
	
Q14 — Churn Rate by Payment Method

sqlSELECT
    Payment_Method,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) AS Churned,
    ROUND(SUM(CASE WHEN Customer_Status = 'Churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Churn_Rate_Pct
	FROM prod_Churn
	GROUP BY Payment_Method
	ORDER BY Churn_Rate_Pct DESC;
	
Q15 — Early Warning Risk Level Summary

sqlSELECT Risk_Level,
	COUNT(*) AS Total_Customers
	FROM vw_EarlyWarning
	GROUP BY Risk_Level
	ORDER BY Total_Customers DESC;