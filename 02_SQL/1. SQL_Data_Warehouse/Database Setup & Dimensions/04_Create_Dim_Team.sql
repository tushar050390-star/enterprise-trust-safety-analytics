/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 04_Create_Dim_Team.sql
Author       : Tushar Mehta
Purpose      : Creates the Team Dimension
Created On   : 29-Jul-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

--============================================================
-- Drop table if it already exists (Development Only)
--============================================================

IF OBJECT_ID('dbo.Dim_Team', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Dim_Team;
END;
GO

--============================================================
-- Create Team Dimension
--============================================================

CREATE TABLE dbo.Dim_Team
(
    Team_Key           INT IDENTITY(1,1) NOT NULL,
    Team_Name          NVARCHAR(100) NOT NULL,
    Team_Description   NVARCHAR(255) NULL,

    Created_Date       DATETIME2 NOT NULL
        CONSTRAINT DF_Dim_Team_Created_Date
        DEFAULT(GETDATE()),

    Modified_Date      DATETIME2 NULL,

    CONSTRAINT PK_Dim_Team
        PRIMARY KEY CLUSTERED (Team_Key),

    CONSTRAINT UQ_Dim_Team_Team_Name
        UNIQUE (Team_Name)
);
GO

PRINT 'Dim_Team created successfully.';
GO
