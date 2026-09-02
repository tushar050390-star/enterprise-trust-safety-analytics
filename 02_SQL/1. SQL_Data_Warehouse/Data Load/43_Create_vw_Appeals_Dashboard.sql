/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 43_Create_vw_Appeals_Dashboard.sql
Purpose      : Reporting View for Appeals Dashboard
Author       : Tushar Mehta
Created Date : 07-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

IF OBJECT_ID('dbo.vw_Appeals_Dashboard','V') IS NOT NULL
    DROP VIEW dbo.vw_Appeals_Dashboard;
GO

CREATE VIEW dbo.vw_Appeals_Dashboard
AS

SELECT

      DD.Full_Date
    , DD.Year_Number
    , DD.Month_Name
    , DD.Quarter_Name

    , DP.Policy_Name

    , DAD.Appeal_Decision

    , FA.Resolution_Time

FROM dbo.Fact_Appeals FA

INNER JOIN dbo.Dim_Date DD
ON FA.Date_Key = DD.Date_Key

INNER JOIN dbo.Dim_Policy DP
ON FA.Policy_Key = DP.Policy_Key

INNER JOIN dbo.Dim_Appeal_Decision DAD
ON FA.Appeal_Decision_Key = DAD.Appeal_Decision_Key;

GO

PRINT 'vw_Appeals_Dashboard created successfully.';