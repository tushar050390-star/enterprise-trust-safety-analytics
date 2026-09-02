/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 47B_Create_Fact_Indexes.sql
Purpose      : Create Nonclustered Indexes for Fact Tables
Author       : Tushar Mehta
Created Date : 08-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

/*==============================================================
  Fact_Operations
==============================================================*/

CREATE NONCLUSTERED INDEX IX_Fact_Operations_Date
ON dbo.Fact_Operations (Date_Key);

CREATE NONCLUSTERED INDEX IX_Fact_Operations_Employee
ON dbo.Fact_Operations (Employee_Key);

CREATE NONCLUSTERED INDEX IX_Fact_Operations_Client
ON dbo.Fact_Operations (Client_Key);

CREATE NONCLUSTERED INDEX IX_Fact_Operations_Process
ON dbo.Fact_Operations (Process_Key);

CREATE NONCLUSTERED INDEX IX_Fact_Operations_Team
ON dbo.Fact_Operations (Team_Key);

CREATE NONCLUSTERED INDEX IX_Fact_Operations_Site
ON dbo.Fact_Operations (Site_Key);

CREATE NONCLUSTERED INDEX IX_Fact_Operations_Shift
ON dbo.Fact_Operations (Shift_Key);

CREATE NONCLUSTERED INDEX IX_Fact_Operations_Policy
ON dbo.Fact_Operations (Policy_Key);


/*==============================================================
  Fact_QA
==============================================================*/

CREATE NONCLUSTERED INDEX IX_Fact_QA_Date
ON dbo.Fact_QA (Date_Key);

CREATE NONCLUSTERED INDEX IX_Fact_QA_Policy
ON dbo.Fact_QA (Policy_Key);

CREATE NONCLUSTERED INDEX IX_Fact_QA_Error_Code
ON dbo.Fact_QA (Error_Code_Key);


/*==============================================================
  Fact_Appeals
==============================================================*/

CREATE NONCLUSTERED INDEX IX_Fact_Appeals_Date
ON dbo.Fact_Appeals (Date_Key);

CREATE NONCLUSTERED INDEX IX_Fact_Appeals_Policy
ON dbo.Fact_Appeals (Policy_Key);

CREATE NONCLUSTERED INDEX IX_Fact_Appeals_Decision
ON dbo.Fact_Appeals (Appeal_Decision_Key);


/*==============================================================
  Fact_Coaching
==============================================================*/

CREATE NONCLUSTERED INDEX IX_Fact_Coaching_Date
ON dbo.Fact_Coaching (Date_Key);

CREATE NONCLUSTERED INDEX IX_Fact_Coaching_Client
ON dbo.Fact_Coaching (Client_Key);

CREATE NONCLUSTERED INDEX IX_Fact_Coaching_Site
ON dbo.Fact_Coaching (Site_Key);

CREATE NONCLUSTERED INDEX IX_Fact_Coaching_Process
ON dbo.Fact_Coaching (Process_Key);

CREATE NONCLUSTERED INDEX IX_Fact_Coaching_Team
ON dbo.Fact_Coaching (Team_Key);

CREATE NONCLUSTERED INDEX IX_Fact_Coaching_Employee
ON dbo.Fact_Coaching (Employee_Key);


/*==============================================================
  Fact_Workforce
==============================================================*/

CREATE NONCLUSTERED INDEX IX_Fact_Workforce_Date
ON dbo.Fact_Workforce (Date_Key);

CREATE NONCLUSTERED INDEX IX_Fact_Workforce_Shift
ON dbo.Fact_Workforce (Shift_Key);

CREATE NONCLUSTERED INDEX IX_Fact_Workforce_Shrinkage
ON dbo.Fact_Workforce (Shrinkage_Key);


/*==============================================================
  Fact_Finance
==============================================================*/

CREATE NONCLUSTERED INDEX IX_Fact_Finance_Date
ON dbo.Fact_Finance (Date_Key);

CREATE NONCLUSTERED INDEX IX_Fact_Finance_Billing_Model
ON dbo.Fact_Finance (Billing_Model_Key);

CREATE NONCLUSTERED INDEX IX_Fact_Finance_Cost_Center
ON dbo.Fact_Finance (Cost_Center_Key);

GO

PRINT 'Fact table indexes created successfully.';

SELECT
    OBJECT_NAME(i.object_id) AS Table_Name,
    i.name AS Index_Name,
    i.type_desc AS Index_Type,
    c.name AS Column_Name
FROM sys.indexes i
INNER JOIN sys.index_columns ic
    ON i.object_id = ic.object_id
    AND i.index_id = ic.index_id
INNER JOIN sys.columns c
    ON ic.object_id = c.object_id
    AND ic.column_id = c.column_id
WHERE i.name LIKE 'IX_Fact_%'
ORDER BY
    Table_Name,
    Index_Name;