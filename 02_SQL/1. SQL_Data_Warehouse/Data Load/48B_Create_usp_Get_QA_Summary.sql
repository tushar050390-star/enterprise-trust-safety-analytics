/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 48B_Create_usp_Get_QA_Summary.sql
Purpose      : Parameterized QA Summary for Reporting
Author       : Tushar Mehta
Created Date : 09-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

IF OBJECT_ID('dbo.usp_Get_QA_Summary', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.usp_Get_QA_Summary;
END;
GO

CREATE PROCEDURE dbo.usp_Get_QA_Summary

      @Start_Date  DATE = NULL
    , @End_Date    DATE = NULL
    , @Policy_Name NVARCHAR(100) = NULL
    , @Error_Code  NVARCHAR(100) = NULL

AS
BEGIN

    SET NOCOUNT ON;

    SELECT

          COUNT(*) AS Total_QA_Audits

        , AVG(QA_Score) AS Average_QA_Score

        , MIN(QA_Score) AS Minimum_QA_Score

        , MAX(QA_Score) AS Maximum_QA_Score

    FROM dbo.vw_QA_Dashboard

    WHERE
        (@Start_Date IS NULL
         OR Full_Date >= @Start_Date)

        AND

        (@End_Date IS NULL
         OR Full_Date <= @End_Date)

        AND

        (@Policy_Name IS NULL
         OR Policy_Name = @Policy_Name)

        AND

        (@Error_Code IS NULL
         OR Error_Code = @Error_Code);

END;
GO

PRINT 'usp_Get_QA_Summary created successfully.';

EXEC dbo.usp_Get_QA_Summary;

EXEC dbo.usp_Get_QA_Summary
     @Start_Date = '2026-01-01',
     @End_Date = '2026-03-31';

SELECT DISTINCT Policy_Name
FROM dbo.vw_QA_Dashboard
ORDER BY Policy_Name;

EXEC dbo.usp_Get_QA_Summary
     @Policy_Name = 'Adult Content';

SELECT DISTINCT Error_Code
FROM dbo.vw_QA_Dashboard
ORDER BY Error_Code;

EXEC dbo.usp_Get_QA_Summary
     @Start_Date = '2026-01-01',
     @End_Date = '2026-03-31',
     @Policy_Name = 'Adult Content',
     @Error_Code = 'EC001';

