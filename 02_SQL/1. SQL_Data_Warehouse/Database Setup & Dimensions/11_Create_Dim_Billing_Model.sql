/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 11_Create_Dim_Billing_Model.sql
Author       : Tushar Mehta
Purpose      : Creates the Billing Model Dimension
Created On   : 30-Jul-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

IF OBJECT_ID('dbo.Dim_Billing_Model', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Dim_Billing_Model;
END;
GO

CREATE TABLE dbo.Dim_Billing_Model
(
    Billing_Model_Key      INT IDENTITY(1,1) NOT NULL,
    Billing_Model          NVARCHAR(100) NOT NULL,

    Created_Date           DATETIME2 NOT NULL
        CONSTRAINT DF_Dim_Billing_Model_Created_Date
        DEFAULT(SYSDATETIME()),

    Modified_Date          DATETIME2 NULL,

    CONSTRAINT PK_Dim_Billing_Model
        PRIMARY KEY CLUSTERED (Billing_Model_Key),

    CONSTRAINT UQ_Dim_Billing_Model
        UNIQUE (Billing_Model)
);
GO

PRINT 'Dim_Billing_Model created successfully.';
GO

