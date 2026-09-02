/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 21_Load_Dim_Shift.sql
Author       : Tushar Mehta
Purpose      : Load Client Dimension Master Data
Created On   : 04-Aug-2026
******************************************************************************/


USE Enterprise_Trust_Safety_DWH;
GO

INSERT INTO dbo.Dim_Shift
(
    Shift_Name,
    Shift_Start_Time,
    Shift_End_Time
)
SELECT
    Source.Shift_Name,
    Source.Shift_Start_Time,
    Source.Shift_End_Time
FROM
(
    VALUES
        ('Morning','06:00','14:00'),
        ('Afternoon','14:00','22:00'),
        ('Night','22:00','06:00'),
        ('General','09:00','18:00')
) AS Source
(
    Shift_Name,
    Shift_Start_Time,
    Shift_End_Time
)

WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Dim_Shift Target
    WHERE Target.Shift_Name = Source.Shift_Name
);

GO

PRINT 'Dim_Shift loaded successfully.';
GO