/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 41_Create_vw_Operations_Dashboard.sql
Purpose      : Reporting View for Operations Dashboard
Author       : Tushar Mehta
Created Date : 07-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

IF OBJECT_ID('dbo.vw_Operations_Dashboard','V') IS NOT NULL
    DROP VIEW dbo.vw_Operations_Dashboard;
GO

CREATE VIEW dbo.vw_Operations_Dashboard
AS

SELECT

      DD.Full_Date
    , DD.Year_Number
    , DD.Month_Name
    , DD.Quarter_Name

    , DC.Client_Name
    , DP.Process_Name
    , DT.Team_Name
    , DS.Site_Name

    , DE.Employee_ID
    , DE.Employee_Name
    , DE.Designation

    , DSH.Shift_Name

    , FO.Cases_Handled
    , FO.Cases_Reviewed
    , FO.Cases_Approved
    , FO.Cases_Rejected

    , FO.Appeals_Received
    , FO.Appeals_Reversed

    , FO.QA_Score
    , FO.AHT_Minutes
    , FO.SLA_Compliance_Pct

    , FO.Productive_Hours
    , FO.Idle_Hours
    , FO.Break_Hours
    , FO.Billable_Hours
    , FO.Overtime_Hours

    , FO.Revenue_USD
    , FO.Operating_Cost_USD

FROM dbo.Fact_Operations FO

INNER JOIN dbo.Dim_Date DD
ON FO.Date_Key = DD.Date_Key

INNER JOIN dbo.Dim_Employee DE
ON FO.Employee_Key = DE.Employee_Key

INNER JOIN dbo.Dim_Client DC
ON FO.Client_Key = DC.Client_Key

INNER JOIN dbo.Dim_Process DP
ON FO.Process_Key = DP.Process_Key

INNER JOIN dbo.Dim_Team DT
ON FO.Team_Key = DT.Team_Key

INNER JOIN dbo.Dim_Site DS
ON FO.Site_Key = DS.Site_Key

INNER JOIN dbo.Dim_Shift DSH
ON FO.Shift_Key = DSH.Shift_Key;
GO

PRINT 'vw_Operations_Dashboard created successfully.';