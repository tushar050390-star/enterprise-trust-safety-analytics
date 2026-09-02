/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 51A_Reporting_Reconciliation.sql
Purpose      : Reconcile Fact Tables Against Reporting Views
Author       : Tushar Mehta
Created Date : 10-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO


/*==============================================================
  1. OPERATIONS RECONCILIATION
==============================================================*/

SELECT
    'Operations' AS Domain,

    (SELECT COUNT(*)
     FROM dbo.Fact_Operations) AS Fact_Record_Count,

    (SELECT COUNT(*)
     FROM dbo.vw_Operations_Dashboard) AS View_Record_Count,

    (SELECT SUM(Cases_Handled)
     FROM dbo.Fact_Operations) AS Fact_Cases_Handled,

    (SELECT SUM(Cases_Handled)
     FROM dbo.vw_Operations_Dashboard) AS View_Cases_Handled,

    (SELECT SUM(Revenue_USD)
     FROM dbo.Fact_Operations) AS Fact_Revenue_USD,

    (SELECT SUM(Revenue_USD)
     FROM dbo.vw_Operations_Dashboard) AS View_Revenue_USD;
GO


/*==============================================================
  2. QA RECONCILIATION
==============================================================*/

SELECT
    'QA' AS Domain,

    (SELECT COUNT(*)
     FROM dbo.Fact_QA) AS Fact_Record_Count,

    (SELECT COUNT(*)
     FROM dbo.vw_QA_Dashboard) AS View_Record_Count,

    (SELECT AVG(QA_Score)
     FROM dbo.Fact_QA) AS Fact_Average_QA_Score,

    (SELECT AVG(QA_Score)
     FROM dbo.vw_QA_Dashboard) AS View_Average_QA_Score;
GO


/*==============================================================
  3. APPEALS RECONCILIATION
==============================================================*/

SELECT
    'Appeals' AS Domain,

    (SELECT COUNT(*)
     FROM dbo.Fact_Appeals) AS Fact_Record_Count,

    (SELECT COUNT(*)
     FROM dbo.vw_Appeals_Dashboard) AS View_Record_Count,

    (SELECT AVG(Resolution_Time)
     FROM dbo.Fact_Appeals) AS Fact_Average_Resolution_Time,

    (SELECT AVG(Resolution_Time)
     FROM dbo.vw_Appeals_Dashboard) AS View_Average_Resolution_Time;
GO


/*==============================================================
  4. COACHING RECONCILIATION
==============================================================*/

SELECT
    'Coaching' AS Domain,

    (SELECT COUNT(*)
     FROM dbo.Fact_Coaching) AS Fact_Record_Count,

    (SELECT COUNT(*)
     FROM dbo.vw_Coaching_Dashboard) AS View_Record_Count,

    (SELECT SUM(Duration_Minutes)
     FROM dbo.Fact_Coaching) AS Fact_Total_Coaching_Minutes,

    (SELECT SUM(Duration_Minutes)
     FROM dbo.vw_Coaching_Dashboard) AS View_Total_Coaching_Minutes;
GO


/*==============================================================
  5. WORKFORCE RECONCILIATION
==============================================================*/

SELECT
    'Workforce' AS Domain,

    (SELECT COUNT(*)
     FROM dbo.Fact_Workforce) AS Fact_Record_Count,

    (SELECT COUNT(*)
     FROM dbo.vw_Workforce_Dashboard) AS View_Record_Count,

    (SELECT SUM(Hours)
     FROM dbo.Fact_Workforce) AS Fact_Total_Hours,

    (SELECT SUM(Hours)
     FROM dbo.vw_Workforce_Dashboard) AS View_Total_Hours;
GO


/*==============================================================
  6. FINANCE RECONCILIATION
==============================================================*/

SELECT
    'Finance' AS Domain,

    (SELECT COUNT(*)
     FROM dbo.Fact_Finance) AS Fact_Record_Count,

    (SELECT COUNT(*)
     FROM dbo.vw_Finance_Dashboard) AS View_Record_Count,

    (SELECT SUM(Revenue_USD)
     FROM dbo.Fact_Finance) AS Fact_Total_Revenue_USD,

    (SELECT SUM(Revenue_USD)
     FROM dbo.vw_Finance_Dashboard) AS View_Total_Revenue_USD;
GO


PRINT '51A Reporting reconciliation completed successfully.';
GO