/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 08_Create_Dim_Error_Code.sql
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

IF OBJECT_ID('dbo.Dim_Error_Code', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Dim_Error_Code;
END;
GO

CREATE TABLE dbo.Dim_Error_Code
(
    Error_Code_Key         INT IDENTITY(1,1) NOT NULL,
    Error_Code             NVARCHAR(20) NOT NULL,
    Error_Description      NVARCHAR(255) NOT NULL,
    Error_Category         NVARCHAR(100) NULL,

    Created_Date           DATETIME2 NOT NULL
        CONSTRAINT DF_Dim_Error_Code_Created_Date
        DEFAULT(GETDATE()),

    Modified_Date          DATETIME2 NULL,

    CONSTRAINT PK_Dim_Error_Code
        PRIMARY KEY CLUSTERED (Error_Code_Key),

    CONSTRAINT UQ_Dim_Error_Code
        UNIQUE (Error_Code)
);
GO

PRINT 'Dim_Error_Code created successfully.';
GO