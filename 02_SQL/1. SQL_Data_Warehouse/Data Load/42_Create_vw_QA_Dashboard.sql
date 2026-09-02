/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 42_Create_vw_QA_Dashboard.sql
Purpose      : Reporting View for QA Dashboard
Author       : Tushar Mehta
Created Date : 07-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

IF OBJECT_ID('dbo.vw_QA_Dashboard','V') IS NOT NULL
    DROP VIEW dbo.vw_QA_Dashboard;
GO

CREATE VIEW dbo.vw_QA_Dashboard
AS

SELECT

      DD.Full_Date
    , DD.Year_Number
    , DD.Month_Name
    , DD.Quarter_Name

    , DP.Policy_Name

    , DEC.Error_Code

    , FQ.QA_Score

FROM dbo.Fact_QA FQ

INNER JOIN dbo.Dim_Date DD
ON FQ.Date_Key = DD.Date_Key

INNER JOIN dbo.Dim_Policy DP
ON FQ.Policy_Key = DP.Policy_Key

INNER JOIN dbo.Dim_Error_Code DEC
ON FQ.Error_Code_Key = DEC.Error_Code_Key;

GO

PRINT 'vw_QA_Dashboard created successfully.';