/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 19_Load_Dim_Team.sql
Author       : Tushar Mehta
Purpose      : Load Client Dimension Master Data
Created On   : 04-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

INSERT INTO dbo.Dim_Team
(
    Team_Name
)
SELECT Source.Team_Name
FROM
(
    VALUES
        ('Team Alpha'),
        ('Team Bravo'),
        ('Team Charlie'),
        ('Team Delta'),
        ('Team Falcon'),
        ('Team Phoenix'),
        ('Team Titan'),
        ('Team Orion')
) AS Source(Team_Name)

WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Dim_Team Target
    WHERE Target.Team_Name = Source.Team_Name
);

GO

PRINT 'Dim_Team loaded successfully.';
GO