/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 30A_Generate_Fact_Operations_Base.sql
Purpose      : Generate Base Dataset for Fact_Operations
Author       : Tushar Mehta
Created Date : 06-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

SET NOCOUNT ON;

--============================================================
-- Remove Existing Temporary Table
--============================================================

IF OBJECT_ID('tempdb..#FactBase') IS NOT NULL
    DROP TABLE #FactBase;

--============================================================
-- Create Base Dataset
--============================================================

CREATE TABLE #FactBase
(
    Date_Key                INT,
    Employee_Key            INT,
    Client_Key              INT,
    Process_Key             INT,
    Team_Key                INT,
    Site_Key                INT,
    Shift_Key               INT,
    Policy_Key              INT,
    Error_Code_Key          INT,
    Appeal_Decision_Key     INT,
    Billing_Model_Key       INT,
    Cost_Center_Key         INT,
    Shrinkage_Key           INT
);

--============================================================
-- Generate Employee × Date Records
-- One record per Employee per Working Day
--============================================================

INSERT INTO #FactBase
(
    Date_Key,
    Employee_Key,
    Client_Key,
    Process_Key,
    Team_Key,
    Site_Key,
    Shift_Key,
    Policy_Key,
    Error_Code_Key,
    Appeal_Decision_Key,
    Billing_Model_Key,
    Cost_Center_Key,
    Shrinkage_Key
)

SELECT

    D.Date_Key,

    E.Employee_Key,
    E.Client_Key,
    E.Process_Key,
    E.Team_Key,
    E.Site_Key,

    (
    SELECT Shift_Key
    FROM
    (
        SELECT
            Shift_Key,
            ROW_NUMBER() OVER (ORDER BY Shift_Key) AS RN
        FROM dbo.Dim_Shift
    ) S
    WHERE S.RN = ((E.Employee_Key - 1) % 4) + 1
) AS Shift_Key,

    ((E.Employee_Key - 1) % 8) + 1            AS Policy_Key,

    ((ABS(CHECKSUM(NEWID())) % 8) + 1) AS Error_Code_Key,

    ((ABS(CHECKSUM(NEWID())) % 3) + 1) AS Appeal_Decision_Key,

    ((E.Client_Key - 1) % 4) + 1              AS Billing_Model_Key,

    CASE ((E.Site_Key - 7) % 6)
    WHEN 0 THEN 1
    WHEN 1 THEN 2
    WHEN 2 THEN 3
    WHEN 3 THEN 5
    WHEN 4 THEN 6
    ELSE 7
END AS Cost_Center_Key,

    ((ABS(CHECKSUM(NEWID())) % 2) + 1) AS Shrinkage_Key

FROM dbo.Dim_Date D

CROSS JOIN dbo.Dim_Employee E

WHERE D.Full_Date
BETWEEN
(
    SELECT MIN(Hire_Date)
    FROM dbo.Dim_Employee
)
AND
CAST(GETDATE() AS DATE)

AND D.Is_Weekend = 0;

PRINT 'Fact Base Dataset Generated Successfully.';

--============================================================
-- Validation 1
--============================================================

SELECT COUNT(*) AS Total_Base_Records
FROM #FactBase;

--============================================================
-- Validation 2
--============================================================

SELECT TOP (25) *
FROM #FactBase
ORDER BY Date_Key,
         Employee_Key;

--============================================================
-- Validation 3
--============================================================

SELECT
    COUNT(DISTINCT Employee_Key) AS Employees,
    COUNT(DISTINCT Date_Key)     AS Working_Days
FROM #FactBase;

PRINT '30A_Generate_Fact_Operations_Base completed successfully.';


/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 30B_Generate_Fact_Operations_Measures.sql
Purpose      : Generate Operational Measures
Author       : Tushar Mehta
Created Date : 06-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

SET NOCOUNT ON;

--============================================================
-- Remove Existing Temporary Table
--============================================================

IF OBJECT_ID('tempdb..#FactMeasures') IS NOT NULL
    DROP TABLE #FactMeasures;

--============================================================
-- Generate Measures
--============================================================

SELECT

    FB.Date_Key,
    FB.Employee_Key,
    FB.Client_Key,
    FB.Process_Key,
    FB.Team_Key,
    FB.Site_Key,
    FB.Shift_Key,
    FB.Policy_Key,
    FB.Error_Code_Key,
    FB.Appeal_Decision_Key,
    FB.Billing_Model_Key,
    FB.Cost_Center_Key,
    FB.Shrinkage_Key,

    ----------------------------------------------------------
    -- Operational Metrics
    ----------------------------------------------------------

    CASE
        WHEN FB.Employee_Key <= 72 THEN 180 + ABS(CHECKSUM(NEWID())) % 61
        WHEN FB.Employee_Key <= 90 THEN 120 + ABS(CHECKSUM(NEWID())) % 41
        WHEN FB.Employee_Key <= 97 THEN 70 + ABS(CHECKSUM(NEWID())) % 21
        ELSE 30 + ABS(CHECKSUM(NEWID())) % 21
    END
    AS Cases_Handled,

    CASE
        WHEN FB.Employee_Key <= 72 THEN 20 + ABS(CHECKSUM(NEWID())) % 15
        WHEN FB.Employee_Key <= 90 THEN 40 + ABS(CHECKSUM(NEWID())) % 21
        WHEN FB.Employee_Key <= 97 THEN 90 + ABS(CHECKSUM(NEWID())) % 31
        ELSE 140 + ABS(CHECKSUM(NEWID())) % 41
    END
    AS Cases_Reviewed,

    ABS(CHECKSUM(NEWID())) % 6
        AS Cases_Rejected,

    CAST(90 + (ABS(CHECKSUM(NEWID())) % 1000)/100.0 AS DECIMAL(5,2))
        AS QA_Score,

    CAST(4 + (ABS(CHECKSUM(NEWID())) % 500)/100.0 AS DECIMAL(6,2))
        AS AHT_Minutes,

    CAST(94 + (ABS(CHECKSUM(NEWID())) % 600)/100.0 AS DECIMAL(5,2))
        AS SLA_Compliance_Pct,

    CAST(6.5 + (ABS(CHECKSUM(NEWID())) % 150)/100.0 AS DECIMAL(5,2))
        AS Productive_Hours,

    CAST((ABS(CHECKSUM(NEWID())) % 80)/100.0 AS DECIMAL(5,2))
        AS Idle_Hours,

    CAST(1.00 AS DECIMAL(5,2))
        AS Break_Hours,

    CAST(7.5 + (ABS(CHECKSUM(NEWID())) % 60)/100.0 AS DECIMAL(5,2))
        AS Billable_Hours,

    CAST((ABS(CHECKSUM(NEWID())) % 200)/100.0 AS DECIMAL(5,2))
        AS Overtime_Hours,

    ABS(CHECKSUM(NEWID())) % 4
        AS Appeals_Received,

    ABS(CHECKSUM(NEWID())) % 2
        AS Appeals_Reversed

INTO #FactMeasures

FROM #FactBase FB;

--============================================================
-- Calculate Derived Measures
--============================================================

ALTER TABLE #FactMeasures
ADD

    Cases_Approved INT,

    Revenue_USD DECIMAL(12,2),

    Operating_Cost_USD DECIMAL(12,2);

UPDATE FM
SET

    Cases_Approved =
        Cases_Handled - Cases_Rejected,

    Revenue_USD =
        Billable_Hours * 25,

    Operating_Cost_USD =
        (Productive_Hours + Break_Hours + Overtime_Hours) * 12

FROM #FactMeasures FM;

PRINT 'Fact Measures Generated Successfully.';

--============================================================
-- Validation
--============================================================

SELECT COUNT(*) AS Total_Records
FROM #FactMeasures;

SELECT TOP (20) *
FROM #FactMeasures;

/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 30C_Load_Fact_Operations.sql
Purpose      : Load Fact_Operations
Author       : Tushar Mehta
Created Date : 06-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

SET NOCOUNT ON;

--============================================================
-- Remove Existing Data
--============================================================

TRUNCATE TABLE dbo.Fact_Operations;

--============================================================
-- Load Fact Table
--============================================================

INSERT INTO dbo.Fact_Operations
(
    Date_Key,
    Employee_Key,
    Client_Key,
    Process_Key,
    Team_Key,
    Site_Key,
    Shift_Key,
    Policy_Key,
    Error_Code_Key,
    Appeal_Decision_Key,
    Billing_Model_Key,
    Cost_Center_Key,
    Shrinkage_Key,

    Cases_Handled,
    Cases_Reviewed,
    Cases_Approved,
    Cases_Rejected,

    Appeals_Received,
    Appeals_Reversed,

    QA_Score,
    AHT_Minutes,
    SLA_Compliance_Pct,

    Productive_Hours,
    Idle_Hours,
    Break_Hours,
    Billable_Hours,
    Overtime_Hours,

    Revenue_USD,
    Operating_Cost_USD
)

SELECT

    Date_Key,
    Employee_Key,
    Client_Key,
    Process_Key,
    Team_Key,
    Site_Key,
    Shift_Key,
    Policy_Key,
    Error_Code_Key,
    Appeal_Decision_Key,
    Billing_Model_Key,
    Cost_Center_Key,
    Shrinkage_Key,

    Cases_Handled,
    Cases_Reviewed,
    Cases_Approved,
    Cases_Rejected,

    Appeals_Received,
    Appeals_Reversed,

    QA_Score,
    AHT_Minutes,
    SLA_Compliance_Pct,

    Productive_Hours,
    Idle_Hours,
    Break_Hours,
    Billable_Hours,
    Overtime_Hours,

    Revenue_USD,
    Operating_Cost_USD

FROM #FactMeasures;

PRINT 'Fact_Operations loaded successfully.';

--============================================================
-- Validation 1
--============================================================

SELECT
    COUNT(*) AS Total_Fact_Records
FROM dbo.Fact_Operations;

--============================================================
-- Validation 2
--============================================================

SELECT TOP (20)
       Fact_Operations_Key,
       Date_Key,
       Employee_Key,
       Client_Key,
       Process_Key,
       Team_Key,
       Site_Key,
       Shift_Key,
       Cases_Handled,
       Cases_Reviewed,
       Cases_Approved,
       Cases_Rejected,
       QA_Score,
       Revenue_USD,
       Operating_Cost_USD
FROM dbo.Fact_Operations
ORDER BY Fact_Operations_Key;

--============================================================
-- Validation 3
--============================================================

SELECT
    Employee_Key,
    COUNT(*) AS Records_Per_Employee
FROM dbo.Fact_Operations
GROUP BY Employee_Key
ORDER BY Employee_Key;

--============================================================
-- Validation 4
--============================================================

SELECT
    Date_Key,
    COUNT(*) AS Records_Per_Day
FROM dbo.Fact_Operations
GROUP BY Date_Key
ORDER BY Date_Key;

PRINT '30C_Load_Fact_Operations completed successfully.';

SELECT Policy_Key
FROM dbo.Dim_Policy
ORDER BY Policy_Key;

SELECT Appeal_Decision_Key
FROM dbo.Dim_Appeal_Decision
ORDER BY Appeal_Decision_Key;

SELECT Billing_Model_Key
FROM dbo.Dim_Billing_Model
ORDER BY Billing_Model_Key;

SELECT Cost_Center_Key
FROM dbo.Dim_Cost_Center
ORDER BY Cost_Center_Key;

SELECT Shrinkage_Key
FROM dbo.Dim_Shrinkage
ORDER BY Shrinkage_Key;