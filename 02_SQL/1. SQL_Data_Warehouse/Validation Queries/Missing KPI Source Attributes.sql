/* ============================================================
   ENTERPRISE TRUST & SAFETY ANALYTICS
   Missing KPI Source Attributes
   SQL Server / SSMS

   Purpose:
   Add source attributes required by approved dashboard
   specifications but missing from the implemented Fact tables.

   This script is designed to be re-runnable.
   ============================================================ */

USE Enterprise_Trust_Safety_DWH;
GO


/* ============================================================
   1. FACT_OPERATIONS
   ============================================================ */

IF COL_LENGTH('dbo.Fact_Operations', 'Case_Status') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Operations
    ADD Case_Status NVARCHAR(30) NULL;
END;

IF COL_LENGTH('dbo.Fact_Operations', 'Active_Work') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Operations
    ADD Active_Work INT NULL;
END;

IF COL_LENGTH('dbo.Fact_Operations', 'Total_Capacity') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Operations
    ADD Total_Capacity INT NULL;
END;

IF COL_LENGTH('dbo.Fact_Operations', 'Escalated_Cases') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Operations
    ADD Escalated_Cases INT NULL;
END;
GO


/* ============================================================
   2. FACT_WORKFORCE
   ============================================================ */

IF COL_LENGTH('dbo.Fact_Workforce', 'Scheduled_Hours') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Workforce
    ADD Scheduled_Hours DECIMAL(10,2) NULL;
END;

IF COL_LENGTH('dbo.Fact_Workforce', 'Adherence_Hours') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Workforce
    ADD Adherence_Hours DECIMAL(10,2) NULL;
END;

IF COL_LENGTH('dbo.Fact_Workforce', 'Logged_Hours') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Workforce
    ADD Logged_Hours DECIMAL(10,2) NULL;
END;

IF COL_LENGTH('dbo.Fact_Workforce', 'Handle_Hours') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Workforce
    ADD Handle_Hours DECIMAL(10,2) NULL;
END;

IF COL_LENGTH('dbo.Fact_Workforce', 'Absent_Flag') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Workforce
    ADD Absent_Flag BIT NULL;
END;

IF COL_LENGTH('dbo.Fact_Workforce', 'Scheduled_Headcount') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Workforce
    ADD Scheduled_Headcount INT NULL;
END;

IF COL_LENGTH('dbo.Fact_Workforce', 'Actual_Headcount') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Workforce
    ADD Actual_Headcount INT NULL;
END;

IF COL_LENGTH('dbo.Fact_Workforce', 'Required_Headcount') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Workforce
    ADD Required_Headcount INT NULL;
END;
GO


/* ============================================================
   3. FACT_APPEALS
   ============================================================ */

IF COL_LENGTH('dbo.Fact_Appeals', 'Appeal_Status') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Appeals
    ADD Appeal_Status NVARCHAR(30) NULL;
END;

IF COL_LENGTH('dbo.Fact_Appeals', 'SLA_Target_Hours') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Appeals
    ADD SLA_Target_Hours DECIMAL(10,2) NULL;
END;

IF COL_LENGTH('dbo.Fact_Appeals', 'Resolved_In_SLA_Flag') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Appeals
    ADD Resolved_In_SLA_Flag BIT NULL;
END;
GO


/* ============================================================
   4. FACT_QA
   ============================================================ */

IF COL_LENGTH('dbo.Fact_QA', 'Auditor_Employee_Key') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_QA
    ADD Auditor_Employee_Key INT NULL;
END;

IF COL_LENGTH('dbo.Fact_QA', 'Dispute_Status') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_QA
    ADD Dispute_Status NVARCHAR(30) NULL;
END;

IF COL_LENGTH('dbo.Fact_QA', 'Dispute_Overturned_Flag') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_QA
    ADD Dispute_Overturned_Flag BIT NULL;
END;
GO


/* ============================================================
   5. FACT_FINANCE
   ============================================================ */

IF COL_LENGTH('dbo.Fact_Finance', 'Billed_Amount') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Finance
    ADD Billed_Amount DECIMAL(18,2) NULL;
END;

IF COL_LENGTH('dbo.Fact_Finance', 'Labor_Cost') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Finance
    ADD Labor_Cost DECIMAL(18,2) NULL;
END;

IF COL_LENGTH('dbo.Fact_Finance', 'Overhead_Cost') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Finance
    ADD Overhead_Cost DECIMAL(18,2) NULL;
END;

IF COL_LENGTH('dbo.Fact_Finance', 'Billed_Hours') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Finance
    ADD Billed_Hours DECIMAL(18,2) NULL;
END;

IF COL_LENGTH('dbo.Fact_Finance', 'Unbilled_Hours') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Finance
    ADD Unbilled_Hours DECIMAL(18,2) NULL;
END;

IF COL_LENGTH('dbo.Fact_Finance', 'Penalty_Amount') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Finance
    ADD Penalty_Amount DECIMAL(18,2) NULL;
END;

IF COL_LENGTH('dbo.Fact_Finance', 'Contracted_Billable_Hours') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Finance
    ADD Contracted_Billable_Hours DECIMAL(18,2) NULL;
END;

IF COL_LENGTH('dbo.Fact_Finance', 'Actual_Billable_Hours') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Finance
    ADD Actual_Billable_Hours DECIMAL(18,2) NULL;
END;

IF COL_LENGTH('dbo.Fact_Finance', 'Forecast_Revenue_USD') IS NULL
BEGIN
    ALTER TABLE dbo.Fact_Finance
    ADD Forecast_Revenue_USD DECIMAL(18,2) NULL;
END;
GO