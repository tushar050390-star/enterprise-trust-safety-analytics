/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 45_Create_vw_Workforce_Dashboard.sql
Purpose      : Reporting View for Workforce Dashboard
Author       : Tushar Mehta
Created Date : 07-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

IF OBJECT_ID('dbo.vw_Workforce_Dashboard','V') IS NOT NULL
    DROP VIEW dbo.vw_Workforce_Dashboard;
GO

CREATE VIEW dbo.vw_Workforce_Dashboard
AS

SELECT

      DD.Full_Date
    , DD.Year_Number
    , DD.Month_Name
    , DD.Quarter_Name

    , DSH.Shift_Name

    , DSG.Shrinkage_Type

    , FW.Hours

FROM dbo.Fact_Workforce FW

INNER JOIN dbo.Dim_Date DD
ON FW.Date_Key = DD.Date_Key

INNER JOIN dbo.Dim_Shift DSH
ON FW.Shift_Key = DSH.Shift_Key

INNER JOIN dbo.Dim_Shrinkage DSG
ON FW.Shrinkage_Key = DSG.Shrinkage_Key;

GO

PRINT 'vw_Workforce_Dashboard created successfully.';

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Dim_Shrinkage';