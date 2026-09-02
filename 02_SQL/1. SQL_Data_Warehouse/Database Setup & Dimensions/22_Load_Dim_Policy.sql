/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 22_Load_Dim_Policy.sql
Author       : Tushar Mehta
Purpose      : Load Policy Dimension Master Data
Created On   : 04-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

--============================================================
-- Load Policy Master Data
-- Inserts only new records
--============================================================

INSERT INTO dbo.Dim_Policy
(
    Policy_Name,
    Policy_Category
)
SELECT
    Source.Policy_Name,
    Source.Policy_Category
FROM
(
    VALUES
        ('Spam & Scam',          'Integrity'),
        ('Hate Speech',          'Safety'),
        ('Harassment',           'Safety'),
        ('Violence',             'Safety'),
        ('Adult Content',        'Sensitive Content'),
        ('Child Safety',         'Critical Safety'),
        ('Misinformation',       'Integrity'),
        ('Copyright',            'Intellectual Property')
) AS Source
(
    Policy_Name,
    Policy_Category
)

WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Dim_Policy Target
    WHERE Target.Policy_Name = Source.Policy_Name
);

GO

PRINT 'Dim_Policy loaded successfully.';
GO