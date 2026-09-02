/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 50B_Data_Quality_Fact_Integrity.sql
Purpose      : Validate Foreign Key Integrity for Remaining Fact Tables
Author       : Tushar Mehta
Created Date : 10-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO


/*==============================================================
  1. FACT QA → DIMENSIONS
==============================================================*/

SELECT
    'QA → Date' AS Validation,
    COUNT(*) AS Orphan_Records
FROM dbo.Fact_QA F
LEFT JOIN dbo.Dim_Date D
    ON F.Date_Key = D.Date_Key
WHERE D.Date_Key IS NULL

UNION ALL

SELECT
    'QA → Policy',
    COUNT(*)
FROM dbo.Fact_QA F
LEFT JOIN dbo.Dim_Policy D
    ON F.Policy_Key = D.Policy_Key
WHERE D.Policy_Key IS NULL

UNION ALL

SELECT
    'QA → Error Code',
    COUNT(*)
FROM dbo.Fact_QA F
LEFT JOIN dbo.Dim_Error_Code D
    ON F.Error_Code_Key = D.Error_Code_Key
WHERE D.Error_Code_Key IS NULL;


/*==============================================================
  2. FACT APPEALS → DIMENSIONS
==============================================================*/

SELECT
    'Appeals → Date' AS Validation,
    COUNT(*) AS Orphan_Records
FROM dbo.Fact_Appeals F
LEFT JOIN dbo.Dim_Date D
    ON F.Date_Key = D.Date_Key
WHERE D.Date_Key IS NULL

UNION ALL

SELECT
    'Appeals → Policy',
    COUNT(*)
FROM dbo.Fact_Appeals F
LEFT JOIN dbo.Dim_Policy D
    ON F.Policy_Key = D.Policy_Key
WHERE D.Policy_Key IS NULL

UNION ALL

SELECT
    'Appeals → Decision',
    COUNT(*)
FROM dbo.Fact_Appeals F
LEFT JOIN dbo.Dim_Appeal_Decision D
    ON F.Appeal_Decision_Key = D.Appeal_Decision_Key
WHERE D.Appeal_Decision_Key IS NULL;


/*==============================================================
  3. FACT COACHING → DIMENSIONS
==============================================================*/

SELECT
    'Coaching → Date' AS Validation,
    COUNT(*) AS Orphan_Records
FROM dbo.Fact_Coaching F
LEFT JOIN dbo.Dim_Date D
    ON F.Date_Key = D.Date_Key
WHERE D.Date_Key IS NULL

UNION ALL

SELECT
    'Coaching → Employee',
    COUNT(*)
FROM dbo.Fact_Coaching F
LEFT JOIN dbo.Dim_Employee D
    ON F.Employee_Key = D.Employee_Key
WHERE D.Employee_Key IS NULL

UNION ALL

SELECT
    'Coaching → Client',
    COUNT(*)
FROM dbo.Fact_Coaching F
LEFT JOIN dbo.Dim_Client D
    ON F.Client_Key = D.Client_Key
WHERE D.Client_Key IS NULL

UNION ALL

SELECT
    'Coaching → Process',
    COUNT(*)
FROM dbo.Fact_Coaching F
LEFT JOIN dbo.Dim_Process D
    ON F.Process_Key = D.Process_Key
WHERE D.Process_Key IS NULL

UNION ALL

SELECT
    'Coaching → Team',
    COUNT(*)
FROM dbo.Fact_Coaching F
LEFT JOIN dbo.Dim_Team D
    ON F.Team_Key = D.Team_Key
WHERE D.Team_Key IS NULL

UNION ALL

SELECT
    'Coaching → Site',
    COUNT(*)
FROM dbo.Fact_Coaching F
LEFT JOIN dbo.Dim_Site D
    ON F.Site_Key = D.Site_Key
WHERE D.Site_Key IS NULL;


/*==============================================================
  4. FACT WORKFORCE → DIMENSIONS
==============================================================*/

SELECT
    'Workforce → Date' AS Validation,
    COUNT(*) AS Orphan_Records
FROM dbo.Fact_Workforce F
LEFT JOIN dbo.Dim_Date D
    ON F.Date_Key = D.Date_Key
WHERE D.Date_Key IS NULL

UNION ALL

SELECT
    'Workforce → Shift',
    COUNT(*)
FROM dbo.Fact_Workforce F
LEFT JOIN dbo.Dim_Shift D
    ON F.Shift_Key = D.Shift_Key
WHERE D.Shift_Key IS NULL

UNION ALL

SELECT
    'Workforce → Shrinkage',
    COUNT(*)
FROM dbo.Fact_Workforce F
LEFT JOIN dbo.Dim_Shrinkage D
    ON F.Shrinkage_Key = D.Shrinkage_Key
WHERE D.Shrinkage_Key IS NULL;


/*==============================================================
  5. FACT FINANCE → DIMENSIONS
==============================================================*/

SELECT
    'Finance → Date' AS Validation,
    COUNT(*) AS Orphan_Records
FROM dbo.Fact_Finance F
LEFT JOIN dbo.Dim_Date D
    ON F.Date_Key = D.Date_Key
WHERE D.Date_Key IS NULL

UNION ALL

SELECT
    'Finance → Billing Model',
    COUNT(*)
FROM dbo.Fact_Finance F
LEFT JOIN dbo.Dim_Billing_Model D
    ON F.Billing_Model_Key = D.Billing_Model_Key
WHERE D.Billing_Model_Key IS NULL

UNION ALL

SELECT
    'Finance → Cost Center',
    COUNT(*)
FROM dbo.Fact_Finance F
LEFT JOIN dbo.Dim_Cost_Center D
    ON F.Cost_Center_Key = D.Cost_Center_Key
WHERE D.Cost_Center_Key IS NULL;

GO

PRINT '50B Fact integrity validation completed.';

