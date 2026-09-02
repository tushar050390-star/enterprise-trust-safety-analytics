/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 26_Load_Dim_Billing_Model.sql
Author       : Tushar Mehta
Purpose      : Load Billing Model Dimension Master Data
Created On   : 05-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

--============================================================
-- Load Billing Model Master Data
-- Inserts only new records
--============================================================

INSERT INTO dbo.Dim_Billing_Model
(
    Billing_Model
)
SELECT
    Source.Billing_Model
FROM
(
    VALUES
        ('FTE'),
        ('Per Hour'),
        ('Per Transaction'),
        ('Hybrid')
) AS Source
(
    Billing_Model
)

WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Dim_Billing_Model Target
    WHERE Target.Billing_Model = Source.Billing_Model
);

GO

PRINT 'Dim_Billing_Model loaded successfully.';
GO