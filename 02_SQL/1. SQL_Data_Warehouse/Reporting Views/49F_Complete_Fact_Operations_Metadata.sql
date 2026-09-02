/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 49F_Complete_Fact_Operations_Metadata.sql
Purpose      : Complete Missing Business Definitions and Transformation Rules
Author       : Tushar Mehta
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO


/*==============================================================
  1. APPEALS RECEIVED
==============================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        'Number of appeals received as part of the operational workload.',

    Transformation_Rule =
        'Generated during Fact_Operations creation from the operational analytics dataset and stored as the appeals received measure.'
WHERE Table_Name = 'Fact_Operations'
  AND Column_Name = 'Appeals_Received'
  AND
  (
      Business_Definition IS NULL
      OR Transformation_Rule IS NULL
  );
GO


/*==============================================================
  2. IDLE HOURS
==============================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        'Number of hours during which operational capacity was available but not actively engaged in productive processing.',

    Transformation_Rule =
        'Generated during Fact_Operations creation from the operational analytics dataset and stored as the idle hours measure.'
WHERE Table_Name = 'Fact_Operations'
  AND Column_Name = 'Idle_Hours'
  AND
  (
      Business_Definition IS NULL
      OR Transformation_Rule IS NULL
  );
GO


/*==============================================================
  3. BREAK HOURS
==============================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        'Number of hours recorded as employee break time during the operational period.',

    Transformation_Rule =
        'Generated during Fact_Operations creation from the operational analytics dataset and stored as the break hours measure.'
WHERE Table_Name = 'Fact_Operations'
  AND Column_Name = 'Break_Hours'
  AND
  (
      Business_Definition IS NULL
      OR Transformation_Rule IS NULL
  );
GO


/*==============================================================
  4. BILLABLE HOURS
==============================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        'Number of hours considered eligible for client billing based on the operational activity.',

    Transformation_Rule =
        'Generated during Fact_Operations creation from the operational analytics dataset and stored as the billable hours measure.'
WHERE Table_Name = 'Fact_Operations'
  AND Column_Name = 'Billable_Hours'
  AND
  (
      Business_Definition IS NULL
      OR Transformation_Rule IS NULL
  );
GO


/*==============================================================
  5. OVERTIME HOURS
==============================================================*/

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        'Number of hours worked beyond the standard scheduled working hours.',

    Transformation_Rule =
        'Generated during Fact_Operations creation from the operational analytics dataset and stored as the overtime hours measure.'
WHERE Table_Name = 'Fact_Operations'
  AND Column_Name = 'Overtime_Hours'
  AND
  (
      Business_Definition IS NULL
      OR Transformation_Rule IS NULL
  );
GO


PRINT '49F Fact_Operations metadata completion completed successfully.';
GO


USE Enterprise_Trust_Safety_DWH;
GO

USE Enterprise_Trust_Safety_DWH;
GO

UPDATE dbo.Data_Dictionary
SET
    Business_Definition =
        'Number of appeals received as part of the operational workload.',

    Transformation_Rule =
        'Generated during Fact_Operations creation from the operational analytics dataset and stored as the appeals received measure.'
WHERE Dictionary_Key = 125;
GO

PRINT 'Dictionary_Key 125 metadata completed successfully.';
GO