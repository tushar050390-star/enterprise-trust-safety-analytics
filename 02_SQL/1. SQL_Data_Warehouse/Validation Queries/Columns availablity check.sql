USE Enterprise_Trust_Safety_DWH;
GO

;WITH RequiredColumns AS
(
    SELECT *
    FROM
    (
        VALUES

        /* =========================================================
           DB-01 EXECUTIVE OVERVIEW
           ========================================================= */

        ('DB-01','Executive Overview','Cases Closed',
         'Fact_Operations','Case_Key',
         'Required by document: terminal/closed case identification'),

        ('DB-01','Executive Overview','Cases Closed',
         'Fact_Operations','Is_Terminal_State_Flag',
         'Required by document: terminal state flag'),

        ('DB-01','Executive Overview','Open Cases',
         'Fact_Operations','Status',
         'Required by document: Open status'),

        ('DB-01','Executive Overview','Average AHT',
         'Fact_Operations','Handling_Time_Seconds',
         'Document source field'),

        ('DB-01','Executive Overview','SLA Compliance',
         'Fact_Operations','SLA_Compliance_Pct',
         'Document source field'),

        ('DB-01','Executive Overview','QA Score',
         'Fact_QA','Points_Scored',
         'Required by document QA formula'),

        ('DB-01','Executive Overview','QA Score',
         'Fact_QA','Points_Possible',
         'Required by document QA formula'),

        ('DB-01','Executive Overview','Productivity',
         'Fact_Workforce','Actual_Duration_Seconds',
         'Required by document productivity formula'),

        ('DB-01','Executive Overview','Revenue',
         'Fact_Finance','Estimated_Revenue',
         'Required by document revenue formula'),

        ('DB-01','Executive Overview','Cost Per Case',
         'Fact_Finance','Operating_Cost_USD',
         'Candidate existing cost field'),

        /* =========================================================
           DB-02 OPERATIONS
           ========================================================= */

        ('DB-02','Operations','Cases Reviewed Today',
         'Fact_Operations','Cases_Reviewed',
         'Existing source field'),

        ('DB-02','Operations','Open Backlog',
         'Fact_Operations','Case_Status',
         'Added scenario-derived status field'),

        ('DB-02','Operations','SLA Compliance',
         'Fact_Operations','SLA_Compliance_Pct',
         'Existing source field'),

        ('DB-02','Operations','Average AHT',
         'Fact_Operations','AHT_Minutes',
         'Existing source field'),

        ('DB-02','Operations','Productivity',
         'Fact_Workforce','Hours',
         'Candidate workforce hours field'),

        ('DB-02','Operations','Active Reviewers',
         'Dim_Employee','Employment_Status',
         'Candidate employee status field'),

        ('DB-02','Operations','Queue Utilization',
         'Fact_Operations','Active_Work',
         'Added scenario-derived field'),

        ('DB-02','Operations','Queue Utilization',
         'Fact_Operations','Total_Capacity',
         'Added scenario-derived field'),

        ('DB-02','Operations','Escalation Rate',
         'Fact_Operations','Escalated_Cases',
         'Added scenario-derived field'),

        /* =========================================================
           DB-03 QUALITY ASSURANCE
           ========================================================= */

        ('DB-03','Quality','Overall QA Score',
         'Fact_QA','QA_Score',
         'Existing source field'),

        ('DB-03','Quality','Fatal Error Rate',
         'Fact_QA','Error_Code_Key',
         'Requires error classification'),

        ('DB-03','Quality','Fatal Error Rate',
         'Dim_Error_Code','Error_Severity',
         'Required to distinguish fatal/non-fatal'),

        ('DB-03','Quality','Non-Fatal Error Rate',
         'Fact_QA','Error_Code_Key',
         'Requires error classification'),

        ('DB-03','Quality','Total Audits',
         'Fact_QA','QA_Key',
         'Existing audit key'),

        ('DB-03','Quality','Audit Coverage',
         'Fact_QA','QA_Key',
         'Audit numerator'),

        ('DB-03','Quality','Audit Coverage',
         'Fact_Operations','Cases_Reviewed',
         'Operational denominator'),

        ('DB-03','Quality','Dispute Win Rate',
         'Fact_QA','Disputed_Flag',
         'Required by document formula'),

        ('DB-03','Quality','Dispute Win Rate',
         'Fact_QA','Overturned_Flag',
         'Required by document formula'),

        ('DB-03','Quality','Auditor Productivity',
         'Fact_Workforce','Hours',
         'Candidate productive-time denominator'),

        /* =========================================================
           DB-04 WORKFORCE
           ========================================================= */

        ('DB-04','Workforce','Schedule Adherence',
         'Fact_Workforce','Adherence_Hours',
         'Required by document formula'),

        ('DB-04','Workforce','Schedule Adherence',
         'Fact_Workforce','Scheduled_Hours',
         'Required by document formula'),

        ('DB-04','Workforce','Occupancy Rate',
         'Fact_Workforce','Handle_Hours',
         'Required by document formula'),

        ('DB-04','Workforce','Occupancy Rate',
         'Fact_Workforce','Logged_Hours',
         'Required by document formula'),

        ('DB-04','Workforce','Absenteeism Rate',
         'Fact_Workforce','Absent_Employees',
         'Required by document formula'),

        ('DB-04','Workforce','Absenteeism Rate',
         'Fact_Workforce','Scheduled_Employees',
         'Required by document formula'),

        ('DB-04','Workforce','Shrinkage',
         'Fact_Workforce','Hours',
         'Existing workforce hours'),

        ('DB-04','Workforce','Shrinkage',
         'Dim_Shrinkage','Shrinkage_Type',
         'Existing shrinkage dimension'),

        ('DB-04','Workforce','Staffing Variance',
         'Fact_Workforce','Actual_Headcount',
         'Required by document formula'),

        ('DB-04','Workforce','Staffing Variance',
         'Fact_Workforce','Required_Headcount',
         'Required by document formula'),

        ('DB-04','Workforce','Available FTE',
         'Fact_Workforce','Hours',
         'Productive-hours basis'),

        /* =========================================================
           DB-05 APPEALS
           ========================================================= */

        ('DB-05','Appeals','Appeals Received',
         'Fact_Appeals','Appeal_Key',
         'Existing appeal key'),

        ('DB-05','Appeals','Appeals Resolved',
         'Fact_Appeals','Status',
         'Required resolved status'),

        ('DB-05','Appeals','Overturn Rate',
         'Dim_Appeal_Decision','Decision_Name',
         'Required to identify overturned decisions'),

        ('DB-05','Appeals','Upheld Rate',
         'Dim_Appeal_Decision','Decision_Name',
         'Required to identify upheld decisions'),

        ('DB-05','Appeals','Appeal Backlog',
         'Fact_Appeals','Status',
         'Required pending status'),

        ('DB-05','Appeals','Appeals SLA',
         'Fact_Appeals','Resolution_Time',
         'Existing resolution-time field'),

        ('DB-05','Appeals','Appeals SLA',
         'Fact_Appeals','SLA_Target_Hours',
         'Required SLA comparison'),

        ('DB-05','Appeals','Average Resolution Time',
         'Fact_Appeals','Resolution_Time',
         'Existing source field'),

        ('DB-05','Appeals','Appeal Rate',
         'Fact_Appeals','Appeal_Key',
         'Appeal numerator'),

        ('DB-05','Appeals','Appeal Rate',
         'Fact_Operations','Cases_Handled',
         'Operational denominator'),

        /* =========================================================
           DB-06 FINANCE
           ========================================================= */

        ('DB-06','Finance','Total Revenue',
         'Fact_Finance','Billed_Amount',
         'Required by approved finance specification'),

        ('DB-06','Finance','Total Costs',
         'Fact_Finance','Labor_Cost',
         'Required by approved finance specification'),

        ('DB-06','Finance','Total Costs',
         'Fact_Finance','Overhead_Cost',
         'Required by approved finance specification'),

        ('DB-06','Finance','Gross Margin',
         'Fact_Finance','Billed_Amount',
         'Revenue component'),

        ('DB-06','Finance','Cost Per Case',
         'Fact_Finance','Labor_Cost',
         'Cost component'),

        ('DB-06','Finance','Cost Per Case',
         'Fact_Finance','Overhead_Cost',
         'Cost component'),

        ('DB-06','Finance','Billed Hours',
         'Fact_Finance','Billed_Hours',
         'Required by approved finance specification'),

        ('DB-06','Finance','Revenue Leakage',
         'Fact_Finance','Unbilled_Hours',
         'Required by approved finance specification'),

        ('DB-06','Finance','Revenue Leakage',
         'Fact_Workforce','Hours',
         'Worked-hours denominator'),

        ('DB-06','Finance','SLA Penalties',
         'Fact_Finance','Penalty_Amount',
         'Required by approved finance specification')

    ) AS V
    (
        Dashboard_ID,
        Dashboard_Name,
        KPI_Name,
        Expected_Table,
        Expected_Column,
        Requirement
    )
)

SELECT
    R.Dashboard_ID,
    R.Dashboard_Name,
    R.KPI_Name,
    R.Expected_Table,
    R.Expected_Column,
    R.Requirement,

    CASE
        WHEN C.COLUMN_NAME IS NOT NULL
            THEN 'AVAILABLE'
        ELSE 'MISSING'
    END AS Validation_Status

FROM RequiredColumns R

LEFT JOIN INFORMATION_SCHEMA.COLUMNS C
    ON C.TABLE_SCHEMA = 'dbo'
    AND C.TABLE_NAME = R.Expected_Table
    AND C.COLUMN_NAME = R.Expected_Column

ORDER BY
    R.Dashboard_ID,
    R.KPI_Name,
    R.Expected_Table,
    R.Expected_Column;