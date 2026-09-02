/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 10_Create_Dim_Shrinkage.sql
Author       : Tushar Mehta
Purpose      : Creates the Shrinkage Dimension
Created On   : 30-Jul-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

IF OBJECT_ID('dbo.Dim_Shrinkage', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Dim_Shrinkage;
END;
GO

CREATE TABLE dbo.Dim_Shrinkage
(
    Shrinkage_Key      INT IDENTITY(1,1) NOT NULL,
    Shrinkage_Type     NVARCHAR(100) NOT NULL,
    Is_Planned         BIT NOT NULL,

    Created_Date       DATETIME2 NOT NULL
        CONSTRAINT DF_Dim_Shrinkage_Created_Date
        DEFAULT(GETDATE()),

    Modified_Date      DATETIME2 NULL,

    CONSTRAINT PK_Dim_Shrinkage
        PRIMARY KEY CLUSTERED (Shrinkage_Key),

    CONSTRAINT UQ_Dim_Shrinkage
        UNIQUE (Shrinkage_Type)
);
GO

PRINT 'Dim_Shrinkage created successfully.';
GO