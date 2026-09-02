/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 39_Create_Fact_Finance.sql
Purpose      : Create Fact_Finance Table
Author       : Tushar Mehta
Created Date : 07-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

IF OBJECT_ID('dbo.Fact_Finance','U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Fact_Finance;
END;
GO

CREATE TABLE dbo.Fact_Finance
(
    Finance_Key            INT IDENTITY(1,1) NOT NULL,

    Date_Key               INT NOT NULL,
    Billing_Model_Key      INT NOT NULL,
    Cost_Center_Key        INT NOT NULL,

    Revenue_USD            DECIMAL(12,2) NOT NULL,

    Created_Date           DATETIME2(3) NOT NULL
        CONSTRAINT DF_Fact_Finance_Created_Date
        DEFAULT SYSUTCDATETIME(),

    Modified_Date          DATETIME2(3) NULL,

    CONSTRAINT PK_Fact_Finance
        PRIMARY KEY CLUSTERED (Finance_Key),

    CONSTRAINT FK_Fact_Finance_Date
        FOREIGN KEY (Date_Key)
        REFERENCES dbo.Dim_Date(Date_Key),

    CONSTRAINT FK_Fact_Finance_Billing_Model
        FOREIGN KEY (Billing_Model_Key)
        REFERENCES dbo.Dim_Billing_Model(Billing_Model_Key),

    CONSTRAINT FK_Fact_Finance_Cost_Center
        FOREIGN KEY (Cost_Center_Key)
        REFERENCES dbo.Dim_Cost_Center(Cost_Center_Key)
);
GO

PRINT 'Fact_Finance created successfully.';

/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 40A_Generate_Fact_Finance.sql
Purpose      : Generate Finance Dataset
Author       : Tushar Mehta
Created Date : 07-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

SET NOCOUNT ON;

------------------------------------------------------------
-- Remove Existing Temporary Table
------------------------------------------------------------

IF OBJECT_ID('tempdb..#FactFinance_Base') IS NOT NULL
    DROP TABLE #FactFinance_Base;

CREATE TABLE #FactFinance_Base
(
      Finance_No            INT IDENTITY(1,1)
    , Date_Key              INT
    , Billing_Model_Key     INT
    , Cost_Center_Key       INT
);

DECLARE @TargetRows INT = 18000;

WHILE (SELECT COUNT(*) FROM #FactFinance_Base) < @TargetRows
BEGIN

    INSERT INTO #FactFinance_Base
    (
          Date_Key
        , Billing_Model_Key
        , Cost_Center_Key
    )

    SELECT TOP (1000)

          D.Date_Key

        , BM.Billing_Model_Key

        , CC.Cost_Center_Key

    FROM
    (
        SELECT Date_Key
        FROM dbo.Dim_Date
        WHERE Is_Weekend = 0
    ) D

    CROSS APPLY
    (
        SELECT TOP (1)
               Billing_Model_Key
        FROM dbo.Dim_Billing_Model
        ORDER BY NEWID()
    ) BM

    CROSS APPLY
    (
        SELECT TOP (1)
               Cost_Center_Key
        FROM dbo.Dim_Cost_Center
        ORDER BY NEWID()
    ) CC

    ORDER BY NEWID();

END;

IF (SELECT COUNT(*) FROM #FactFinance_Base) > @TargetRows
BEGIN

    DELETE
    FROM #FactFinance_Base
    WHERE Finance_No > @TargetRows;

END;

PRINT 'Finance Base Dataset Generated Successfully';

------------------------------------------------------------
-- Validation 1
------------------------------------------------------------

SELECT COUNT(*) AS Total_Finance_Records
FROM #FactFinance_Base;

------------------------------------------------------------
-- Validation 2
------------------------------------------------------------

SELECT TOP (20) *
FROM #FactFinance_Base;

------------------------------------------------------------
-- Validation 3
------------------------------------------------------------

SELECT
      Billing_Model_Key,
      COUNT(*) AS Total_Records
FROM #FactFinance_Base
GROUP BY Billing_Model_Key
ORDER BY Billing_Model_Key;

------------------------------------------------------------
-- Validation 4
------------------------------------------------------------

SELECT
      Cost_Center_Key,
      COUNT(*) AS Total_Records
FROM #FactFinance_Base
GROUP BY Cost_Center_Key
ORDER BY Cost_Center_Key;

PRINT '40A_Generate_Fact_Finance completed successfully.';

/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 40B_Load_Fact_Finance.sql
Purpose      : Generate Revenue and Load Fact_Finance
Author       : Tushar Mehta
Created Date : 07-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

SET NOCOUNT ON;

------------------------------------------------------------
-- Remove Existing Temporary Table
------------------------------------------------------------

IF OBJECT_ID('tempdb..#FactFinance') IS NOT NULL
    DROP TABLE #FactFinance;

------------------------------------------------------------
-- Generate Revenue
------------------------------------------------------------

SELECT

      Finance_No
    , Date_Key
    , Billing_Model_Key
    , Cost_Center_Key

    , CASE Billing_Model_Key

        WHEN 1 THEN
            CAST(800 + (ABS(CHECKSUM(NEWID())) % 401) AS DECIMAL(12,2))

        WHEN 2 THEN
            CAST(1200 + (ABS(CHECKSUM(NEWID())) % 601) AS DECIMAL(12,2))

        WHEN 3 THEN
            CAST(1800 + (ABS(CHECKSUM(NEWID())) % 901) AS DECIMAL(12,2))

        WHEN 4 THEN
            CAST(2500 + (ABS(CHECKSUM(NEWID())) % 1501) AS DECIMAL(12,2))

      END AS Revenue_USD

INTO #FactFinance

FROM #FactFinance_Base;

PRINT 'Finance Revenue Generated Successfully';

------------------------------------------------------------
-- Remove Existing Data
------------------------------------------------------------

TRUNCATE TABLE dbo.Fact_Finance;

------------------------------------------------------------
-- Load Fact_Finance
------------------------------------------------------------

INSERT INTO dbo.Fact_Finance
(
      Date_Key
    , Billing_Model_Key
    , Cost_Center_Key
    , Revenue_USD
)

SELECT

      Date_Key
    , Billing_Model_Key
    , Cost_Center_Key
    , Revenue_USD

FROM #FactFinance;

PRINT 'Fact_Finance Loaded Successfully';

------------------------------------------------------------
-- Validation 1
------------------------------------------------------------

SELECT
    COUNT(*) AS Total_Finance_Records
FROM dbo.Fact_Finance;

------------------------------------------------------------
-- Validation 2
------------------------------------------------------------

SELECT TOP (20)

      Finance_Key
    , Date_Key
    , Billing_Model_Key
    , Cost_Center_Key
    , Revenue_USD

FROM dbo.Fact_Finance
ORDER BY Finance_Key;

------------------------------------------------------------
-- Validation 3
------------------------------------------------------------

SELECT

      Billing_Model_Key

    , COUNT(*) AS Total_Records

    , AVG(Revenue_USD) AS Avg_Revenue

    , MIN(Revenue_USD) AS Min_Revenue

    , MAX(Revenue_USD) AS Max_Revenue

FROM dbo.Fact_Finance

GROUP BY Billing_Model_Key

ORDER BY Billing_Model_Key;

------------------------------------------------------------
-- Validation 4
------------------------------------------------------------

SELECT

      Cost_Center_Key

    , COUNT(*) AS Total_Records

    , AVG(Revenue_USD) AS Avg_Revenue

FROM dbo.Fact_Finance

GROUP BY Cost_Center_Key

ORDER BY Cost_Center_Key;

PRINT '40B_Load_Fact_Finance completed successfully.';