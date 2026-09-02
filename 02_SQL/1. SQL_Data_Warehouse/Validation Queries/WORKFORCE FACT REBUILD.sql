USE Enterprise_Trust_Safety_DWH;
GO

/* ============================================================
   WORKFORCE FACT REBUILD
   Employee-level daily workforce scenario
   ============================================================ */

SET NOCOUNT ON;

PRINT 'Starting Workforce rebuild...';


/* ============================================================
   STEP 1: ADD REQUIRED COLUMNS IF MISSING
   ============================================================ */

IF COL_LENGTH('dbo.Fact_Workforce', 'Employee_Key') IS NULL
    ALTER TABLE dbo.Fact_Workforce ADD Employee_Key INT NULL;

IF COL_LENGTH('dbo.Fact_Workforce', 'Scheduled_Flag') IS NULL
    ALTER TABLE dbo.Fact_Workforce ADD Scheduled_Flag BIT NULL;

IF COL_LENGTH('dbo.Fact_Workforce', 'Absent_Flag') IS NULL
    ALTER TABLE dbo.Fact_Workforce ADD Absent_Flag BIT NULL;

IF COL_LENGTH('dbo.Fact_Workforce', 'Handle_Hours') IS NULL
    ALTER TABLE dbo.Fact_Workforce ADD Handle_Hours DECIMAL(18,2) NULL;

IF COL_LENGTH('dbo.Fact_Workforce', 'Logged_Hours') IS NULL
    ALTER TABLE dbo.Fact_Workforce ADD Logged_Hours DECIMAL(18,2) NULL;

IF COL_LENGTH('dbo.Fact_Workforce', 'Adherence_Hours') IS NULL
    ALTER TABLE dbo.Fact_Workforce ADD Adherence_Hours DECIMAL(18,2) NULL;

IF COL_LENGTH('dbo.Fact_Workforce', 'Scheduled_Hours') IS NULL
    ALTER TABLE dbo.Fact_Workforce ADD Scheduled_Hours DECIMAL(18,2) NULL;

IF COL_LENGTH('dbo.Fact_Workforce', 'Actual_Headcount') IS NULL
    ALTER TABLE dbo.Fact_Workforce ADD Actual_Headcount INT NULL;

IF COL_LENGTH('dbo.Fact_Workforce', 'Required_Headcount') IS NULL
    ALTER TABLE dbo.Fact_Workforce ADD Required_Headcount INT NULL;


/* ============================================================
   STEP 2: DETERMINE ACTUAL REPORTING PERIOD
   FROM FACT_OPERATIONS
   ============================================================ */

DECLARE @MinReportingDate DATE;
DECLARE @MaxReportingDate DATE;

SELECT
    @MinReportingDate = MIN(D.Full_Date),
    @MaxReportingDate = MAX(D.Full_Date)
FROM dbo.Fact_Operations O
INNER JOIN dbo.Dim_Date D
    ON O.Date_Key = D.Date_Key;

PRINT 'Reporting period: '
    + CONVERT(VARCHAR(10), @MinReportingDate, 120)
    + ' to '
    + CONVERT(VARCHAR(10), @MaxReportingDate, 120);


/* ============================================================
   STEP 3: BUILD NEW WORKFORCE DATA IN TEMP TABLE
   ============================================================ */

IF OBJECT_ID('tempdb..#NewWorkforce') IS NOT NULL
    DROP TABLE #NewWorkforce;

CREATE TABLE #NewWorkforce
(
    Workforce_Key BIGINT IDENTITY(1,1),
    Employee_Key INT,
    Date_Key INT,
    Shift_Key INT,
    Shrinkage_Key INT,
    Hours DECIMAL(18,2),
    Scheduled_Flag BIT,
    Absent_Flag BIT,
    Handle_Hours DECIMAL(18,2),
    Logged_Hours DECIMAL(18,2),
    Adherence_Hours DECIMAL(18,2),
    Scheduled_Hours DECIMAL(18,2),
    Actual_Headcount INT,
    Required_Headcount INT
);


/* ============================================================
   STEP 4: GENERATE EMPLOYEE x DATE WORKFORCE RECORDS
   ============================================================ */

INSERT INTO #NewWorkforce
(
    Employee_Key,
    Date_Key,
    Shift_Key,
    Shrinkage_Key,
    Hours,
    Scheduled_Flag,
    Absent_Flag,
    Handle_Hours,
    Logged_Hours,
    Adherence_Hours,
    Scheduled_Hours,
    Actual_Headcount,
    Required_Headcount
)
SELECT
    E.Employee_Key,

    D.Date_Key,

    /* Distribute employees across the 4 available shifts */
    CASE
        WHEN ((E.Employee_Key + D.Date_Key) % 4) = 0 THEN 2
        WHEN ((E.Employee_Key + D.Date_Key) % 4) = 1 THEN 3
        WHEN ((E.Employee_Key + D.Date_Key) % 4) = 2 THEN 4
        ELSE 5
    END AS Shift_Key,

    /* Approximately 4% unplanned shrinkage */
    CASE
        WHEN ABS(CHECKSUM(CONCAT(E.Employee_Key, '-', D.Date_Key))) % 100 < 4
            THEN 2
        ELSE 1
    END AS Shrinkage_Key,

    /* Scheduled hours based on shift */
    CASE
        WHEN ((E.Employee_Key + D.Date_Key) % 4) = 3 THEN 10.00
        ELSE 8.00
    END AS Hours,

    /* Every active employee is scheduled */
    CAST(1 AS BIT) AS Scheduled_Flag,

    /* Approximately 4% absenteeism */
    CASE
        WHEN ABS(CHECKSUM(CONCAT(E.Employee_Key, '-', D.Date_Key))) % 100 < 4
            THEN CAST(1 AS BIT)
        ELSE CAST(0 AS BIT)
    END AS Absent_Flag,

    /* Productive/handle hours for present employees */
    CASE
        WHEN ABS(CHECKSUM(CONCAT(E.Employee_Key, '-', D.Date_Key))) % 100 < 4
            THEN 0.00
        WHEN ((E.Employee_Key + D.Date_Key) % 4) = 3
            THEN 8.50
        ELSE 6.80
    END AS Handle_Hours,

    /* Logged hours */
    CASE
        WHEN ABS(CHECKSUM(CONCAT(E.Employee_Key, '-', D.Date_Key))) % 100 < 4
            THEN 0.00
        WHEN ((E.Employee_Key + D.Date_Key) % 4) = 3
            THEN 10.00
        ELSE 8.00
    END AS Logged_Hours,

    /* Schedule adherence hours */
    CASE
        WHEN ABS(CHECKSUM(CONCAT(E.Employee_Key, '-', D.Date_Key))) % 100 < 4
            THEN 0.00
        WHEN ((E.Employee_Key + D.Date_Key) % 4) = 3
            THEN 9.60
        ELSE 7.68
    END AS Adherence_Hours,

    /* Scheduled hours */
    CASE
        WHEN ((E.Employee_Key + D.Date_Key) % 4) = 3
            THEN 10.00
        ELSE 8.00
    END AS Scheduled_Hours,

    /* Actual headcount */
    CASE
        WHEN ABS(CHECKSUM(CONCAT(E.Employee_Key, '-', D.Date_Key))) % 100 < 4
            THEN 0
        ELSE 1
    END AS Actual_Headcount,

    /* Required headcount */
    1 AS Required_Headcount

FROM dbo.Dim_Employee E
CROSS JOIN dbo.Dim_Date D
WHERE
    E.Employment_Status = 'Active'
    AND D.Full_Date >= @MinReportingDate
    AND D.Full_Date <= @MaxReportingDate;


/* ============================================================
   STEP 5: CLEAR OLD INCORRECT WORKFORCE DATA
   ============================================================ */

DELETE FROM dbo.Fact_Workforce;


/* ============================================================
   STEP 6: INSERT REBUILT DATA
   Handles Workforce_Key whether it is identity or not
   ============================================================ */

DECLARE @IsIdentity BIT;

SELECT
    @IsIdentity =
        CASE
            WHEN c.is_identity = 1 THEN 1
            ELSE 0
        END
FROM sys.columns c
WHERE c.object_id = OBJECT_ID('dbo.Fact_Workforce')
  AND c.name = 'Workforce_Key';


IF @IsIdentity = 1
BEGIN

    INSERT INTO dbo.Fact_Workforce
    (
        Employee_Key,
        Date_Key,
        Shift_Key,
        Shrinkage_Key,
        Hours,
        Scheduled_Flag,
        Absent_Flag,
        Handle_Hours,
        Logged_Hours,
        Adherence_Hours,
        Scheduled_Hours,
        Actual_Headcount,
        Required_Headcount
    )
    SELECT
        Employee_Key,
        Date_Key,
        Shift_Key,
        Shrinkage_Key,
        Hours,
        Scheduled_Flag,
        Absent_Flag,
        Handle_Hours,
        Logged_Hours,
        Adherence_Hours,
        Scheduled_Hours,
        Actual_Headcount,
        Required_Headcount
    FROM #NewWorkforce;

END
ELSE
BEGIN

    INSERT INTO dbo.Fact_Workforce
    (
        Workforce_Key,
        Employee_Key,
        Date_Key,
        Shift_Key,
        Shrinkage_Key,
        Hours,
        Scheduled_Flag,
        Absent_Flag,
        Handle_Hours,
        Logged_Hours,
        Adherence_Hours,
        Scheduled_Hours,
        Actual_Headcount,
        Required_Headcount
    )
    SELECT
        Workforce_Key,
        Employee_Key,
        Date_Key,
        Shift_Key,
        Shrinkage_Key,
        Hours,
        Scheduled_Flag,
        Absent_Flag,
        Handle_Hours,
        Logged_Hours,
        Adherence_Hours,
        Scheduled_Hours,
        Actual_Headcount,
        Required_Headcount
    FROM #NewWorkforce;

END;


/* ============================================================
   STEP 7: REFRESH EXISTING DERIVED COLUMNS
   ============================================================ */

UPDATE dbo.Fact_Workforce
SET
    Created_Date = ISNULL(Created_Date, SYSUTCDATETIME()),
    Modified_Date = SYSUTCDATETIME();


/* ============================================================
   STEP 8: FINAL VALIDATION
   ============================================================ */

SELECT
    COUNT(*) AS Total_Workforce_Rows,
    COUNT(DISTINCT Employee_Key) AS Distinct_Employees,
    COUNT(DISTINCT Date_Key) AS Workforce_Dates,
    MIN(D.Full_Date) AS Min_Workforce_Date,
    MAX(D.Full_Date) AS Max_Workforce_Date,
    SUM(Scheduled_Flag) AS Scheduled_Records,
    SUM(Absent_Flag) AS Absent_Records,
    CAST(
        SUM(Absent_Flag) * 100.0
        / NULLIF(SUM(Scheduled_Flag), 0)
        AS DECIMAL(10,2)
    ) AS Absenteeism_Rate_Pct,
    SUM(Hours) AS Total_Scheduled_Hours,
    SUM(Logged_Hours) AS Total_Logged_Hours,
    SUM(Handle_Hours) AS Total_Handle_Hours
FROM dbo.Fact_Workforce W
INNER JOIN dbo.Dim_Date D
    ON W.Date_Key = D.Date_Key;


/* Employee distribution */
SELECT
    E.Site_Key,
    E.Team_Key,
    COUNT(DISTINCT W.Employee_Key) AS Employees,
    COUNT(*) AS Workforce_Rows,
    SUM(W.Absent_Flag) AS Absent_Records
FROM dbo.Fact_Workforce W
INNER JOIN dbo.Dim_Employee E
    ON W.Employee_Key = E.Employee_Key
GROUP BY
    E.Site_Key,
    E.Team_Key
ORDER BY
    E.Site_Key,
    E.Team_Key;


DROP TABLE #NewWorkforce;

PRINT 'Workforce rebuild completed successfully.';
GO