/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 01_Create_Database.sql
Author       : Tushar Mehta
Purpose      : Creates the Enterprise Data Warehouse database
Created On   : 29-Jul-2026
******************************************************************************/

--============================================================
-- Drop the database if it already exists (Development Only)
--============================================================

USE master;
GO

IF DB_ID('Enterprise_Trust_Safety_DWH') IS NOT NULL
BEGIN
    ALTER DATABASE Enterprise_Trust_Safety_DWH
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE Enterprise_Trust_Safety_DWH;
END;
GO

--============================================================
-- Create Database
--============================================================

CREATE DATABASE Enterprise_Trust_Safety_DWH;
GO

--============================================================
-- Use the Database
--============================================================

USE Enterprise_Trust_Safety_DWH;
GO

PRINT 'Enterprise_Trust_Safety_DWH database created successfully.';
GO
