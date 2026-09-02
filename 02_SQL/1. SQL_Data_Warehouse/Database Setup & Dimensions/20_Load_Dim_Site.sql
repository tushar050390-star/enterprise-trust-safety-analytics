/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 20_Load_Dim_Site.sql
Author       : Tushar Mehta
Purpose      : Load Client Dimension Master Data
Created On   : 04-Aug-2026
******************************************************************************/


INSERT INTO dbo.Dim_Site
(
    Site_Name,
    Country
)
SELECT
    Source.Site_Name,
    Source.Country
FROM
(
    VALUES
        ('Bengaluru','India'),
        ('Hyderabad','India'),
        ('Mohali','India'),
        ('Indore','India'),
        ('Austin','USA'),
        ('New York','USA'),
        ('Manila','Philippines'),
        ('Cebu','Philippines')
) AS Source
(
    Site_Name,
    Country
)
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Dim_Site Target
    WHERE Target.Site_Name = Source.Site_Name
);
GO