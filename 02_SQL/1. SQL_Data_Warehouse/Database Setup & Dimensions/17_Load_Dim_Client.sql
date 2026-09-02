/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 17_Load_Dim_Client.sql
Author       : Tushar Mehta
Purpose      : Load Client Dimension Master Data
Created On   : 04-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

--============================================================
-- Load Client Master Data
-- Inserts only new records
--============================================================

INSERT INTO dbo.Dim_Client
(
    Client_Name
)
SELECT
    Source.Client_Name
FROM
(
    VALUES
        ('Apex Digital'),
        ('Nova Media'),
        ('Vertex AI'),
        ('Orion Solutions'),
        ('Quantum Platforms'),
        ('Horizon Tech'),
        ('Pinnacle Services'),
        ('Nimbus Interactive')
) AS Source (Client_Name)

WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Dim_Client Target
    WHERE Target.Client_Name = Source.Client_Name
);

GO

PRINT 'Dim_Client loaded successfully.';
GO

