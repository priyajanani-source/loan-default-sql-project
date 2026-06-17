--   LOAN DEFAULT SQL PROJECT
--   Dataset : Loan Default Analysis  (255,347 records)
--   Tool    : MySQL Workbench
--   Author  : [Priya Janani]

-- SECTION 1 – DATABASE & TABLE SETUP

CREATE DATABASE IF NOT EXISTS loan_project;
USE loan_project;

DROP TABLE IF EXISTS loan_default;

CREATE TABLE loan_default (
    LoanID          VARCHAR(20)    PRIMARY KEY,
    Age             INT,
    Income          INT,
    LoanAmount      INT,
    CreditScore     INT,
    MonthsEmployed  INT,
    NumCreditLines  INT,
    InterestRate    DECIMAL(5,2),
    LoanTerm        INT,
    DTIRatio        DECIMAL(4,2),
    Education       VARCHAR(30),
    EmploymentType  VARCHAR(20),
    MaritalStatus   VARCHAR(20),
    HasMortgage     VARCHAR(5),
    HasDependents   VARCHAR(5),
    LoanPurpose     VARCHAR(20),
    HasCoSigner     VARCHAR(5),
    DefaultStatus   INT,            
    LoanDate        Varchar(20)
);

-- After creating the table, import the CSV file:
-- MySQL Workbench → Table Data Import Wizard → select Loan_default_updated.csv
-- Map "Default" column → DefaultStatus
-- Map "Loan Date (DD/MM/YYYY)" column → LoanDate  (set format: %d-%m-%Y)


-- ================================================================
-- SECTION 2 – SQL QUESTIONS (Basic → Advanced)
-- ================================================================


-- ----------------------------------------------------------------
-- Q1 [BASIC] How many loan records are in the dataset?
-- ----------------------------------------------------------------
-- Skills: COUNT, basic SELECT

SELECT COUNT(*) AS Total_Loans
FROM loan_default;

-- Q2 [BASIC] Show the first 10 records from the table.

SELECT *
FROM loan_default
LIMIT 10;


-- Q3 [BASIC] How many borrowers defaulted vs did not default?

SELECT
    CASE WHEN DefaultStatus = 1 THEN 'Defaulted'
         ELSE 'Not Defaulted' END  AS Status,
    COUNT(*) AS Total_Borrowers,
    ROUND(COUNT(*) * 100.0
          / (SELECT COUNT(*) FROM loan_default), 2) AS Percentage
FROM loan_default
GROUP BY DefaultStatus;


-- Q4 [BASIC] What are the distinct loan purposes in the dataset?

SELECT DISTINCT LoanPurpose
FROM loan_default
ORDER BY LoanPurpose;

-- Q5 [BASIC] What is the minimum, maximum, and average 
--    loan amount across all borrowers?


SELECT
    MIN(LoanAmount) AS Min_LoanAmount,
    MAX(LoanAmount) AS Max_LoanAmount,
    ROUND(AVG(LoanAmount), 2) AS Avg_LoanAmount
FROM loan_default;


-- Q6 [BASIC] Find all borrowers who are unemployed 
--    and have defaulted.

SELECT
    LoanID, Age, Income, LoanAmount, CreditScore, DTIRatio
FROM loan_default
WHERE EmploymentType = 'Unemployed'
  AND DefaultStatus = 1
ORDER BY LoanAmount DESC;



-- Q7 [INTERMEDIATE] What is the default rate (%) 
--    by education level?


SELECT
    Education,
    COUNT(*) AS Total_Loans,
    SUM(DefaultStatus)  AS Total_Defaults,
    ROUND(SUM(DefaultStatus) * 100.0 / COUNT(*), 2) AS Default_Rate_Pct
FROM loan_default
GROUP BY Education
ORDER BY Default_Rate_Pct DESC;

-- Q8 [INTERMEDIATE] Which loan purpose has the 
--    highest default rate?


SELECT
    LoanPurpose,
    COUNT(*) AS Total_Loans,
    SUM(DefaultStatus) AS Defaults,
    ROUND(SUM(DefaultStatus) * 100.0 / COUNT(*), 2) AS Default_Rate_Pct
FROM loan_default
GROUP BY LoanPurpose
ORDER BY Default_Rate_Pct DESC;

-- Q9 [INTERMEDIATE] Compare average income, credit score, 
--    and loan amount between defaulted and non-defaulted borrowers.


SELECT
    CASE WHEN DefaultStatus = 1 THEN 'Defaulted'
         ELSE 'Not Defaulted' END AS Status,
    ROUND(AVG(Income), 2) AS Avg_Income,
    ROUND(AVG(LoanAmount), 2) AS Avg_LoanAmount,
    ROUND(AVG(CreditScore), 2) AS Avg_CreditScore,
    ROUND(AVG(InterestRate), 2) AS Avg_InterestRate,
    ROUND(AVG(DTIRatio), 2)  AS Avg_DTI_Ratio
FROM loan_default
GROUP BY DefaultStatus;

-- Q10 [INTERMEDIATE] Group borrowers into age brackets and find 
--     the default rate for each group.


SELECT
    CASE
        WHEN Age < 25              THEN 'Under 25'
        WHEN Age BETWEEN 25 AND 34 THEN '25 - 34'
        WHEN Age BETWEEN 35 AND 44 THEN '35 - 44'
        WHEN Age BETWEEN 45 AND 54 THEN '45 - 54'
        WHEN Age BETWEEN 55 AND 64 THEN '55 - 64'
        ELSE '65+'
    END AS Age_Group,
    COUNT(*) AS Total,
    SUM(DefaultStatus) AS Defaults,
    ROUND(SUM(DefaultStatus) * 100.0 / COUNT(*), 2) AS Default_Rate_Pct
FROM loan_default
GROUP BY Age_Group
ORDER BY Default_Rate_Pct DESC;

-- Q11 [INTERMEDIATE] Does having a co-signer reduce 
--     the default rate?


SELECT
    HasCoSigner,
    COUNT(*)  AS Total_Loans,                                          
    SUM(DefaultStatus)  AS Defaults,                                
    ROUND(SUM(DefaultStatus) * 100.0 / COUNT(*), 2)  AS Default_Rate_Pct
FROM loan_default
GROUP BY HasCoSigner
ORDER BY Default_Rate_Pct DESC;

-- Q12 [INTERMEDIATE] What is the average interest rate 
--     for each loan term?
SELECT
    LoanTerm,
    COUNT(*)   AS Total_Loans,                         
    ROUND(AVG(InterestRate), 2) AS Avg_Interest_Rate,       
    ROUND(AVG(LoanAmount), 2)   AS Avg_Loan_Amount       
FROM loan_default
GROUP BY LoanTerm
ORDER BY LoanTerm;

-- Q13 [INTERMEDIATE] Find high-risk borrowers: 
--     Credit Score < 400, DTI Ratio > 0.6, and Defaulted.


SELECT
    LoanID, Age, Income, LoanAmount,
    CreditScore, DTIRatio, EmploymentType, LoanPurpose
FROM loan_default
WHERE CreditScore  < 400
  AND DTIRatio     > 0.6
  AND DefaultStatus = 1
ORDER BY CreditScore ASC, DTIRatio DESC;


-- Q14 [INTERMEDIATE] Monthly trend: how many loans were issued 
--     and how many defaulted each month?


SELECT
    DATE_FORMAT(LoanDate, '%Y-%m')  AS Loan_Month,
    COUNT(*) AS Total_Loans,
    SUM(DefaultStatus) AS Defaults,
    ROUND(SUM(DefaultStatus) * 100.0 / COUNT(*), 2)    AS Default_Rate_Pct
FROM loan_default
GROUP BY Loan_Month
ORDER BY Loan_Month;


-- Q15 [INTERMEDIATE] What is the default rate by 
--     employment type and marital status combined?


SELECT
    EmploymentType,
    MaritalStatus,
    COUNT(*)                                            AS Total,
    SUM(DefaultStatus)                                  AS Defaults,
    ROUND(SUM(DefaultStatus) * 100.0 / COUNT(*), 2)    AS Default_Rate_Pct
FROM loan_default
GROUP BY EmploymentType, MaritalStatus
ORDER BY Default_Rate_Pct DESC;

-- Q16 [ADVANCED] Using a Subquery — Find borrowers whose 
--     loan amount is above the overall average loan amount 
--     and who defaulted.


SELECT
    LoanID, Age, Income, LoanAmount, CreditScore, EmploymentType
FROM loan_default
WHERE LoanAmount > (SELECT AVG(LoanAmount) FROM loan_default)
  AND DefaultStatus = 1
ORDER BY LoanAmount DESC
LIMIT 20;


-- Q17 [ADVANCED] Using CTE — Find employment types where 
--     the average credit score of defaulters is below 500.


WITH Defaulter_Stats AS (
    SELECT
        EmploymentType,
        ROUND(AVG(CreditScore), 2)  AS Avg_CreditScore,
        COUNT(*)                    AS Total_Defaulters
    FROM loan_default
    WHERE DefaultStatus = 1
    GROUP BY EmploymentType
)
SELECT *
FROM Defaulter_Stats
WHERE Avg_CreditScore < 500
ORDER BY Avg_CreditScore ASC;


-- Q18 [ADVANCED] Using Window Function — Rank borrowers 
--     by loan amount within each employment type.


SELECT
    LoanID,
    EmploymentType,
    LoanAmount,
    CreditScore,
    DefaultStatus,
    RANK() OVER (
        PARTITION BY EmploymentType
        ORDER BY LoanAmount DESC
    ) AS Rank_In_Group
FROM loan_default;


-- Q19 [ADVANCED] Using Window Function — Calculate the 
--     running total of loans issued over time.


SELECT
    DATE_FORMAT(LoanDate, '%Y-%m')              AS Loan_Month,
    COUNT(*)                                    AS Monthly_Loans,
    SUM(COUNT(*)) OVER (
        ORDER BY DATE_FORMAT(LoanDate, '%Y-%m')
    )                                           AS Running_Total_Loans
FROM loan_default
GROUP BY Loan_Month
ORDER BY Loan_Month;


-- Q20 [ADVANCED] Using CTE + Window Function — For each 
--     loan purpose, find the top 3 borrowers with the 
--     highest loan amount who defaulted.

WITH Ranked_Defaulters AS (
    SELECT
        LoanID,
        LoanPurpose,
        LoanAmount,
        Income,
        CreditScore,
        EmploymentType,
        DENSE_RANK() OVER (
            PARTITION BY LoanPurpose
            ORDER BY LoanAmount DESC
        ) AS Rank_In_Purpose
    FROM loan_default
    WHERE DefaultStatus = 1
)
SELECT *
FROM Ranked_Defaulters
WHERE Rank_In_Purpose <= 3
ORDER BY LoanPurpose, Rank_In_Purpose;

