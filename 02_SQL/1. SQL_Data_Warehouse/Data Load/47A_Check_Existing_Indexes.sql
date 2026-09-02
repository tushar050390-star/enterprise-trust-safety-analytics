/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 47A_Check_Existing_Indexes.sql
Purpose      : Review existing indexes before optimization
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

SELECT
    OBJECT_NAME(i.object_id) AS Table_Name,
    i.name AS Index_Name,
    i.type_desc AS Index_Type,
    c.name AS Column_Name,
    ic.key_ordinal AS Key_Order
FROM sys.indexes i
INNER JOIN sys.index_columns ic
    ON i.object_id = ic.object_id
    AND i.index_id = ic.index_id
INNER JOIN sys.columns c
    ON ic.object_id = c.object_id
    AND ic.column_id = c.column_id
WHERE i.object_id IN
(
    OBJECT_ID('dbo.Fact_Operations'),
    OBJECT_ID('dbo.Fact_QA'),
    OBJECT_ID('dbo.Fact_Appeals'),
    OBJECT_ID('dbo.Fact_Coaching'),
    OBJECT_ID('dbo.Fact_Workforce'),
    OBJECT_ID('dbo.Fact_Finance')
)
AND i.name IS NOT NULL
ORDER BY
    Table_Name,
    Index_Name,
    Key_Order;
GO