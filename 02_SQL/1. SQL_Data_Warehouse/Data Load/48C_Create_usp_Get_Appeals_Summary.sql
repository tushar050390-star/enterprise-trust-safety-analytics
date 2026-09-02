/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 48C_Create_usp_Get_Appeals_Summary.sql
Purpose      : Parameterized Appeals Summary for Reporting
Author       : Tushar Mehta
Created Date : 09-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

IF OBJECT_ID('dbo.usp_Get_Appeals_Summary', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.usp_Get_Appeals_Summary;
END;
GO

CREATE PROCEDURE dbo.usp_Get_Appeals_Summary

      @Start_Date          DATE = NULL
    , @End_Date            DATE = NULL
    , @Policy_Name         NVARCHAR(100) = NULL
    , @Appeal_Decision     NVARCHAR(100) = NULL

AS
BEGIN

    SET NOCOUNT ON;

    SELECT

          COUNT(*) AS Total_Appeals

        , AVG(Resolution_Time) AS Average_Resolution_Time

        , MIN(Resolution_Time) AS Minimum_Resolution_Time

        , MAX(Resolution_Time) AS Maximum_Resolution_Time

    FROM dbo.vw_Appeals_Dashboard

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

        (@Appeal_Decision IS NULL
         OR Appeal_Decision = @Appeal_Decision);

END;
GO

PRINT 'usp_Get_Appeals_Summary created successfully.';

EXEC dbo.usp_Get_Appeals_Summary
     @Appeal_Decision = 'Approved';

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'vw_Appeals_Dashboard'
ORDER BY ORDINAL_POSITION;

SELECT DISTINCT Appeal_Decision
FROM dbo.vw_Appeals_Dashboard
ORDER BY Appeal_Decision;

EXEC dbo.usp_Get_Appeals_Summary
     @Appeal_Decision = 'Upheld';
