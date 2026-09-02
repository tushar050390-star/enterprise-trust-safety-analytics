/******************************************************************************
Project      : Enterprise Trust & Safety Operations Analytics
Script       : 28_Generate_Dim_Employee.sql
Author       : Tushar Mehta
Purpose      : Generate Employee Dimension Data
Created On   : 05-Aug-2026
******************************************************************************/

USE Enterprise_Trust_Safety_DWH;
GO

--============================================================
-- Number of Employees to Generate
--============================================================

DECLARE @EmployeeCount INT = 100;

--============================================================
-- Campaign Mapping
--============================================================

DECLARE @Campaign TABLE
(
    Campaign_ID INT IDENTITY(1,1),
    Client_Key INT,
    Process_Key INT,
    Team_Key INT,
    Site_Key INT
);

INSERT INTO @Campaign
(
    Client_Key,
    Process_Key,
    Team_Key,
    Site_Key
)
VALUES
(1,1,1,1),
(2,2,2,2),
(3,3,3,5),
(4,4,4,6),
(5,5,5,7),
(6,6,6,4),
(7,7,7,3),
(8,8,8,8);

--============================================================
-- Employee Name Pool
--============================================================

DECLARE @EmployeeNames TABLE
(
    Name_ID INT IDENTITY(1,1),
    Employee_Name NVARCHAR(100)
);

INSERT INTO @EmployeeNames
(Employee_Name)

VALUES
('Rahul Sharma'),
('Priya Singh'),
('Amit Verma'),
('Neha Gupta'),
('Rohit Kumar'),
('Anjali Mehta'),
('Vikas Patel'),
('Sneha Joshi'),
('Arjun Nair'),
('Pooja Shah'),
('Karan Malhotra'),
('Deepak Yadav'),
('Ritika Jain'),
('Nikhil Kapoor'),
('Swati Mishra'),
('Harsh Agarwal'),
('Komal Sinha'),
('Abhishek Tiwari'),
('Megha Chawla'),
('Sandeep Reddy');

--============================================================
-- Designation Pool
--============================================================

DECLARE @Designation TABLE
(
    ID INT IDENTITY(1,1),
    Designation NVARCHAR(50)
);

INSERT INTO @Designation
VALUES
('Associate'),
('Senior Associate'),
('SME'),
('Team Leader');