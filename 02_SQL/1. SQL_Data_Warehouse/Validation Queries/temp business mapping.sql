IF OBJECT_ID('tempdb..#CampaignMapping') IS NOT NULL
    DROP TABLE #CampaignMapping;

CREATE TABLE #CampaignMapping
(
    Campaign_ID INT IDENTITY(1,1),
    Client_Name VARCHAR(100),
    Process_Name VARCHAR(100),
    Team_Name VARCHAR(100),
    Site_Name VARCHAR(100)
);

INSERT INTO #CampaignMapping
(
    Client_Name,
    Process_Name,
    Team_Name,
    Site_Name
)
VALUES
('Apex Digital','Content Moderation','Team Alpha','Bengaluru'),
('Nova Media','Appeals','Team Bravo','Hyderabad'),
('Vertex AI','Fraud Investigation','Team Charlie','Mohali'),
('Orion Solutions','Risk Operations','Team Delta','Indore'),
('Quantum Platforms','Trust & Safety','Team Falcon','Austin'),
('Horizon Tech','Customer Support','Team Phoenix','New York'),
('Pinnacle Services','Payments Review','Team Titan','Manila'),
('Nimbus Interactive','Identity Verification','Team Orion','Cebu');

SELECT *
FROM #CampaignMapping;

/*==============================================================
Resolve Business Names to Surrogate Keys
==============================================================*/

SELECT
    CM.Campaign_ID,
    C.Client_Key,
    C.Client_Name,
    P.Process_Key,
    P.Process_Name,
    T.Team_Key,
    T.Team_Name,
    S.Site_Key,
    S.Site_Name
FROM #CampaignMapping CM
INNER JOIN dbo.Dim_Client C
    ON CM.Client_Name = C.Client_Name
INNER JOIN dbo.Dim_Process P
    ON CM.Process_Name = P.Process_Name
INNER JOIN dbo.Dim_Team T
    ON CM.Team_Name = T.Team_Name
INNER JOIN dbo.Dim_Site S
    ON CM.Site_Name = S.Site_Name
ORDER BY CM.Campaign_ID;