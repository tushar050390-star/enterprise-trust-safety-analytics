/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 02_Create_Dim_Client.sql
Author       : Tushar Mehta
Purpose      : Creates the Client Dimension
Created On   : 29-Jul-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

--============================================================
-- Drop table if it already exists (Development Only)
--============================================================

IF OBJECT_ID('dbo.Dim_Client', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Dim_Client;
END;
GO

--============================================================
-- Create Client Dimension
--============================================================

CREATE TABLE dbo.Dim_Client
(
    Client_Key     INT IDENTITY(1,1) NOT NULL,
    Client_Name    NVARCHAR(100) NOT NULL,

    Created_Date   DATETIME2 NOT NULL
        CONSTRAINT DF_Dim_Client_Created_Date
        DEFAULT(GETDATE()),

    Modified_Date  DATETIME2 NULL,

    CONSTRAINT PK_Dim_Client
        PRIMARY KEY CLUSTERED (Client_Key),

    CONSTRAINT UQ_Dim_Client_Client_Name
        UNIQUE (Client_Name)
);
GO

PRINT 'Dim_Client created successfully.';
GO