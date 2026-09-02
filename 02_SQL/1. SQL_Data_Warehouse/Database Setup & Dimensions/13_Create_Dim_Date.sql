/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 13_Create_Dim_Date.sql
Author       : Tushar Mehta
Purpose      : Creates the Date Dimension
Created On   : 30-Jul-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

--============================================================
-- Drop table if it already exists (Development Only)
--============================================================

IF OBJECT_ID('dbo.Dim_Date', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Dim_Date;
END;
GO

--============================================================
-- Create Date Dimension
--============================================================

CREATE TABLE dbo.Dim_Date
(
    Date_Key           INT             NOT NULL,
    Full_Date          DATE            NOT NULL,

    Day_Number         TINYINT         NOT NULL,
    Day_Name           NVARCHAR(15)    NOT NULL,

    Week_Number        TINYINT         NOT NULL,

    Month_Number       TINYINT         NOT NULL,
    Month_Name         NVARCHAR(15)    NOT NULL,

    Quarter_Number     TINYINT         NOT NULL,
    Quarter_Name       NVARCHAR(2)     NOT NULL,

    Year_Number        SMALLINT        NOT NULL,

    Is_Weekend         BIT             NOT NULL,

    Fiscal_Month       TINYINT         NOT NULL,
    Fiscal_Quarter     NVARCHAR(3)     NOT NULL,
    Fiscal_Year        NVARCHAR(10)    NOT NULL,

    Created_Date       DATETIME2       NOT NULL
        CONSTRAINT DF_Dim_Date_Created_Date
        DEFAULT(SYSDATETIME()),

    Modified_Date      DATETIME2       NULL,

    CONSTRAINT PK_Dim_Date
        PRIMARY KEY CLUSTERED (Date_Key),

    CONSTRAINT UQ_Dim_Date_Full_Date
        UNIQUE (Full_Date)
);
GO

PRINT 'Dim_Date created successfully.';
GO