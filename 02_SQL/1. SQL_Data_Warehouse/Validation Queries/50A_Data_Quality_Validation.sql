/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 50A_Data_Quality_Validation.sql
Purpose      : Core Data Quality and Integrity Validation
Author       : Tushar Mehta
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO


/*==============================================================
  1. FACT TABLE RECORD COUNTS
==============================================================*/

SELECT
    'Fact_Operations' AS Table_Name,
    COUNT(*) AS Record_Count
FROM dbo.Fact_Operations

UNION ALL

SELECT
    'Fact_QA',
    COUNT(*)
FROM dbo.Fact_QA

UNION ALL

SELECT
    'Fact_Appeals',
    COUNT(*)
FROM dbo.Fact_Appeals

UNION ALL

SELECT
    'Fact_Coaching',
    COUNT(*)
FROM dbo.Fact_Coaching

UNION ALL

SELECT
    'Fact_Workforce',
    COUNT(*)
FROM dbo.Fact_Workforce

UNION ALL

SELECT
    'Fact_Finance',
    COUNT(*)
FROM dbo.Fact_Finance

ORDER BY Table_Name;
GO

/*==============================================================
  2. DIMENSION TABLE RECORD COUNTS
==============================================================*/

SELECT
    'Dim_Appeal_Decision' AS Table_Name,
    COUNT(*) AS Record_Count
FROM dbo.Dim_Appeal_Decision

UNION ALL

SELECT
    'Dim_Billing_Model',
    COUNT(*)
FROM dbo.Dim_Billing_Model

UNION ALL

SELECT
    'Dim_Client',
    COUNT(*)
FROM dbo.Dim_Client

UNION ALL

SELECT
    'Dim_Cost_Center',
    COUNT(*)
FROM dbo.Dim_Cost_Center

UNION ALL

SELECT
    'Dim_Date',
    COUNT(*)
FROM dbo.Dim_Date

UNION ALL

SELECT
    'Dim_Employee',
    COUNT(*)
FROM dbo.Dim_Employee

UNION ALL

SELECT
    'Dim_Error_Code',
    COUNT(*)
FROM dbo.Dim_Error_Code

UNION ALL

SELECT
    'Dim_Policy',
    COUNT(*)
FROM dbo.Dim_Policy

UNION ALL

SELECT
    'Dim_Process',
    COUNT(*)
FROM dbo.Dim_Process

UNION ALL

SELECT
    'Dim_Shift',
    COUNT(*)
FROM dbo.Dim_Shift

UNION ALL

SELECT
    'Dim_Shrinkage',
    COUNT(*)
FROM dbo.Dim_Shrinkage

UNION ALL

SELECT
    'Dim_Site',
    COUNT(*)
FROM dbo.Dim_Site

UNION ALL

SELECT
    'Dim_Team',
    COUNT(*)
FROM dbo.Dim_Team

ORDER BY Table_Name;
GO


/*==============================================================
  3. NULL CHECK ON CRITICAL FOREIGN KEYS
==============================================================*/

SELECT
    'Fact_Operations' AS Table_Name,
    SUM(CASE WHEN Date_Key IS NULL THEN 1 ELSE 0 END) AS Null_Date_Key,
    SUM(CASE WHEN Employee_Key IS NULL THEN 1 ELSE 0 END) AS Null_Employee_Key,
    SUM(CASE WHEN Client_Key IS NULL THEN 1 ELSE 0 END) AS Null_Client_Key,
    SUM(CASE WHEN Process_Key IS NULL THEN 1 ELSE 0 END) AS Null_Process_Key,
    SUM(CASE WHEN Team_Key IS NULL THEN 1 ELSE 0 END) AS Null_Team_Key
FROM dbo.Fact_Operations

UNION ALL

SELECT
    'Fact_QA',
    SUM(CASE WHEN Date_Key IS NULL THEN 1 ELSE 0 END),
    0,
    0,
    0,
    0
FROM dbo.Fact_QA

UNION ALL

SELECT
    'Fact_Appeals',
    SUM(CASE WHEN Date_Key IS NULL THEN 1 ELSE 0 END),
    0,
    0,
    0,
    0
FROM dbo.Fact_Appeals

UNION ALL

SELECT
    'Fact_Coaching',
    SUM(CASE WHEN Date_Key IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN Employee_Key IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN Client_Key IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN Process_Key IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN Team_Key IS NULL THEN 1 ELSE 0 END)
FROM dbo.Fact_Coaching;
GO


/*==============================================================
  4. DUPLICATE PRIMARY KEY CHECK
==============================================================*/

SELECT
    'Fact_Operations' AS Table_Name,
    Fact_Operations_Key AS Key_Value,
    COUNT(*) AS Duplicate_Count
FROM dbo.Fact_Operations
GROUP BY Fact_Operations_Key
HAVING COUNT(*) > 1

UNION ALL

SELECT
    'Fact_QA',
    QA_Key,
    COUNT(*)
FROM dbo.Fact_QA
GROUP BY QA_Key
HAVING COUNT(*) > 1

UNION ALL

SELECT
    'Fact_Appeals',
    Appeal_Key,
    COUNT(*)
FROM dbo.Fact_Appeals
GROUP BY Appeal_Key
HAVING COUNT(*) > 1

UNION ALL

SELECT
    'Fact_Coaching',
    Coaching_Key,
    COUNT(*)
FROM dbo.Fact_Coaching
GROUP BY Coaching_Key
HAVING COUNT(*) > 1

UNION ALL

SELECT
    'Fact_Workforce',
    Workforce_Key,
    COUNT(*)
FROM dbo.Fact_Workforce
GROUP BY Workforce_Key
HAVING COUNT(*) > 1

UNION ALL

SELECT
    'Fact_Finance',
    Finance_Key,
    COUNT(*)
FROM dbo.Fact_Finance
GROUP BY Finance_Key
HAVING COUNT(*) > 1;
GO

/*==============================================================
  5. FACT OPERATIONS → DIMENSION INTEGRITY
==============================================================*/

SELECT
    'Operations → Date' AS Validation,
    COUNT(*) AS Orphan_Records
FROM dbo.Fact_Operations F
LEFT JOIN dbo.Dim_Date D
    ON F.Date_Key = D.Date_Key
WHERE D.Date_Key IS NULL

UNION ALL

SELECT
    'Operations → Employee',
    COUNT(*)
FROM dbo.Fact_Operations F
LEFT JOIN dbo.Dim_Employee D
    ON F.Employee_Key = D.Employee_Key
WHERE D.Employee_Key IS NULL

UNION ALL

SELECT
    'Operations → Client',
    COUNT(*)
FROM dbo.Fact_Operations F
LEFT JOIN dbo.Dim_Client D
    ON F.Client_Key = D.Client_Key
WHERE D.Client_Key IS NULL

UNION ALL

SELECT
    'Operations → Process',
    COUNT(*)
FROM dbo.Fact_Operations F
LEFT JOIN dbo.Dim_Process D
    ON F.Process_Key = D.Process_Key
WHERE D.Process_Key IS NULL

UNION ALL

SELECT
    'Operations → Team',
    COUNT(*)
FROM dbo.Fact_Operations F
LEFT JOIN dbo.Dim_Team D
    ON F.Team_Key = D.Team_Key
WHERE D.Team_Key IS NULL

UNION ALL

SELECT
    'Operations → Site',
    COUNT(*)
FROM dbo.Fact_Operations F
LEFT JOIN dbo.Dim_Site D
    ON F.Site_Key = D.Site_Key
WHERE D.Site_Key IS NULL

UNION ALL

SELECT
    'Operations → Shift',
    COUNT(*)
FROM dbo.Fact_Operations F
LEFT JOIN dbo.Dim_Shift D
    ON F.Shift_Key = D.Shift_Key
WHERE D.Shift_Key IS NULL

UNION ALL

SELECT
    'Operations → Policy',
    COUNT(*)
FROM dbo.Fact_Operations F
LEFT JOIN dbo.Dim_Policy D
    ON F.Policy_Key = D.Policy_Key
WHERE D.Policy_Key IS NULL

UNION ALL

SELECT
    'Operations → Error Code',
    COUNT(*)
FROM dbo.Fact_Operations F
LEFT JOIN dbo.Dim_Error_Code D
    ON F.Error_Code_Key = D.Error_Code_Key
WHERE D.Error_Code_Key IS NULL;
GO