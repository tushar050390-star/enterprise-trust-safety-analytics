/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 05_Create_Dim_Site.sql
Author       : Tushar Mehta
Purpose      : Creates the Site Dimension
Created On   : 30-Jul-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

--============================================================
-- Drop table if it already exists (Development Only)
--============================================================

IF OBJECT_ID('dbo.Dim_Site', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Dim_Site;
END;
GO

--============================================================
-- Create Site Dimension
--============================================================

CREATE TABLE dbo.Dim_Site
(
    Site_Key         INT IDENTITY(1,1) NOT NULL,
    Site_Name        NVARCHAR(100) NOT NULL,
    Country          NVARCHAR(50) NOT NULL,

    Created_Date     DATETIME2 NOT NULL
        CONSTRAINT DF_Dim_Site_Created_Date
        DEFAULT(GETDATE()),

    Modified_Date    DATETIME2 NULL,

    CONSTRAINT PK_Dim_Site
        PRIMARY KEY CLUSTERED (Site_Key),

    CONSTRAINT UQ_Dim_Site_Site_Name
        UNIQUE (Site_Name),

    CONSTRAINT CHK_Dim_Site_Country
        CHECK (Country IN ('India', 'Philippines', 'USA'))
);
GO

PRINT 'Dim_Site created successfully.';
GO
