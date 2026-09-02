ALTER VIEW dbo.vw_Workforce_Dashboard
AS
SELECT
      DD.Full_Date
    , DD.Year_Number
    , DD.Month_Name
    , DD.Quarter_Name
    , DSH.Shift_Name
    , DSG.Shrinkage_Type

    , FW.Workforce_Key
    , FW.Date_Key
    , FW.Shift_Key
    , FW.Shrinkage_Key
    , FW.Employee_Key

    , DE.Client_Key
    , DE.Process_Key
    , DE.Site_Key
    , DE.Team_Key

    , FW.Hours
    , FW.Scheduled_Hours
    , FW.Adherence_Hours
    , FW.Logged_Hours
    , FW.Handle_Hours
    , FW.Absent_Flag
    , FW.Scheduled_Headcount
    , FW.Actual_Headcount
    , FW.Required_Headcount
    , FW.Scheduled_Employees
    , FW.Absent_Employees

    , FW.Created_Date
    , FW.Modified_Date

FROM dbo.Fact_Workforce FW

INNER JOIN dbo.Dim_Employee DE
    ON FW.Employee_Key = DE.Employee_Key

INNER JOIN dbo.Dim_Date DD
    ON FW.Date_Key = DD.Date_Key

INNER JOIN dbo.Dim_Shift DSH
    ON FW.Shift_Key = DSH.Shift_Key

INNER JOIN dbo.Dim_Shrinkage DSG
    ON FW.Shrinkage_Key = DSG.Shrinkage_Key;