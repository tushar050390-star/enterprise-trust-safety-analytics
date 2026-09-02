/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 48E_Create_usp_Get_Workforce_Summary.sql
Purpose      : Parameterized Workforce Summary for Reporting
Author       : Tushar Mehta
Created Date : 10-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

IF OBJECT_ID('dbo.usp_Get_Workforce_Summary', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.usp_Get_Workforce_Summary;
END;
GO

CREATE PROCEDURE dbo.usp_Get_Workforce_Summary

      @Start_Date      DATE = NULL
    , @End_Date        DATE = NULL
    , @Shift_Name      NVARCHAR(100) = NULL
    , @Shrinkage_Type  NVARCHAR(100) = NULL

AS
BEGIN

    SET NOCOUNT ON;

    SELECT

          COUNT(*) AS Total_Workforce_Records

        , SUM(Hours) AS Total_Workforce_Hours

        , AVG(Hours) AS Average_Workforce_Hours

        , MIN(Hours) AS Minimum_Workforce_Hours

        , MAX(Hours) AS Maximum_Workforce_Hours

    FROM dbo.vw_Workforce_Dashboard

    WHERE
        (@Start_Date IS NULL
         OR Full_Date >= @Start_Date)

        AND

        (@End_Date IS NULL
         OR Full_Date <= @End_Date)

        AND

        (@Shift_Name IS NULL
         OR Shift_Name = @Shift_Name)

        AND

        (@Shrinkage_Type IS NULL
         OR Shrinkage_Type = @Shrinkage_Type);

END;
GO

PRINT 'usp_Get_Workforce_Summary created successfully.';