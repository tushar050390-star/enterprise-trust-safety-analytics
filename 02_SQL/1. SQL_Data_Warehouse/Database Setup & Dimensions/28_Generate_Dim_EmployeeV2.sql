/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 28_Generate_Dim_EmployeeV2.sql
Section      : Campaign Mapping
Purpose      : Map valid business combinations for Employee Generation
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

SET NOCOUNT ON;

--============================================================
-- Remove Existing Temporary Mapping
--============================================================

IF OBJECT_ID('tempdb..#CampaignMapping') IS NOT NULL
    DROP TABLE #CampaignMapping;

--============================================================
-- Create Temporary Campaign Mapping
--============================================================

CREATE TABLE #CampaignMapping
(
    Campaign_ID     INT IDENTITY(1,1),
    Client_Name     VARCHAR(100) NOT NULL,
    Process_Name    VARCHAR(100) NOT NULL,
    Team_Name       VARCHAR(100) NOT NULL,
    Site_Name       VARCHAR(100) NOT NULL
);

--============================================================
-- Insert Business Mapping
--============================================================

INSERT INTO #CampaignMapping
(
    Client_Name,
    Process_Name,
    Team_Name,
    Site_Name
)
VALUES
('Apex Digital','Content Moderation','Team Alpha','Bengaluru'),
('Nova Media','Appeals','Team Bravo','Hyderabad'),
('Vertex AI','Fraud Investigation','Team Charlie','Mohali'),
('Orion Solutions','Risk Operations','Team Delta','Indore'),
('Quantum Platforms','Trust & Safety','Team Falcon','Austin'),
('Horizon Tech','Customer Support','Team Phoenix','New York'),
('Pinnacle Services','Payments Review','Team Titan','Manila'),
('Nimbus Interactive','Identity Verification','Team Orion','Cebu');

--============================================================
-- Resolve Business Names to Surrogate Keys
--============================================================

IF OBJECT_ID('tempdb..#CampaignResolved') IS NOT NULL
    DROP TABLE #CampaignResolved;

SELECT
    CM.Campaign_ID,
    C.Client_Key,
    C.Client_Name,
    P.Process_Key,
    P.Process_Name,
    T.Team_Key,
    T.Team_Name,
    S.Site_Key,
    S.Site_Name
INTO #CampaignResolved
FROM #CampaignMapping CM
INNER JOIN dbo.Dim_Client C
    ON CM.Client_Name = C.Client_Name
INNER JOIN dbo.Dim_Process P
    ON CM.Process_Name = P.Process_Name
INNER JOIN dbo.Dim_Team T
    ON CM.Team_Name = T.Team_Name
INNER JOIN dbo.Dim_Site S
    ON CM.Site_Name = S.Site_Name;

--============================================================
-- Validation
--============================================================

SELECT *
FROM #CampaignResolved
ORDER BY Campaign_ID;

SELECT TOP (5) *
FROM dbo.Numbers;

/******************************************************************************
Section      : Step 2 - Generate Employee Master Data
Purpose      : Generate 100 Employees using Campaign Mapping
******************************************************************************/

--============================================================
-- Number of Employees to Generate
--============================================================

DECLARE @EmployeeCount INT = 100;

--============================================================
-- Employee Name Pool
--============================================================

IF OBJECT_ID('tempdb..#EmployeeNames') IS NOT NULL
    DROP TABLE #EmployeeNames;

CREATE TABLE #EmployeeNames
(
    Name_ID INT IDENTITY(1,1),
    Employee_Name VARCHAR(100)
);

INSERT INTO #EmployeeNames(Employee_Name)
VALUES
('Rahul Sharma'),
('Priya Singh'),
('Amit Verma'),
('Neha Gupta'),
('Rohit Kumar'),
('Anjali Mehta'),
('Vikas Patel'),
('Sneha Joshi'),
('Arjun Nair'),
('Pooja Shah'),
('Karan Malhotra'),
('Deepak Yadav'),
('Ritika Jain'),
('Nikhil Kapoor'),
('Swati Mishra'),
('Harsh Agarwal'),
('Komal Sinha'),
('Abhishek Tiwari'),
('Megha Chawla'),
('Sandeep Reddy');

--============================================================
-- Employee Seed
--============================================================

IF OBJECT_ID('tempdb..#EmployeeSeed') IS NOT NULL
    DROP TABLE #EmployeeSeed;

;WITH EmployeeSeed AS
(
    SELECT TOP (@EmployeeCount)
        ROW_NUMBER() OVER (ORDER BY Number) AS Employee_No
    FROM dbo.Numbers
)

SELECT
    ES.Employee_No,

    CONCAT
    (
        'EMP',
        RIGHT('0000' + CAST(ES.Employee_No AS VARCHAR(4)),4)
    ) AS Employee_ID,

    EN.Employee_Name,

    CASE
        WHEN ES.Employee_No <= 22 THEN 1
        WHEN ES.Employee_No <= 40 THEN 2
        WHEN ES.Employee_No <= 56 THEN 3
        WHEN ES.Employee_No <= 70 THEN 4
        WHEN ES.Employee_No <= 82 THEN 5
        WHEN ES.Employee_No <= 90 THEN 6
        WHEN ES.Employee_No <= 96 THEN 7
        ELSE 8
    END AS Campaign_ID,

    CASE
        WHEN ES.Employee_No <= 72 THEN 'Associate'
        WHEN ES.Employee_No <= 90 THEN 'Senior Associate'
        WHEN ES.Employee_No <= 97 THEN 'SME'
        ELSE 'Team Leader'
    END AS Designation,

    DATEADD
    (
        DAY,
        ABS(CHECKSUM(NEWID())) % 1825,
        CAST('2021-01-01' AS DATE)
    ) AS Hire_Date,

    CASE
        WHEN ES.Employee_No <= 95 THEN 'Active'
        ELSE 'Inactive'
    END AS Employment_Status

INTO #EmployeeSeed

FROM EmployeeSeed ES

INNER JOIN #EmployeeNames EN
ON EN.Name_ID = ((ES.Employee_No - 1) % 20) + 1;

--============================================================
-- Validation
--============================================================

SELECT *
FROM #EmployeeSeed
ORDER BY Employee_No;

/******************************************************************************
Section      : Step 3 - Resolve Campaign Keys for Employees
Purpose      : Attach Client, Process, Team and Site Keys to Employees
******************************************************************************/

--============================================================
-- Create Final Employee Dataset
--============================================================

IF OBJECT_ID('tempdb..#EmployeeFinal') IS NOT NULL
    DROP TABLE #EmployeeFinal;

SELECT

    ES.Employee_ID,
    ES.Employee_Name,

    CR.Client_Key,
    CR.Process_Key,
    CR.Team_Key,
    CR.Site_Key,

    ES.Designation,
    ES.Hire_Date,
    ES.Employment_Status

INTO #EmployeeFinal

FROM #EmployeeSeed ES

INNER JOIN #CampaignResolved CR
    ON ES.Campaign_ID = CR.Campaign_ID;

--============================================================
-- Validation
--============================================================

SELECT *
FROM #EmployeeFinal
ORDER BY Employee_ID;

--============================================================
-- Validation 2
--============================================================

SELECT
    COUNT(*) AS Total_Employees
FROM #EmployeeFinal;

--============================================================
-- Validation 3
--============================================================

SELECT
    Client_Key,
    COUNT(*) AS Employee_Count
FROM #EmployeeFinal
GROUP BY Client_Key
ORDER BY Client_Key;

--============================================================
-- Validation 4
--============================================================

SELECT
    Designation,
    COUNT(*) AS Employee_Count
FROM #EmployeeFinal
GROUP BY Designation;

--============================================================
-- Validation 5
--============================================================

SELECT
    Employment_Status,
    COUNT(*) AS Employee_Count
FROM #EmployeeFinal
GROUP BY Employment_Status;

/******************************************************************************
Section      : Step 4 - Load Dim_Employee
Purpose      : Insert Employee Records into Dim_Employee
******************************************************************************/

--============================================================
-- Prevent Duplicate Load
--============================================================

TRUNCATE TABLE dbo.Dim_Employee;

--============================================================
-- Load Employee Dimension
--============================================================

INSERT INTO dbo.Dim_Employee
(
    Employee_ID,
    Employee_Name,
    Client_Key,
    Process_Key,
    Team_Key,
    Site_Key,
    Designation,
    Hire_Date,
    Employment_Status
)
SELECT
    Employee_ID,
    Employee_Name,
    Client_Key,
    Process_Key,
    Team_Key,
    Site_Key,
    Designation,
    Hire_Date,
    Employment_Status
FROM #EmployeeFinal
ORDER BY Employee_ID;

PRINT 'Dim_Employee loaded successfully.';

--============================================================
-- Validation 1
--============================================================

SELECT
    COUNT(*) AS Total_Employees
FROM dbo.Dim_Employee;

--============================================================
-- Validation 2
--============================================================

SELECT TOP (20)
       Employee_Key,
       Employee_ID,
       Employee_Name,
       Client_Key,
       Process_Key,
       Team_Key,
       Site_Key,
       Designation,
       Hire_Date,
       Employment_Status,
       Created_Date,
       Modified_Date
FROM dbo.Dim_Employee
ORDER BY Employee_Key;

--============================================================
-- Validation 3
--============================================================

SELECT
    Designation,
    COUNT(*) AS Employee_Count
FROM dbo.Dim_Employee
GROUP BY Designation;

--============================================================
-- Validation 4
--============================================================

SELECT
    Employment_Status,
    COUNT(*) AS Employee_Count
FROM dbo.Dim_Employee
GROUP BY Employment_Status;

--============================================================
-- Validation 5
--============================================================

SELECT
    Client_Key,
    COUNT(*) AS Employee_Count
FROM dbo.Dim_Employee
GROUP BY Client_Key
ORDER BY Client_Key;

--============================================================
-- Validation 6
--============================================================

SELECT
    Site_Key,
    COUNT(*) AS Employee_Count
FROM dbo.Dim_Employee
GROUP BY Site_Key
ORDER BY Site_Key;

--============================================================
-- Cleanup
--============================================================

DROP TABLE #EmployeeNames;
DROP TABLE #EmployeeSeed;
DROP TABLE #EmployeeFinal;
DROP TABLE #CampaignResolved;
DROP TABLE #CampaignMapping;

PRINT '28_Generate_Dim_Employee.sql completed successfully.';