/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 29_Create_Fact_Operations.sql
Purpose      : Create Fact_Operations table
Author       : Tushar Mehta
Created Date : 06-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

IF OBJECT_ID('dbo.Fact_Operations', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Fact_Operations;
END;
GO

CREATE TABLE dbo.Fact_Operations
(
    Fact_Operations_Key      BIGINT IDENTITY(1,1) NOT NULL,

    --===============================
    -- Foreign Keys
    --===============================

    Date_Key                 INT             NOT NULL,
    Employee_Key             INT             NOT NULL,
    Client_Key               INT             NOT NULL,
    Process_Key              INT             NOT NULL,
    Team_Key                 INT             NOT NULL,
    Site_Key                 INT             NOT NULL,
    Shift_Key                INT             NOT NULL,
    Policy_Key               INT             NOT NULL,
    Error_Code_Key           INT             NOT NULL,
    Appeal_Decision_Key      INT             NOT NULL,
    Billing_Model_Key        INT             NOT NULL,
    Cost_Center_Key          INT             NOT NULL,
    Shrinkage_Key            INT             NOT NULL,

    --===============================
    -- Operational Measures
    --===============================

    Cases_Handled            INT             NOT NULL,
    Cases_Reviewed           INT             NOT NULL,
    Cases_Approved           INT             NOT NULL,
    Cases_Rejected           INT             NOT NULL,

    Appeals_Received         INT             NOT NULL,
    Appeals_Reversed         INT             NOT NULL,

    QA_Score                 DECIMAL(5,2)   NOT NULL,
    AHT_Minutes              DECIMAL(8,2)   NOT NULL,
    SLA_Compliance_Pct       DECIMAL(5,2)   NOT NULL,

    Productive_Hours         DECIMAL(6,2)   NOT NULL,
    Idle_Hours               DECIMAL(6,2)   NOT NULL,
    Break_Hours              DECIMAL(6,2)   NOT NULL,
    Billable_Hours           DECIMAL(6,2)   NOT NULL,
    Overtime_Hours           DECIMAL(6,2)   NOT NULL,

    Revenue_USD              DECIMAL(12,2)  NOT NULL,
    Operating_Cost_USD       DECIMAL(12,2)  NOT NULL,

    Created_Date             DATETIME2(3)   NOT NULL
        CONSTRAINT DF_Fact_Operations_Created_Date
        DEFAULT SYSUTCDATETIME(),

    Modified_Date            DATETIME2(3)   NULL,

    CONSTRAINT PK_Fact_Operations
        PRIMARY KEY CLUSTERED (Fact_Operations_Key),

    CONSTRAINT FK_Fact_Operations_Date
        FOREIGN KEY (Date_Key)
        REFERENCES dbo.Dim_Date(Date_Key),

    CONSTRAINT FK_Fact_Operations_Employee
        FOREIGN KEY (Employee_Key)
        REFERENCES dbo.Dim_Employee(Employee_Key),

    CONSTRAINT FK_Fact_Operations_Client
        FOREIGN KEY (Client_Key)
        REFERENCES dbo.Dim_Client(Client_Key),

    CONSTRAINT FK_Fact_Operations_Process
        FOREIGN KEY (Process_Key)
        REFERENCES dbo.Dim_Process(Process_Key),

    CONSTRAINT FK_Fact_Operations_Team
        FOREIGN KEY (Team_Key)
        REFERENCES dbo.Dim_Team(Team_Key),

    CONSTRAINT FK_Fact_Operations_Site
        FOREIGN KEY (Site_Key)
        REFERENCES dbo.Dim_Site(Site_Key),

    CONSTRAINT FK_Fact_Operations_Shift
        FOREIGN KEY (Shift_Key)
        REFERENCES dbo.Dim_Shift(Shift_Key),

    CONSTRAINT FK_Fact_Operations_Policy
        FOREIGN KEY (Policy_Key)
        REFERENCES dbo.Dim_Policy(Policy_Key),

    CONSTRAINT FK_Fact_Operations_Error_Code
        FOREIGN KEY (Error_Code_Key)
        REFERENCES dbo.Dim_Error_Code(Error_Code_Key),

    CONSTRAINT FK_Fact_Operations_Appeal
        FOREIGN KEY (Appeal_Decision_Key)
        REFERENCES dbo.Dim_Appeal_Decision(Appeal_Decision_Key),

    CONSTRAINT FK_Fact_Operations_Billing_Model
        FOREIGN KEY (Billing_Model_Key)
        REFERENCES dbo.Dim_Billing_Model(Billing_Model_Key),

    CONSTRAINT FK_Fact_Operations_Cost_Center
        FOREIGN KEY (Cost_Center_Key)
        REFERENCES dbo.Dim_Cost_Center(Cost_Center_Key),

    CONSTRAINT FK_Fact_Operations_Shrinkage
        FOREIGN KEY (Shrinkage_Key)
        REFERENCES dbo.Dim_Shrinkage(Shrinkage_Key)
);
GO

PRINT 'Fact_Operations created successfully.';