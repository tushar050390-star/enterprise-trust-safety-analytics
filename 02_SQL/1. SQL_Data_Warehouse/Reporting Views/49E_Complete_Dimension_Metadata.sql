/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 49E_Complete_Dimension_Metadata.sql
Purpose      : Complete Business Metadata for Dimension Tables
Author       : Tushar Mehta
Created Date : 10-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO


/*====================================================================
  1. DATA SOURCE FOR ALL DIMENSIONS
====================================================================*/

UPDATE dbo.Data_Dictionary
SET
    Data_Source =
        CASE Table_Name

            WHEN 'Dim_Appeal_Decision'
                THEN 'Generated and populated from the Appeal Decision reference data.'

            WHEN 'Dim_Billing_Model'
                THEN 'Generated and populated from the Billing Model reference data.'

            WHEN 'Dim_Client'
                THEN 'Generated and populated from the Client reference data.'

            WHEN 'Dim_Cost_Center'
                THEN 'Generated and populated from the Cost Center reference data.'

            WHEN 'Dim_Date'
                THEN 'Generated calendar dimension populated using the warehouse date range.'

            WHEN 'Dim_Employee'
                THEN 'Generated and populated from employee reference data.'

            WHEN 'Dim_Error_Code'
                THEN 'Generated and populated from Error Code reference data.'

            WHEN 'Dim_Policy'
                THEN 'Generated and populated from Policy reference data.'

            WHEN 'Dim_Process'
                THEN 'Generated and populated from Process reference data.'

            WHEN 'Dim_Shift'
                THEN 'Generated and populated from Shift reference data.'

            WHEN 'Dim_Shrinkage'
                THEN 'Generated and populated from Shrinkage reference data.'

            WHEN 'Dim_Site'
                THEN 'Generated and populated from Site reference data.'

            WHEN 'Dim_Team'
                THEN 'Generated and populated from Team reference data.'

            ELSE Data_Source

        END
WHERE Table_Name LIKE 'Dim_%';
GO


/*====================================================================
  2. DIM APPEAL DECISION
====================================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE Column_Name

            WHEN 'Appeal_Decision_Key'
                THEN 'Unique surrogate key identifying an appeal decision.'

            WHEN 'Appeal_Decision'
                THEN 'Business decision or outcome assigned to an appeal.'

            WHEN 'Created_Date'
                THEN 'Timestamp indicating when the dimension record was created.'

            WHEN 'Modified_Date'
                THEN 'Timestamp indicating the most recent modification to the dimension record.'

            ELSE Business_Definition

        END,

    Transformation_Rule =
        CASE Column_Name

            WHEN 'Appeal_Decision_Key'
                THEN 'Generated as an identity surrogate key during dimension creation.'

            WHEN 'Appeal_Decision'
                THEN 'Loaded from the appeal decision reference values.'

            WHEN 'Created_Date'
                THEN 'Assigned when the dimension record is inserted.'

            WHEN 'Modified_Date'
                THEN 'Updated when the dimension record is modified.'

            ELSE Transformation_Rule

        END

WHERE Table_Name = 'Dim_Appeal_Decision';
GO


/*====================================================================
  3. DIM BILLING MODEL
====================================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE Column_Name

            WHEN 'Billing_Model_Key'
                THEN 'Unique surrogate key identifying the billing model.'

            WHEN 'Billing_Model'
                THEN 'Business billing model used to determine how services are charged.'

            WHEN 'Created_Date'
                THEN 'Timestamp indicating when the dimension record was created.'

            WHEN 'Modified_Date'
                THEN 'Timestamp indicating the most recent modification to the dimension record.'

            ELSE Business_Definition

        END,

    Transformation_Rule =
        CASE Column_Name

            WHEN 'Billing_Model_Key'
                THEN 'Generated as an identity surrogate key during dimension creation.'

            WHEN 'Billing_Model'
                THEN 'Loaded from the billing model reference values.'

            WHEN 'Created_Date'
                THEN 'Assigned when the dimension record is inserted.'

            WHEN 'Modified_Date'
                THEN 'Updated when the dimension record is modified.'

            ELSE Transformation_Rule

        END

WHERE Table_Name = 'Dim_Billing_Model';
GO


/*====================================================================
  4. DIM DATE
====================================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE Column_Name

            WHEN 'Date_Key'
                THEN 'Unique surrogate key identifying the reporting date.'

            WHEN 'Is_Weekend'
                THEN 'Indicator identifying whether the date falls on a weekend.'

            WHEN 'Fiscal_Month'
                THEN 'Fiscal month associated with the reporting date.'

            WHEN 'Fiscal_Quarter'
                THEN 'Fiscal quarter associated with the reporting date.'

            WHEN 'Fiscal_Year'
                THEN 'Fiscal year associated with the reporting date.'

            ELSE Business_Definition

        END,

    Transformation_Rule =
        CASE Column_Name

            WHEN 'Date_Key'
                THEN 'Generated as a date-based surrogate key during calendar dimension population.'

            WHEN 'Is_Weekend'
                THEN 'Derived from the day of week associated with Full_Date.'

            WHEN 'Fiscal_Month'
                THEN 'Derived from the applicable fiscal calendar logic.'

            WHEN 'Fiscal_Quarter'
                THEN 'Derived from the applicable fiscal calendar logic.'

            WHEN 'Fiscal_Year'
                THEN 'Derived from the applicable fiscal calendar logic.'

            ELSE Transformation_Rule

        END

WHERE Table_Name = 'Dim_Date';
GO


/*====================================================================
  5. DIM ERROR CODE
====================================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE Column_Name

            WHEN 'Error_Code_Key'
                THEN 'Unique surrogate key identifying an error code.'

            WHEN 'Error_Code'
                THEN 'Business code identifying a specific operational error.'

            WHEN 'Error_Description'
                THEN 'Business description explaining the operational error.'

            WHEN 'Error_Category'
                THEN 'Business classification grouping related error codes.'

            WHEN 'Created_Date'
                THEN 'Timestamp indicating when the dimension record was created.'

            WHEN 'Modified_Date'
                THEN 'Timestamp indicating the most recent modification to the dimension record.'

            ELSE Business_Definition

        END,

    Transformation_Rule =
        CASE Column_Name

            WHEN 'Error_Code_Key'
                THEN 'Generated as an identity surrogate key during dimension creation.'

            WHEN 'Error_Code'
                THEN 'Loaded from the error code reference values.'

            WHEN 'Error_Description'
                THEN 'Loaded from the error code reference description.'

            WHEN 'Error_Category'
                THEN 'Loaded or classified according to the error code reference category.'

            WHEN 'Created_Date'
                THEN 'Assigned when the dimension record is inserted.'

            WHEN 'Modified_Date'
                THEN 'Updated when the dimension record is modified.'

            ELSE Transformation_Rule

        END

WHERE Table_Name = 'Dim_Error_Code';
GO


/*====================================================================
  6. DIM POLICY
====================================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE Column_Name

            WHEN 'Policy_Key'
                THEN 'Unique surrogate key identifying a policy.'

            WHEN 'Policy_Name'
                THEN 'Name of the operational policy.'

            WHEN 'Policy_Category'
                THEN 'Business category used to classify the policy.'

            WHEN 'Created_Date'
                THEN 'Timestamp indicating when the dimension record was created.'

            WHEN 'Modified_Date'
                THEN 'Timestamp indicating the most recent modification to the dimension record.'

            ELSE Business_Definition

        END,

    Transformation_Rule =
        CASE Column_Name

            WHEN 'Policy_Key'
                THEN 'Generated as an identity surrogate key during dimension creation.'

            WHEN 'Policy_Name'
                THEN 'Loaded from the policy reference values.'

            WHEN 'Policy_Category'
                THEN 'Loaded from the policy reference classification.'

            WHEN 'Created_Date'
                THEN 'Assigned when the dimension record is inserted.'

            WHEN 'Modified_Date'
                THEN 'Updated when the dimension record is modified.'

            ELSE Transformation_Rule

        END

WHERE Table_Name = 'Dim_Policy';
GO


/*====================================================================
  7. DIM SHIFT
====================================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE Column_Name

            WHEN 'Shift_Key'
                THEN 'Unique surrogate key identifying a workforce shift.'

            WHEN 'Shift_Name'
                THEN 'Name identifying the workforce shift.'

            WHEN 'Shift_Start_Time'
                THEN 'Scheduled start time of the workforce shift.'

            WHEN 'Shift_End_Time'
                THEN 'Scheduled end time of the workforce shift.'

            WHEN 'Created_Date'
                THEN 'Timestamp indicating when the dimension record was created.'

            WHEN 'Modified_Date'
                THEN 'Timestamp indicating the most recent modification to the dimension record.'

            ELSE Business_Definition

        END,

    Transformation_Rule =
        CASE Column_Name

            WHEN 'Shift_Key'
                THEN 'Generated as an identity surrogate key during dimension creation.'

            WHEN 'Shift_Name'
                THEN 'Loaded from the shift reference values.'

            WHEN 'Shift_Start_Time'
                THEN 'Loaded from the shift schedule reference values.'

            WHEN 'Shift_End_Time'
                THEN 'Loaded from the shift schedule reference values.'

            WHEN 'Created_Date'
                THEN 'Assigned when the dimension record is inserted.'

            WHEN 'Modified_Date'
                THEN 'Updated when the dimension record is modified.'

            ELSE Transformation_Rule

        END

WHERE Table_Name = 'Dim_Shift';
GO


/*====================================================================
  8. DIM SHRINKAGE
====================================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE Column_Name

            WHEN 'Shrinkage_Key'
                THEN 'Unique surrogate key identifying a shrinkage classification.'

            WHEN 'Shrinkage_Type'
                THEN 'Business classification identifying the type of workforce shrinkage.'

            WHEN 'Is_Planned'
                THEN 'Indicator identifying whether the shrinkage type is planned.'

            WHEN 'Created_Date'
                THEN 'Timestamp indicating when the dimension record was created.'

            WHEN 'Modified_Date'
                THEN 'Timestamp indicating the most recent modification to the dimension record.'

            ELSE Business_Definition

        END,

    Transformation_Rule =
        CASE Column_Name

            WHEN 'Shrinkage_Key'
                THEN 'Generated as an identity surrogate key during dimension creation.'

            WHEN 'Shrinkage_Type'
                THEN 'Loaded from the shrinkage reference values.'

            WHEN 'Is_Planned'
                THEN 'Derived from the business classification of the shrinkage type.'

            WHEN 'Created_Date'
                THEN 'Assigned when the dimension record is inserted.'

            WHEN 'Modified_Date'
                THEN 'Updated when the dimension record is modified.'

            ELSE Transformation_Rule

        END

WHERE Table_Name = 'Dim_Shrinkage';
GO


/*====================================================================
  9. DIM SITE
====================================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE Column_Name

            WHEN 'Site_Key'
                THEN 'Unique surrogate key identifying an operational site.'

            WHEN 'Site_Name'
                THEN 'Name identifying the operational site.'

            WHEN 'Country'
                THEN 'Country in which the operational site is located.'

            WHEN 'Created_Date'
                THEN 'Timestamp indicating when the dimension record was created.'

            WHEN 'Modified_Date'
                THEN 'Timestamp indicating the most recent modification to the dimension record.'

            ELSE Business_Definition

        END,

    Transformation_Rule =
        CASE Column_Name

            WHEN 'Site_Key'
                THEN 'Generated as an identity surrogate key during dimension creation.'

            WHEN 'Site_Name'
                THEN 'Loaded from the site reference values.'

            WHEN 'Country'
                THEN 'Loaded from the site reference location values.'

            WHEN 'Created_Date'
                THEN 'Assigned when the dimension record is inserted.'

            WHEN 'Modified_Date'
                THEN 'Updated when the dimension record is modified.'

            ELSE Transformation_Rule

        END

WHERE Table_Name = 'Dim_Site';
GO


/*====================================================================
  10. DIM TEAM
====================================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        CASE Column_Name

            WHEN 'Team_Key'
                THEN 'Unique surrogate key identifying an operational team.'

            WHEN 'Team_Name'
                THEN 'Name identifying the operational team.'

            WHEN 'Team_Description'
                THEN 'Business description of the operational team and its responsibility.'

            WHEN 'Created_Date'
                THEN 'Timestamp indicating when the dimension record was created.'

            WHEN 'Modified_Date'
                THEN 'Timestamp indicating the most recent modification to the dimension record.'

            ELSE Business_Definition

        END,

    Transformation_Rule =
        CASE Column_Name

            WHEN 'Team_Key'
                THEN 'Generated as an identity surrogate key during dimension creation.'

            WHEN 'Team_Name'
                THEN 'Loaded from the team reference values.'

            WHEN 'Team_Description'
                THEN 'Loaded from the team reference description.'

            WHEN 'Created_Date'
                THEN 'Assigned when the dimension record is inserted.'

            WHEN 'Modified_Date'
                THEN 'Updated when the dimension record is modified.'

            ELSE Transformation_Rule

        END

WHERE Table_Name = 'Dim_Team';
GO


/*====================================================================
  11. FINAL AUDIT COLUMN RULES
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
                THEN 'Updated when the dimension record is modified.'

            ELSE Transformation_Rule

        END

WHERE Table_Name LIKE 'Dim_%';
GO


PRINT '49E dimension metadata completed successfully.';
GO

SELECT
    COUNT(*) AS Total_Dimension_Columns,

    SUM(
        CASE
            WHEN Business_Definition IS NULL
            THEN 1
            ELSE 0
        END
    ) AS Missing_Business_Definitions,

    SUM(
        CASE
            WHEN Data_Source IS NULL
            THEN 1
            ELSE 0
        END
    ) AS Missing_Data_Sources,

    SUM(
        CASE
            WHEN Transformation_Rule IS NULL
            THEN 1
            ELSE 0
        END
    ) AS Missing_Transformation_Rules

FROM dbo.Data_Dictionary
WHERE Table_Name LIKE 'Dim_%';

SELECT
    Table_Name,
    Column_Name,
    Data_Type,
    Is_Nullable,
    Is_Primary_Key,
    Is_Foreign_Key,
    Business_Definition,
    Data_Source,
    Transformation_Rule
FROM dbo.Data_Dictionary
ORDER BY
    Table_Name,
    Dictionary_Key;