/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 33_Create_Fact_Appeals.sql
Purpose      : Create Fact_Appeals Table
Author       : Tushar Mehta
Created Date : 06-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

IF OBJECT_ID('dbo.Fact_Appeals','U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Fact_Appeals;
END;
GO

CREATE TABLE dbo.Fact_Appeals
(
    Appeal_Key             INT IDENTITY(1,1) NOT NULL,

    Date_Key               INT NOT NULL,
    Policy_Key             INT NOT NULL,
    Appeal_Decision_Key    INT NOT NULL,

    Resolution_Time        DECIMAL(6,2) NOT NULL,

    Created_Date           DATETIME2(3) NOT NULL
        CONSTRAINT DF_Fact_Appeals_Created_Date
        DEFAULT SYSUTCDATETIME(),

    Modified_Date          DATETIME2(3) NULL,

    CONSTRAINT PK_Fact_Appeals
        PRIMARY KEY CLUSTERED (Appeal_Key),

    CONSTRAINT FK_Fact_Appeals_Date
        FOREIGN KEY (Date_Key)
        REFERENCES dbo.Dim_Date(Date_Key),

    CONSTRAINT FK_Fact_Appeals_Policy
        FOREIGN KEY (Policy_Key)
        REFERENCES dbo.Dim_Policy(Policy_Key),

    CONSTRAINT FK_Fact_Appeals_Appeal_Decision
        FOREIGN KEY (Appeal_Decision_Key)
        REFERENCES dbo.Dim_Appeal_Decision(Appeal_Decision_Key)
);
GO

PRINT 'Fact_Appeals created successfully.';

/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 34A_Generate_Fact_Appeals.sql
Purpose      : Generate Appeal Dataset
Author       : Tushar Mehta
Created Date : 06-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

SET NOCOUNT ON;

------------------------------------------------------------
-- Remove Existing Temporary Table
------------------------------------------------------------

IF OBJECT_ID('tempdb..#FactAppeals_Base') IS NOT NULL
    DROP TABLE #FactAppeals_Base;

CREATE TABLE #FactAppeals_Base
(
      Appeal_No             INT IDENTITY(1,1)
    , Date_Key              INT
    , Policy_Key            INT
    , Appeal_Decision_Key   INT
);

DECLARE @TargetRows INT = 25000;

WHILE (SELECT COUNT(*) FROM #FactAppeals_Base) < @TargetRows
BEGIN

    INSERT INTO #FactAppeals_Base
    (
          Date_Key
        , Policy_Key
        , Appeal_Decision_Key
    )

    SELECT TOP (1000)

          D.Date_Key

        , P.Policy_Key

        , A.Appeal_Decision_Key

    FROM dbo.Dim_Date D

    CROSS APPLY
    (
        SELECT TOP (1)
               Policy_Key
        FROM dbo.Dim_Policy
        ORDER BY NEWID()
    ) P

    CROSS APPLY
    (
        SELECT TOP (1)
               Appeal_Decision_Key
        FROM dbo.Dim_Appeal_Decision
        ORDER BY NEWID()
    ) A

    WHERE D.Is_Weekend = 0

    ORDER BY NEWID();

END;

IF (SELECT COUNT(*) FROM #FactAppeals_Base) > @TargetRows
BEGIN

    DELETE
    FROM #FactAppeals_Base
    WHERE Appeal_No > @TargetRows;

END;

PRINT 'Appeal Base Dataset Generated Successfully';

------------------------------------------------------------
-- Validation 1
------------------------------------------------------------

SELECT COUNT(*) AS Total_Appeals
FROM #FactAppeals_Base;

------------------------------------------------------------
-- Validation 2
------------------------------------------------------------

SELECT TOP (20) *
FROM #FactAppeals_Base;

------------------------------------------------------------
-- Validation 3
------------------------------------------------------------

SELECT
      Appeal_Decision_Key
    , COUNT(*) AS Total_Records
FROM #FactAppeals_Base
GROUP BY Appeal_Decision_Key
ORDER BY Appeal_Decision_Key;

------------------------------------------------------------
-- Validation 4
------------------------------------------------------------

SELECT
      Policy_Key
    , COUNT(*) AS Total_Records
FROM #FactAppeals_Base
GROUP BY Policy_Key
ORDER BY Policy_Key;

PRINT '34A_Generate_Fact_Appeals completed successfully.';

/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 34B_Load_Fact_Appeals.sql
Purpose      : Generate Resolution Time and Load Fact_Appeals
Author       : Tushar Mehta
Created Date : 06-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

SET NOCOUNT ON;

------------------------------------------------------------
-- Remove Existing Temporary Table
------------------------------------------------------------

IF OBJECT_ID('tempdb..#FactAppeals') IS NOT NULL
    DROP TABLE #FactAppeals;

------------------------------------------------------------
-- Generate Resolution Time
------------------------------------------------------------

SELECT

      Appeal_No
    , Date_Key
    , Policy_Key
    , Appeal_Decision_Key

    , CASE Appeal_Decision_Key

        WHEN 1 THEN
            CAST(2 + (ABS(CHECKSUM(NEWID())) % 400) / 100.0 AS DECIMAL(6,2))

        WHEN 2 THEN
            CAST(4 + (ABS(CHECKSUM(NEWID())) % 600) / 100.0 AS DECIMAL(6,2))

        WHEN 3 THEN
            CAST(6 + (ABS(CHECKSUM(NEWID())) % 900) / 100.0 AS DECIMAL(6,2))

      END AS Resolution_Time

INTO #FactAppeals

FROM #FactAppeals_Base;

PRINT 'Resolution Time Generated Successfully';

------------------------------------------------------------
-- Clear Existing Data
------------------------------------------------------------

TRUNCATE TABLE dbo.Fact_Appeals;

------------------------------------------------------------
-- Load Fact_Appeals
------------------------------------------------------------

INSERT INTO dbo.Fact_Appeals
(
      Date_Key
    , Policy_Key
    , Appeal_Decision_Key
    , Resolution_Time
)

SELECT

      Date_Key
    , Policy_Key
    , Appeal_Decision_Key
    , Resolution_Time

FROM #FactAppeals;

PRINT 'Fact_Appeals Loaded Successfully';

------------------------------------------------------------
-- Validation 1
------------------------------------------------------------

SELECT
    COUNT(*) AS Total_Appeal_Records
FROM dbo.Fact_Appeals;

------------------------------------------------------------
-- Validation 2
------------------------------------------------------------

SELECT TOP (20)
       Appeal_Key,
       Date_Key,
       Policy_Key,
       Appeal_Decision_Key,
       Resolution_Time
FROM dbo.Fact_Appeals
ORDER BY Appeal_Key;

------------------------------------------------------------
-- Validation 3
------------------------------------------------------------

SELECT

      Appeal_Decision_Key

    , COUNT(*) AS Total_Appeals

    , AVG(Resolution_Time) AS Avg_Resolution_Time

    , MIN(Resolution_Time) AS Min_Resolution_Time

    , MAX(Resolution_Time) AS Max_Resolution_Time

FROM dbo.Fact_Appeals

GROUP BY Appeal_Decision_Key

ORDER BY Appeal_Decision_Key;

------------------------------------------------------------
-- Validation 4
------------------------------------------------------------

SELECT

      Policy_Key

    , COUNT(*) AS Total_Appeals

FROM dbo.Fact_Appeals

GROUP BY Policy_Key

ORDER BY Policy_Key;

PRINT '34B_Load_Fact_Appeals completed successfully.';

