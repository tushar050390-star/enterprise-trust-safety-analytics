***********************************************************
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


/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 49B_Add_Business_Metadata.sql
Purpose      : Add Business Definitions and Data Lineage Metadata
Author       : Tushar Mehta
Created Date : 10-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

/*==============================================================
  Operations Fact
==============================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE Column_Name

            WHEN 'Date_Key'
                THEN 'Surrogate key identifying the reporting date.'

            WHEN 'Employee_Key'
                THEN 'Surrogate key identifying the employee responsible for the operational activity.'

            WHEN 'Client_Key'
                THEN 'Surrogate key identifying the client associated with the operational activity.'

            WHEN 'Process_Key'
                THEN 'Surrogate key identifying the business process.'

            WHEN 'Team_Key'
                THEN 'Surrogate key identifying the operational team.'

            WHEN 'Site_Key'
                THEN 'Surrogate key identifying the operational site.'

            WHEN 'Shift_Key'
                THEN 'Surrogate key identifying the employee shift.'

            WHEN 'Policy_Key'
                THEN 'Surrogate key identifying the policy associated with the activity.'

            WHEN 'Cases_Handled'
                THEN 'Number of cases processed by operations.'

            WHEN 'Cases_Reviewed'
                THEN 'Number of cases reviewed as part of the operational workflow.'

            WHEN 'Cases_Approved'
                THEN 'Number of cases approved after operational review.'

            WHEN 'Cases_Rejected'
                THEN 'Number of cases rejected after operational review.'

            WHEN 'QA_Score'
                THEN 'Quality score associated with the operational activity.'

            WHEN 'AHT_Minutes'
                THEN 'Average handling time measured in minutes.'

            WHEN 'SLA_Compliance_Pct'
                THEN 'Percentage of cases meeting the defined service level agreement.'

            WHEN 'Productive_Hours'
                THEN 'Hours spent performing productive operational work.'

            WHEN 'Revenue_USD'
                THEN 'Revenue attributed to the operational activity in US dollars.'

            WHEN 'Operating_Cost_USD'
                THEN 'Operating cost associated with the activity in US dollars.'

            ELSE Business_Definition

        END,

    Data_Source =
        CASE
            WHEN Table_Name LIKE 'Fact_%'
                THEN 'Generated operational analytics dataset and ETL transformation logic.'
            ELSE Data_Source
        END

WHERE Table_Name = 'Fact_Operations';
GO


/*==============================================================
  QA Fact
==============================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE Column_Name

            WHEN 'Date_Key'
                THEN 'Surrogate key identifying the QA audit date.'

            WHEN 'Policy_Key'
                THEN 'Surrogate key identifying the policy being audited.'

            WHEN 'Error_Code_Key'
                THEN 'Surrogate key identifying the error code associated with the audit.'

            WHEN 'QA_Score'
                THEN 'Quality score assigned during the QA audit.'

            ELSE Business_Definition

        END,

    Data_Source =
        'Generated QA dataset and ETL transformation logic.'

WHERE Table_Name = 'Fact_QA';
GO


/*==============================================================
  Appeals Fact
==============================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE Column_Name

            WHEN 'Date_Key'
                THEN 'Surrogate key identifying the appeal date.'

            WHEN 'Policy_Key'
                THEN 'Surrogate key identifying the policy associated with the appeal.'

            WHEN 'Appeal_Decision_Key'
                THEN 'Surrogate key identifying the decision reached for the appeal.'

            WHEN 'Resolution_Time'
                THEN 'Time required to resolve an appeal.'

            ELSE Business_Definition

        END,

    Data_Source =
        'Generated appeals dataset and ETL transformation logic.'

WHERE Table_Name = 'Fact_Appeals';
GO


/*==============================================================
  Coaching Fact
==============================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE Column_Name

            WHEN 'Date_Key'
                THEN 'Surrogate key identifying the coaching date.'

            WHEN 'Employee_Key'
                THEN 'Surrogate key identifying the employee receiving or associated with coaching.'

            WHEN 'Client_Key'
                THEN 'Surrogate key identifying the client associated with coaching.'

            WHEN 'Process_Key'
                THEN 'Surrogate key identifying the process associated with coaching.'

            WHEN 'Team_Key'
                THEN 'Surrogate key identifying the team associated with coaching.'

            WHEN 'Site_Key'
                THEN 'Surrogate key identifying the site associated with coaching.'

            WHEN 'Duration_Minutes'
                THEN 'Duration of the coaching session measured in minutes.'

            ELSE Business_Definition

        END,

    Data_Source =
        'Generated coaching dataset and ETL transformation logic.'

WHERE Table_Name = 'Fact_Coaching';
GO


/*==============================================================
  Workforce Fact
==============================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE Column_Name

            WHEN 'Date_Key'
                THEN 'Surrogate key identifying the workforce reporting date.'

            WHEN 'Shift_Key'
                THEN 'Surrogate key identifying the employee shift.'

            WHEN 'Shrinkage_Key'
                THEN 'Surrogate key identifying the shrinkage classification.'

            WHEN 'Hours'
                THEN 'Workforce hours recorded for the applicable date, shift, and shrinkage classification.'

            ELSE Business_Definition

        END,

    Data_Source =
        'Generated workforce dataset and ETL transformation logic.'

WHERE Table_Name = 'Fact_Workforce';
GO


/*==============================================================
  Finance Fact
==============================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE Column_Name

            WHEN 'Date_Key'
                THEN 'Surrogate key identifying the finance reporting date.'

            WHEN 'Billing_Model_Key'
                THEN 'Surrogate key identifying the applicable billing model.'

            WHEN 'Cost_Center_Key'
                THEN 'Surrogate key identifying the cost center.'

            WHEN 'Revenue_USD'
                THEN 'Revenue generated under the applicable billing model in US dollars.'

            ELSE Business_Definition

        END,

    Data_Source =
        'Generated finance dataset and ETL transformation logic.'

WHERE Table_Name = 'Fact_Finance';
GO

PRINT 'Business metadata updated successfully.';

/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 49C_Populate_Fact_Transformation_Rules.sql
Purpose      : Populate Transformation Rules for Fact Tables
Author       : Tushar Mehta
Created Date : 10-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO


/*==============================================================
  FACT OPERATIONS
==============================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE Column_Name

            WHEN 'Fact_Operations_Key'
                THEN 'Unique surrogate key identifying each operations fact record.'

            WHEN 'Error_Code_Key'
                THEN 'Surrogate key identifying the error code associated with the operation.'

            WHEN 'Appeal_Decision_Key'
                THEN 'Surrogate key identifying the appeal decision associated with the operation.'

            WHEN 'Billing_Model_Key'
                THEN 'Surrogate key identifying the billing model associated with the operation.'

            WHEN 'Cost_Center_Key'
                THEN 'Surrogate key identifying the cost center associated with the operation.'

            WHEN 'Shrinkage_Key'
                THEN 'Surrogate key identifying the shrinkage classification associated with the operation.'

            WHEN 'Created_Date'
                THEN 'Timestamp indicating when the warehouse record was created.'

            WHEN 'Modified_Date'
                THEN 'Timestamp indicating the most recent modification to the warehouse record.'

            ELSE Business_Definition

        END,

    Transformation_Rule =
        CASE Column_Name

            WHEN 'Fact_Operations_Key'
                THEN 'Generated as an identity surrogate key when the fact record is inserted.'

            WHEN 'Date_Key'
                THEN 'Mapped to Dim_Date using the reporting date.'

            WHEN 'Employee_Key'
                THEN 'Mapped to Dim_Employee using the employee identifier.'

            WHEN 'Client_Key'
                THEN 'Mapped to Dim_Client using the client identifier.'

            WHEN 'Process_Key'
                THEN 'Mapped to Dim_Process using the process identifier.'

            WHEN 'Team_Key'
                THEN 'Mapped to Dim_Team using the team identifier.'

            WHEN 'Site_Key'
                THEN 'Mapped to Dim_Site using the site identifier.'

            WHEN 'Shift_Key'
                THEN 'Mapped to Dim_Shift using the shift identifier.'

            WHEN 'Policy_Key'
                THEN 'Mapped to Dim_Policy using the policy identifier.'

            WHEN 'Error_Code_Key'
                THEN 'Mapped to Dim_Error_Code using the applicable error code.'

            WHEN 'Appeal_Decision_Key'
                THEN 'Mapped to Dim_Appeal_Decision using the applicable appeal decision.'

            WHEN 'Billing_Model_Key'
                THEN 'Mapped to Dim_Billing_Model using the applicable billing model.'

            WHEN 'Cost_Center_Key'
                THEN 'Mapped to Dim_Cost_Center using the applicable cost center.'

            WHEN 'Shrinkage_Key'
                THEN 'Mapped to Dim_Shrinkage using the applicable shrinkage classification.'

            WHEN 'Cases_Handled'
                THEN 'Generated during Fact_Operations measure generation.'

            WHEN 'Cases_Reviewed'
                THEN 'Generated during Fact_Operations measure generation.'

            WHEN 'Cases_Approved'
                THEN 'Generated from operational activity during Fact_Operations measure generation.'

            WHEN 'Cases_Rejected'
                THEN 'Generated from operational activity during Fact_Operations measure generation.'

            WHEN 'QA_Score'
                THEN 'Generated during Fact_Operations measure generation using the defined QA scoring logic.'

            WHEN 'AHT_Minutes'
                THEN 'Generated during Fact_Operations measure generation.'

            WHEN 'SLA_Compliance_Pct'
                THEN 'Generated during Fact_Operations measure generation.'

            WHEN 'Productive_Hours'
                THEN 'Generated during Fact_Operations measure generation.'

            WHEN 'Revenue_USD'
                THEN 'Generated during Fact_Operations measure generation based on the applicable billing logic.'

            WHEN 'Operating_Cost_USD'
                THEN 'Generated during Fact_Operations measure generation based on operational cost logic.'

            WHEN 'Created_Date'
                THEN 'Assigned when the warehouse record is inserted.'

            WHEN 'Modified_Date'
                THEN 'Updated when the warehouse record is modified; remains NULL when no modification has occurred.'

            ELSE Transformation_Rule

        END

WHERE Table_Name = 'Fact_Operations';
GO


/*==============================================================
  FACT QA
==============================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE Column_Name

            WHEN 'QA_Key'
                THEN 'Unique surrogate key identifying each QA fact record.'

            WHEN 'Created_Date'
                THEN 'Timestamp indicating when the warehouse record was created.'

            WHEN 'Modified_Date'
                THEN 'Timestamp indicating the most recent modification to the warehouse record.'

            ELSE Business_Definition

        END,

    Transformation_Rule =
        CASE Column_Name

            WHEN 'QA_Key'
                THEN 'Generated as an identity surrogate key when the fact record is inserted.'

            WHEN 'Date_Key'
                THEN 'Mapped to Dim_Date using the QA audit date.'

            WHEN 'Policy_Key'
                THEN 'Mapped to Dim_Policy using the applicable policy.'

            WHEN 'Error_Code_Key'
                THEN 'Mapped to Dim_Error_Code using the applicable error code.'

            WHEN 'QA_Score'
                THEN 'Generated during QA fact generation using the defined QA scoring logic.'

            WHEN 'Created_Date'
                THEN 'Assigned when the warehouse record is inserted.'

            WHEN 'Modified_Date'
                THEN 'Updated when the warehouse record is modified; remains NULL when no modification has occurred.'

            ELSE Transformation_Rule

        END

WHERE Table_Name = 'Fact_QA';
GO


/*==============================================================
  FACT APPEALS
==============================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE Column_Name

            WHEN 'Appeal_Key'
                THEN 'Unique surrogate key identifying each appeal fact record.'

            WHEN 'Created_Date'
                THEN 'Timestamp indicating when the warehouse record was created.'

            WHEN 'Modified_Date'
                THEN 'Timestamp indicating the most recent modification to the warehouse record.'

            ELSE Business_Definition

        END,

    Transformation_Rule =
        CASE Column_Name

            WHEN 'Appeal_Key'
                THEN 'Generated as an identity surrogate key when the fact record is inserted.'

            WHEN 'Date_Key'
                THEN 'Mapped to Dim_Date using the appeal date.'

            WHEN 'Policy_Key'
                THEN 'Mapped to Dim_Policy using the applicable policy.'

            WHEN 'Appeal_Decision_Key'
                THEN 'Mapped to Dim_Appeal_Decision using the applicable appeal decision.'

            WHEN 'Resolution_Time'
                THEN 'Generated during appeal fact generation using the defined resolution time logic.'

            WHEN 'Created_Date'
                THEN 'Assigned when the warehouse record is inserted.'

            WHEN 'Modified_Date'
                THEN 'Updated when the warehouse record is modified; remains NULL when no modification has occurred.'

            ELSE Transformation_Rule

        END

WHERE Table_Name = 'Fact_Appeals';
GO


/*==============================================================
  FACT COACHING
==============================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE Column_Name

            WHEN 'Coaching_Key'
                THEN 'Unique surrogate key identifying each coaching fact record.'

            WHEN 'Created_Date'
                THEN 'Timestamp indicating when the warehouse record was created.'

            WHEN 'Modified_Date'
                THEN 'Timestamp indicating the most recent modification to the warehouse record.'

            ELSE Business_Definition

        END,

    Transformation_Rule =
        CASE Column_Name

            WHEN 'Coaching_Key'
                THEN 'Generated as an identity surrogate key when the fact record is inserted.'

            WHEN 'Date_Key'
                THEN 'Mapped to Dim_Date using the coaching date.'

            WHEN 'Employee_Key'
                THEN 'Mapped to Dim_Employee using the employee identifier.'

            WHEN 'Client_Key'
                THEN 'Mapped to Dim_Client using the client identifier.'

            WHEN 'Process_Key'
                THEN 'Mapped to Dim_Process using the process identifier.'

            WHEN 'Team_Key'
                THEN 'Mapped to Dim_Team using the team identifier.'

            WHEN 'Site_Key'
                THEN 'Mapped to Dim_Site using the site identifier.'

            WHEN 'Duration_Minutes'
                THEN 'Generated during coaching fact generation using the defined coaching duration logic.'

            WHEN 'Created_Date'
                THEN 'Assigned when the warehouse record is inserted.'

            WHEN 'Modified_Date'
                THEN 'Updated when the warehouse record is modified; remains NULL when no modification has occurred.'

            ELSE Transformation_Rule

        END

WHERE Table_Name = 'Fact_Coaching';
GO


/*==============================================================
  FACT WORKFORCE
==============================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE Column_Name

            WHEN 'Workforce_Key'
                THEN 'Unique surrogate key identifying each workforce fact record.'

            WHEN 'Created_Date'
                THEN 'Timestamp indicating when the warehouse record was created.'

            WHEN 'Modified_Date'
                THEN 'Timestamp indicating the most recent modification to the warehouse record.'

            ELSE Business_Definition

        END,

    Transformation_Rule =
        CASE Column_Name

            WHEN 'Workforce_Key'
                THEN 'Generated as an identity surrogate key when the fact record is inserted.'

            WHEN 'Date_Key'
                THEN 'Mapped to Dim_Date using the workforce reporting date.'

            WHEN 'Shift_Key'
                THEN 'Mapped to Dim_Shift using the applicable shift.'

            WHEN 'Shrinkage_Key'
                THEN 'Mapped to Dim_Shrinkage using the applicable shrinkage classification.'

            WHEN 'Hours'
                THEN 'Generated during workforce fact generation using the defined workforce hours logic.'

            WHEN 'Created_Date'
                THEN 'Assigned when the warehouse record is inserted.'

            WHEN 'Modified_Date'
                THEN 'Updated when the warehouse record is modified; remains NULL when no modification has occurred.'

            ELSE Transformation_Rule

        END

WHERE Table_Name = 'Fact_Workforce';
GO


/*==============================================================
  FACT FINANCE
==============================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE Column_Name

            WHEN 'Finance_Key'
                THEN 'Unique surrogate key identifying each finance fact record.'

            WHEN 'Created_Date'
                THEN 'Timestamp indicating when the warehouse record was created.'

            WHEN 'Modified_Date'
                THEN 'Timestamp indicating the most recent modification to the warehouse record.'

            ELSE Business_Definition

        END,

    Transformation_Rule =
        CASE Column_Name

            WHEN 'Finance_Key'
                THEN 'Generated as an identity surrogate key when the fact record is inserted.'

            WHEN 'Date_Key'
                THEN 'Mapped to Dim_Date using the finance reporting date.'

            WHEN 'Billing_Model_Key'
                THEN 'Mapped to Dim_Billing_Model using the applicable billing model.'

            WHEN 'Cost_Center_Key'
                THEN 'Mapped to Dim_Cost_Center using the applicable cost center.'

            WHEN 'Revenue_USD'
                THEN 'Generated during finance fact generation using the defined revenue logic.'

            WHEN 'Created_Date'
                THEN 'Assigned when the warehouse record is inserted.'

            WHEN 'Modified_Date'
                THEN 'Updated when the warehouse record is modified; remains NULL when no modification has occurred.'

            ELSE Transformation_Rule

        END

WHERE Table_Name = 'Fact_Finance';
GO


PRINT 'Fact table business definitions and transformation rules populated successfully.';
GO

SELECT
    Table_Name,
    COUNT(*) AS Total_Columns,
    SUM(
        CASE
            WHEN Business_Definition IS NOT NULL
            THEN 1 ELSE 0
        END
    ) AS Defined_Business_Columns,
    SUM(
        CASE
            WHEN Transformation_Rule IS NOT NULL
            THEN 1 ELSE 0
        END
    ) AS Defined_Transformation_Rules
FROM dbo.Data_Dictionary
WHERE Table_Name LIKE 'Fact_%'
GROUP BY Table_Name
ORDER BY Table_Name;

SELECT
    Table_Name,
    Column_Name,
    Business_Definition,
    Data_Source,
    Transformation_Rule
FROM dbo.Data_Dictionary
WHERE Table_Name LIKE 'Fact_%'
ORDER BY Table_Name, Dictionary_Key;