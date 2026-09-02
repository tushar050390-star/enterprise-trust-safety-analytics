/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 48D_Create_usp_Get_Coaching_Summary.sql
Purpose      : Parameterized Coaching Summary for Reporting
Author       : Tushar Mehta
Created Date : 10-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

IF OBJECT_ID('dbo.usp_Get_Coaching_Summary', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.usp_Get_Coaching_Summary;
END;
GO

CREATE PROCEDURE dbo.usp_Get_Coaching_Summary

      @Start_Date     DATE = NULL
    , @End_Date       DATE = NULL
    , @Client_Name    NVARCHAR(100) = NULL
    , @Process_Name   NVARCHAR(100) = NULL
    , @Team_Name      NVARCHAR(100) = NULL
    , @Employee_ID    NVARCHAR(50) = NULL

AS
BEGIN

    SET NOCOUNT ON;

    SELECT

          COUNT(*) AS Total_Coaching_Sessions

        , AVG(Duration_Minutes) AS Average_Coaching_Duration

        , MIN(Duration_Minutes) AS Minimum_Coaching_Duration

        , MAX(Duration_Minutes) AS Maximum_Coaching_Duration

        , SUM(Duration_Minutes) AS Total_Coaching_Minutes

    FROM dbo.vw_Coaching_Dashboard

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

        (@Process_Name IS NULL
         OR Process_Name = @Process_Name)

        AND

        (@Team_Name IS NULL
         OR Team_Name = @Team_Name)

        AND

        (@Employee_ID IS NULL
         OR Employee_ID = @Employee_ID);

END;
GO

PRINT 'usp_Get_Coaching_Summary created successfully.';

SELECT DISTINCT Client_Name
FROM dbo.vw_Coaching_Dashboard
ORDER BY Client_Name;

SELECT DISTINCT Process_Name
FROM dbo.vw_Coaching_Dashboard
ORDER BY Process_Name;

SELECT DISTINCT Team_Name
FROM dbo.vw_Coaching_Dashboard
ORDER BY Team_Name;

EXEC dbo.usp_Get_Coaching_Summary
     @Start_Date = '2026-01-01',
     @End_Date = '2026-03-31',
     @Team_Name = 'Team Titan';



