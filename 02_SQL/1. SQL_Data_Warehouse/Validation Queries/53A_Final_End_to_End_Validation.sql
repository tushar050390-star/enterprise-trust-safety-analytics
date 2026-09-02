/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 53A_Final_End_to_End_Validation.sql
Purpose      : Final End-to-End Warehouse and Reporting Validation
Author       : Tushar Mehta
Created Date : 10-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO


/*==============================================================
  1. CORE TABLE EXISTENCE CHECK
==============================================================*/

SELECT
    Table_Name,
    CASE
        WHEN OBJECT_ID('dbo.' + Table_Name, 'U') IS NOT NULL
        THEN 'PASS'
        ELSE 'FAIL'
    END AS Validation_Status
FROM
(
    SELECT 'Dim_Appeal_Decision' AS Table_Name
    UNION ALL SELECT 'Dim_Billing_Model'
    UNION ALL SELECT 'Dim_Client'
    UNION ALL SELECT 'Dim_Cost_Center'
    UNION ALL SELECT 'Dim_Date'
    UNION ALL SELECT 'Dim_Employee'
    UNION ALL SELECT 'Dim_Error_Code'
    UNION ALL SELECT 'Dim_Policy'
    UNION ALL SELECT 'Dim_Process'
    UNION ALL SELECT 'Dim_Shift'
    UNION ALL SELECT 'Dim_Shrinkage'
    UNION ALL SELECT 'Dim_Site'
    UNION ALL SELECT 'Dim_Team'
    UNION ALL SELECT 'Fact_Appeals'
    UNION ALL SELECT 'Fact_Coaching'
    UNION ALL SELECT 'Fact_Finance'
    UNION ALL SELECT 'Fact_Operations'
    UNION ALL SELECT 'Fact_QA'
    UNION ALL SELECT 'Fact_Workforce'
) T
ORDER BY Table_Name;
GO


/*==============================================================
  2. DIMENSION RECORD COUNT VALIDATION
==============================================================*/

SELECT
    Table_Name,
    Record_Count
FROM
(
    SELECT 'Dim_Appeal_Decision' AS Table_Name,
           COUNT(*) AS Record_Count
    FROM dbo.Dim_Appeal_Decision

    UNION ALL
    SELECT 'Dim_Billing_Model',
           COUNT(*)
    FROM dbo.Dim_Billing_Model

    UNION ALL
    SELECT 'Dim_Client',
           COUNT(*)
    FROM dbo.Dim_Client

    UNION ALL
    SELECT 'Dim_Cost_Center',
           COUNT(*)
    FROM dbo.Dim_Cost_Center

    UNION ALL
    SELECT 'Dim_Date',
           COUNT(*)
    FROM dbo.Dim_Date

    UNION ALL
    SELECT 'Dim_Employee',
           COUNT(*)
    FROM dbo.Dim_Employee

    UNION ALL
    SELECT 'Dim_Error_Code',
           COUNT(*)
    FROM dbo.Dim_Error_Code

    UNION ALL
    SELECT 'Dim_Policy',
           COUNT(*)
    FROM dbo.Dim_Policy

    UNION ALL
    SELECT 'Dim_Process',
           COUNT(*)
    FROM dbo.Dim_Process

    UNION ALL
    SELECT 'Dim_Shift',
           COUNT(*)
    FROM dbo.Dim_Shift

    UNION ALL
    SELECT 'Dim_Shrinkage',
           COUNT(*)
    FROM dbo.Dim_Shrinkage

    UNION ALL
    SELECT 'Dim_Site',
           COUNT(*)
    FROM dbo.Dim_Site

    UNION ALL
    SELECT 'Dim_Team',
           COUNT(*)
    FROM dbo.Dim_Team
) D
ORDER BY Table_Name;
GO


/*==============================================================
  3. FACT RECORD COUNT VALIDATION
==============================================================*/

SELECT
    Table_Name,
    Record_Count
FROM
(
    SELECT 'Fact_Appeals' AS Table_Name,
           COUNT(*) AS Record_Count
    FROM dbo.Fact_Appeals

    UNION ALL
    SELECT 'Fact_Coaching',
           COUNT(*)
    FROM dbo.Fact_Coaching

    UNION ALL
    SELECT 'Fact_Finance',
           COUNT(*)
    FROM dbo.Fact_Finance

    UNION ALL
    SELECT 'Fact_Operations',
           COUNT(*)
    FROM dbo.Fact_Operations

    UNION ALL
    SELECT 'Fact_QA',
           COUNT(*)
    FROM dbo.Fact_QA

    UNION ALL
    SELECT 'Fact_Workforce',
           COUNT(*)
    FROM dbo.Fact_Workforce
) F
ORDER BY Table_Name;
GO


/*==============================================================
  4. REPORTING VIEW EXISTENCE CHECK
==============================================================*/

SELECT
    View_Name,
    CASE
        WHEN OBJECT_ID('dbo.' + View_Name, 'V') IS NOT NULL
        THEN 'PASS'
        ELSE 'FAIL'
    END AS Validation_Status
FROM
(
    SELECT 'vw_Operations_Dashboard' AS View_Name
    UNION ALL SELECT 'vw_QA_Dashboard'
    UNION ALL SELECT 'vw_Appeals_Dashboard'
    UNION ALL SELECT 'vw_Coaching_Dashboard'
    UNION ALL SELECT 'vw_Workforce_Dashboard'
    UNION ALL SELECT 'vw_Finance_Dashboard'
) V
ORDER BY View_Name;
GO


/*==============================================================
  5. REPORTING VIEW RECORD COUNT VALIDATION
==============================================================*/

SELECT
    View_Name,
    Record_Count
FROM
(
    SELECT 'vw_Operations_Dashboard' AS View_Name,
           COUNT(*) AS Record_Count
    FROM dbo.vw_Operations_Dashboard

    UNION ALL
    SELECT 'vw_QA_Dashboard',
           COUNT(*)
    FROM dbo.vw_QA_Dashboard

    UNION ALL
    SELECT 'vw_Appeals_Dashboard',
           COUNT(*)
    FROM dbo.vw_Appeals_Dashboard

    UNION ALL
    SELECT 'vw_Coaching_Dashboard',
           COUNT(*)
    FROM dbo.vw_Coaching_Dashboard

    UNION ALL
    SELECT 'vw_Workforce_Dashboard',
           COUNT(*)
    FROM dbo.vw_Workforce_Dashboard

    UNION ALL
    SELECT 'vw_Finance_Dashboard',
           COUNT(*)
    FROM dbo.vw_Finance_Dashboard
) V
ORDER BY View_Name;
GO


/*==============================================================
  6. DATA DICTIONARY VALIDATION
==============================================================*/

SELECT
    COUNT(*) AS Total_Dictionary_Records,

    SUM(
        CASE
            WHEN Business_Definition IS NULL
            THEN 1
            ELSE 0
        END
    ) AS Missing_Business_Definitions,

    SUM(
        CASE
            WHEN Data_Source IS NULL
            THEN 1
            ELSE 0
        END
    ) AS Missing_Data_Sources,

    SUM(
        CASE
            WHEN Transformation_Rule IS NULL
            THEN 1
            ELSE 0
        END
    ) AS Missing_Transformation_Rules

FROM dbo.Data_Dictionary;
GO


/*==============================================================
  7. FINAL REPORTING RECONCILIATION
==============================================================*/

SELECT
    'Operations' AS Domain,

    (SELECT COUNT(*)
     FROM dbo.Fact_Operations) AS Fact_Rows,

    (SELECT COUNT(*)
     FROM dbo.vw_Operations_Dashboard) AS View_Rows,

    CASE
        WHEN
            (SELECT COUNT(*) FROM dbo.Fact_Operations)
            =
            (SELECT COUNT(*) FROM dbo.vw_Operations_Dashboard)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS Validation_Status

UNION ALL

SELECT
    'QA',

    (SELECT COUNT(*)
     FROM dbo.Fact_QA),

    (SELECT COUNT(*)
     FROM dbo.vw_QA_Dashboard),

    CASE
        WHEN
            (SELECT COUNT(*) FROM dbo.Fact_QA)
            =
            (SELECT COUNT(*) FROM dbo.vw_QA_Dashboard)
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

SELECT
    'Appeals',

    (SELECT COUNT(*)
     FROM dbo.Fact_Appeals),

    (SELECT COUNT(*)
     FROM dbo.vw_Appeals_Dashboard),

    CASE
        WHEN
            (SELECT COUNT(*) FROM dbo.Fact_Appeals)
            =
            (SELECT COUNT(*) FROM dbo.vw_Appeals_Dashboard)
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

SELECT
    'Coaching',

    (SELECT COUNT(*)
     FROM dbo.Fact_Coaching),

    (SELECT COUNT(*)
     FROM dbo.vw_Coaching_Dashboard),

    CASE
        WHEN
            (SELECT COUNT(*) FROM dbo.Fact_Coaching)
            =
            (SELECT COUNT(*) FROM dbo.vw_Coaching_Dashboard)
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

SELECT
    'Workforce',

    (SELECT COUNT(*)
     FROM dbo.Fact_Workforce),

    (SELECT COUNT(*)
     FROM dbo.vw_Workforce_Dashboard),

    CASE
        WHEN
            (SELECT COUNT(*) FROM dbo.Fact_Workforce)
            =
            (SELECT COUNT(*) FROM dbo.vw_Workforce_Dashboard)
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

SELECT
    'Finance',

    (SELECT COUNT(*)
     FROM dbo.Fact_Finance),

    (SELECT COUNT(*)
     FROM dbo.vw_Finance_Dashboard),

    CASE
        WHEN
            (SELECT COUNT(*) FROM dbo.Fact_Finance)
            =
            (SELECT COUNT(*) FROM dbo.vw_Finance_Dashboard)
        THEN 'PASS'
        ELSE 'FAIL'
    END;
GO


/*==============================================================
  8. FINAL EXECUTIVE KPI AVAILABILITY
==============================================================*/

SELECT
    COUNT(*) AS Total_Executive_KPIs,
    SUM(
        CASE
            WHEN KPI_Value IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS Valid_KPIs,
    SUM(
        CASE
            WHEN KPI_Value IS NULL
            THEN 1
            ELSE 0
        END
    ) AS Missing_KPIs
FROM
(
    SELECT SUM(Cases_Handled) AS KPI_Value
    FROM dbo.vw_Operations_Dashboard

    UNION ALL

    SELECT AVG(QA_Score)
    FROM dbo.vw_Operations_Dashboard

    UNION ALL

    SELECT AVG(AHT_Minutes)
    FROM dbo.vw_Operations_Dashboard

    UNION ALL

    SELECT AVG(SLA_Compliance_Pct)
    FROM dbo.vw_Operations_Dashboard

    UNION ALL

    SELECT SUM(Revenue_USD)
    FROM dbo.vw_Operations_Dashboard

    UNION ALL

    SELECT SUM(Operating_Cost_USD)
    FROM dbo.vw_Operations_Dashboard

    UNION ALL

    SELECT AVG(QA_Score)
    FROM dbo.vw_QA_Dashboard

    UNION ALL

    SELECT AVG(Resolution_Time)
    FROM dbo.vw_Appeals_Dashboard

    UNION ALL

    SELECT SUM(Duration_Minutes)
    FROM dbo.vw_Coaching_Dashboard

    UNION ALL

    SELECT SUM(Hours)
    FROM dbo.vw_Workforce_Dashboard

    UNION ALL

    SELECT SUM(Revenue_USD)
    FROM dbo.vw_Finance_Dashboard
) KPI_Check;
GO


/*==============================================================
  9. FINAL END-TO-END STATUS
==============================================================*/

SELECT
    'Enterprise Trust & Safety Analytics Warehouse'
        AS Project,

    'End-to-End Validation'
        AS Validation_Type,

    CASE
        WHEN
            /* All six fact/view counts match */
            (SELECT COUNT(*) FROM dbo.Fact_Operations)
                =
            (SELECT COUNT(*) FROM dbo.vw_Operations_Dashboard)

            AND
            (SELECT COUNT(*) FROM dbo.Fact_QA)
                =
            (SELECT COUNT(*) FROM dbo.vw_QA_Dashboard)

            AND
            (SELECT COUNT(*) FROM dbo.Fact_Appeals)
                =
            (SELECT COUNT(*) FROM dbo.vw_Appeals_Dashboard)

            AND
            (SELECT COUNT(*) FROM dbo.Fact_Coaching)
                =
            (SELECT COUNT(*) FROM dbo.vw_Coaching_Dashboard)

            AND
            (SELECT COUNT(*) FROM dbo.Fact_Workforce)
                =
            (SELECT COUNT(*) FROM dbo.vw_Workforce_Dashboard)

            AND
            (SELECT COUNT(*) FROM dbo.Fact_Finance)
                =
            (SELECT COUNT(*) FROM dbo.vw_Finance_Dashboard)

            /* Data Dictionary is complete */
            AND
            (SELECT COUNT(*)
             FROM dbo.Data_Dictionary
             WHERE Business_Definition IS NULL) = 0

            AND
            (SELECT COUNT(*)
             FROM dbo.Data_Dictionary
             WHERE Data_Source IS NULL) = 0

            AND
            (SELECT COUNT(*)
             FROM dbo.Data_Dictionary
             WHERE Transformation_Rule IS NULL) = 0

        THEN 'PASS'
        ELSE 'FAIL'
    END AS Final_Validation_Status;
GO


PRINT '53A Final End-to-End Validation completed successfully.';
GO

USE Enterprise_Trust_Safety_DWH;
GO
