/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 25_Load_Dim_Shrinkage.sql
Author       : Tushar Mehta
Purpose      : Load Shrinkage Dimension Master Data
Created On   : 05-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

--============================================================
-- Load Shrinkage Master Data
-- Inserts only new records
--============================================================

INSERT INTO dbo.Dim_Shrinkage
(
    Shrinkage_Type,
    Is_Planned
)
SELECT
    Source.Shrinkage_Type,
    Source.Is_Planned
FROM
(
    VALUES
        ('Planned', 1),
        ('Unplanned', 0)
) AS Source
(
    Shrinkage_Type,
    Is_Planned
)

WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Dim_Shrinkage Target
    WHERE Target.Shrinkage_Type = Source.Shrinkage_Type
);

GO

PRINT 'Dim_Shrinkage loaded successfully.';
GO