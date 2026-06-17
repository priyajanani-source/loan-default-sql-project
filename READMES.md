# Loan Default Analysis SQL Project

## Project Overview

**Project Title**: Loan Default Analysis  
**Level**: Beginner to Advanced  
**Database**: `loan_project`  
**Tool**: MySQL Workbench  

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze loan default data. The project involves setting up a loan database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. This project is ideal for those who are building a solid foundation in SQL and want to work on a real-world financial dataset.

## Objectives

1. **Set up a loan database**: Create and populate a loan database with the provided data.
2. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
3. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the loan data.
4. **Advanced SQL**: Apply CTEs, Window Functions, and Subqueries to solve complex problems.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `loan_project`.
- **Table Creation**: A table named `loan_default` is created to store the loan data. The table structure includes columns for Loan ID, borrower demographics, financial details, loan characteristics, and default status.

```sql
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
    LoanDate        VARCHAR(20)
);
```

### 2. Data Exploration

- **Record Count**: Determine the total number of records in the dataset.
- **Default Count**: Find out how many borrowers defaulted vs did not default.
- **Category Count**: Identify all unique loan purposes in the dataset.

```sql
SELECT COUNT(*) AS Total_Loans FROM loan_default;

SELECT DISTINCT LoanPurpose FROM loan_default ORDER BY LoanPurpose;
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

**Q1. How many loan records are in the dataset?**
```sql
SELECT COUNT(*) AS Total_Loans
FROM loan_default;
```

**Q2. Show the first 10 records from the table.**
```sql
SELECT *
FROM loan_default
LIMIT 10;
```

**Q3. How many borrowers defaulted vs did not default?**
```sql
SELECT
    CASE WHEN DefaultStatus = 1 THEN 'Defaulted'
         ELSE 'Not Defaulted' END AS Status,
    COUNT(*) AS Total_Borrowers,
    ROUND(COUNT(*) * 100.0
          / (SELECT COUNT(*) FROM loan_default), 2) AS Percentage
FROM loan_default
GROUP BY DefaultStatus;
```

**Q4. What are the distinct loan purposes in the dataset?**
```sql
SELECT DISTINCT LoanPurpose
FROM loan_default
ORDER BY LoanPurpose;
```

**Q5. What is the minimum, maximum, and average loan amount across all borrowers?**
```sql
SELECT
    MIN(LoanAmount) AS Min_LoanAmount,
    MAX(LoanAmount) AS Max_LoanAmount,
    ROUND(AVG(LoanAmount), 2) AS Avg_LoanAmount
FROM loan_default;
```

**Q6. Find all borrowers who are unemployed and have defaulted.**
```sql
SELECT
    LoanID, Age, Income, LoanAmount, CreditScore, DTIRatio
FROM loan_default
WHERE EmploymentType = 'Unemployed'
  AND DefaultStatus = 1
ORDER BY LoanAmount DESC;
```

**Q7. What is the default rate (%) by education level?**
```sql
SELECT
    Education,
    COUNT(*) AS Total_Loans,
    SUM(DefaultStatus) AS Total_Defaults,
    ROUND(SUM(DefaultStatus) * 100.0 / COUNT(*), 2) AS Default_Rate_Pct
FROM loan_default
GROUP BY Education
ORDER BY Default_Rate_Pct DESC;
```

**Q8. Which loan purpose has the highest default rate?**
```sql
SELECT
    LoanPurpose,
    COUNT(*) AS Total_Loans,
    SUM(DefaultStatus) AS Defaults,
    ROUND(SUM(DefaultStatus) * 100.0 / COUNT(*), 2) AS Default_Rate_Pct
FROM loan_default
GROUP BY LoanPurpose
ORDER BY Default_Rate_Pct DESC;
```

**Q9. Compare average income, credit score, and loan amount between defaulted and non-defaulted borrowers.**
```sql
SELECT
    CASE WHEN DefaultStatus = 1 THEN 'Defaulted'
         ELSE 'Not Defaulted' END AS Status,
    ROUND(AVG(Income), 2) AS Avg_Income,
    ROUND(AVG(LoanAmount), 2) AS Avg_LoanAmount,
    ROUND(AVG(CreditScore), 2) AS Avg_CreditScore,
    ROUND(AVG(InterestRate), 2) AS Avg_InterestRate,
    ROUND(AVG(DTIRatio), 2) AS Avg_DTI_Ratio
FROM loan_default
GROUP BY DefaultStatus;
```

**Q10. Group borrowers into age brackets and find the default rate for each group.**
```sql
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
```

**Q11. Does having a co-signer reduce the default rate?**
```sql
SELECT
    HasCoSigner,
    COUNT(*) AS Total_Loans,
    SUM(DefaultStatus) AS Defaults,
    ROUND(SUM(DefaultStatus) * 100.0 / COUNT(*), 2) AS Default_Rate_Pct
FROM loan_default
GROUP BY HasCoSigner
ORDER BY Default_Rate_Pct DESC;
```

**Q12. What is the average interest rate for each loan term?**
```sql
SELECT
    LoanTerm,
    COUNT(*) AS Total_Loans,
    ROUND(AVG(InterestRate), 2) AS Avg_Interest_Rate,
    ROUND(AVG(LoanAmount), 2) AS Avg_Loan_Amount
FROM loan_default
GROUP BY LoanTerm
ORDER BY LoanTerm;
```

**Q13. Find high-risk borrowers: Credit Score < 400, DTI Ratio > 0.6, and Defaulted.**
```sql
SELECT
    LoanID, Age, Income, LoanAmount,
    CreditScore, DTIRatio, EmploymentType, LoanPurpose
FROM loan_default
WHERE CreditScore < 400
  AND DTIRatio > 0.6
  AND DefaultStatus = 1
ORDER BY CreditScore ASC, DTIRatio DESC;
```

**Q14. Monthly trend: how many loans were issued and how many defaulted each month?**
```sql
SELECT
    DATE_FORMAT(LoanDate, '%Y-%m') AS Loan_Month,
    COUNT(*) AS Total_Loans,
    SUM(DefaultStatus) AS Defaults,
    ROUND(SUM(DefaultStatus) * 100.0 / COUNT(*), 2) AS Default_Rate_Pct
FROM loan_default
GROUP BY Loan_Month
ORDER BY Loan_Month;
```

**Q15. What is the default rate by employment type and marital status combined?**
```sql
SELECT
    EmploymentType,
    MaritalStatus,
    COUNT(*) AS Total,
    SUM(DefaultStatus) AS Defaults,
    ROUND(SUM(DefaultStatus) * 100.0 / COUNT(*), 2) AS Default_Rate_Pct
FROM loan_default
GROUP BY EmploymentType, MaritalStatus
ORDER BY Default_Rate_Pct DESC;
```

**Q16. [Advanced] Using a Subquery — Find borrowers whose loan amount is above the overall average loan amount and who defaulted.**
```sql
SELECT
    LoanID, Age, Income, LoanAmount, CreditScore, EmploymentType
FROM loan_default
WHERE LoanAmount > (SELECT AVG(LoanAmount) FROM loan_default)
  AND DefaultStatus = 1
ORDER BY LoanAmount DESC
LIMIT 20;
```

**Q17. [Advanced] Using CTE — Find employment types where the average credit score of defaulters is below 500.**
```sql
WITH Defaulter_Stats AS (
    SELECT
        EmploymentType,
        ROUND(AVG(CreditScore), 2) AS Avg_CreditScore,
        COUNT(*) AS Total_Defaulters
    FROM loan_default
    WHERE DefaultStatus = 1
    GROUP BY EmploymentType
)
SELECT *
FROM Defaulter_Stats
WHERE Avg_CreditScore < 500
ORDER BY Avg_CreditScore ASC;
```

**Q18. [Advanced] Using Window Function — Rank borrowers by loan amount within each employment type.**
```sql
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
```

**Q19. [Advanced] Using Window Function — Calculate the running total of loans issued over time.**
```sql
SELECT
    DATE_FORMAT(LoanDate, '%Y-%m') AS Loan_Month,
    COUNT(*) AS Monthly_Loans,
    SUM(COUNT(*)) OVER (
        ORDER BY DATE_FORMAT(LoanDate, '%Y-%m')
    ) AS Running_Total_Loans
FROM loan_default
GROUP BY Loan_Month
ORDER BY Loan_Month;
```

**Q20. [Advanced] Using CTE + Window Function — For each loan purpose, find the top 3 borrowers with the highest loan amount who defaulted.**
```sql
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
```

## Findings

- **Overall Default Rate**: 11.61% of borrowers (29,653 out of 255,347) defaulted on their loans.
- **Employment Impact**: Unemployed borrowers have the highest default rate at 13.55%, while Full-time employees have the lowest at 9.46%.
- **Education Impact**: High School educated borrowers default more (12.88%) compared to PhD holders (10.59%).
- **Loan Purpose**: Business loans carry the highest default risk (12.33%), while Home loans are the safest (10.23%).
- **High-Risk Profile**: Borrowers with Credit Score below 400 and DTI Ratio above 0.6 represent the most vulnerable segment.
- **Co-Signer Effect**: Loans with a co-signer show a lower default rate compared to those without.

## Reports

- **Default Summary**: Total defaults broken down by employment type, education level, and loan purpose.
- **Trend Analysis**: Monthly loan issuance and default trends over time using running totals.
- **Risk Analysis**: High-risk borrower identification using credit score and DTI ratio filters.
- **Borrower Insights**: Age group analysis and financial comparison between defaulted and non-defaulted borrowers.

## Conclusion

This project serves as a comprehensive SQL analysis of loan default behaviour, covering database setup, exploratory data analysis, and business-driven SQL queries progressing from Basic to Advanced. The findings from this project can help financial institutions make better lending decisions by identifying high-risk borrower profiles and understanding default patterns across demographics and loan types.



## Author - Priya Janani

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

- **LinkedIn**: [Connect with me professionally](www.linkedin.com/in/priya-janani-krishnamoorthy-saravanapriya-40795535a)


Thank you for your support, and I look forward to connecting with you!
