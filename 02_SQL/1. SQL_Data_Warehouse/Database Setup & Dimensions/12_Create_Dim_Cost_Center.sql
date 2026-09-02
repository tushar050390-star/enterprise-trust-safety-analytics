/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 12_Create_Dim_Cost_Center.sql
Author       : Tushar Mehta
Purpose      : Creates the Cost Center Dimension
Created On   : 30-Jul-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

IF OBJECT_ID('dbo.Dim_Cost_Center', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Dim_Cost_Center;
END;
GO

CREATE TABLE dbo.Dim_Cost_Center
(
    Cost_Center_Key      INT IDENTITY(1,1) NOT NULL,
    Cost_Center_Code     NVARCHAR(20) NOT NULL,
    Cost_Center_Name     NVARCHAR(100) NOT NULL,

    Created_Date         DATETIME2 NOT NULL
        CONSTRAINT DF_Dim_Cost_Center_Created_Date
        DEFAULT(SYSDATETIME()),

    Modified_Date        DATETIME2 NULL,

    CONSTRAINT PK_Dim_Cost_Center
        PRIMARY KEY CLUSTERED (Cost_Center_Key),

    CONSTRAINT UQ_Dim_Cost_Center_Code
        UNIQUE (Cost_Center_Code)
);
GO

PRINT 'Dim_Cost_Center created successfully.';
GO

