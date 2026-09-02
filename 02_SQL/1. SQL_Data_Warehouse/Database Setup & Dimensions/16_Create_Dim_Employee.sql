/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 16_Create_Dim_Employee.sql
Author       : Tushar Mehta
Purpose      : Creates the Employee Dimension
Created On   : 04-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

--============================================================
-- Drop Table (Development Only)
--============================================================

IF OBJECT_ID('dbo.Dim_Employee','U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Dim_Employee;
END;
GO

--============================================================
-- Create Employee Dimension
--============================================================

CREATE TABLE dbo.Dim_Employee
(
    Employee_Key           INT IDENTITY(1,1) NOT NULL,

    Employee_ID            NVARCHAR(20) NOT NULL,

    Employee_Name          NVARCHAR(150) NOT NULL,

    Client_Key             INT NOT NULL,

    Process_Key            INT NOT NULL,

    Team_Key               INT NOT NULL,

    Site_Key               INT NOT NULL,

    Designation            NVARCHAR(100) NOT NULL,

    Hire_Date              DATE NOT NULL,

    Employment_Status      NVARCHAR(20) NOT NULL,

    Created_Date           DATETIME2 NOT NULL
        CONSTRAINT DF_Dim_Employee_Created_Date
        DEFAULT(SYSDATETIME()),

    Modified_Date          DATETIME2 NULL,

    CONSTRAINT PK_Dim_Employee
        PRIMARY KEY CLUSTERED (Employee_Key),

    CONSTRAINT UQ_Dim_Employee_Employee_ID
        UNIQUE(Employee_ID),

    CONSTRAINT CHK_Dim_Employee_Status
        CHECK (Employment_Status IN ('Active','Inactive')),

    CONSTRAINT FK_Dim_Employee_Client
        FOREIGN KEY (Client_Key)
        REFERENCES dbo.Dim_Client(Client_Key),

    CONSTRAINT FK_Dim_Employee_Process
        FOREIGN KEY (Process_Key)
        REFERENCES dbo.Dim_Process(Process_Key),

    CONSTRAINT FK_Dim_Employee_Team
        FOREIGN KEY (Team_Key)
        REFERENCES dbo.Dim_Team(Team_Key),

    CONSTRAINT FK_Dim_Employee_Site
        FOREIGN KEY (Site_Key)
        REFERENCES dbo.Dim_Site(Site_Key)
);
GO

PRINT 'Dim_Employee created successfully.';
GO

