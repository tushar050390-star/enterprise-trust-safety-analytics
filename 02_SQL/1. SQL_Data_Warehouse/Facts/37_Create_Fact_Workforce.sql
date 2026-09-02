/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 37_Create_Fact_Workforce.sql
Purpose      : Create Fact_Workforce Table
Author       : Tushar Mehta
Created Date : 06-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

IF OBJECT_ID('dbo.Fact_Workforce','U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Fact_Workforce;
END;
GO

CREATE TABLE dbo.Fact_Workforce
(
    Workforce_Key          INT IDENTITY(1,1) NOT NULL,

    Date_Key               INT NOT NULL,
    Shift_Key              INT NOT NULL,
    Shrinkage_Key          INT NOT NULL,

    Hours                  DECIMAL(6,2) NOT NULL,

    Created_Date           DATETIME2(3) NOT NULL
        CONSTRAINT DF_Fact_Workforce_Created_Date
        DEFAULT SYSUTCDATETIME(),

    Modified_Date          DATETIME2(3) NULL,

    CONSTRAINT PK_Fact_Workforce
        PRIMARY KEY CLUSTERED (Workforce_Key),

    CONSTRAINT FK_Fact_Workforce_Date
        FOREIGN KEY (Date_Key)
        REFERENCES dbo.Dim_Date(Date_Key),

    CONSTRAINT FK_Fact_Workforce_Shift
        FOREIGN KEY (Shift_Key)
        REFERENCES dbo.Dim_Shift(Shift_Key),

    CONSTRAINT FK_Fact_Workforce_Shrinkage
        FOREIGN KEY (Shrinkage_Key)
        REFERENCES dbo.Dim_Shrinkage(Shrinkage_Key)
);
GO

PRINT 'Fact_Workforce created successfully.';

/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 38A_Generate_Fact_Workforce.sql
Purpose      : Generate Workforce Dataset
Author       : Tushar Mehta
Created Date : 07-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

SET NOCOUNT ON;

------------------------------------------------------------
-- Remove Existing Temporary Table
------------------------------------------------------------

IF OBJECT_ID('tempdb..#FactWorkforce_Base') IS NOT NULL
    DROP TABLE #FactWorkforce_Base;

CREATE TABLE #FactWorkforce_Base
(
      Workforce_No      INT IDENTITY(1,1)
    , Date_Key          INT
    , Shift_Key         INT
    , Shrinkage_Key     INT
);

DECLARE @TargetRows INT = 20000;

WHILE (SELECT COUNT(*) FROM #FactWorkforce_Base) < @TargetRows
BEGIN

    INSERT INTO #FactWorkforce_Base
    (
          Date_Key
        , Shift_Key
        , Shrinkage_Key
    )

    SELECT TOP (1000)

          D.Date_Key

        , S.Shift_Key

        , SG.Shrinkage_Key

    FROM
    (
        SELECT Date_Key
        FROM dbo.Dim_Date
        WHERE Is_Weekend = 0
    ) D

    CROSS APPLY
    (
        SELECT TOP (1)
               Shift_Key
        FROM dbo.Dim_Shift
        ORDER BY NEWID()
    ) S

    CROSS APPLY
    (
        SELECT TOP (1)
               Shrinkage_Key
        FROM dbo.Dim_Shrinkage
        ORDER BY NEWID()
    ) SG

    ORDER BY NEWID();

END;

IF (SELECT COUNT(*) FROM #FactWorkforce_Base) > @TargetRows
BEGIN

    DELETE
    FROM #FactWorkforce_Base
    WHERE Workforce_No > @TargetRows;

END;

PRINT 'Workforce Base Dataset Generated Successfully';

------------------------------------------------------------
-- Validation 1
------------------------------------------------------------

SELECT COUNT(*) AS Total_Workforce_Records
FROM #FactWorkforce_Base;

------------------------------------------------------------
-- Validation 2
------------------------------------------------------------

SELECT TOP (20) *
FROM #FactWorkforce_Base;

------------------------------------------------------------
-- Validation 3
------------------------------------------------------------

SELECT
      Shift_Key,
      COUNT(*) AS Total_Records
FROM #FactWorkforce_Base
GROUP BY Shift_Key
ORDER BY Shift_Key;

------------------------------------------------------------
-- Validation 4
------------------------------------------------------------

SELECT
      Shrinkage_Key,
      COUNT(*) AS Total_Records
FROM #FactWorkforce_Base
GROUP BY Shrinkage_Key
ORDER BY Shrinkage_Key;

PRINT '38A_Generate_Fact_Workforce completed successfully.';

/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 38B_Load_Fact_Workforce.sql
Purpose      : Generate Hours and Load Fact_Workforce
Author       : Tushar Mehta
Created Date : 07-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

SET NOCOUNT ON;

------------------------------------------------------------
-- Remove Existing Temporary Table
------------------------------------------------------------

IF OBJECT_ID('tempdb..#FactWorkforce') IS NOT NULL
    DROP TABLE #FactWorkforce;

------------------------------------------------------------
-- Generate Workforce Hours
------------------------------------------------------------

SELECT

      Workforce_No
    , Date_Key
    , Shift_Key
    , Shrinkage_Key

    , CASE

        -- Normal Shrinkage
        WHEN Shrinkage_Key = 1
        THEN CAST(7.50 + (ABS(CHECKSUM(NEWID())) % 151) / 100.0 AS DECIMAL(6,2))

        -- High Shrinkage
        ELSE CAST(5.50 + (ABS(CHECKSUM(NEWID())) % 201) / 100.0 AS DECIMAL(6,2))

      END AS Hours

INTO #FactWorkforce

FROM #FactWorkforce_Base;

PRINT 'Workforce Hours Generated Successfully';

------------------------------------------------------------
-- Clear Existing Data
------------------------------------------------------------

TRUNCATE TABLE dbo.Fact_Workforce;

------------------------------------------------------------
-- Load Fact_Workforce
------------------------------------------------------------

INSERT INTO dbo.Fact_Workforce
(
      Date_Key
    , Shift_Key
    , Shrinkage_Key
    , Hours
)

SELECT

      Date_Key
    , Shift_Key
    , Shrinkage_Key
    , Hours

FROM #FactWorkforce;

PRINT 'Fact_Workforce Loaded Successfully';

------------------------------------------------------------
-- Validation 1
------------------------------------------------------------

SELECT
    COUNT(*) AS Total_Workforce_Records
FROM dbo.Fact_Workforce;

------------------------------------------------------------
-- Validation 2
------------------------------------------------------------

SELECT TOP (20)

      Workforce_Key
    , Date_Key
    , Shift_Key
    , Shrinkage_Key
    , Hours

FROM dbo.Fact_Workforce
ORDER BY Workforce_Key;

------------------------------------------------------------
-- Validation 3
------------------------------------------------------------

SELECT

      Shift_Key

    , COUNT(*) AS Total_Records

    , AVG(Hours) AS Avg_Hours

    , MIN(Hours) AS Min_Hours

    , MAX(Hours) AS Max_Hours

FROM dbo.Fact_Workforce

GROUP BY Shift_Key

ORDER BY Shift_Key;

------------------------------------------------------------
-- Validation 4
------------------------------------------------------------

SELECT

      Shrinkage_Key

    , COUNT(*) AS Total_Records

    , AVG(Hours) AS Avg_Hours

FROM dbo.Fact_Workforce

GROUP BY Shrinkage_Key

ORDER BY Shrinkage_Key;

PRINT '38B_Load_Fact_Workforce completed successfully.';