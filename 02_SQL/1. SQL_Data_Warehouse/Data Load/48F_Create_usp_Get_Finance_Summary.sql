/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 48F_Create_usp_Get_Finance_Summary.sql
Purpose      : Parameterized Finance Summary for Reporting
Author       : Tushar Mehta
Created Date : 10-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

IF OBJECT_ID('dbo.usp_Get_Finance_Summary', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.usp_Get_Finance_Summary;
END;
GO

CREATE PROCEDURE dbo.usp_Get_Finance_Summary

      @Start_Date          DATE = NULL
    , @End_Date            DATE = NULL
    , @Billing_Model       NVARCHAR(100) = NULL
    , @Cost_Center_Name    NVARCHAR(100) = NULL

AS
BEGIN

    SET NOCOUNT ON;

    SELECT

          COUNT(*) AS Total_Finance_Records

        , SUM(Revenue_USD) AS Total_Revenue_USD

        , AVG(Revenue_USD) AS Average_Revenue_USD

        , MIN(Revenue_USD) AS Minimum_Revenue_USD

        , MAX(Revenue_USD) AS Maximum_Revenue_USD

    FROM dbo.vw_Finance_Dashboard

    WHERE
        (@Start_Date IS NULL
         OR Full_Date >= @Start_Date)

        AND

        (@End_Date IS NULL
         OR Full_Date <= @End_Date)

        AND

        (@Billing_Model IS NULL
         OR Billing_Model = @Billing_Model)

        AND

        (@Cost_Center_Name IS NULL
         OR Cost_Center_Name = @Cost_Center_Name);

END;
GO

PRINT 'usp_Get_Finance_Summary created successfully.';