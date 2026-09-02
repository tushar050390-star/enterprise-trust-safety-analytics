/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 35_Create_Fact_Coaching.sql
Purpose      : Create Fact_Coaching Table
Author       : Tushar Mehta
Created Date : 06-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

IF OBJECT_ID('dbo.Fact_Coaching','U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Fact_Coaching;
END;
GO

CREATE TABLE dbo.Fact_Coaching
(
    Coaching_Key           INT IDENTITY(1,1) NOT NULL,

    Date_Key               INT NOT NULL,
    Client_Key             INT NOT NULL,
    Site_Key               INT NOT NULL,
    Process_Key            INT NOT NULL,
    Team_Key               INT NOT NULL,
    Employee_Key           INT NOT NULL,

    Duration_Minutes       INT NOT NULL,

    Created_Date           DATETIME2(3) NOT NULL
        CONSTRAINT DF_Fact_Coaching_Created_Date
        DEFAULT SYSUTCDATETIME(),

    Modified_Date          DATETIME2(3) NULL,

    CONSTRAINT PK_Fact_Coaching
        PRIMARY KEY CLUSTERED (Coaching_Key),

    CONSTRAINT FK_Fact_Coaching_Date
        FOREIGN KEY (Date_Key)
        REFERENCES dbo.Dim_Date(Date_Key),

    CONSTRAINT FK_Fact_Coaching_Client
        FOREIGN KEY (Client_Key)
        REFERENCES dbo.Dim_Client(Client_Key),

    CONSTRAINT FK_Fact_Coaching_Site
        FOREIGN KEY (Site_Key)
        REFERENCES dbo.Dim_Site(Site_Key),

    CONSTRAINT FK_Fact_Coaching_Process
        FOREIGN KEY (Process_Key)
        REFERENCES dbo.Dim_Process(Process_Key),

    CONSTRAINT FK_Fact_Coaching_Team
        FOREIGN KEY (Team_Key)
        REFERENCES dbo.Dim_Team(Team_Key),

    CONSTRAINT FK_Fact_Coaching_Employee
        FOREIGN KEY (Employee_Key)
        REFERENCES dbo.Dim_Employee(Employee_Key)
);
GO

PRINT 'Fact_Coaching created successfully.';

/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 36A_Generate_Fact_Coaching.sql
Purpose      : Generate Coaching Dataset
Author       : Tushar Mehta
Created Date : 06-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

SET NOCOUNT ON;

------------------------------------------------------------
-- Remove Existing Temporary Table
------------------------------------------------------------

IF OBJECT_ID('tempdb..#FactCoaching_Base') IS NOT NULL
    DROP TABLE #FactCoaching_Base;

CREATE TABLE #FactCoaching_Base
(
      Coaching_No         INT IDENTITY(1,1)
    , Date_Key            INT
    , Client_Key          INT
    , Process_Key         INT
    , Team_Key            INT
    , Site_Key            INT
    , Employee_Key        INT
);

DECLARE @TargetRows INT = 15000;

WHILE (SELECT COUNT(*) FROM #FactCoaching_Base) < @TargetRows
BEGIN

    INSERT INTO #FactCoaching_Base
    (
          Date_Key
        , Client_Key
        , Process_Key
        , Team_Key
        , Site_Key
        , Employee_Key
    )

    SELECT TOP (1000)

          D.Date_Key

        , E.Client_Key
        , E.Process_Key
        , E.Team_Key
        , E.Site_Key
        , E.Employee_Key

    FROM dbo.Dim_Employee E

    CROSS APPLY
    (
        SELECT TOP (1)
               Date_Key
        FROM dbo.Dim_Date
        WHERE Is_Weekend = 0
        ORDER BY NEWID()
    ) D

    ORDER BY NEWID();

END;

IF (SELECT COUNT(*) FROM #FactCoaching_Base) > @TargetRows
BEGIN

    DELETE
    FROM #FactCoaching_Base
    WHERE Coaching_No > @TargetRows;

END;

PRINT 'Coaching Base Dataset Generated Successfully';

------------------------------------------------------------
-- Validation 1
------------------------------------------------------------

SELECT COUNT(*) AS Total_Coaching_Records
FROM #FactCoaching_Base;

------------------------------------------------------------
-- Validation 2
------------------------------------------------------------

SELECT TOP (20) *
FROM #FactCoaching_Base;

------------------------------------------------------------
-- Validation 3
------------------------------------------------------------

SELECT
      Team_Key
    , COUNT(*) AS Coaching_Sessions
FROM #FactCoaching_Base
GROUP BY Team_Key
ORDER BY Team_Key;

------------------------------------------------------------
-- Validation 4
------------------------------------------------------------

SELECT
      Employee_Key
    , COUNT(*) AS Coaching_Count
FROM #FactCoaching_Base
GROUP BY Employee_Key
ORDER BY Employee_Key;

PRINT '36A_Generate_Fact_Coaching completed successfully.';

/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 36B_Load_Fact_Coaching.sql
Purpose      : Generate Duration and Load Fact_Coaching
Author       : Tushar Mehta
Created Date : 06-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

SET NOCOUNT ON;

------------------------------------------------------------
-- Remove Existing Temporary Table
------------------------------------------------------------

IF OBJECT_ID('tempdb..#FactCoaching') IS NOT NULL
    DROP TABLE #FactCoaching;

------------------------------------------------------------
-- Generate Coaching Duration
------------------------------------------------------------

SELECT

      Coaching_No
    , Date_Key
    , Client_Key
    , Process_Key
    , Team_Key
    , Site_Key
    , Employee_Key

    , CASE
    WHEN Employee_Key <= 72
        THEN 30 + ABS(CHECKSUM(NEWID())) % 31
    WHEN Employee_Key <= 90
        THEN 45 + ABS(CHECKSUM(NEWID())) % 31
    WHEN Employee_Key <= 97
        THEN 60 + ABS(CHECKSUM(NEWID())) % 31
    ELSE
        75 + ABS(CHECKSUM(NEWID())) % 46
END AS Duration_Minutes

INTO #FactCoaching

FROM #FactCoaching_Base;

PRINT 'Coaching Duration Generated Successfully';

------------------------------------------------------------
-- Remove Existing Data
------------------------------------------------------------

TRUNCATE TABLE dbo.Fact_Coaching;

------------------------------------------------------------
-- Load Fact_Coaching
------------------------------------------------------------

INSERT INTO dbo.Fact_Coaching
(
      Date_Key
    , Client_Key
    , Process_Key
    , Team_Key
    , Site_Key
    , Employee_Key
    , Duration_Minutes
)

SELECT

      Date_Key
    , Client_Key
    , Process_Key
    , Team_Key
    , Site_Key
    , Employee_Key
    , Duration_Minutes

FROM #FactCoaching;

PRINT 'Fact_Coaching Loaded Successfully';

------------------------------------------------------------
-- Validation 1
------------------------------------------------------------

SELECT COUNT(*) AS Total_Coaching_Records
FROM dbo.Fact_Coaching;

------------------------------------------------------------
-- Validation 2
------------------------------------------------------------

SELECT TOP (20)
       Coaching_Key,
       Date_Key,
       Employee_Key,
       Team_Key,
       Duration_Minutes
FROM dbo.Fact_Coaching
ORDER BY Coaching_Key;

------------------------------------------------------------
-- Validation 3
------------------------------------------------------------

SELECT
      Team_Key,
      COUNT(*) AS Coaching_Sessions,
      AVG(Duration_Minutes) AS Avg_Duration
FROM dbo.Fact_Coaching
GROUP BY Team_Key
ORDER BY Team_Key;

------------------------------------------------------------
-- Validation 4
------------------------------------------------------------

SELECT
      Employee_Key,
      COUNT(*) AS Coaching_Count
FROM dbo.Fact_Coaching
GROUP BY Employee_Key
ORDER BY Employee_Key;

PRINT '36B_Load_Fact_Coaching completed successfully.';

