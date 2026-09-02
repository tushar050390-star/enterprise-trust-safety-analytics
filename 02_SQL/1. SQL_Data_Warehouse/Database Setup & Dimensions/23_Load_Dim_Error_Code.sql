/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 23_Load_Dim_Error_Code.sql
Author       : Tushar Mehta
Purpose      : Load Error Code Dimension Master Data
Created On   : 05-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

--============================================================
-- Load Error Code Master Data
-- Inserts only new records
--============================================================

INSERT INTO dbo.Dim_Error_Code
(
    Error_Code,
    Error_Category,
    Error_Description
)
SELECT
    Source.Error_Code,
    Source.Error_Category,
    Source.Error_Description
FROM
(
    VALUES
        ('EC001','Policy Interpretation','Incorrect interpretation of policy guidelines'),
        ('EC002','Missed Violation','Violating content or account action was missed'),
        ('EC003','False Positive','Non-violating content/action incorrectly enforced'),
        ('EC004','Evidence Review','Available evidence was not reviewed correctly'),
        ('EC005','Process Compliance','Standard operating procedure was not followed'),
        ('EC006','Documentation','Required case notes or documentation were incomplete'),
        ('EC007','Escalation','Case was incorrectly escalated or not escalated when required'),
        ('EC008','System Error','Tool limitation or system issue affected the decision')
) AS Source
(
    Error_Code,
    Error_Category,
    Error_Description
)

WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Dim_Error_Code Target
    WHERE Target.Error_Code = Source.Error_Code
);

GO

PRINT 'Dim_Error_Code loaded successfully.';
GO

