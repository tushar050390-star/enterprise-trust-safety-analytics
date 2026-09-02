/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 50C_Data_Quality_Measure_Validation.sql
Purpose      : Validate Business Measures and Data Ranges
Author       : Tushar Mehta
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO


/*==============================================================
  1. OPERATIONS - INVALID / NEGATIVE MEASURES
==============================================================*/

SELECT
    'Operations - Negative Cases' AS Validation,
    COUNT(*) AS Invalid_Records
FROM dbo.Fact_Operations
WHERE Cases_Handled < 0
   OR Cases_Reviewed < 0
   OR Cases_Approved < 0
   OR Cases_Rejected < 0

UNION ALL

SELECT
    'Operations - Invalid QA Score',
    COUNT(*)
FROM dbo.Fact_Operations
WHERE QA_Score < 0
   OR QA_Score > 100

UNION ALL

SELECT
    'Operations - Invalid AHT',
    COUNT(*)
FROM dbo.Fact_Operations
WHERE AHT_Minutes <= 0

UNION ALL

SELECT
    'Operations - Invalid SLA',
    COUNT(*)
FROM dbo.Fact_Operations
WHERE SLA_Compliance_Pct < 0
   OR SLA_Compliance_Pct > 100

UNION ALL

SELECT
    'Operations - Invalid Productive Hours',
    COUNT(*)
FROM dbo.Fact_Operations
WHERE Productive_Hours < 0

UNION ALL

SELECT
    'Operations - Invalid Revenue',
    COUNT(*)
FROM dbo.Fact_Operations
WHERE Revenue_USD < 0

UNION ALL

SELECT
    'Operations - Invalid Operating Cost',
    COUNT(*)
FROM dbo.Fact_Operations
WHERE Operating_Cost_USD < 0;
GO


/*==============================================================
  2. OPERATIONS - APPROVAL / REJECTION CONSISTENCY
==============================================================*/

SELECT
    'Operations - Approval/Rejection Mismatch' AS Validation,
    COUNT(*) AS Invalid_Records
FROM dbo.Fact_Operations
WHERE Cases_Approved + Cases_Rejected <> Cases_Handled;
GO


/*==============================================================
  3. QA SCORE VALIDATION
==============================================================*/

SELECT
    'QA - Invalid QA Score' AS Validation,
    COUNT(*) AS Invalid_Records
FROM dbo.Fact_QA
WHERE QA_Score < 0
   OR QA_Score > 100;
GO


/*==============================================================
  4. APPEALS - RESOLUTION TIME
==============================================================*/

SELECT
    'Appeals - Invalid Resolution Time' AS Validation,
    COUNT(*) AS Invalid_Records
FROM dbo.Fact_Appeals
WHERE Resolution_Time < 0;
GO


/*==============================================================
  5. COACHING - DURATION
==============================================================*/

SELECT
    'Coaching - Invalid Duration' AS Validation,
    COUNT(*) AS Invalid_Records
FROM dbo.Fact_Coaching
WHERE Duration_Minutes <= 0;
GO


/*==============================================================
  6. WORKFORCE - HOURS
==============================================================*/

SELECT
    'Workforce - Invalid Hours' AS Validation,
    COUNT(*) AS Invalid_Records
FROM dbo.Fact_Workforce
WHERE Hours < 0;
GO


/*==============================================================
  7. FINANCE - REVENUE
==============================================================*/

SELECT
    'Finance - Negative Revenue' AS Validation,
    COUNT(*) AS Invalid_Records
FROM dbo.Fact_Finance
WHERE Revenue_USD < 0;
GO


/*==============================================================
  8. OPERATIONS - SUMMARY RANGE CHECK
==============================================================*/

SELECT
    MIN(QA_Score) AS Minimum_QA_Score,
    MAX(QA_Score) AS Maximum_QA_Score,
    MIN(AHT_Minutes) AS Minimum_AHT_Minutes,
    MAX(AHT_Minutes) AS Maximum_AHT_Minutes,
    MIN(SLA_Compliance_Pct) AS Minimum_SLA_Compliance_Pct,
    MAX(SLA_Compliance_Pct) AS Maximum_SLA_Compliance_Pct,
    MIN(Productive_Hours) AS Minimum_Productive_Hours,
    MAX(Productive_Hours) AS Maximum_Productive_Hours,
    MIN(Revenue_USD) AS Minimum_Revenue_USD,
    MAX(Revenue_USD) AS Maximum_Revenue_USD,
    MIN(Operating_Cost_USD) AS Minimum_Operating_Cost_USD,
    MAX(Operating_Cost_USD) AS Maximum_Operating_Cost_USD
FROM dbo.Fact_Operations;
GO


/*==============================================================
  9. QA - SUMMARY RANGE CHECK
==============================================================*/

SELECT
    COUNT(*) AS Total_QA_Records,
    MIN(QA_Score) AS Minimum_QA_Score,
    MAX(QA_Score) AS Maximum_QA_Score,
    AVG(QA_Score) AS Average_QA_Score
FROM dbo.Fact_QA;
GO


/*==============================================================
  10. COACHING - SUMMARY CHECK
==============================================================*/

SELECT
    COUNT(*) AS Total_Coaching_Records,
    MIN(Duration_Minutes) AS Minimum_Duration,
    MAX(Duration_Minutes) AS Maximum_Duration,
    AVG(Duration_Minutes) AS Average_Duration
FROM dbo.Fact_Coaching;
GO


/*==============================================================
  11. WORKFORCE - SUMMARY CHECK
==============================================================*/

SELECT
    COUNT(*) AS Total_Workforce_Records,
    MIN(Hours) AS Minimum_Hours,
    MAX(Hours) AS Maximum_Hours,
    AVG(Hours) AS Average_Hours
FROM dbo.Fact_Workforce;
GO


/*==============================================================
  12. APPEALS - SUMMARY CHECK
==============================================================*/

SELECT
    COUNT(*) AS Total_Appeals,
    MIN(Resolution_Time) AS Minimum_Resolution_Time,
    MAX(Resolution_Time) AS Maximum_Resolution_Time,
    AVG(Resolution_Time) AS Average_Resolution_Time
FROM dbo.Fact_Appeals;
GO


/*==============================================================
  13. FINANCE - SUMMARY CHECK
==============================================================*/

SELECT
    COUNT(*) AS Total_Finance_Records,
    MIN(Revenue_USD) AS Minimum_Revenue_USD,
    MAX(Revenue_USD) AS Maximum_Revenue_USD,
    AVG(Revenue_USD) AS Average_Revenue_USD,
    SUM(Revenue_USD) AS Total_Revenue_USD
FROM dbo.Fact_Finance;
GO


PRINT '50C Business measure validation completed.';
GO