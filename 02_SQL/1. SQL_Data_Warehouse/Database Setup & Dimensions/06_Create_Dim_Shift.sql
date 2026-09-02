/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 06_Create_Dim_Shift.sql
Author       : Tushar Mehta
Purpose      : Creates the Shift Dimension
Created On   : 30-Jul-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

--============================================================
-- Drop table if it already exists (Development Only)
--============================================================

IF OBJECT_ID('dbo.Dim_Shift', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Dim_Shift;
END;
GO

--============================================================
-- Create Shift Dimension
--============================================================

CREATE TABLE dbo.Dim_Shift
(
    Shift_Key          INT IDENTITY(1,1) NOT NULL,
    Shift_Name         NVARCHAR(50) NOT NULL,
    Shift_Start_Time   TIME NOT NULL,
    Shift_End_Time     TIME NOT NULL,

    Created_Date       DATETIME2 NOT NULL
        CONSTRAINT DF_Dim_Shift_Created_Date
        DEFAULT(GETDATE()),

    Modified_Date      DATETIME2 NULL,

    CONSTRAINT PK_Dim_Shift
        PRIMARY KEY CLUSTERED (Shift_Key),

    CONSTRAINT UQ_Dim_Shift_Shift_Name
        UNIQUE (Shift_Name),

    CONSTRAINT CHK_Dim_Shift_Time
        CHECK (Shift_Start_Time <> Shift_End_Time)
);
GO

PRINT 'Dim_Shift created successfully.';
GO