/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 07_Create_Dim_Policy.sql
Author       : Tushar Mehta
Purpose      : Creates the Policy Dimension
Created On   : 30-Jul-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

IF OBJECT_ID('dbo.Dim_Policy', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Dim_Policy;
END;
GO

CREATE TABLE dbo.Dim_Policy
(
    Policy_Key        INT IDENTITY(1,1) NOT NULL,
    Policy_Name       NVARCHAR(150) NOT NULL,
    Policy_Category   NVARCHAR(100) NULL,

    Created_Date      DATETIME2 NOT NULL
        CONSTRAINT DF_Dim_Policy_Created_Date
        DEFAULT(GETDATE()),

    Modified_Date     DATETIME2 NULL,

    CONSTRAINT PK_Dim_Policy
        PRIMARY KEY CLUSTERED (Policy_Key),

    CONSTRAINT UQ_Dim_Policy_Policy_Name
        UNIQUE (Policy_Name)
);
GO

PRINT 'Dim_Policy created successfully.';
GO
