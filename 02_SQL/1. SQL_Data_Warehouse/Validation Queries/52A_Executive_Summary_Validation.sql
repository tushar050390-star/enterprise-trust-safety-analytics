/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 52A_Executive_Summary_Validation.sql
Purpose      : Validate Executive Summary Management KPIs
Author       : Tushar Mehta
Created Date : 10-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO


/*==============================================================
  1. EXECUTIVE SUMMARY KPI VALIDATION
==============================================================*/

SELECT
    'Total Cases Handled' AS KPI,
    'vw_Operations_Dashboard' AS Source_View,
    CAST(SUM(Cases_Handled) AS DECIMAL(18,2)) AS KPI_Value
FROM dbo.vw_Operations_Dashboard

UNION ALL

SELECT
    'Average QA Score',
    'vw_Operations_Dashboard',
    CAST(AVG(QA_Score) AS DECIMAL(18,4))
FROM dbo.vw_Operations_Dashboard

UNION ALL

SELECT
    'Average AHT',
    'vw_Operations_Dashboard',
    CAST(AVG(AHT_Minutes) AS DECIMAL(18,4))
FROM dbo.vw_Operations_Dashboard

UNION ALL

SELECT
    'Average SLA Compliance',
    'vw_Operations_Dashboard',
    CAST(AVG(SLA_Compliance_Pct) AS DECIMAL(18,4))
FROM dbo.vw_Operations_Dashboard

UNION ALL

SELECT
    'Total Operations Revenue',
    'vw_Operations_Dashboard',
    CAST(SUM(Revenue_USD) AS DECIMAL(18,2))
FROM dbo.vw_Operations_Dashboard

UNION ALL

SELECT
    'Total Operating Cost',
    'vw_Operations_Dashboard',
    CAST(SUM(Operating_Cost_USD) AS DECIMAL(18,2))
FROM dbo.vw_Operations_Dashboard

UNION ALL

SELECT
    'QA Average Score',
    'vw_QA_Dashboard',
    CAST(AVG(QA_Score) AS DECIMAL(18,4))
FROM dbo.vw_QA_Dashboard

UNION ALL

SELECT
    'Average Appeal Resolution Time',
    'vw_Appeals_Dashboard',
    CAST(AVG(Resolution_Time) AS DECIMAL(18,4))
FROM dbo.vw_Appeals_Dashboard

UNION ALL

SELECT
    'Total Coaching Minutes',
    'vw_Coaching_Dashboard',
    CAST(SUM(Duration_Minutes) AS DECIMAL(18,2))
FROM dbo.vw_Coaching_Dashboard

UNION ALL

SELECT
    'Total Workforce Hours',
    'vw_Workforce_Dashboard',
    CAST(SUM(Hours) AS DECIMAL(18,2))
FROM dbo.vw_Workforce_Dashboard

UNION ALL

SELECT
    'Total Finance Revenue',
    'vw_Finance_Dashboard',
    CAST(SUM(Revenue_USD) AS DECIMAL(18,2))
FROM dbo.vw_Finance_Dashboard

ORDER BY KPI;
GO


/*==============================================================
  2. EXECUTIVE SUMMARY KPI STATUS
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


PRINT '52A Executive Summary validation completed successfully.';
GO