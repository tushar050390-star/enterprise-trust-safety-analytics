/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 48A_Create_usp_Get_Operations_Summary.sql
Purpose      : Parameterized Operations Summary for Reporting
Author       : Tushar Mehta
Created Date : 09-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

IF OBJECT_ID('dbo.usp_Get_Operations_Summary', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.usp_Get_Operations_Summary;
END;
GO

CREATE PROCEDURE dbo.usp_Get_Operations_Summary

      @Start_Date DATE = NULL
    , @End_Date   DATE = NULL
    , @Client_Name NVARCHAR(100) = NULL
    , @Team_Name   NVARCHAR(100) = NULL

AS
BEGIN

    SET NOCOUNT ON;

    SELECT

          COUNT(*) AS Total_Records

        , SUM(Cases_Handled) AS Total_Cases_Handled

        , SUM(Cases_Reviewed) AS Total_Cases_Reviewed

        , SUM(Cases_Approved) AS Total_Cases_Approved

        , SUM(Cases_Rejected) AS Total_Cases_Rejected

        , AVG(QA_Score) AS Average_QA_Score

        , AVG(AHT_Minutes) AS Average_AHT_Minutes

        , AVG(SLA_Compliance_Pct) AS Average_SLA_Compliance_Pct

        , SUM(Productive_Hours) AS Total_Productive_Hours

        , SUM(Revenue_USD) AS Total_Revenue_USD

        , SUM(Operating_Cost_USD) AS Total_Operating_Cost_USD

    FROM dbo.vw_Operations_Dashboard

    WHERE
        (@Start_Date IS NULL
         OR Full_Date >= @Start_Date)

        AND

        (@End_Date IS NULL
         OR Full_Date <= @End_Date)

        AND

        (@Client_Name IS NULL
         OR Client_Name = @Client_Name)

        AND

        (@Team_Name IS NULL
         OR Team_Name = @Team_Name);

END;
GO

PRINT 'usp_Get_Operations_Summary created successfully.';

EXEC dbo.usp_Get_Operations_Summary;

EXEC dbo.usp_Get_Operations_Summary
      @Start_Date = '2026-01-01',
      @End_Date   = '2026-03-31';

EXEC dbo.usp_Get_Operations_Summary
      @Start_Date  = '2026-01-01',
      @End_Date    = '2026-03-31',
      @Client_Name = 'YouTube',
      @Team_Name   = 'Team 1';

SELECT
    Client_Name,
    Team_Name,
    COUNT(*) AS Record_Count
FROM dbo.vw_Operations_Dashboard
WHERE Client_Name = 'YouTube'
GROUP BY
    Client_Name,
    Team_Name
ORDER BY
    Team_Name;

SELECT
    COUNT(*) AS Record_Count
FROM dbo.vw_Operations_Dashboard
WHERE Client_Name = 'YouTube'
  AND Team_Name = 'Team 1'
  AND Full_Date >= '2026-01-01'
  AND Full_Date <= '2026-03-31';

