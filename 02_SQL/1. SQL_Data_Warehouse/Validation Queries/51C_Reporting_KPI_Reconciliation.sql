/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 51C_Reporting_KPI_Reconciliation.sql
Purpose      : Reconcile Key Reporting KPIs Against Underlying Fact Tables
Author       : Tushar Mehta
Created Date : 10-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO


/*==============================================================
  1. OPERATIONS KPI RECONCILIATION
==============================================================*/

SELECT
    'Operations - Total Cases Handled' AS KPI,
    CAST(SUM(Cases_Handled) AS DECIMAL(18,2)) AS Fact_Value,
    CAST(
        (SELECT SUM(Cases_Handled)
         FROM dbo.vw_Operations_Dashboard)
        AS DECIMAL(18,2)
    ) AS View_Value,
    CAST(
        SUM(Cases_Handled) -
        (SELECT SUM(Cases_Handled)
         FROM dbo.vw_Operations_Dashboard)
        AS DECIMAL(18,2)
    ) AS Variance,
    CASE
        WHEN SUM(Cases_Handled) =
             (SELECT SUM(Cases_Handled)
              FROM dbo.vw_Operations_Dashboard)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS Validation_Status
FROM dbo.Fact_Operations

UNION ALL

SELECT
    'Operations - Average QA Score',
    CAST(AVG(QA_Score) AS DECIMAL(18,4)),
    CAST(
        (SELECT AVG(QA_Score)
         FROM dbo.vw_Operations_Dashboard)
        AS DECIMAL(18,4)
    ),
    CAST(
        AVG(QA_Score) -
        (SELECT AVG(QA_Score)
         FROM dbo.vw_Operations_Dashboard)
        AS DECIMAL(18,4)
    ),
    CASE
        WHEN ABS(
            AVG(QA_Score) -
            (SELECT AVG(QA_Score)
             FROM dbo.vw_Operations_Dashboard)
        ) < 0.0001
        THEN 'PASS'
        ELSE 'FAIL'
    END
FROM dbo.Fact_Operations

UNION ALL

SELECT
    'Operations - Average AHT',
    CAST(AVG(AHT_Minutes) AS DECIMAL(18,4)),
    CAST(
        (SELECT AVG(AHT_Minutes)
         FROM dbo.vw_Operations_Dashboard)
        AS DECIMAL(18,4)
    ),
    CAST(
        AVG(AHT_Minutes) -
        (SELECT AVG(AHT_Minutes)
         FROM dbo.vw_Operations_Dashboard)
        AS DECIMAL(18,4)
    ),
    CASE
        WHEN ABS(
            AVG(AHT_Minutes) -
            (SELECT AVG(AHT_Minutes)
             FROM dbo.vw_Operations_Dashboard)
        ) < 0.0001
        THEN 'PASS'
        ELSE 'FAIL'
    END
FROM dbo.Fact_Operations

UNION ALL

SELECT
    'Operations - Average SLA Compliance',
    CAST(AVG(SLA_Compliance_Pct) AS DECIMAL(18,4)),
    CAST(
        (SELECT AVG(SLA_Compliance_Pct)
         FROM dbo.vw_Operations_Dashboard)
        AS DECIMAL(18,4)
    ),
    CAST(
        AVG(SLA_Compliance_Pct) -
        (SELECT AVG(SLA_Compliance_Pct)
         FROM dbo.vw_Operations_Dashboard)
        AS DECIMAL(18,4)
    ),
    CASE
        WHEN ABS(
            AVG(SLA_Compliance_Pct) -
            (SELECT AVG(SLA_Compliance_Pct)
             FROM dbo.vw_Operations_Dashboard)
        ) < 0.0001
        THEN 'PASS'
        ELSE 'FAIL'
    END
FROM dbo.Fact_Operations

UNION ALL

SELECT
    'Operations - Total Revenue',
    CAST(SUM(Revenue_USD) AS DECIMAL(18,2)),
    CAST(
        (SELECT SUM(Revenue_USD)
         FROM dbo.vw_Operations_Dashboard)
        AS DECIMAL(18,2)
    ),
    CAST(
        SUM(Revenue_USD) -
        (SELECT SUM(Revenue_USD)
         FROM dbo.vw_Operations_Dashboard)
        AS DECIMAL(18,2)
    ),
    CASE
        WHEN SUM(Revenue_USD) =
             (SELECT SUM(Revenue_USD)
              FROM dbo.vw_Operations_Dashboard)
        THEN 'PASS'
        ELSE 'FAIL'
    END
FROM dbo.Fact_Operations

UNION ALL

SELECT
    'Operations - Total Operating Cost',
    CAST(SUM(Operating_Cost_USD) AS DECIMAL(18,2)),
    CAST(
        (SELECT SUM(Operating_Cost_USD)
         FROM dbo.vw_Operations_Dashboard)
        AS DECIMAL(18,2)
    ),
    CAST(
        SUM(Operating_Cost_USD) -
        (SELECT SUM(Operating_Cost_USD)
         FROM dbo.vw_Operations_Dashboard)
        AS DECIMAL(18,2)
    ),
    CASE
        WHEN SUM(Operating_Cost_USD) =
             (SELECT SUM(Operating_Cost_USD)
              FROM dbo.vw_Operations_Dashboard)
        THEN 'PASS'
        ELSE 'FAIL'
    END
FROM dbo.Fact_Operations;
GO


/*==============================================================
  2. QA KPI RECONCILIATION
==============================================================*/

SELECT
    'QA - Average QA Score' AS KPI,

    CAST(AVG(QA_Score) AS DECIMAL(18,4)) AS Fact_Value,

    CAST(
        (SELECT AVG(QA_Score)
         FROM dbo.vw_QA_Dashboard)
        AS DECIMAL(18,4)
    ) AS View_Value,

    CAST(
        AVG(QA_Score) -
        (SELECT AVG(QA_Score)
         FROM dbo.vw_QA_Dashboard)
        AS DECIMAL(18,4)
    ) AS Variance,

    CASE
        WHEN ABS(
            AVG(QA_Score) -
            (SELECT AVG(QA_Score)
             FROM dbo.vw_QA_Dashboard)
        ) < 0.0001
        THEN 'PASS'
        ELSE 'FAIL'
    END AS Validation_Status

FROM dbo.Fact_QA;
GO


/*==============================================================
  3. APPEALS KPI RECONCILIATION
==============================================================*/

SELECT
    'Appeals - Average Resolution Time' AS KPI,

    CAST(AVG(Resolution_Time) AS DECIMAL(18,4)) AS Fact_Value,

    CAST(
        (SELECT AVG(Resolution_Time)
         FROM dbo.vw_Appeals_Dashboard)
        AS DECIMAL(18,4)
    ) AS View_Value,

    CAST(
        AVG(Resolution_Time) -
        (SELECT AVG(Resolution_Time)
         FROM dbo.vw_Appeals_Dashboard)
        AS DECIMAL(18,4)
    ) AS Variance,

    CASE
        WHEN ABS(
            AVG(Resolution_Time) -
            (SELECT AVG(Resolution_Time)
             FROM dbo.vw_Appeals_Dashboard)
        ) < 0.0001
        THEN 'PASS'
        ELSE 'FAIL'
    END AS Validation_Status

FROM dbo.Fact_Appeals;
GO


/*==============================================================
  4. COACHING KPI RECONCILIATION
==============================================================*/

SELECT
    'Coaching - Total Coaching Minutes' AS KPI,

    CAST(SUM(Duration_Minutes) AS DECIMAL(18,2)) AS Fact_Value,

    CAST(
        (SELECT SUM(Duration_Minutes)
         FROM dbo.vw_Coaching_Dashboard)
        AS DECIMAL(18,2)
    ) AS View_Value,

    CAST(
        SUM(Duration_Minutes) -
        (SELECT SUM(Duration_Minutes)
         FROM dbo.vw_Coaching_Dashboard)
        AS DECIMAL(18,2)
    ) AS Variance,

    CASE
        WHEN SUM(Duration_Minutes) =
             (SELECT SUM(Duration_Minutes)
              FROM dbo.vw_Coaching_Dashboard)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS Validation_Status

FROM dbo.Fact_Coaching;
GO


/*==============================================================
  5. WORKFORCE KPI RECONCILIATION
==============================================================*/

SELECT
    'Workforce - Total Hours' AS KPI,

    CAST(SUM(Hours) AS DECIMAL(18,2)) AS Fact_Value,

    CAST(
        (SELECT SUM(Hours)
         FROM dbo.vw_Workforce_Dashboard)
        AS DECIMAL(18,2)
    ) AS View_Value,

    CAST(
        SUM(Hours) -
        (SELECT SUM(Hours)
         FROM dbo.vw_Workforce_Dashboard)
        AS DECIMAL(18,2)
    ) AS Variance,

    CASE
        WHEN SUM(Hours) =
             (SELECT SUM(Hours)
              FROM dbo.vw_Workforce_Dashboard)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS Validation_Status

FROM dbo.Fact_Workforce;
GO


/*==============================================================
  6. FINANCE KPI RECONCILIATION
==============================================================*/

SELECT
    'Finance - Total Revenue' AS KPI,

    CAST(SUM(Revenue_USD) AS DECIMAL(18,2)) AS Fact_Value,

    CAST(
        (SELECT SUM(Revenue_USD)
         FROM dbo.vw_Finance_Dashboard)
        AS DECIMAL(18,2)
    ) AS View_Value,

    CAST(
        SUM(Revenue_USD) -
        (SELECT SUM(Revenue_USD)
         FROM dbo.vw_Finance_Dashboard)
        AS DECIMAL(18,2)
    ) AS Variance,

    CASE
        WHEN SUM(Revenue_USD) =
             (SELECT SUM(Revenue_USD)
              FROM dbo.vw_Finance_Dashboard)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS Validation_Status

FROM dbo.Fact_Finance;
GO


PRINT '51C Reporting KPI Reconciliation completed successfully.';
GO