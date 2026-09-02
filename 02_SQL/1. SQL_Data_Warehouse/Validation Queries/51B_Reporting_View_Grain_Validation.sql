/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 51B_Reporting_View_Grain_Validation.sql
Purpose      : Validate Reporting View Grain and Join Cardinality
Author       : Tushar Mehta
Created Date : 10-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO


/*==============================================================
  1. OPERATIONS JOIN CARDINALITY
==============================================================*/

SELECT
    'Operations' AS Domain,

    (SELECT COUNT(*)
     FROM dbo.Fact_Operations) AS Fact_Rows,

    (SELECT COUNT(*)
     FROM dbo.Fact_Operations FO
     INNER JOIN dbo.Dim_Date DD
         ON FO.Date_Key = DD.Date_Key
     INNER JOIN dbo.Dim_Employee DE
         ON FO.Employee_Key = DE.Employee_Key
     INNER JOIN dbo.Dim_Client DC
         ON FO.Client_Key = DC.Client_Key
     INNER JOIN dbo.Dim_Process DP
         ON FO.Process_Key = DP.Process_Key
     INNER JOIN dbo.Dim_Team DT
         ON FO.Team_Key = DT.Team_Key
     INNER JOIN dbo.Dim_Site DS
         ON FO.Site_Key = DS.Site_Key
     INNER JOIN dbo.Dim_Shift DSH
         ON FO.Shift_Key = DSH.Shift_Key
    ) AS Joined_Rows,

    (
        SELECT COUNT(*)
        FROM dbo.vw_Operations_Dashboard
    ) AS View_Rows;
GO


/*==============================================================
  2. QA JOIN CARDINALITY
==============================================================*/

SELECT
    'QA' AS Domain,

    (SELECT COUNT(*)
     FROM dbo.Fact_QA) AS Fact_Rows,

    (SELECT COUNT(*)
     FROM dbo.Fact_QA FQ
     INNER JOIN dbo.Dim_Date DD
         ON FQ.Date_Key = DD.Date_Key
     INNER JOIN dbo.Dim_Policy DP
         ON FQ.Policy_Key = DP.Policy_Key
     INNER JOIN dbo.Dim_Error_Code DEC
         ON FQ.Error_Code_Key = DEC.Error_Code_Key
    ) AS Joined_Rows,

    (
        SELECT COUNT(*)
        FROM dbo.vw_QA_Dashboard
    ) AS View_Rows;
GO


/*==============================================================
  3. APPEALS JOIN CARDINALITY
==============================================================*/

SELECT
    'Appeals' AS Domain,

    (SELECT COUNT(*)
     FROM dbo.Fact_Appeals) AS Fact_Rows,

    (SELECT COUNT(*)
     FROM dbo.Fact_Appeals FA
     INNER JOIN dbo.Dim_Date DD
         ON FA.Date_Key = DD.Date_Key
     INNER JOIN dbo.Dim_Policy DP
         ON FA.Policy_Key = DP.Policy_Key
     INNER JOIN dbo.Dim_Appeal_Decision DAD
         ON FA.Appeal_Decision_Key = DAD.Appeal_Decision_Key
    ) AS Joined_Rows,

    (
        SELECT COUNT(*)
        FROM dbo.vw_Appeals_Dashboard
    ) AS View_Rows;
GO


/*==============================================================
  4. COACHING JOIN CARDINALITY
==============================================================*/

SELECT
    'Coaching' AS Domain,

    (SELECT COUNT(*)
     FROM dbo.Fact_Coaching) AS Fact_Rows,

    (SELECT COUNT(*)
     FROM dbo.Fact_Coaching FC
     INNER JOIN dbo.Dim_Date DD
         ON FC.Date_Key = DD.Date_Key
     INNER JOIN dbo.Dim_Client DC
         ON FC.Client_Key = DC.Client_Key
     INNER JOIN dbo.Dim_Site DS
         ON FC.Site_Key = DS.Site_Key
     INNER JOIN dbo.Dim_Process DP
         ON FC.Process_Key = DP.Process_Key
     INNER JOIN dbo.Dim_Team DT
         ON FC.Team_Key = DT.Team_Key
     INNER JOIN dbo.Dim_Employee DE
         ON FC.Employee_Key = DE.Employee_Key
    ) AS Joined_Rows,

    (
        SELECT COUNT(*)
        FROM dbo.vw_Coaching_Dashboard
    ) AS View_Rows;
GO


/*==============================================================
  5. WORKFORCE JOIN CARDINALITY
==============================================================*/

SELECT
    'Workforce' AS Domain,

    (SELECT COUNT(*)
     FROM dbo.Fact_Workforce) AS Fact_Rows,

    (SELECT COUNT(*)
     FROM dbo.Fact_Workforce FW
     INNER JOIN dbo.Dim_Date DD
         ON FW.Date_Key = DD.Date_Key
     INNER JOIN dbo.Dim_Shift DSH
         ON FW.Shift_Key = DSH.Shift_Key
     INNER JOIN dbo.Dim_Shrinkage DSG
         ON FW.Shrinkage_Key = DSG.Shrinkage_Key
    ) AS Joined_Rows,

    (
        SELECT COUNT(*)
        FROM dbo.vw_Workforce_Dashboard
    ) AS View_Rows;
GO


/*==============================================================
  6. FINANCE JOIN CARDINALITY
==============================================================*/

SELECT
    'Finance' AS Domain,

    (SELECT COUNT(*)
     FROM dbo.Fact_Finance) AS Fact_Rows,

    (SELECT COUNT(*)
     FROM dbo.Fact_Finance FF
     INNER JOIN dbo.Dim_Date DD
         ON FF.Date_Key = DD.Date_Key
     INNER JOIN dbo.Dim_Billing_Model DBM
         ON FF.Billing_Model_Key = DBM.Billing_Model_Key
     INNER JOIN dbo.Dim_Cost_Center DCC
         ON FF.Cost_Center_Key = DCC.Cost_Center_Key
    ) AS Joined_Rows,

    (
        SELECT COUNT(*)
        FROM dbo.vw_Finance_Dashboard
    ) AS View_Rows;
GO


/*==============================================================
  7. FINAL GRAIN STATUS
==============================================================*/

SELECT
    X.Domain,
    X.Fact_Rows,
    X.Joined_Rows,
    X.View_Rows,

    CASE
        WHEN X.Fact_Rows = X.Joined_Rows
         AND X.Joined_Rows = X.View_Rows
        THEN 'PASS'
        ELSE 'FAIL'
    END AS Validation_Status

FROM
(
    SELECT
        'Operations' AS Domain,
        (SELECT COUNT(*) FROM dbo.Fact_Operations) AS Fact_Rows,
        (SELECT COUNT(*)
         FROM dbo.Fact_Operations FO
         INNER JOIN dbo.Dim_Date DD
             ON FO.Date_Key = DD.Date_Key
         INNER JOIN dbo.Dim_Employee DE
             ON FO.Employee_Key = DE.Employee_Key
         INNER JOIN dbo.Dim_Client DC
             ON FO.Client_Key = DC.Client_Key
         INNER JOIN dbo.Dim_Process DP
             ON FO.Process_Key = DP.Process_Key
         INNER JOIN dbo.Dim_Team DT
             ON FO.Team_Key = DT.Team_Key
         INNER JOIN dbo.Dim_Site DS
             ON FO.Site_Key = DS.Site_Key
         INNER JOIN dbo.Dim_Shift DSH
             ON FO.Shift_Key = DSH.Shift_Key
        ) AS Joined_Rows,
        (SELECT COUNT(*) FROM dbo.vw_Operations_Dashboard) AS View_Rows

    UNION ALL

    SELECT
        'QA',
        (SELECT COUNT(*) FROM dbo.Fact_QA),
        (SELECT COUNT(*)
         FROM dbo.Fact_QA FQ
         INNER JOIN dbo.Dim_Date DD
             ON FQ.Date_Key = DD.Date_Key
         INNER JOIN dbo.Dim_Policy DP
             ON FQ.Policy_Key = DP.Policy_Key
         INNER JOIN dbo.Dim_Error_Code DEC
             ON FQ.Error_Code_Key = DEC.Error_Code_Key
        ),
        (SELECT COUNT(*) FROM dbo.vw_QA_Dashboard)

    UNION ALL

    SELECT
        'Appeals',
        (SELECT COUNT(*) FROM dbo.Fact_Appeals),
        (SELECT COUNT(*)
         FROM dbo.Fact_Appeals FA
         INNER JOIN dbo.Dim_Date DD
             ON FA.Date_Key = DD.Date_Key
         INNER JOIN dbo.Dim_Policy DP
             ON FA.Policy_Key = DP.Policy_Key
         INNER JOIN dbo.Dim_Appeal_Decision DAD
             ON FA.Appeal_Decision_Key = DAD.Appeal_Decision_Key
        ),
        (SELECT COUNT(*) FROM dbo.vw_Appeals_Dashboard)

    UNION ALL

    SELECT
        'Coaching',
        (SELECT COUNT(*) FROM dbo.Fact_Coaching),
        (SELECT COUNT(*)
         FROM dbo.Fact_Coaching FC
         INNER JOIN dbo.Dim_Date DD
             ON FC.Date_Key = DD.Date_Key
         INNER JOIN dbo.Dim_Client DC
             ON FC.Client_Key = DC.Client_Key
         INNER JOIN dbo.Dim_Site DS
             ON FC.Site_Key = DS.Site_Key
         INNER JOIN dbo.Dim_Process DP
             ON FC.Process_Key = DP.Process_Key
         INNER JOIN dbo.Dim_Team DT
             ON FC.Team_Key = DT.Team_Key
         INNER JOIN dbo.Dim_Employee DE
             ON FC.Employee_Key = DE.Employee_Key
        ),
        (SELECT COUNT(*) FROM dbo.vw_Coaching_Dashboard)

    UNION ALL

    SELECT
        'Workforce',
        (SELECT COUNT(*) FROM dbo.Fact_Workforce),
        (SELECT COUNT(*)
         FROM dbo.Fact_Workforce FW
         INNER JOIN dbo.Dim_Date DD
             ON FW.Date_Key = DD.Date_Key
         INNER JOIN dbo.Dim_Shift DSH
             ON FW.Shift_Key = DSH.Shift_Key
         INNER JOIN dbo.Dim_Shrinkage DSG
             ON FW.Shrinkage_Key = DSG.Shrinkage_Key
        ),
        (SELECT COUNT(*) FROM dbo.vw_Workforce_Dashboard)

    UNION ALL

    SELECT
        'Finance',
        (SELECT COUNT(*) FROM dbo.Fact_Finance),
        (SELECT COUNT(*)
         FROM dbo.Fact_Finance FF
         INNER JOIN dbo.Dim_Date DD
             ON FF.Date_Key = DD.Date_Key
         INNER JOIN dbo.Dim_Billing_Model DBM
             ON FF.Billing_Model_Key = DBM.Billing_Model_Key
         INNER JOIN dbo.Dim_Cost_Center DCC
             ON FF.Cost_Center_Key = DCC.Cost_Center_Key
        ),
        (SELECT COUNT(*) FROM dbo.vw_Finance_Dashboard)
) X
ORDER BY X.Domain;
GO


PRINT '51B Reporting View Grain Validation completed successfully.';
GO