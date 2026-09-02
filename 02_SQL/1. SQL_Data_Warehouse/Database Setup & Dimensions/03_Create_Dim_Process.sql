/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 03_Create_Dim_Process.sql
Author       : Tushar Mehta
Purpose      : Creates the Process Dimension
Created On   : 29-Jul-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

--============================================================
-- Drop table if it already exists (Development Only)
--============================================================

IF OBJECT_ID('dbo.Dim_Process', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Dim_Process;
END;
GO

--============================================================
-- Create Process Dimension
--============================================================

CREATE TABLE dbo.Dim_Process
(
    Process_Key     INT IDENTITY(1,1) NOT NULL,
    Process_Name    NVARCHAR(100) NOT NULL,

    Created_Date    DATETIME2 NOT NULL
        CONSTRAINT DF_Dim_Process_Created_Date
        DEFAULT(GETDATE()),

    Modified_Date   DATETIME2 NULL,

    CONSTRAINT PK_Dim_Process
        PRIMARY KEY CLUSTERED (Process_Key),

    CONSTRAINT UQ_Dim_Process_Process_Name
        UNIQUE (Process_Name)
);
GO

PRINT 'Dim_Process created successfully.';