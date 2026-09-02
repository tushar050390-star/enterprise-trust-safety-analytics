/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 31_Create_Fact_QA.sql
Purpose      : Create Fact_QA Table
Author       : Tushar Mehta
Created Date : 06-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

IF OBJECT_ID('dbo.Fact_QA','U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Fact_QA;
END;
GO

CREATE TABLE dbo.Fact_QA
(
    QA_Key              INT IDENTITY(1,1) NOT NULL,

    Date_Key            INT NOT NULL,
    Policy_Key          INT NOT NULL,
    Error_Code_Key      INT NOT NULL,

    QA_Score            DECIMAL(5,2) NOT NULL,

    Created_Date        DATETIME2(3) NOT NULL
        CONSTRAINT DF_Fact_QA_Created_Date
        DEFAULT SYSUTCDATETIME(),

    Modified_Date       DATETIME2(3) NULL,

    CONSTRAINT PK_Fact_QA
        PRIMARY KEY CLUSTERED (QA_Key),

    CONSTRAINT FK_Fact_QA_Date
        FOREIGN KEY(Date_Key)
        REFERENCES dbo.Dim_Date(Date_Key),

    CONSTRAINT FK_Fact_QA_Policy
        FOREIGN KEY(Policy_Key)
        REFERENCES dbo.Dim_Policy(Policy_Key),

    CONSTRAINT FK_Fact_QA_Error_Code
        FOREIGN KEY(Error_Code_Key)
        REFERENCES dbo.Dim_Error_Code(Error_Code_Key)
);
GO

PRINT 'Fact_QA created successfully.';

/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 32A_Generate_Fact_QA
Section      : 1 - Create QA Base Dataset
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#FactQA_Base') IS NOT NULL
    DROP TABLE #FactQA_Base;

CREATE TABLE #FactQA_Base
(
      QA_No           INT IDENTITY(1,1)
    , Date_Key        INT
    , Policy_Key      INT
    , Error_Code_Key  INT
);

DECLARE @TargetRows INT = 50000;

WHILE (SELECT COUNT(*) FROM #FactQA_Base) < @TargetRows
BEGIN

    INSERT INTO #FactQA_Base
    (
          Date_Key
        , Policy_Key
        , Error_Code_Key
    )

    SELECT TOP (1000)

          D.Date_Key

        , P.Policy_Key

        , EC.Error_Code_Key

    FROM dbo.Dim_Date D

    CROSS APPLY
    (
        SELECT TOP 1 Policy_Key
        FROM dbo.Dim_Policy
        ORDER BY NEWID()
    ) P

    CROSS APPLY
    (
        SELECT TOP 1 Error_Code_Key
        FROM dbo.Dim_Error_Code
        ORDER BY NEWID()
    ) EC

    WHERE D.Is_Weekend = 0
    ORDER BY NEWID();

END;

IF (SELECT COUNT(*) FROM #FactQA_Base) > @TargetRows
BEGIN

    DELETE FROM #FactQA_Base

    WHERE QA_No >
    (
        SELECT @TargetRows
    );

END;

PRINT 'QA Base Dataset Created';

/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 32A_Generate_Fact_QA
Section      : 2 - Generate QA Scores
******************************************************************************/

IF OBJECT_ID('tempdb..#FactQA') IS NOT NULL
    DROP TABLE #FactQA;

SELECT

      QA_No
    , Date_Key
    , Policy_Key
    , Error_Code_Key

    , CASE Error_Code_Key

        WHEN 1 THEN CAST(98 + (ABS(CHECKSUM(NEWID())) % 201)/100.0 AS DECIMAL(5,2))
        WHEN 2 THEN CAST(95 + (ABS(CHECKSUM(NEWID())) % 401)/100.0 AS DECIMAL(5,2))
        WHEN 3 THEN CAST(92 + (ABS(CHECKSUM(NEWID())) % 501)/100.0 AS DECIMAL(5,2))
        WHEN 4 THEN CAST(88 + (ABS(CHECKSUM(NEWID())) % 601)/100.0 AS DECIMAL(5,2))
        WHEN 5 THEN CAST(84 + (ABS(CHECKSUM(NEWID())) % 701)/100.0 AS DECIMAL(5,2))
        WHEN 6 THEN CAST(78 + (ABS(CHECKSUM(NEWID())) % 801)/100.0 AS DECIMAL(5,2))
        WHEN 7 THEN CAST(70 + (ABS(CHECKSUM(NEWID())) %1201)/100.0 AS DECIMAL(5,2))
        WHEN 8 THEN CAST(60 + (ABS(CHECKSUM(NEWID())) %1501)/100.0 AS DECIMAL(5,2))

      END AS QA_Score

INTO #FactQA

FROM #FactQA_Base;

PRINT 'QA Scores Generated Successfully';

SELECT
    Error_Code_Key,
    COUNT(*) AS Total_Audits,
    AVG(QA_Score) AS Avg_QA,
    MIN(QA_Score) AS Min_QA,
    MAX(QA_Score) AS Max_QA
FROM #FactQA
GROUP BY Error_Code_Key
ORDER BY Error_Code_Key;

/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 32B_Load_Fact_QA.sql
Purpose      : Load Fact_QA
Author       : Tushar Mehta
Created Date : 06-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

SET NOCOUNT ON;

--============================================================
-- Clear Existing Data
--============================================================

TRUNCATE TABLE dbo.Fact_QA;

--============================================================
-- Load Fact_QA
--============================================================

INSERT INTO dbo.Fact_QA
(
      Date_Key
    , Policy_Key
    , Error_Code_Key
    , QA_Score
)

SELECT

      Date_Key
    , Policy_Key
    , Error_Code_Key
    , QA_Score

FROM #FactQA;

PRINT 'Fact_QA loaded successfully.';

--============================================================
-- Validation 1
--============================================================

SELECT
    COUNT(*) AS Total_QA_Records
FROM dbo.Fact_QA;

--============================================================
-- Validation 2
--============================================================

SELECT TOP (20)
       QA_Key,
       Date_Key,
       Policy_Key,
       Error_Code_Key,
       QA_Score
FROM dbo.Fact_QA
ORDER BY QA_Key;

--============================================================
-- Validation 3
--============================================================

SELECT
      Error_Code_Key
    , COUNT(*) AS Total_Audits
    , AVG(QA_Score) AS Avg_QA
    , MIN(QA_Score) AS Min_QA
    , MAX(QA_Score) AS Max_QA
FROM dbo.Fact_QA
GROUP BY Error_Code_Key
ORDER BY Error_Code_Key;

--============================================================
-- Validation 4
--============================================================

SELECT
      Policy_Key
    , COUNT(*) AS Total_Audits
FROM dbo.Fact_QA
GROUP BY Policy_Key
ORDER BY Policy_Key;

PRINT '32B_Load_Fact_QA completed successfully.';