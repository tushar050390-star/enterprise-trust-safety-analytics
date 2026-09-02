/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 49D_Populate_Dimension_Metadata.sql
Purpose      : Populate Business Definitions and Transformation Rules
               for the 13 Dimension Tables
Author       : Tushar Mehta
Created Date : 10-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO


/*====================================================================
  1. DIMENSION KEYS
====================================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE
            WHEN Is_Primary_Key = 'YES'
                THEN 'Unique surrogate key identifying the dimension record.'

            WHEN Is_Foreign_Key = 'YES'
                THEN 'Foreign key linking the dimension record to a related dimension.'

            ELSE Business_Definition
        END,

    Transformation_Rule =
        CASE
            WHEN Is_Primary_Key = 'YES'
                THEN 'Generated as a surrogate key during dimension record creation.'

            WHEN Is_Foreign_Key = 'YES'
                THEN 'Mapped to the corresponding dimension key during data generation or loading.'

            ELSE Transformation_Rule
        END

WHERE Table_Name IN
(
      'Dim_Appeal_Decision'
    , 'Dim_Billing_Model'
    , 'Dim_Client'
    , 'Dim_Cost_Center'
    , 'Dim_Date'
    , 'Dim_Employee'
    , 'Dim_Error_Code'
    , 'Dim_Policy'
    , 'Dim_Process'
    , 'Dim_Shift'
    , 'Dim_Shrinkage'
    , 'Dim_Site'
    , 'Dim_Team'
);
GO


/*====================================================================
  2. DATE ATTRIBUTES
====================================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE Column_Name

            WHEN 'Full_Date'
                THEN 'Calendar date used for reporting and time-based analysis.'

            WHEN 'Year_Number'
                THEN 'Calendar year associated with the reporting date.'

            WHEN 'Month_Number'
                THEN 'Numeric month associated with the reporting date.'

            WHEN 'Month_Name'
                THEN 'Name of the calendar month associated with the reporting date.'

            WHEN 'Quarter_Number'
                THEN 'Numeric quarter associated with the reporting date.'

            WHEN 'Quarter_Name'
                THEN 'Quarter label associated with the reporting date.'

            WHEN 'Day_Number'
                THEN 'Day number within the calendar month.'

            WHEN 'Day_Name'
                THEN 'Name of the day of the week.'

            WHEN 'Week_Number'
                THEN 'Calendar week number associated with the reporting date.'

            ELSE Business_Definition

        END,

    Transformation_Rule =
        CASE Column_Name

            WHEN 'Full_Date'
                THEN 'Generated from the calendar date during Dim_Date population.'

            WHEN 'Year_Number'
                THEN 'Derived from Full_Date.'

            WHEN 'Month_Number'
                THEN 'Derived from Full_Date.'

            WHEN 'Month_Name'
                THEN 'Derived from Full_Date.'

            WHEN 'Quarter_Number'
                THEN 'Derived from Full_Date.'

            WHEN 'Quarter_Name'
                THEN 'Derived from Full_Date.'

            WHEN 'Day_Number'
                THEN 'Derived from Full_Date.'

            WHEN 'Day_Name'
                THEN 'Derived from Full_Date.'

            WHEN 'Week_Number'
                THEN 'Derived from Full_Date.'

            ELSE Transformation_Rule

        END

WHERE Table_Name = 'Dim_Date';
GO


/*====================================================================
  3. COMMON DESCRIPTIVE ATTRIBUTES
====================================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE

            WHEN Column_Name IN
            (
                  'Client_Name'
                , 'Process_Name'
                , 'Team_Name'
                , 'Site_Name'
                , 'Shift_Name'
                , 'Policy_Name'
                , 'Error_Code'
                , 'Designation'
                , 'Decision_Name'
                , 'Billing_Model'
                , 'Billing_Model_Name'
                , 'Cost_Center_Name'
                , 'Shrinkage_Type'
            )
            THEN
                'Business descriptive attribute used to identify and classify '
                + REPLACE(Column_Name, '_', ' ') + '.'

            WHEN Column_Name LIKE '%_ID'
            THEN
                'Business identifier used to uniquely identify the related entity.'

            WHEN Column_Name LIKE '%_Code'
            THEN
                'Business code used to classify the related entity or activity.'

            WHEN Column_Name LIKE '%_Status'
            THEN
                'Status indicating the current state of the related business entity.'

            WHEN Column_Name LIKE '%_Date'
            THEN
                'Date associated with the related business entity or business event.'

            WHEN Column_Name LIKE 'Is_%'
            THEN
                'Boolean indicator identifying whether the applicable business condition is true.'

            ELSE Business_Definition

        END,

    Transformation_Rule =
        CASE

            WHEN Column_Name LIKE '%_Name'
            THEN
                'Stored as a descriptive attribute during dimension record creation.'

            WHEN Column_Name LIKE '%_ID'
            THEN
                'Loaded from the source entity identifier and retained as a business identifier.'

            WHEN Column_Name LIKE '%_Code'
            THEN
                'Loaded from the applicable source or generated reference code.'

            WHEN Column_Name LIKE '%_Status'
            THEN
                'Loaded or generated based on the applicable business status.'

            WHEN Column_Name LIKE '%_Date'
            THEN
                'Loaded from the applicable source date or generated during dimension creation.'

            WHEN Column_Name LIKE 'Is_%'
            THEN
                'Derived as a business indicator during dimension creation.'

            ELSE Transformation_Rule

        END

WHERE Table_Name IN
(
      'Dim_Appeal_Decision'
    , 'Dim_Billing_Model'
    , 'Dim_Client'
    , 'Dim_Cost_Center'
    , 'Dim_Date'
    , 'Dim_Employee'
    , 'Dim_Error_Code'
    , 'Dim_Policy'
    , 'Dim_Process'
    , 'Dim_Shift'
    , 'Dim_Shrinkage'
    , 'Dim_Site'
    , 'Dim_Team'
);
GO


/*====================================================================
  4. EMPLOYEE-SPECIFIC ATTRIBUTES
====================================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE Column_Name

            WHEN 'Employee_ID'
                THEN 'Business identifier assigned to the employee.'

            WHEN 'Employee_Name'
                THEN 'Name of the employee.'

            WHEN 'Hire_Date'
                THEN 'Date on which the employee joined the organization.'

            WHEN 'Employment_Status'
                THEN 'Current employment status of the employee.'

            WHEN 'Designation'
                THEN 'Job designation or role held by the employee.'

            ELSE Business_Definition

        END,

    Transformation_Rule =
        CASE Column_Name

            WHEN 'Employee_ID'
                THEN 'Loaded from the employee source identifier.'

            WHEN 'Employee_Name'
                THEN 'Loaded from the employee source data.'

            WHEN 'Hire_Date'
                THEN 'Loaded from the employee source hire date.'

            WHEN 'Employment_Status'
                THEN 'Loaded or standardized from the employee source status.'

            WHEN 'Designation'
                THEN 'Loaded from the employee source designation.'

            ELSE Transformation_Rule

        END

WHERE Table_Name = 'Dim_Employee';
GO


/*====================================================================
  5. AUDIT COLUMNS
====================================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE Column_Name

            WHEN 'Created_Date'
                THEN 'Timestamp indicating when the warehouse dimension record was created.'

            WHEN 'Modified_Date'
                THEN 'Timestamp indicating the most recent modification to the warehouse dimension record.'

            ELSE Business_Definition

        END,

    Transformation_Rule =
        CASE Column_Name

            WHEN 'Created_Date'
                THEN 'Assigned automatically when the dimension record is inserted.'

            WHEN 'Modified_Date'
                THEN 'Updated when the dimension record is modified; remains NULL when no modification has occurred.'

            ELSE Transformation_Rule

        END

WHERE Table_Name IN
(
      'Dim_Appeal_Decision'
    , 'Dim_Billing_Model'
    , 'Dim_Client'
    , 'Dim_Cost_Center'
    , 'Dim_Date'
    , 'Dim_Employee'
    , 'Dim_Error_Code'
    , 'Dim_Policy'
    , 'Dim_Process'
    , 'Dim_Shift'
    , 'Dim_Shrinkage'
    , 'Dim_Site'
    , 'Dim_Team'
);
GO


PRINT 'Dimension business definitions and transformation rules populated successfully.';
GO

SELECT
    Table_Name,
    COUNT(*) AS Total_Columns,

    SUM(
        CASE
            WHEN Business_Definition IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS Defined_Business_Columns,

    SUM(
        CASE
            WHEN Transformation_Rule IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS Defined_Transformation_Rules

FROM dbo.Data_Dictionary

WHERE Table_Name LIKE 'Dim_%'

GROUP BY Table_Name

ORDER BY Table_Name;

SELECT
    Table_Name,
    Column_Name,
    Business_Definition,
    Data_Source,
    Transformation_Rule

FROM dbo.Data_Dictionary

WHERE Table_Name LIKE 'Dim_%'

ORDER BY
    Table_Name,
    Dictionary_Key;


	SELECT
    Table_Name,
    Column_Name,
    Business_Definition,
    Data_Source,
    Transformation_Rule
FROM dbo.Data_Dictionary
WHERE Table_Name LIKE 'Dim_%'
  AND
  (
       Business_Definition IS NULL
       OR Data_Source IS NULL
       OR Transformation_Rule IS NULL
  )
ORDER BY
    Table_Name,
    Dictionary_Key;