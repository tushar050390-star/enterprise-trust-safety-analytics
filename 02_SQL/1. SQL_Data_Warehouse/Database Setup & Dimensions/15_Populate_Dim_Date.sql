/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 15_Populate_Dim_Date.sql
Author       : Tushar Mehta
Purpose      : Populate Date Dimension using Numbers Table
Created On   : 03-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

--============================================================
-- Populate Dim_Date
--============================================================

WITH Calendar AS
(
    SELECT
        DATEADD(DAY, Number, CAST('2000-01-01' AS DATE)) AS Calendar_Date
    FROM dbo.Numbers
    WHERE Number <= DATEDIFF(DAY, '2000-01-01', '2050-12-31')
)

INSERT INTO dbo.Dim_Date
(
    Date_Key,
    Full_Date,
    Day_Number,
    Day_Name,
    Week_Number,
    Month_Number,
    Month_Name,
    Quarter_Number,
    Quarter_Name,
    Year_Number,
    Is_Weekend,
    Fiscal_Month,
    Fiscal_Quarter,
    Fiscal_Year
)

SELECT

--============================================================
-- Smart Date Key (YYYYMMDD)
--============================================================

(YEAR(Calendar_Date) * 10000)
+ (MONTH(Calendar_Date) * 100)
+ DAY(Calendar_Date),

--============================================================
-- Calendar Date
--============================================================

Calendar_Date,

--============================================================
-- Day Number
--============================================================

DAY(Calendar_Date),

--============================================================
-- Day Name
--============================================================

DATENAME(WEEKDAY, Calendar_Date),

--============================================================
-- Week Number
--============================================================

DATEPART(ISO_WEEK, Calendar_Date),

--============================================================
-- Month Number
--============================================================

MONTH(Calendar_Date),

--============================================================
-- Month Name
--============================================================

DATENAME(MONTH, Calendar_Date),

--============================================================
-- Quarter Number
--============================================================

DATEPART(QUARTER, Calendar_Date),

--============================================================
-- Quarter Name
--============================================================

CONCAT('Q', DATEPART(QUARTER, Calendar_Date)),

--============================================================
-- Year Number
--============================================================

YEAR(Calendar_Date),

--============================================================
-- Weekend Flag
--============================================================

CASE
    WHEN DATENAME(WEEKDAY, Calendar_Date) IN ('Saturday','Sunday')
    THEN 1
    ELSE 0
END,

--============================================================
-- Fiscal Month
--============================================================

CASE
    WHEN MONTH(Calendar_Date) >= 4
        THEN MONTH(Calendar_Date) - 3
    ELSE MONTH(Calendar_Date) + 9
END,

--============================================================
-- Fiscal Quarter
--============================================================

CASE
    WHEN MONTH(Calendar_Date) BETWEEN 4 AND 6 THEN 'FQ1'
    WHEN MONTH(Calendar_Date) BETWEEN 7 AND 9 THEN 'FQ2'
    WHEN MONTH(Calendar_Date) BETWEEN 10 AND 12 THEN 'FQ3'
    ELSE 'FQ4'
END,

--============================================================
-- Fiscal Year
--============================================================

CASE
    WHEN MONTH(Calendar_Date) >= 4
        THEN CONCAT('FY', YEAR(Calendar_Date) + 1)
    ELSE CONCAT('FY', YEAR(Calendar_Date))
END

FROM Calendar;

GO

PRINT 'Dim_Date populated successfully.';
GO

