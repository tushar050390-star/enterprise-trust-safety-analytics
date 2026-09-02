/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 09_Create_Dim_Appeal_Decision.sql
Author       : Tushar Mehta
Purpose      : Creates the Appeal Decision Dimension
Created On   : 30-Jul-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

--============================================================
-- Drop table if it already exists (Development Only)
--============================================================

IF OBJECT_ID('dbo.Dim_Appeal_Decision', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Dim_Appeal_Decision;
END;
GO

--============================================================
-- Create Appeal Decision Dimension
--============================================================

CREATE TABLE dbo.Dim_Appeal_Decision
(
    Appeal_Decision_Key     INT IDENTITY(1,1) NOT NULL,
    Appeal_Decision         NVARCHAR(100) NOT NULL,

    Created_Date            DATETIME2 NOT NULL
        CONSTRAINT DF_Dim_Appeal_Decision_Created_Date
        DEFAULT(GETDATE()),

    Modified_Date           DATETIME2 NULL,

    CONSTRAINT PK_Dim_Appeal_Decision
        PRIMARY KEY CLUSTERED (Appeal_Decision_Key),

    CONSTRAINT UQ_Dim_Appeal_Decision
        UNIQUE (Appeal_Decision)
);
GO

PRINT 'Dim_Appeal_Decision created successfully.';
GO
