USE Enterprise_Trust_Safety_DWH;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;

PRINT '============================================================';
PRINT 'ENTERPRISE TRUST & SAFETY ANALYTICS';
PRINT 'CONSOLIDATED BACKEND GAP REMEDIATION';
PRINT '============================================================';


/* ============================================================
   1. EXECUTIVE / OPERATIONS BACKEND ATTRIBUTES
   ============================================================ */

PRINT 'Adding Executive / Operations fields...';


/* Case_Key
   Reuses the existing Fact_Operations_Key as the case identifier.
*/
IF COL_LENGTH('dbo.Fact_Operations', 'Case_Key') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Operations
    ADD Case_Key BIGINT NULL;
END;


/* Handling_Time_Seconds
   Derived from the existing AHT_Minutes.
*/
IF COL_LENGTH('dbo.Fact_Operations', 'Handling_Time_Seconds') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Operations
    ADD Handling_Time_Seconds DECIMAL(18,2) NULL;
END;


/* Status
   Alias of the already-created Case_Status.
*/
IF COL_LENGTH('dbo.Fact_Operations', 'Status') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Operations
    ADD Status VARCHAR(30) NULL;
END;


/* Is_Terminal_State_Flag
   Closed = terminal state.
*/
IF COL_LENGTH('dbo.Fact_Operations', 'Is_Terminal_State_Flag') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Operations
    ADD Is_Terminal_State_Flag BIT NULL;
END;


/* Populate Operations fields */

UPDATE dbo.Fact_Operations
SET
    Case_Key =
        Fact_Operations_Key,

    Handling_Time_Seconds =
        ROUND(AHT_Minutes * 60.0, 2),

    Status =
        Case_Status,

    Is_Terminal_State_Flag =
        CASE
            WHEN Case_Status = 'Closed' THEN 1
            ELSE 0
        END
WHERE
    Case_Key IS NULL
    OR Handling_Time_Seconds IS NULL
    OR Status IS NULL
    OR Is_Terminal_State_Flag IS NULL;


/* ============================================================
   2. QUALITY BACKEND ATTRIBUTES
   ============================================================ */

PRINT 'Adding Quality fields...';


/* Points_Possible
   Scenario/documentation basis:
   QA score is treated as a percentage out of 100.
*/
IF COL_LENGTH('dbo.Fact_QA', 'Points_Possible') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_QA
    ADD Points_Possible DECIMAL(10,2) NULL;
END;


/* Points_Scored
   Existing QA_Score is already expressed on a 0-100 basis.
*/
IF COL_LENGTH('dbo.Fact_QA', 'Points_Scored') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_QA
    ADD Points_Scored DECIMAL(10,2) NULL;
END;


/* Disputed_Flag
   Derived project-model attribute.
*/
IF COL_LENGTH('dbo.Fact_QA', 'Disputed_Flag') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_QA
    ADD Disputed_Flag BIT NULL;
END;


/* Overturned_Flag
   Derived project-model attribute.
*/
IF COL_LENGTH('dbo.Fact_QA', 'Overturned_Flag') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_QA
    ADD Overturned_Flag BIT NULL;
END;


/* Error_Severity
   Add to the error-code dimension so Fatal / Non-Fatal analysis
   can be performed through the existing Dim_Error_Code relationship.
*/
IF COL_LENGTH('dbo.Dim_Error_Code', 'Error_Severity') IS NULL
BEGIN
    ALTER TABLE dbo.Dim_Error_Code
    ADD Error_Severity VARCHAR(20) NULL;
END;


/* Populate QA scoring */

UPDATE dbo.Fact_QA
SET
    Points_Possible = 100,
    Points_Scored =
        CASE
            WHEN QA_Score IS NULL THEN NULL
            WHEN QA_Score < 0 THEN 0
            WHEN QA_Score > 100 THEN 100
            ELSE QA_Score
        END
WHERE
    Points_Possible IS NULL
    OR Points_Scored IS NULL;


/*
   Dispute / overturn scenario logic.

   This is NOT original source-system data.
   It is deterministic project-model data.

   Every 20th audit = disputed.
   Of disputed audits, every second disputed audit = overturned.
*/

UPDATE dbo.Fact_QA
SET
    Disputed_Flag =
        CASE
            WHEN QA_Key % 20 = 0 THEN 1
            ELSE 0
        END,

    Overturned_Flag =
        CASE
            WHEN QA_Key % 20 = 0
                 AND QA_Key % 40 = 0
            THEN 1
            ELSE 0
        END
WHERE
    Disputed_Flag IS NULL
    OR Overturned_Flag IS NULL;


/*
   Error severity.

   Deterministic classification using existing Error_Code_Key.

   Every 5th error code is treated as Fatal.
   Remaining codes are Non-Fatal.

   This is explicitly a project-model classification because
   the original schema did not contain severity.
*/

UPDATE dbo.Dim_Error_Code
SET
    Error_Severity =
        CASE
            WHEN Error_Code_Key % 5 = 0 THEN 'Fatal'
            ELSE 'Non-Fatal'
        END
WHERE
    Error_Severity IS NULL;


/* ============================================================
   3. WORKFORCE BACKEND ATTRIBUTES
   ============================================================ */

PRINT 'Adding Workforce fields...';


IF COL_LENGTH('dbo.Fact_Workforce', 'Scheduled_Employees') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Workforce
    ADD Scheduled_Employees INT NULL;
END;


IF COL_LENGTH('dbo.Fact_Workforce', 'Absent_Employees') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Workforce
    ADD Absent_Employees INT NULL;
END;


/*
   Scheduled Employees

   Workforce Hours are converted into an approximate headcount
   using an 8-hour workday assumption.

   This is a project-model calculation.
*/

UPDATE dbo.Fact_Workforce
SET
    Scheduled_Employees =
        CASE
            WHEN Hours IS NULL OR Hours <= 0 THEN 0
            ELSE CEILING(Hours / 8.0)
        END
WHERE
    Scheduled_Employees IS NULL;


/*
   Absent Employees

   Deterministic project-model assumption:
   approximately 5% of scheduled employees.

   The value is capped so it can never exceed scheduled employees.
*/

UPDATE dbo.Fact_Workforce
SET
    Absent_Employees =
        CASE
            WHEN Scheduled_Employees <= 0 THEN 0
            ELSE
                CASE
                    WHEN CEILING(Scheduled_Employees * 0.05)
                         > Scheduled_Employees
                    THEN Scheduled_Employees
                    ELSE CEILING(Scheduled_Employees * 0.05)
                END
        END
WHERE
    Absent_Employees IS NULL;


/* ============================================================
   4. APPEALS BACKEND ATTRIBUTES
   ============================================================ */

PRINT 'Adding Appeals fields...';


/* Status */

IF COL_LENGTH('dbo.Fact_Appeals', 'Status') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Appeals
    ADD Status VARCHAR(30) NULL;
END;


/* SLA Target */

IF COL_LENGTH('dbo.Fact_Appeals', 'SLA_Target_Hours') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Appeals
    ADD SLA_Target_Hours DECIMAL(10,2) NULL;
END;


/* Decision_Name in Appeal Decision dimension */

IF COL_LENGTH('dbo.Dim_Appeal_Decision', 'Decision_Name') IS NULL
BEGIN
    ALTER TABLE dbo.Dim_Appeal_Decision
    ADD Decision_Name VARCHAR(50) NULL;
END;


/*
   Appeal Status

   Deterministic project-model status based on Appeal_Key.

   70% Resolved
   20% Pending
   10% Escalated
*/

UPDATE dbo.Fact_Appeals
SET
    Status =
        CASE
            WHEN Appeal_Key % 10 < 7 THEN 'Resolved'
            WHEN Appeal_Key % 10 < 9 THEN 'Pending'
            ELSE 'Escalated'
        END
WHERE
    Status IS NULL;


/*
   Appeal SLA target.

   Standard project-model target = 48 hours.
*/

UPDATE dbo.Fact_Appeals
SET
    SLA_Target_Hours = 48
WHERE
    SLA_Target_Hours IS NULL;


/*
   Appeal decision classification.

   Existing decision key is used to create a deterministic
   decision classification.

   This is project-model data, not original source-system
   decision text.
*/

UPDATE dbo.Dim_Appeal_Decision
SET
    Decision_Name =
        CASE
            WHEN Appeal_Decision_Key % 3 = 0 THEN 'Overturned'
            WHEN Appeal_Decision_Key % 3 = 1 THEN 'Upheld'
            ELSE 'Partially Overturned'
        END
WHERE
    Decision_Name IS NULL;


/* ============================================================
   5. EXECUTIVE REVENUE ALIAS
   ============================================================ */

PRINT 'Adding Executive Revenue field...';


/*
   Estimated_Revenue is an analytical alias of the existing
   Revenue_USD.

   We are NOT creating a second independent revenue value.
*/

IF COL_LENGTH('dbo.Fact_Finance', 'Estimated_Revenue') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Finance
    ADD Estimated_Revenue DECIMAL(18,2) NULL;
END;


UPDATE dbo.Fact_Finance
SET
    Estimated_Revenue = Revenue_USD
WHERE
    Estimated_Revenue IS NULL;


/* ============================================================
   6. COMMIT
   ============================================================ */

COMMIT TRANSACTION;

PRINT '============================================================';
PRINT 'BACKEND REMEDIATION COMPLETED SUCCESSFULLY';
PRINT '============================================================';
GO


/* ============================================================
   7. FINAL VALIDATION
   ============================================================ */

SELECT
    'Fact_Operations' AS Table_Name,
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN Case_Key IS NULL THEN 1 ELSE 0 END) AS Null_Case_Key,
    SUM(CASE WHEN Handling_Time_Seconds IS NULL THEN 1 ELSE 0 END) AS Null_Handling_Time,
    SUM(CASE WHEN Status IS NULL THEN 1 ELSE 0 END) AS Null_Status,
    SUM(CASE WHEN Is_Terminal_State_Flag IS NULL THEN 1 ELSE 0 END) AS Null_Terminal_Flag
FROM dbo.Fact_Operations;


SELECT
    'Fact_QA' AS Table_Name,
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN Points_Possible IS NULL THEN 1 ELSE 0 END) AS Null_Points_Possible,
    SUM(CASE WHEN Points_Scored IS NULL THEN 1 ELSE 0 END) AS Null_Points_Scored,
    SUM(CASE WHEN Disputed_Flag IS NULL THEN 1 ELSE 0 END) AS Null_Disputed,
    SUM(CASE WHEN Overturned_Flag IS NULL THEN 1 ELSE 0 END) AS Null_Overturned
FROM dbo.Fact_QA;


SELECT
    'Dim_Error_Code' AS Table_Name,
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN Error_Severity IS NULL THEN 1 ELSE 0 END) AS Null_Error_Severity
FROM dbo.Dim_Error_Code;


SELECT
    'Fact_Workforce' AS Table_Name,
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN Scheduled_Employees IS NULL THEN 1 ELSE 0 END) AS Null_Scheduled_Employees,
    SUM(CASE WHEN Absent_Employees IS NULL THEN 1 ELSE 0 END) AS Null_Absent_Employees
FROM dbo.Fact_Workforce;


SELECT
    'Fact_Appeals' AS Table_Name,
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN Status IS NULL THEN 1 ELSE 0 END) AS Null_Status,
    SUM(CASE WHEN SLA_Target_Hours IS NULL THEN 1 ELSE 0 END) AS Null_SLA_Target
FROM dbo.Fact_Appeals;


SELECT
    'Dim_Appeal_Decision' AS Table_Name,
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN Decision_Name IS NULL THEN 1 ELSE 0 END) AS Null_Decision_Name
FROM dbo.Dim_Appeal_Decision;


SELECT
    'Fact_Finance' AS Table_Name,
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN Estimated_Revenue IS NULL THEN 1 ELSE 0 END) AS Null_Estimated_Revenue
FROM dbo.Fact_Finance;



USE Enterprise_Trust_Safety_DWH;
GO

/* ============================================================
   CREATE MISSING BACKEND COLUMNS
   ============================================================ */

/* Fact_Operations */

IF COL_LENGTH('dbo.Fact_Operations', 'Case_Key') IS NULL
    ALTER TABLE dbo.Fact_Operations ADD Case_Key BIGINT NULL;

IF COL_LENGTH('dbo.Fact_Operations', 'Handling_Time_Seconds') IS NULL
    ALTER TABLE dbo.Fact_Operations ADD Handling_Time_Seconds DECIMAL(18,2) NULL;

IF COL_LENGTH('dbo.Fact_Operations', 'Status') IS NULL
    ALTER TABLE dbo.Fact_Operations ADD Status VARCHAR(30) NULL;

IF COL_LENGTH('dbo.Fact_Operations', 'Is_Terminal_State_Flag') IS NULL
    ALTER TABLE dbo.Fact_Operations ADD Is_Terminal_State_Flag BIT NULL;


/* Fact_QA */

IF COL_LENGTH('dbo.Fact_QA', 'Points_Possible') IS NULL
    ALTER TABLE dbo.Fact_QA ADD Points_Possible DECIMAL(10,2) NULL;

IF COL_LENGTH('dbo.Fact_QA', 'Points_Scored') IS NULL
    ALTER TABLE dbo.Fact_QA ADD Points_Scored DECIMAL(10,2) NULL;

IF COL_LENGTH('dbo.Fact_QA', 'Disputed_Flag') IS NULL
    ALTER TABLE dbo.Fact_QA ADD Disputed_Flag BIT NULL;

IF COL_LENGTH('dbo.Fact_QA', 'Overturned_Flag') IS NULL
    ALTER TABLE dbo.Fact_QA ADD Overturned_Flag BIT NULL;


/* Dim_Error_Code */

IF COL_LENGTH('dbo.Dim_Error_Code', 'Error_Severity') IS NULL
    ALTER TABLE dbo.Dim_Error_Code ADD Error_Severity VARCHAR(20) NULL;


/* Fact_Workforce */

IF COL_LENGTH('dbo.Fact_Workforce', 'Scheduled_Employees') IS NULL
    ALTER TABLE dbo.Fact_Workforce ADD Scheduled_Employees INT NULL;

IF COL_LENGTH('dbo.Fact_Workforce', 'Absent_Employees') IS NULL
    ALTER TABLE dbo.Fact_Workforce ADD Absent_Employees INT NULL;


/* Fact_Appeals */

IF COL_LENGTH('dbo.Fact_Appeals', 'Status') IS NULL
    ALTER TABLE dbo.Fact_Appeals ADD Status VARCHAR(30) NULL;

IF COL_LENGTH('dbo.Fact_Appeals', 'SLA_Target_Hours') IS NULL
    ALTER TABLE dbo.Fact_Appeals ADD SLA_Target_Hours DECIMAL(10,2) NULL;


/* Dim_Appeal_Decision */

IF COL_LENGTH('dbo.Dim_Appeal_Decision', 'Decision_Name') IS NULL
    ALTER TABLE dbo.Dim_Appeal_Decision ADD Decision_Name VARCHAR(50) NULL;


/* Fact_Finance */

IF COL_LENGTH('dbo.Fact_Finance', 'Estimated_Revenue') IS NULL
    ALTER TABLE dbo.Fact_Finance ADD Estimated_Revenue DECIMAL(18,2) NULL;

GO

PRINT 'Column creation stage completed successfully.';

USE Enterprise_Trust_Safety_DWH;
GO

/* ============================================================
   VALIDATE NEW BACKEND VALUES
   ============================================================ */

/* 1. Operations */
SELECT
    COUNT(*) AS Total_Rows,
    MIN(AHT_Minutes) AS Min_AHT_Minutes,
    MAX(AHT_Minutes) AS Max_AHT_Minutes,
    MIN(Handling_Time_Seconds) AS Min_Handling_Seconds,
    MAX(Handling_Time_Seconds) AS Max_Handling_Seconds,
    SUM(CASE WHEN Status = 'Closed' THEN 1 ELSE 0 END) AS Closed_Cases,
    SUM(CASE WHEN Is_Terminal_State_Flag = 1 THEN 1 ELSE 0 END) AS Terminal_Cases
FROM dbo.Fact_Operations;


/* 2. QA */
SELECT
    COUNT(*) AS Total_Audits,
    MIN(Points_Scored) AS Min_Points_Scored,
    MAX(Points_Scored) AS Max_Points_Scored,
    MIN(Points_Possible) AS Min_Points_Possible,
    MAX(Points_Possible) AS Max_Points_Possible,
    SUM(CASE WHEN Disputed_Flag = 1 THEN 1 ELSE 0 END) AS Disputed_Audits,
    SUM(CASE WHEN Overturned_Flag = 1 THEN 1 ELSE 0 END) AS Overturned_Audits
FROM dbo.Fact_QA;


/* 3. Error Severity */
SELECT
    Error_Severity,
    COUNT(*) AS Error_Code_Count
FROM dbo.Dim_Error_Code
GROUP BY Error_Severity;


/* 4. Workforce */
SELECT
    COUNT(*) AS Total_Rows,
    MIN(Scheduled_Employees) AS Min_Scheduled_Employees,
    MAX(Scheduled_Employees) AS Max_Scheduled_Employees,
    MIN(Absent_Employees) AS Min_Absent_Employees,
    MAX(Absent_Employees) AS Max_Absent_Employees,
    SUM(Scheduled_Employees) AS Total_Scheduled_Employees,
    SUM(Absent_Employees) AS Total_Absent_Employees
FROM dbo.Fact_Workforce;


/* 5. Appeals */
SELECT
    Status,
    COUNT(*) AS Appeal_Count,
    MIN(SLA_Target_Hours) AS Min_SLA_Target,
    MAX(SLA_Target_Hours) AS Max_SLA_Target
FROM dbo.Fact_Appeals
GROUP BY Status;


/* 6. Appeal Decisions */
SELECT
    Decision_Name,
    COUNT(*) AS Decision_Count
FROM dbo.Dim_Appeal_Decision
GROUP BY Decision_Name;


/* 7. Finance */
SELECT
    COUNT(*) AS Total_Rows,
    SUM(Revenue_USD) AS Existing_Revenue,
    SUM(Estimated_Revenue) AS Estimated_Revenue,
    MIN(Estimated_Revenue) AS Min_Estimated_Revenue,
    MAX(Estimated_Revenue) AS Max_Estimated_Revenue
FROM dbo.Fact_Finance;



SELECT
    COUNT(*) AS Total_Rows,
    MIN(Hours) AS Min_Hours,
    MAX(Hours) AS Max_Hours,
    AVG(Hours) AS Avg_Hours,
    SUM(Hours) AS Total_Hours,
    MIN(Scheduled_Employees) AS Min_Scheduled,
    MAX(Scheduled_Employees) AS Max_Scheduled,
    AVG(CAST(Scheduled_Employees AS DECIMAL(18,2))) AS Avg_Scheduled
FROM dbo.Fact_Workforce;


USE Enterprise_Trust_Safety_DWH;
GO

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'Dim_Employee'
ORDER BY ORDINAL_POSITION;

USE Enterprise_Trust_Safety_DWH;
GO

SELECT
    COUNT(*) AS Workforce_Rows,
    COUNT(DISTINCT Shift_Key) AS Workforce_Shifts,
    COUNT(DISTINCT Shrinkage_Key) AS Workforce_Shrinkage_Types
FROM dbo.Fact_Workforce;

SELECT
    COUNT(*) AS Employees,
    COUNT(DISTINCT Client_Key) AS Clients,
    COUNT(DISTINCT Process_Key) AS Processes,
    COUNT(DISTINCT Team_Key) AS Teams,
    COUNT(DISTINCT Site_Key) AS Sites,
    SUM(CASE WHEN Employment_Status = 'Active' THEN 1 ELSE 0 END) AS Active_Employees,
    SUM(CASE WHEN Employment_Status <> 'Active' OR Employment_Status IS NULL THEN 1 ELSE 0 END) AS Non_Active_Employees
FROM dbo.Dim_Employee;