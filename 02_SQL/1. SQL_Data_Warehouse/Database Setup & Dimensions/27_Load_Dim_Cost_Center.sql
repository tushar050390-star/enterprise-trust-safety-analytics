/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 27_Load_Dim_Cost_Center.sql
Author       : Tushar Mehta
Purpose      : Load Cost Center Dimension Master Data
Created On   : 05-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

--============================================================
-- Load Cost Center Master Data
-- Inserts only new records
--============================================================

INSERT INTO dbo.Dim_Cost_Center
(
    Cost_Center_Code,
    Cost_Center_Name
)
SELECT
    Source.Cost_Center_Code,
    Source.Cost_Center_Name
FROM
(
    VALUES
        ('CC100','Trust & Safety'),
        ('CC200','Fraud Operations'),
        ('CC300','Appeals'),
        ('CC400','Risk Operations'),
        ('CC500','Quality Assurance'),
        ('CC600','Training')
) AS Source
(
    Cost_Center_Code,
    Cost_Center_Name
)

WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Dim_Cost_Center Target
    WHERE Target.Cost_Center_Code = Source.Cost_Center_Code
);

GO

PRINT 'Dim_Cost_Center loaded successfully.';
GO