/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 14_Create_Numbers_Table.sql
Author       : Tushar Mehta
Purpose      : Creates a reusable Numbers (Tally) table
Created On   : 03-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

--============================================================
-- Drop table if it already exists
--============================================================

IF OBJECT_ID('dbo.Numbers', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Numbers;
END;
GO

--============================================================
-- Create Numbers Table
--============================================================

CREATE TABLE dbo.Numbers
(
    Number INT NOT NULL
        CONSTRAINT PK_Numbers
        PRIMARY KEY CLUSTERED
);
GO

--============================================================
-- Populate Numbers Table (0 - 50000)
--============================================================

WITH NumberGenerator AS
(
    SELECT TOP (50001)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS Number
    FROM sys.all_objects A
    CROSS JOIN sys.all_objects B
)

INSERT INTO dbo.Numbers
(
    Number
)
SELECT Number
FROM NumberGenerator;
GO

PRINT 'Numbers table created successfully.';
GO
