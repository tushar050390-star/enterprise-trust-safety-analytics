/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 48G_Create_usp_Get_Executive_Summary.sql
Purpose      : Executive Summary KPI Procedure
Author       : Tushar Mehta
Created Date : 10-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

IF OBJECT_ID('dbo.usp_Get_Executive_Summary', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.usp_Get_Executive_Summary;
END;
GO

CREATE PROCEDURE dbo.usp_Get_Executive_Summary

      @Start_Date DATE = NULL
    , @End_Date   DATE = NULL

AS
BEGIN

    SET NOCOUNT ON;

    SELECT

        /*========================================================
          OPERATIONS
        ========================================================*/

        (
            SELECT COUNT(*)
            FROM dbo.vw_Operations_Dashboard
            WHERE
                (@Start_Date IS NULL OR Full_Date >= @Start_Date)
                AND
                (@End_Date IS NULL OR Full_Date <= @End_Date)
        ) AS Total_Operations_Records,

        (
            SELECT SUM(Cases_Handled)
            FROM dbo.vw_Operations_Dashboard
            WHERE
                (@Start_Date IS NULL OR Full_Date >= @Start_Date)
                AND
                (@End_Date IS NULL OR Full_Date <= @End_Date)
        ) AS Total_Cases_Handled,

        (
            SELECT AVG(QA_Score)
            FROM dbo.vw_Operations_Dashboard
            WHERE
                (@Start_Date IS NULL OR Full_Date >= @Start_Date)
                AND
                (@End_Date IS NULL OR Full_Date <= @End_Date)
        ) AS Average_Operations_QA_Score,

        (
            SELECT AVG(AHT_Minutes)
            FROM dbo.vw_Operations_Dashboard
            WHERE
                (@Start_Date IS NULL OR Full_Date >= @Start_Date)
                AND
                (@End_Date IS NULL OR Full_Date <= @End_Date)
        ) AS Average_AHT_Minutes,

        (
            SELECT AVG(SLA_Compliance_Pct)
            FROM dbo.vw_Operations_Dashboard
            WHERE
                (@Start_Date IS NULL OR Full_Date >= @Start_Date)
                AND
                (@End_Date IS NULL OR Full_Date <= @End_Date)
        ) AS Average_SLA_Compliance_Pct,

        /*========================================================
          QA
        ========================================================*/

        (
            SELECT COUNT(*)
            FROM dbo.vw_QA_Dashboard
            WHERE
                (@Start_Date IS NULL OR Full_Date >= @Start_Date)
                AND
                (@End_Date IS NULL OR Full_Date <= @End_Date)
        ) AS Total_QA_Audits,

        (
            SELECT AVG(QA_Score)
            FROM dbo.vw_QA_Dashboard
            WHERE
                (@Start_Date IS NULL OR Full_Date >= @Start_Date)
                AND
                (@End_Date IS NULL OR Full_Date <= @End_Date)
        ) AS Average_QA_Score,

        /*========================================================
          APPEALS
        ========================================================*/

        (
            SELECT COUNT(*)
            FROM dbo.vw_Appeals_Dashboard
            WHERE
                (@Start_Date IS NULL OR Full_Date >= @Start_Date)
                AND
                (@End_Date IS NULL OR Full_Date <= @End_Date)
        ) AS Total_Appeals,

        (
            SELECT AVG(Resolution_Time)
            FROM dbo.vw_Appeals_Dashboard
            WHERE
                (@Start_Date IS NULL OR Full_Date >= @Start_Date)
                AND
                (@End_Date IS NULL OR Full_Date <= @End_Date)
        ) AS Average_Appeal_Resolution_Time,

        /*========================================================
          COACHING
        ========================================================*/

        (
            SELECT COUNT(*)
            FROM dbo.vw_Coaching_Dashboard
            WHERE
                (@Start_Date IS NULL OR Full_Date >= @Start_Date)
                AND
                (@End_Date IS NULL OR Full_Date <= @End_Date)
        ) AS Total_Coaching_Sessions,

        (
            SELECT AVG(Duration_Minutes)
            FROM dbo.vw_Coaching_Dashboard
            WHERE
                (@Start_Date IS NULL OR Full_Date >= @Start_Date)
                AND
                (@End_Date IS NULL OR Full_Date <= @End_Date)
        ) AS Average_Coaching_Duration,

        /*========================================================
          WORKFORCE
        ========================================================*/

        (
            SELECT SUM(Hours)
            FROM dbo.vw_Workforce_Dashboard
            WHERE
                (@Start_Date IS NULL OR Full_Date >= @Start_Date)
                AND
                (@End_Date IS NULL OR Full_Date <= @End_Date)
        ) AS Total_Workforce_Hours,

        (
            SELECT AVG(Hours)
            FROM dbo.vw_Workforce_Dashboard
            WHERE
                (@Start_Date IS NULL OR Full_Date >= @Start_Date)
                AND
                (@End_Date IS NULL OR Full_Date <= @End_Date)
        ) AS Average_Workforce_Hours,

        /*========================================================
          FINANCE
        ========================================================*/

        (
            SELECT SUM(Revenue_USD)
            FROM dbo.vw_Finance_Dashboard
            WHERE
                (@Start_Date IS NULL OR Full_Date >= @Start_Date)
                AND
                (@End_Date IS NULL OR Full_Date <= @End_Date)
        ) AS Total_Revenue_USD,

        (
            SELECT AVG(Revenue_USD)
            FROM dbo.vw_Finance_Dashboard
            WHERE
                (@Start_Date IS NULL OR Full_Date >= @Start_Date)
                AND
                (@End_Date IS NULL OR Full_Date <= @End_Date)
        ) AS Average_Revenue_USD;

END;
GO

PRINT 'usp_Get_Executive_Summary created successfully.';