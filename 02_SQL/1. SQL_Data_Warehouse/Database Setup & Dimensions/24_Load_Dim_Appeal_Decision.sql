/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 24_Load_Dim_Appeal_Decision.sql
Author       : Tushar Mehta
Purpose      : Load Appeal Decision Dimension Master Data
Created On   : 05-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

--============================================================
-- Load Appeal Decision Master Data
-- Inserts only new records
--============================================================

INSERT INTO dbo.Dim_Appeal_Decision
(
    Appeal_Decision
)
SELECT
    Source.Appeal_Decision
FROM
(
    VALUES
        ('Upheld'),
        ('Reversed'),
        ('Partially Reversed')
) AS Source
(
    Appeal_Decision
)

WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Dim_Appeal_Decision Target
    WHERE Target.Appeal_Decision = Source.Appeal_Decision
);

GO

PRINT 'Dim_Appeal_Decision loaded successfully.';
GO
