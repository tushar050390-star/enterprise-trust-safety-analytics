/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 44_Create_vw_Coaching_Dashboard.sql
Purpose      : Reporting View for Coaching Dashboard
Author       : Tushar Mehta
Created Date : 07-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

IF OBJECT_ID('dbo.vw_Coaching_Dashboard','V') IS NOT NULL
    DROP VIEW dbo.vw_Coaching_Dashboard;
GO

CREATE VIEW dbo.vw_Coaching_Dashboard
AS

SELECT

      DD.Full_Date
    , DD.Year_Number
    , DD.Month_Name
    , DD.Quarter_Name

    , DC.Client_Name
    , DS.Site_Name
    , DP.Process_Name
    , DT.Team_Name

    , DE.Employee_ID
    , DE.Employee_Name
    , DE.Designation

    , FC.Duration_Minutes

FROM dbo.Fact_Coaching FC

INNER JOIN dbo.Dim_Date DD
ON FC.Date_Key = DD.Date_Key

INNER JOIN dbo.Dim_Client DC
ON FC.Client_Key = DC.Client_Key

INNER JOIN dbo.Dim_Site DS
ON FC.Site_Key = DS.Site_Key

INNER JOIN dbo.Dim_Process DP
ON FC.Process_Key = DP.Process_Key

INNER JOIN dbo.Dim_Team DT
ON FC.Team_Key = DT.Team_Key

INNER JOIN dbo.Dim_Employee DE
ON FC.Employee_Key = DE.Employee_Key;

GO

PRINT 'vw_Coaching_Dashboard created successfully.';