/* ============================================================
   POPULATE MISSING OPERATIONS ATTRIBUTES
   Scenario-derived using existing SLA performance
   ============================================================ */

UPDATE dbo.Fact_Operations
SET
    Case_Status =
        CASE
            WHEN SLA_Compliance_Pct >= 98 THEN
                CASE
                    WHEN Fact_Operations_Key % 20 < 18 THEN 'Closed'
                    WHEN Fact_Operations_Key % 20 = 18 THEN 'Pending'
                    ELSE 'Open'
                END

            WHEN SLA_Compliance_Pct >= 97 THEN
                CASE
                    WHEN Fact_Operations_Key % 20 < 16 THEN 'Closed'
                    WHEN Fact_Operations_Key % 20 < 19 THEN 'Pending'
                    ELSE 'Open'
                END

            WHEN SLA_Compliance_Pct >= 96 THEN
                CASE
                    WHEN Fact_Operations_Key % 20 < 14 THEN 'Closed'
                    WHEN Fact_Operations_Key % 20 < 18 THEN 'Pending'
                    WHEN Fact_Operations_Key % 20 = 18 THEN 'Open'
                    ELSE 'Escalated'
                END

            ELSE
                CASE
                    WHEN Fact_Operations_Key % 20 < 12 THEN 'Closed'
                    WHEN Fact_Operations_Key % 20 < 16 THEN 'Pending'
                    WHEN Fact_Operations_Key % 20 < 18 THEN 'Open'
                    ELSE 'Escalated'
                END
        END,

    Active_Work =
        CASE
            WHEN SLA_Compliance_Pct >= 98
                THEN ROUND(Cases_Handled * 0.08, 0)

            WHEN SLA_Compliance_Pct >= 97
                THEN ROUND(Cases_Handled * 0.10, 0)

            WHEN SLA_Compliance_Pct >= 96
                THEN ROUND(Cases_Handled * 0.12, 0)

            ELSE
                ROUND(Cases_Handled * 0.15, 0)
        END,

    Total_Capacity =
        CASE
            WHEN SLA_Compliance_Pct >= 98
                THEN ROUND(Cases_Handled * 0.08 / 0.85, 0)

            WHEN SLA_Compliance_Pct >= 97
                THEN ROUND(Cases_Handled * 0.10 / 0.82, 0)

            WHEN SLA_Compliance_Pct >= 96
                THEN ROUND(Cases_Handled * 0.12 / 0.80, 0)

            ELSE
                ROUND(Cases_Handled * 0.15 / 0.75, 0)
        END,

    Escalated_Cases =
        CASE
            WHEN SLA_Compliance_Pct >= 98
                THEN ROUND(Cases_Handled * 0.01, 0)

            WHEN SLA_Compliance_Pct >= 97
                THEN ROUND(Cases_Handled * 0.015, 0)

            WHEN SLA_Compliance_Pct >= 96
                THEN ROUND(Cases_Handled * 0.02, 0)

            ELSE
                ROUND(Cases_Handled * 0.03, 0)
        END

WHERE Case_Status IS NULL
   OR Active_Work IS NULL
   OR Total_Capacity IS NULL
   OR Escalated_Cases IS NULL;

   SELECT
    Case_Status,
    COUNT(*) AS Row_Count,
    SUM(Cases_Handled) AS Cases_Handled,
    SUM(Active_Work) AS Active_Work,
    SUM(Total_Capacity) AS Total_Capacity,
    SUM(Escalated_Cases) AS Escalated_Cases
FROM dbo.Fact_Operations
GROUP BY Case_Status
ORDER BY Row_Count DESC;


SELECT
    COUNT(*) AS Total_Rows,

    SUM(CASE WHEN Case_Status IS NULL THEN 1 ELSE 0 END) AS Null_Case_Status,
    SUM(CASE WHEN Active_Work IS NULL THEN 1 ELSE 0 END) AS Null_Active_Work,
    SUM(CASE WHEN Total_Capacity IS NULL THEN 1 ELSE 0 END) AS Null_Total_Capacity,
    SUM(CASE WHEN Escalated_Cases IS NULL THEN 1 ELSE 0 END) AS Null_Escalated_Cases,

    SUM(Active_Work) AS Total_Active_Work,
    SUM(Total_Capacity) AS Total_Capacity,
    SUM(Escalated_Cases) AS Total_Escalated_Cases,

    CAST(
        SUM(Active_Work) * 100.0 /
        NULLIF(SUM(Total_Capacity), 0)
        AS DECIMAL(10,2)
    ) AS Queue_Utilization_Pct,

    CAST(
        SUM(Escalated_Cases) * 100.0 /
        NULLIF(SUM(Cases_Handled), 0)
        AS DECIMAL(10,2)
    ) AS Escalation_Rate_Pct

FROM dbo.Fact_Operations;