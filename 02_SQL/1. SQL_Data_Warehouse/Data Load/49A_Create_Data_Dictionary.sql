/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 49A_Create_Data_Dictionary.sql
Purpose      : Create Centralized Data Dictionary
Author       : Tushar Mehta
Created Date : 10-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

/*==============================================================
  Remove Existing Data Dictionary
==============================================================*/

IF OBJECT_ID('dbo.Data_Dictionary', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Data_Dictionary;
END;
GO

/*==============================================================
  Create Data Dictionary
==============================================================*/

CREATE TABLE dbo.Data_Dictionary
(
    Dictionary_Key       INT IDENTITY(1,1) NOT NULL,

    Table_Name           NVARCHAR(128) NOT NULL,
    Column_Name          NVARCHAR(128) NOT NULL,
    Data_Type            NVARCHAR(128) NOT NULL,

    Max_Length           INT NULL,
    Precision_Value      INT NULL,
    Scale_Value          INT NULL,

    Is_Nullable           NVARCHAR(3) NOT NULL,

    Is_Primary_Key        NVARCHAR(3) NOT NULL,
    Is_Foreign_Key        NVARCHAR(3) NOT NULL,

    Business_Definition   NVARCHAR(500) NULL,
    Data_Source           NVARCHAR(250) NULL,
    Transformation_Rule   NVARCHAR(500) NULL,

    Created_Date          DATETIME2(3) NOT NULL
        CONSTRAINT DF_Data_Dictionary_Created_Date
        DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_Data_Dictionary
        PRIMARY KEY CLUSTERED (Dictionary_Key)
);
GO

/*==============================================================
  Populate Technical Metadata
==============================================================*/

INSERT INTO dbo.Data_Dictionary
(
      Table_Name
    , Column_Name
    , Data_Type
    , Max_Length
    , Precision_Value
    , Scale_Value
    , Is_Nullable
    , Is_Primary_Key
    , Is_Foreign_Key
)
SELECT

      T.TABLE_NAME

    , C.COLUMN_NAME

    , C.DATA_TYPE

    , C.CHARACTER_MAXIMUM_LENGTH

    , C.NUMERIC_PRECISION

    , C.NUMERIC_SCALE

    , C.IS_NULLABLE

    , CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM sys.indexes I
            INNER JOIN sys.index_columns IC
                ON I.object_id = IC.object_id
                AND I.index_id = IC.index_id
            INNER JOIN sys.columns SC
                ON IC.object_id = SC.object_id
                AND IC.column_id = SC.column_id
            WHERE I.is_primary_key = 1
              AND I.object_id = OBJECT_ID(
                    QUOTENAME(C.TABLE_SCHEMA)
                    + '.'
                    + QUOTENAME(C.TABLE_NAME)
                  )
              AND SC.name = C.COLUMN_NAME
        )
        THEN 'YES'
        ELSE 'NO'
      END AS Is_Primary_Key

    , CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM sys.foreign_key_columns FKC
            INNER JOIN sys.columns SC
                ON FKC.parent_object_id = SC.object_id
                AND FKC.parent_column_id = SC.column_id
            WHERE FKC.parent_object_id =
                    OBJECT_ID(
                        QUOTENAME(C.TABLE_SCHEMA)
                        + '.'
                        + QUOTENAME(C.TABLE_NAME)
                    )
              AND SC.name = C.COLUMN_NAME
        )
        THEN 'YES'
        ELSE 'NO'
      END AS Is_Foreign_Key

FROM INFORMATION_SCHEMA.TABLES T

INNER JOIN INFORMATION_SCHEMA.COLUMNS C
    ON T.TABLE_SCHEMA = C.TABLE_SCHEMA
    AND T.TABLE_NAME = C.TABLE_NAME

WHERE T.TABLE_SCHEMA = 'dbo'
  AND T.TABLE_TYPE = 'BASE TABLE'
  AND T.TABLE_NAME NOT IN
  (
      'Data_Dictionary',
      'Numbers'
  )

ORDER BY
      T.TABLE_NAME
    , C.ORDINAL_POSITION;
GO

PRINT 'Data Dictionary created and technical metadata loaded successfully.';

SELECT COUNT(*) AS Total_Data_Dictionary_Records
FROM dbo.Data_Dictionary;

SELECT TOP (50)
      Table_Name,
      Column_Name,
      Data_Type,
      Is_Nullable,
      Is_Primary_Key,
      Is_Foreign_Key
FROM dbo.Data_Dictionary
ORDER BY
      Table_Name,
      Dictionary_Key;

	  SELECT
      Table_Name,
      COUNT(*) AS Column_Count
FROM dbo.Data_Dictionary
GROUP BY Table_Name
ORDER BY Table_Name;