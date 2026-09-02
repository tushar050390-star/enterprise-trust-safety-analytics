/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 46_Create_vw_Finance_Dashboard.sql
Purpose      : Reporting View for Finance Dashboard
Author       : Tushar Mehta
Created Date : 07-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

IF OBJECT_ID('dbo.vw_Finance_Dashboard','V') IS NOT NULL
    DROP VIEW dbo.vw_Finance_Dashboard;
GO

CREATE VIEW dbo.vw_Finance_Dashboard
AS

SELECT

      DD.Full_Date
    , DD.Year_Number
    , DD.Month_Name
    , DD.Quarter_Name

    , DBM.Billing_Model

    , DCC.Cost_Center_Name

    , FF.Revenue_USD

FROM dbo.Fact_Finance FF

INNER JOIN dbo.Dim_Date DD
ON FF.Date_Key = DD.Date_Key

INNER JOIN dbo.Dim_Billing_Model DBM
ON FF.Billing_Model_Key = DBM.Billing_Model_Key

INNER JOIN dbo.Dim_Cost_Center DCC
ON FF.Cost_Center_Key = DCC.Cost_Center_Key;

GO

PRINT 'vw_Finance_Dashboard created successfully.';