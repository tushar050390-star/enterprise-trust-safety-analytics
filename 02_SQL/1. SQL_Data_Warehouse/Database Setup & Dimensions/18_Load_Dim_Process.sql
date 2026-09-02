/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 18_Load_Dim_Process.sql
Author       : Tushar Mehta
Purpose      : Load Process Dimension Master Data
Created On   : 04-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

--============================================================
-- Load Process Master Data
-- Inserts only new records
--============================================================

INSERT INTO dbo.Dim_Process
(
    Process_Name
)
SELECT
    Source.Process_Name
FROM
(
    VALUES
        ('Content Moderation'),
        ('Appeals'),
        ('Fraud Investigation'),
        ('Risk Operations'),
        ('Trust & Safety'),
        ('Customer Support'),
        ('Payments Review'),
        ('Identity Verification')
) AS Source (Process_Name)

WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Dim_Process Target
    WHERE Target.Process_Name = Source.Process_Name
);

GO

PRINT 'Dim_Process loaded successfully.';
GO

SELECT COUNT(*) AS Total_Processes
FROM dbo.Dim_Process;
GO

SELECT *
FROM dbo.Dim_Process
ORDER BY Process_Key;
GO