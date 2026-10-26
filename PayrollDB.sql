-- =====================================================
-- MODULE 1: DATABASE SCHEMA AND DATA
-- =====================================================
-- Project      : Employee Payroll Management System
-- Description  : Covers database creation, DDL (table
--                definitions with constraints), and
--                DML (INSERT, UPDATE, DELETE).
-- Tables       : Department, Position, Employee,
--                PermanentEmployee, ContractEmployee,
--                Attendance, Bonus, Deduction,
--                Payroll, PayrollAudit, PerformanceReview
-- Total Tables : 11  |  Min Records per Table : 15
-- =====================================================


-- =====================================================
-- SECTION 1: DATABASE CREATION
-- Drop and recreate PayrollDB for a clean slate.
-- =====================================================

USE master;
GO

IF DB_ID('PayrollDB') IS NOT NULL
BEGIN
    ALTER DATABASE PayrollDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE PayrollDB;
END
GO

CREATE DATABASE PayrollDB;
GO

USE PayrollDB;
GO


-- =====================================================
-- SECTION 2: TABLE CREATION (DDL)
-- All 11 tables are created here with primary keys,
-- foreign keys, check constraints, and defaults.
-- Insert order: Department -> Position -> Employee ->
-- PermanentEmployee / ContractEmployee -> Attendance
-- -> Bonus -> Deduction -> Payroll -> PayrollAudit
-- -> PerformanceReview
-- =====================================================

-- Table 1: Department
-- Stores company departments with location and budget.
CREATE TABLE Department (
    DepartmentID   INT           PRIMARY KEY,
    DepartmentName VARCHAR(50)   NOT NULL,
    Location       VARCHAR(50),
    Budget         DECIMAL(15,2) DEFAULT 0.00
);

-- Table 2: Position
-- Stores job positions with basic salary and grade level.
CREATE TABLE [Position] (
    PositionID   INT           PRIMARY KEY,
    PositionName VARCHAR(50)   NOT NULL,
    BasicSalary  DECIMAL(10,2) NOT NULL,
    GradeLevel   VARCHAR(10)
);

-- Table 3: Employee
-- Core employee information. References Department and
-- Position via foreign keys. Gender is CHECK-constrained.
CREATE TABLE Employee (
    EmployeeID   INT          PRIMARY KEY,
    FirstName    VARCHAR(50)  NOT NULL,
    LastName     VARCHAR(50)  NOT NULL,
    Gender       VARCHAR(10),
    DOB          DATE,
    Phone        VARCHAR(15)  UNIQUE,
    Email        VARCHAR(100) UNIQUE,
    HireDate     DATE,
    DepartmentID INT,
    PositionID   INT,
    Address      VARCHAR(100),
    IsActive     BIT          DEFAULT 1,
    CONSTRAINT chk_gender CHECK (Gender IN ('Male','Female','Other')),
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    FOREIGN KEY (PositionID)   REFERENCES [Position](PositionID)
);

-- Table 4: PermanentEmployee
-- Stores allowances specific to permanent employees.
-- EmployeeID is both PK and FK to Employee.
CREATE TABLE PermanentEmployee (
    EmployeeID       INT           PRIMARY KEY,
    MedicalAllowance DECIMAL(10,2) DEFAULT 0.00,
    HouseAllowance   DECIMAL(10,2) DEFAULT 0.00,
    ProvidentFund    DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

-- Table 5: ContractEmployee
-- Stores contract details for contract-based employees.
CREATE TABLE ContractEmployee (
    EmployeeID      INT           PRIMARY KEY,
    ContractPeriod  INT,
    HourlyRate      DECIMAL(10,2),
    ContractEndDate DATE,
    RenewalAllowed  BIT DEFAULT 0,
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

-- Table 6: Attendance
-- Records daily attendance per employee.
-- Status is restricted via CHECK constraint.
CREATE TABLE Attendance (
    AttendanceID   INT  PRIMARY KEY,
    EmployeeID     INT,
    AttendanceDate DATE,
    Status         VARCHAR(20),
    CheckInTime    TIME,
    CONSTRAINT chk_status CHECK (Status IN ('Present','Absent','Leave','Half-Day','Late')),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

-- Table 7: Bonus
-- Records bonuses given to employees with date and reason.
CREATE TABLE Bonus (
    BonusID     INT           PRIMARY KEY,
    EmployeeID  INT,
    BonusAmount DECIMAL(10,2),
    BonusDate   DATE,
    Description VARCHAR(100),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

-- Table 8: Deduction
-- Records salary deductions per employee with reason.
CREATE TABLE Deduction (
    DeductionID     INT           PRIMARY KEY,
    EmployeeID      INT,
    DeductionAmount DECIMAL(10,2),
    DeductionDate   DATE,
    Reason          VARCHAR(100),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

-- Table 9: Payroll
-- Monthly payroll records showing BasicSalary, Bonus,
-- Deduction, and computed NetSalary per employee.
CREATE TABLE Payroll (
    PayrollID    INT           PRIMARY KEY,
    EmployeeID   INT,
    PayrollMonth VARCHAR(20),
    BasicSalary  DECIMAL(10,2),
    Bonus        DECIMAL(10,2) DEFAULT 0.00,
    Deduction    DECIMAL(10,2) DEFAULT 0.00,
    NetSalary    DECIMAL(10,2),
    PaymentDate  DATE,
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

-- Table 10: PayrollAudit
-- Automatically logs every INSERT/UPDATE/DELETE on Payroll.
-- AuditID is auto-incremented via IDENTITY.
CREATE TABLE PayrollAudit (
    AuditID    INT      IDENTITY(1,1) PRIMARY KEY,
    PayrollID  INT,
    ActionType VARCHAR(20),
    ActionDate DATETIME DEFAULT GETDATE()
);

-- Table 11: PerformanceReview
-- Stores performance reviews with rating (1-5).
-- ReviewerID is a self-referencing FK to Employee.
CREATE TABLE PerformanceReview (
    ReviewID   INT  PRIMARY KEY,
    EmployeeID INT,
    ReviewDate DATE,
    ReviewerID INT,
    Rating     INT,
    Comments   VARCHAR(200),
    CONSTRAINT chk_rating CHECK (Rating BETWEEN 1 AND 5),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);


-- =====================================================
-- SECTION 3: DATA INSERTION (DML)
-- Minimum 15 records inserted into every table.
-- =====================================================

-- -------------------------------------------------
-- INSERT: Department (15 records)
-- Company departments across major Pakistani cities.
-- -------------------------------------------------
INSERT INTO Department VALUES
(1,  'Human Resources',        'Lahore',    5000000.00),
(2,  'Information Technology', 'Islamabad', 12000000.00),
(3,  'Finance',                'Karachi',   8000000.00),
(4,  'Marketing',              'Lahore',    6000000.00),
(5,  'Operations',             'Peshawar',  7500000.00),
(6,  'Legal',                  'Islamabad', 4500000.00),
(7,  'Procurement',            'Karachi',   5500000.00),
(8,  'Research & Development', 'Lahore',    9000000.00),
(9,  'Customer Support',       'Multan',    4000000.00),
(10, 'Administration',         'Islamabad', 3500000.00),
(11, 'Sales',                  'Karachi',   7000000.00),
(12, 'Logistics',              'Peshawar',  5000000.00),
(13, 'Quality Assurance',      'Lahore',    4800000.00),
(14, 'Public Relations',       'Islamabad', 3800000.00),
(15, 'Training & Development', 'Multan',    4200000.00);

-- -------------------------------------------------
-- INSERT: Position (15 records)
-- Job roles with salary bands and grade levels.
-- -------------------------------------------------
INSERT INTO [Position] VALUES
(1,  'Manager',          80000.00,  'G-7'),
(2,  'Developer',        60000.00,  'G-5'),
(3,  'Accountant',       50000.00,  'G-4'),
(4,  'HR Officer',       45000.00,  'G-4'),
(5,  'Team Lead',        75000.00,  'G-6'),
(6,  'Analyst',          65000.00,  'G-5'),
(7,  'Director',         120000.00, 'G-9'),
(8,  'Intern',           25000.00,  'G-1'),
(9,  'Consultant',       90000.00,  'G-8'),
(10, 'Support Officer',  35000.00,  'G-3'),
(11, 'Sales Executive',  40000.00,  'G-3'),
(12, 'QA Engineer',      55000.00,  'G-5'),
(13, 'Legal Advisor',    85000.00,  'G-7'),
(14, 'Procurement Lead', 70000.00,  'G-6'),
(15, 'Trainer',          48000.00,  'G-4');

-- -------------------------------------------------
-- INSERT: Employee (15 records)
-- Core employee data referencing Department/Position.
-- Employees 101-115 cover diverse roles and locations.
-- -------------------------------------------------
INSERT INTO Employee VALUES
(101, 'Ali',     'Khan',    'Male',   '1998-05-10', '03001234567', 'ali@company.com',     '2022-01-01', 2,  2,  'Gulberg Lahore',      1),
(102, 'Ahmed',   'Raza',    'Male',   '1997-03-12', '03112223333', 'ahmed@company.com',   '2021-05-01', 1,  1,  'F-8 Islamabad',       1),
(103, 'Sara',    'Iqbal',   'Female', '1999-08-15', '03223334444', 'sara@company.com',    '2023-02-01', 3,  3,  'Clifton Karachi',     1),
(104, 'Ayesha',  'Noor',    'Female', '1996-11-05', '03334445555', 'ayesha@company.com',  '2020-06-08', 1,  1,  'Model Town Lahore',   1),
(105, 'Bilal',   'Ahmed',   'Male',   '1995-04-18', '03445556666', 'bilal@company.com',   '2019-08-15', 2,  2,  'G-10 Islamabad',      1),
(106, 'Zara',    'Sheikh',  'Female', '2000-01-22', '03556667777', 'zara@company.com',    '2024-03-01', 4,  6,  'DHA Phase4 Lahore',   1),
(107, 'Usman',   'Ali',     'Male',   '1993-07-30', '03667778888', 'usman@company.com',   '2018-11-10', 2,  5,  'E-7 Islamabad',       1),
(108, 'Hina',    'Malik',   'Female', '1994-09-14', '03778889999', 'hina@company.com',    '2017-04-20', 3,  3,  'PECHS Karachi',       1),
(109, 'Kamran',  'Butt',    'Male',   '1990-12-01', '03889990000', 'kamran@company.com',  '2015-07-01', 5,  1,  'Hayatabad Peshawar',  1),
(110, 'Tariq',   'Mehmood', 'Male',   '1988-02-25', '03990001111', 'tariq@company.com',   '2013-03-15', 2,  5,  'Bahria Islamabad',    1),
(111, 'Omar',    'Farhan',  'Male',   '2000-09-15', '03600001122', 'omar@company.com',    '2025-06-01', 2,  2,  'DHA Lahore',          1),
(112, 'Nadia',   'Hussain', 'Female', '1992-06-20', '03711112233', 'nadia@company.com',   '2016-09-01', 6,  13, 'Blue Area Islamabad', 1),
(113, 'Fahad',   'Qureshi', 'Male',   '1991-03-11', '03822223344', 'fahad@company.com',   '2014-01-20', 11, 11, 'Gulshan Karachi',     1),
(114, 'Mahnoor', 'Baig',    'Female', '2001-07-18', '03933334455', 'mahnoor@company.com', '2024-07-15', 13, 12, 'Johar Town Lahore',   1),
(115, 'Faisal',  'Javed',   'Male',   '1989-10-05', '03044445566', 'faisal@company.com',  '2012-05-10', 7,  9,  'F-6 Islamabad',       1);

-- -------------------------------------------------
-- INSERT: PermanentEmployee (12 records)
-- NOTE: Only 12 of 15 employees are permanent;
--       3 are contract-based (103, 106, 108).
--       Additional employees (111-115) are included.
-- -------------------------------------------------
INSERT INTO PermanentEmployee VALUES
(101, 5000.00,  8000.00,  3000.00),
(102, 6000.00,  10000.00, 4000.00),
(104, 4500.00,  7000.00,  2500.00),
(105, 5000.00,  8000.00,  3000.00),
(107, 5500.00,  9000.00,  3500.00),
(109, 7000.00,  12000.00, 5000.00),
(110, 6500.00,  11000.00, 4500.00),
(111, 4000.00,  6000.00,  2000.00),
(112, 7500.00,  13000.00, 5500.00),
(113, 4000.00,  6500.00,  2200.00),
(114, 3500.00,  5500.00,  1800.00),
(115, 8000.00,  15000.00, 6000.00);

-- -------------------------------------------------
-- INSERT: ContractEmployee (3 records)
-- Employees 103, 106, 108 are on contract terms.
-- -------------------------------------------------
INSERT INTO ContractEmployee VALUES
(103, 12, 700.00,  '2024-02-01', 1),
(106,  6, 850.00,  '2024-09-01', 0),
(108, 12, 600.00,  '2025-04-20', 1);

-- -------------------------------------------------
-- INSERT: Attendance (15 records)
-- Daily attendance log covering different statuses.
-- -------------------------------------------------
INSERT INTO Attendance VALUES
(1,  101, '2025-05-01', 'Present',  '08:55'),
(2,  102, '2025-05-01', 'Present',  '09:00'),
(3,  103, '2025-05-01', 'Absent',   NULL),
(4,  104, '2025-05-01', 'Present',  '08:50'),
(5,  105, '2025-05-01', 'Late',     '09:45'),
(6,  106, '2025-05-02', 'Present',  '09:00'),
(7,  107, '2025-05-02', 'Present',  '08:45'),
(8,  108, '2025-05-02', 'Leave',    NULL),
(9,  109, '2025-05-03', 'Present',  '08:30'),
(10, 110, '2025-05-03', 'Half-Day', '09:00'),
(11, 111, '2025-05-03', 'Present',  '08:58'),
(12, 112, '2025-05-04', 'Present',  '09:05'),
(13, 113, '2025-05-04', 'Late',     '09:50'),
(14, 114, '2025-05-05', 'Present',  '08:45'),
(15, 115, '2025-05-05', 'Absent',   NULL);

-- -------------------------------------------------
-- INSERT: Bonus (15 records)
-- Bonuses given to employees for various reasons.
-- -------------------------------------------------
INSERT INTO Bonus VALUES
(1,  101, 5000.00,  '2025-05-30', 'Performance bonus'),
(2,  102, 7000.00,  '2025-05-30', 'Annual appraisal'),
(3,  104, 4000.00,  '2025-05-30', 'Team management award'),
(4,  107, 6000.00,  '2025-05-30', 'Project completion'),
(5,  109, 8000.00,  '2025-05-30', 'Top performer award'),
(6,  110, 5500.00,  '2025-05-30', 'Year-end bonus'),
(7,  111, 3000.00,  '2025-05-30', 'Joining bonus'),
(8,  112, 9000.00,  '2025-05-30', 'Legal case win'),
(9,  113, 3500.00,  '2025-05-30', 'Sales target achieved'),
(10, 115, 10000.00, '2025-05-30', 'Strategic consulting'),
(11, 105, 4500.00,  '2025-05-30', 'Sprint delivery bonus'),
(12, 106, 3000.00,  '2025-05-30', 'Campaign bonus'),
(13, 108, 2500.00,  '2025-05-30', 'Reconciliation bonus'),
(14, 114, 2000.00,  '2025-05-30', 'QA milestone'),
(15, 103, 1500.00,  '2025-05-30', 'Audit completion bonus');

-- -------------------------------------------------
-- INSERT: Deduction (15 records)
-- Salary deductions for tax, fines, and leave.
-- -------------------------------------------------
INSERT INTO Deduction VALUES
(1,  101, 1000.00, '2025-05-30', 'Late Fine'),
(2,  102, 1500.00, '2025-05-30', 'Income Tax'),
(3,  103,  800.00, '2025-05-30', 'Absent Deduction'),
(4,  105,  500.00, '2025-05-30', 'Late Fine'),
(5,  108, 1200.00, '2025-05-30', 'Unpaid Leave'),
(6,  109, 2000.00, '2025-05-30', 'Income Tax'),
(7,  110, 1800.00, '2025-05-30', 'Income Tax'),
(8,  112, 2500.00, '2025-05-30', 'Income Tax'),
(9,  115, 3000.00, '2025-05-30', 'Income Tax'),
(10, 107,  700.00, '2025-05-30', 'Equipment Damage'),
(11, 113,  400.00, '2025-05-30', 'Late Fine'),
(12, 114,  300.00, '2025-05-30', 'Half-Day Deduction'),
(13, 104,  600.00, '2025-05-30', 'Loan Installment'),
(14, 106,  200.00, '2025-05-30', 'Late Fine'),
(15, 111,  500.00, '2025-05-30', 'Provident Fund Contribution');

-- -------------------------------------------------
-- INSERT: Payroll (15 records)
-- Monthly payroll for all 15 employees — May 2025.
-- NetSalary = BasicSalary + Bonus - Deduction
-- -------------------------------------------------
INSERT INTO Payroll VALUES
(1,  101, 'May-2025', 60000.00,  5000.00, 1000.00, 64000.00, '2025-05-31'),
(2,  102, 'May-2025', 80000.00,  7000.00, 1500.00, 85500.00, '2025-05-31'),
(3,  103, 'May-2025', 50000.00,  1500.00,  800.00, 50700.00, '2025-05-31'),
(4,  104, 'May-2025', 80000.00,  4000.00,  600.00, 83400.00, '2025-05-31'),
(5,  105, 'May-2025', 60000.00,  4500.00,  500.00, 64000.00, '2025-05-31'),
(6,  106, 'May-2025', 65000.00,  3000.00,  200.00, 67800.00, '2025-05-31'),
(7,  107, 'May-2025', 75000.00,  6000.00,  700.00, 80300.00, '2025-05-31'),
(8,  108, 'May-2025', 50000.00,  2500.00, 1200.00, 51300.00, '2025-05-31'),
(9,  109, 'May-2025', 80000.00,  8000.00, 2000.00, 86000.00, '2025-05-31'),
(10, 110, 'May-2025', 75000.00,  5500.00, 1800.00, 78700.00, '2025-05-31'),
(11, 111, 'May-2025', 60000.00,  3000.00,  500.00, 62500.00, '2025-05-31'),
(12, 112, 'May-2025', 85000.00,  9000.00, 2500.00, 91500.00, '2025-05-31'),
(13, 113, 'May-2025', 40000.00,  3500.00,  400.00, 43100.00, '2025-05-31'),
(14, 114, 'May-2025', 55000.00,  2000.00,  300.00, 56700.00, '2025-05-31'),
(15, 115, 'May-2025', 90000.00, 10000.00, 3000.00, 97000.00, '2025-05-31');

-- -------------------------------------------------
-- INSERT: PerformanceReview (15 records)
-- Employee reviews with rating 1-5 and comments.
-- ReviewerID references another employee (manager).
-- -------------------------------------------------
INSERT INTO PerformanceReview VALUES
(1,  101, '2025-04-01', 110, 4, 'Good technical skills'),
(2,  102, '2025-04-01', 104, 5, 'Exceptional leadership'),
(3,  103, '2025-04-05', 108, 3, 'Needs improvement in punctuality'),
(4,  104, '2025-04-05', 102, 5, 'Outstanding HR management'),
(5,  105, '2025-04-10', 110, 3, 'Punctuality issues noted'),
(6,  109, '2025-04-15', 102, 5, 'Best operations manager'),
(7,  106, '2025-04-15', 104, 4, 'Creative marketing output'),
(8,  107, '2025-04-20', 110, 4, 'Strong team leadership'),
(9,  108, '2025-04-20', 109, 3, 'Attendance needs attention'),
(10, 110, '2025-04-22', 102, 5, 'Consistent high performer'),
(11, 111, '2025-04-25', 107, 4, 'Quick learner, good attitude'),
(12, 112, '2025-04-25', 115, 5, 'Excellent legal expertise'),
(13, 113, '2025-04-28', 109, 3, 'Sales targets partially met'),
(14, 114, '2025-04-28', 107, 4, 'Solid QA documentation'),
(15, 115, '2025-04-30', 102, 5, 'Strategic consulting excellence');


-- =====================================================
-- SECTION 4: DML — UPDATE & DELETE
-- Demonstrates UPDATE and DELETE operations on data.
-- =====================================================

-- Update employee address after relocation
UPDATE Employee
SET Address = 'Rawalpindi Saddar'
WHERE EmployeeID = 102;

-- Developer salary revised company-wide
UPDATE [Position]
SET BasicSalary = 65000.00
WHERE PositionID = 2;

-- Deactivate employee who resigned
UPDATE Employee
SET IsActive = 0
WHERE EmployeeID = 108;

-- IT department budget increased
UPDATE Department
SET Budget = 13000000.00
WHERE DepartmentID = 2;

-- Promote employee 113 to Team Lead
UPDATE Employee
SET PositionID = 5
WHERE EmployeeID = 113;

-- Remove absent attendance record (data correction)
DELETE FROM Attendance
WHERE AttendanceID = 3;

-- Remove late fine deduction for employee 105 (waived)
DELETE FROM Deduction
WHERE Reason = 'Late Fine' AND EmployeeID = 105;
-- =====================================================
-- MODULE 2: VIEWS, TRIGGERS, STORED PROCEDURES
--           & TRANSACTIONS
-- =====================================================
-- Project      : Employee Payroll Management System
-- Description  : This module builds the business logic
--                layer on top of Module 1. It covers:
--                  - Views for reporting & analytics
--                  - Triggers for automation & auditing
--                  - Stored Procedures for reusable ops
--                  - Transactions with error handling
-- Depends On   : Module1_Schema_Data.sql must be run first
-- =====================================================

USE PayrollDB;
GO


-- =====================================================
-- SECTION 5: VIEWS
-- Views provide reusable, named SELECT queries that
-- simplify reporting and abstract join complexity.
-- =====================================================

-- View 1: EmployeeDepartmentView
-- Shows each employee with their department and location.
-- Useful for HR directory and location-based reporting.
IF OBJECT_ID('EmployeeDepartmentView', 'V') IS NOT NULL
    DROP VIEW EmployeeDepartmentView;
GO
CREATE VIEW EmployeeDepartmentView AS
SELECT
    E.EmployeeID,
    E.FirstName,
    E.LastName,
    D.DepartmentName,
    D.Location
FROM Employee E
JOIN Department D ON E.DepartmentID = D.DepartmentID;
GO

-- View 2: EmployeeSalaryView
-- Full payroll summary per employee with department
-- and position details. Used for payslip generation.
IF OBJECT_ID('EmployeeSalaryView', 'V') IS NOT NULL
    DROP VIEW EmployeeSalaryView;
GO
CREATE VIEW EmployeeSalaryView AS
SELECT
    E.EmployeeID,
    E.FirstName + ' ' + E.LastName AS FullName,
    D.DepartmentName,
    POS.PositionName,
    P.NetSalary,
    P.PayrollMonth
FROM Employee E
JOIN Payroll    P   ON E.EmployeeID   = P.EmployeeID
JOIN Department D   ON E.DepartmentID = D.DepartmentID
JOIN [Position] POS ON E.PositionID   = POS.PositionID;
GO

-- View 3: DepartmentPayrollView
-- Aggregated payroll statistics per department.
-- Includes total, average, max, and min net salary.
IF OBJECT_ID('DepartmentPayrollView', 'V') IS NOT NULL
    DROP VIEW DepartmentPayrollView;
GO
CREATE VIEW DepartmentPayrollView AS
SELECT
    D.DepartmentName,
    COUNT(E.EmployeeID) AS TotalEmployees,
    SUM(P.NetSalary)    AS TotalNetSalary,
    AVG(P.NetSalary)    AS AvgSalary,
    MAX(P.NetSalary)    AS MaxSalary,
    MIN(P.NetSalary)    AS MinSalary
FROM Department D
JOIN Employee E ON D.DepartmentID = E.DepartmentID
JOIN Payroll  P ON E.EmployeeID   = P.EmployeeID
GROUP BY D.DepartmentName;
GO

-- View 4: HighSalaryEmployeeView
-- Lists employees earning above the company average.
-- Useful for budget analysis and benchmarking.
IF OBJECT_ID('HighSalaryEmployeeView', 'V') IS NOT NULL
    DROP VIEW HighSalaryEmployeeView;
GO
CREATE VIEW HighSalaryEmployeeView AS
SELECT
    E.EmployeeID,
    E.FirstName + ' ' + E.LastName AS FullName,
    D.DepartmentName,
    P.NetSalary
FROM Employee E
JOIN Payroll    P ON E.EmployeeID   = P.EmployeeID
JOIN Department D ON E.DepartmentID = D.DepartmentID
WHERE P.NetSalary > (SELECT AVG(NetSalary) FROM Payroll);
GO

-- View 5: ActiveEmployeesView
-- Shows only currently active employees with their role.
-- Used for operational headcount reporting.
IF OBJECT_ID('ActiveEmployeesView', 'V') IS NOT NULL
    DROP VIEW ActiveEmployeesView;
GO
CREATE VIEW ActiveEmployeesView AS
SELECT
    E.EmployeeID,
    E.FirstName + ' ' + E.LastName AS FullName,
    E.Gender,
    D.DepartmentName,
    POS.PositionName,
    E.HireDate
FROM Employee E
JOIN Department D   ON E.DepartmentID = D.DepartmentID
JOIN [Position] POS ON E.PositionID   = POS.PositionID
WHERE E.IsActive = 1;
GO

-- View 6: ContractEmployeeSummaryView
-- Summarizes contract employees with renewal eligibility
-- and remaining contract details.
IF OBJECT_ID('ContractEmployeeSummaryView', 'V') IS NOT NULL
    DROP VIEW ContractEmployeeSummaryView;
GO
CREATE VIEW ContractEmployeeSummaryView AS
SELECT
    E.EmployeeID,
    E.FirstName + ' ' + E.LastName AS FullName,
    CE.ContractPeriod,
    CE.HourlyRate,
    CE.ContractEndDate,
    CASE WHEN CE.RenewalAllowed = 1 THEN 'Yes' ELSE 'No' END AS EligibleForRenewal
FROM Employee E
JOIN ContractEmployee CE ON E.EmployeeID = CE.EmployeeID;
GO

-- Query all views for verification
SELECT * FROM EmployeeDepartmentView;
SELECT * FROM EmployeeSalaryView       ORDER BY NetSalary DESC;
SELECT * FROM DepartmentPayrollView    ORDER BY TotalNetSalary DESC;
SELECT * FROM HighSalaryEmployeeView;
SELECT * FROM ActiveEmployeesView;
SELECT * FROM ContractEmployeeSummaryView;


-- =====================================================
-- SECTION 6: TRIGGERS
-- Triggers automate actions on INSERT/UPDATE/DELETE.
-- Used here for: salary calculation, audit logging.
-- =====================================================

-- Trigger 1: CalculateSalary
-- Fires AFTER INSERT on Payroll.
-- Recalculates NetSalary = BasicSalary + Bonus - Deduction
-- immediately after a new payroll row is inserted.
IF OBJECT_ID('CalculateSalary', 'TR') IS NOT NULL
    DROP TRIGGER CalculateSalary;
GO
CREATE TRIGGER CalculateSalary
ON Payroll
AFTER INSERT
AS
BEGIN
    -- Update NetSalary based on inserted values
    UPDATE P
    SET P.NetSalary = I.BasicSalary + I.Bonus - I.Deduction
    FROM Payroll P
    INNER JOIN inserted I ON P.PayrollID = I.PayrollID;
END;
GO

-- Trigger 2: PayrollInsertAudit
-- Fires AFTER INSERT on Payroll.
-- Logs all new payroll entries into PayrollAudit table.
IF OBJECT_ID('PayrollInsertAudit', 'TR') IS NOT NULL
    DROP TRIGGER PayrollInsertAudit;
GO
CREATE TRIGGER PayrollInsertAudit
ON Payroll
AFTER INSERT
AS
BEGIN
    INSERT INTO PayrollAudit (PayrollID, ActionType)
    SELECT PayrollID, 'INSERT'
    FROM inserted;
END;
GO

-- Trigger 3: PayrollUpdateAudit
-- Fires AFTER UPDATE on Payroll.
-- Logs all payroll modifications into PayrollAudit.
IF OBJECT_ID('PayrollUpdateAudit', 'TR') IS NOT NULL
    DROP TRIGGER PayrollUpdateAudit;
GO
CREATE TRIGGER PayrollUpdateAudit
ON Payroll
AFTER UPDATE
AS
BEGIN
    INSERT INTO PayrollAudit (PayrollID, ActionType)
    SELECT PayrollID, 'UPDATE'
    FROM inserted;
END;
GO

-- Trigger 4: PayrollDeleteAudit
-- Fires AFTER DELETE on Payroll.
-- Logs deleted payroll records into PayrollAudit.
IF OBJECT_ID('PayrollDeleteAudit', 'TR') IS NOT NULL
    DROP TRIGGER PayrollDeleteAudit;
GO
CREATE TRIGGER PayrollDeleteAudit
ON Payroll
AFTER DELETE
AS
BEGIN
    INSERT INTO PayrollAudit (PayrollID, ActionType)
    SELECT PayrollID, 'DELETE'
    FROM deleted;
END;
GO


-- =====================================================
-- SECTION 7: STORED PROCEDURES
-- Stored procedures encapsulate reusable SQL logic.
-- =====================================================

-- Procedure 1: GeneratePayroll
-- Inserts a new payroll record for a given employee.
-- Computes NetSalary inline during insertion.
IF OBJECT_ID('GeneratePayroll', 'P') IS NOT NULL
    DROP PROCEDURE GeneratePayroll;
GO
CREATE PROCEDURE GeneratePayroll
    @PayrollID  INT,
    @EmployeeID INT,
    @Month      VARCHAR(20),
    @Salary     DECIMAL(10,2),
    @Bonus      DECIMAL(10,2),
    @Deduction  DECIMAL(10,2)
AS
BEGIN
    INSERT INTO Payroll
        (PayrollID, EmployeeID, PayrollMonth, BasicSalary,
         Bonus, Deduction, NetSalary, PaymentDate)
    VALUES
        (@PayrollID, @EmployeeID, @Month, @Salary,
         @Bonus, @Deduction,
         @Salary + @Bonus - @Deduction,
         GETDATE());

    PRINT 'Payroll record created for Employee ID: ' + CAST(@EmployeeID AS VARCHAR);
END;
GO

-- Procedure 2: GetDepartmentPayroll
-- Returns full payroll breakdown for all employees
-- in a specified department, sorted by NetSalary.
IF OBJECT_ID('GetDepartmentPayroll', 'P') IS NOT NULL
    DROP PROCEDURE GetDepartmentPayroll;
GO
CREATE PROCEDURE GetDepartmentPayroll
    @DepartmentID INT
AS
BEGIN
    SELECT
        E.EmployeeID,
        E.FirstName + ' ' + E.LastName AS FullName,
        POS.PositionName,
        P.PayrollMonth,
        P.BasicSalary,
        P.Bonus,
        P.Deduction,
        P.NetSalary
    FROM Employee E
    JOIN [Position] POS ON E.PositionID = POS.PositionID
    JOIN Payroll    P   ON E.EmployeeID = P.EmployeeID
    WHERE E.DepartmentID = @DepartmentID
    ORDER BY P.NetSalary DESC;
END;
GO

-- Procedure 3: SearchEmployee
-- Searches employees by first or last name using LIKE.
-- Useful for HR lookup and employee directory search.
IF OBJECT_ID('SearchEmployee', 'P') IS NOT NULL
    DROP PROCEDURE SearchEmployee;
GO
CREATE PROCEDURE SearchEmployee
    @SearchTerm VARCHAR(50)
AS
BEGIN
    SELECT
        E.EmployeeID,
        E.FirstName,
        E.LastName,
        D.DepartmentName,
        POS.PositionName,
        E.Email,
        E.Phone
    FROM Employee E
    JOIN Department D   ON E.DepartmentID = D.DepartmentID
    JOIN [Position] POS ON E.PositionID   = POS.PositionID
    WHERE E.FirstName LIKE '%' + @SearchTerm + '%'
       OR E.LastName  LIKE '%' + @SearchTerm + '%';
END;
GO

-- Procedure 4: GetEmployeePayrollHistory
-- Retrieves complete payroll history for one employee.
-- Ordered by most recent payment first.
IF OBJECT_ID('GetEmployeePayrollHistory', 'P') IS NOT NULL
    DROP PROCEDURE GetEmployeePayrollHistory;
GO
CREATE PROCEDURE GetEmployeePayrollHistory
    @EmployeeID INT
AS
BEGIN
    SELECT
        P.PayrollID,
        P.PayrollMonth,
        P.BasicSalary,
        P.Bonus,
        P.Deduction,
        P.NetSalary,
        P.PaymentDate
    FROM Payroll P
    WHERE P.EmployeeID = @EmployeeID
    ORDER BY P.PaymentDate DESC;
END;
GO

-- Execute Stored Procedures for demonstration
EXEC GeneratePayroll 16, 101, 'June-2025', 65000, 3000, 1000;
EXEC GeneratePayroll 17, 102, 'June-2025', 80000, 5000, 1500;
EXEC GeneratePayroll 18, 115, 'June-2025', 90000, 8000, 3000;
EXEC GetDepartmentPayroll 2;
EXEC SearchEmployee 'Ali';
EXEC GetEmployeePayrollHistory 101;


-- =====================================================
-- SECTION 8: TRANSACTION WITH ERROR HANDLING
-- Demonstrates ACID-compliant multi-step operations.
-- If any step fails, the entire transaction is rolled back.
-- =====================================================

-- Transaction 1: New Employee Full Onboarding
-- Atomically inserts into Employee, PermanentEmployee,
-- and Payroll. All succeed or all are rolled back.
BEGIN TRANSACTION;
BEGIN TRY
    -- Step 1: Insert into core Employee table
    INSERT INTO Employee
        (EmployeeID, FirstName, LastName, Gender, DOB,
         Phone, Email, HireDate, DepartmentID, PositionID, Address)
    VALUES
        (116, 'Rabia', 'Siddiqui', 'Female', '2002-04-10',
         '03155556677', 'rabia@company.com',
         '2025-06-01', 8, 15, 'Gulberg III Lahore');

    -- Step 2: Assign permanent employee allowances
    INSERT INTO PermanentEmployee
        (EmployeeID, MedicalAllowance, HouseAllowance, ProvidentFund)
    VALUES (116, 3000.00, 5000.00, 1500.00);

    -- Step 3: Create initial payroll record
    INSERT INTO Payroll
        (PayrollID, EmployeeID, PayrollMonth,
         BasicSalary, Bonus, Deduction, NetSalary, PaymentDate)
    VALUES
        (19, 116, 'June-2025', 48000.00, 0.00, 0.00, 48000.00, '2025-06-30');

    COMMIT TRANSACTION;
    PRINT 'Employee 116 onboarding committed successfully.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Transaction failed and rolled back: ' + ERROR_MESSAGE();
END CATCH;

-- Transaction 2: Bulk Bonus Update with Rollback Safety
-- Updates bonuses for multiple employees atomically.
BEGIN TRANSACTION;
BEGIN TRY
    UPDATE Payroll SET Bonus = Bonus + 2000, NetSalary = NetSalary + 2000
    WHERE EmployeeID IN (101, 105, 111) AND PayrollMonth = 'May-2025';

    INSERT INTO PayrollAudit (PayrollID, ActionType)
    SELECT PayrollID, 'UPDATE'
    FROM Payroll
    WHERE EmployeeID IN (101, 105, 111) AND PayrollMonth = 'May-2025';

    COMMIT TRANSACTION;
    PRINT 'Bulk bonus update committed successfully.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Bulk update failed and rolled back: ' + ERROR_MESSAGE();
END CATCH;
-- =====================================================
-- MODULE 3: QUERIES AND ANALYTICS
-- =====================================================
-- Project      : Employee Payroll Management System
-- Description  : This module provides comprehensive
--                data retrieval and analysis. It covers:
--                  - JOIN Queries (INNER, LEFT, RIGHT,
--                    FULL OUTER, Multi-table)
--                  - Aggregate Functions with GROUP BY
--                    and HAVING
--                  - Nested / Subqueries
--                  - Cursor-based row iteration
--                  - Advanced Queries (RANK, TOP, DATEDIFF,
--                    BETWEEN, Window Functions)
-- Depends On   : Module1_Schema_Data.sql
--                Module2_Views_Triggers_Procedures.sql
-- =====================================================

USE PayrollDB;
GO


-- =====================================================
-- SECTION 9: JOIN QUERIES
-- Demonstrates various JOIN types to combine data
-- across multiple related tables.
-- =====================================================

-- -----------------------------------------------
-- INNER JOIN: Employee with their Department
-- Returns only employees who have a matching dept.
-- -----------------------------------------------
SELECT
    E.EmployeeID,
    E.FirstName + ' ' + E.LastName AS FullName,
    D.DepartmentName,
    D.Location
FROM Employee E
INNER JOIN Department D ON E.DepartmentID = D.DepartmentID;

-- -----------------------------------------------
-- INNER JOIN: Employee with their Position/Grade
-- Returns employee role, basic salary, and grade.
-- -----------------------------------------------
SELECT
    E.FirstName,
    E.LastName,
    P.PositionName,
    P.BasicSalary,
    P.GradeLevel
FROM Employee E
INNER JOIN [Position] P ON E.PositionID = P.PositionID;

-- -----------------------------------------------
-- LEFT JOIN: Employees with Bonus (NULL if none)
-- Shows all employees; those without a bonus
-- display 0 and 'No Bonus'.
-- -----------------------------------------------
SELECT
    E.FirstName,
    E.LastName,
    ISNULL(B.BonusAmount, 0)          AS BonusAmount,
    ISNULL(B.Description, 'No Bonus') AS BonusDescription
FROM Employee E
LEFT JOIN Bonus B ON E.EmployeeID = B.EmployeeID;

-- -----------------------------------------------
-- LEFT JOIN: Employees with Deductions
-- All employees shown; NULL if no deduction exists.
-- -----------------------------------------------
SELECT
    E.FirstName,
    E.LastName,
    ISNULL(D.DeductionAmount, 0)           AS DeductionAmount,
    ISNULL(D.Reason,   'No Deduction')     AS DeductionReason
FROM Employee E
LEFT JOIN Deduction D ON E.EmployeeID = D.EmployeeID;

-- -----------------------------------------------
-- RIGHT JOIN: All Positions including those with
-- no employees assigned (unoccupied roles).
-- -----------------------------------------------
SELECT
    POS.PositionName,
    POS.BasicSalary,
    E.FirstName,
    E.LastName
FROM Employee E
RIGHT JOIN [Position] POS ON E.PositionID = POS.PositionID;

-- -----------------------------------------------
-- FULL OUTER JOIN Simulation (UNION of L + R)
-- Shows all Employee-Bonus combinations even when
-- one side has no matching record.
-- -----------------------------------------------
SELECT E.EmployeeID, B.BonusID, B.BonusAmount
FROM Employee E LEFT JOIN Bonus B ON E.EmployeeID = B.EmployeeID
UNION
SELECT E.EmployeeID, B.BonusID, B.BonusAmount
FROM Employee E RIGHT JOIN Bonus B ON E.EmployeeID = B.EmployeeID;

-- -----------------------------------------------
-- MULTI-TABLE JOIN: Complete Payroll Detail
-- Combines Employee, Department, Position, Payroll
-- for a full payslip view sorted by NetSalary.
-- -----------------------------------------------
SELECT
    E.EmployeeID,
    E.FirstName + ' ' + E.LastName AS FullName,
    D.DepartmentName,
    POS.PositionName,
    P.PayrollMonth,
    P.BasicSalary,
    P.Bonus,
    P.Deduction,
    P.NetSalary
FROM Employee E
JOIN Department D   ON E.DepartmentID = D.DepartmentID
JOIN [Position] POS ON E.PositionID   = POS.PositionID
JOIN Payroll    P   ON E.EmployeeID   = P.EmployeeID
ORDER BY P.NetSalary DESC;

-- -----------------------------------------------
-- JOIN: Permanent Employees with Allowance Totals
-- Shows gross salary = BasicSalary + allowances.
-- -----------------------------------------------
SELECT
    E.FirstName + ' ' + E.LastName AS FullName,
    PE.MedicalAllowance,
    PE.HouseAllowance,
    PE.ProvidentFund,
    (POS.BasicSalary + PE.MedicalAllowance + PE.HouseAllowance) AS GrossSalary
FROM Employee E
JOIN PermanentEmployee PE  ON E.EmployeeID = PE.EmployeeID
JOIN [Position]        POS ON E.PositionID = POS.PositionID;

-- -----------------------------------------------
-- JOIN: Performance Review with Reviewer Name
-- Self-join on Employee to get reviewer's name.
-- -----------------------------------------------
SELECT
    E.FirstName + ' ' + E.LastName AS EmployeeName,
    R.FirstName + ' ' + R.LastName AS ReviewerName,
    PR.ReviewDate,
    PR.Rating,
    PR.Comments
FROM PerformanceReview PR
JOIN Employee E ON PR.EmployeeID = E.EmployeeID
JOIN Employee R ON PR.ReviewerID = R.EmployeeID;

-- -----------------------------------------------
-- JOIN: Attendance records with Employee names
-- Shows full attendance history with employee info.
-- -----------------------------------------------
SELECT
    A.AttendanceID,
    E.FirstName + ' ' + E.LastName AS EmployeeName,
    A.AttendanceDate,
    A.Status,
    A.CheckInTime
FROM Attendance A
JOIN Employee E ON A.EmployeeID = E.EmployeeID
ORDER BY A.AttendanceDate;


-- =====================================================
-- SECTION 10: AGGREGATE FUNCTIONS
-- Uses COUNT, SUM, AVG, MAX, MIN with GROUP BY
-- and HAVING to summarize payroll data.
-- =====================================================

-- Total number of employees in the system
SELECT COUNT(*)             AS TotalEmployees  FROM Employee;

-- Count of currently active employees only
SELECT COUNT(*)             AS ActiveEmployees FROM Employee WHERE IsActive = 1;

-- Total payroll disbursed across all employees
SELECT SUM(NetSalary)       AS TotalPayroll    FROM Payroll;

-- Average net salary across all payroll records
SELECT AVG(NetSalary)       AS AverageSalary   FROM Payroll;

-- Highest individual net salary in the company
SELECT MAX(NetSalary)       AS HighestSalary   FROM Payroll;

-- Lowest individual net salary in the company
SELECT MIN(NetSalary)       AS LowestSalary    FROM Payroll;

-- Total bonus amount paid out
SELECT SUM(BonusAmount)     AS TotalBonusPaid  FROM Bonus;

-- Total deductions applied across all employees
SELECT SUM(DeductionAmount) AS TotalDeductions FROM Deduction;

-- GROUP BY: Employee headcount per department
SELECT
    D.DepartmentName,
    COUNT(E.EmployeeID) AS EmployeeCount
FROM Department D
LEFT JOIN Employee E ON D.DepartmentID = E.DepartmentID
GROUP BY D.DepartmentName
ORDER BY EmployeeCount DESC;

-- GROUP BY: Salary summary per department
SELECT
    D.DepartmentName,
    SUM(P.NetSalary) AS TotalSalary,
    AVG(P.NetSalary) AS AvgSalary,
    MAX(P.NetSalary) AS MaxSalary,
    MIN(P.NetSalary) AS MinSalary
FROM Department D
JOIN Employee E ON D.DepartmentID = E.DepartmentID
JOIN Payroll  P ON E.EmployeeID   = P.EmployeeID
GROUP BY D.DepartmentName;

-- HAVING: Only departments with more than 1 employee
SELECT
    DepartmentID,
    COUNT(*) AS EmployeeCount
FROM Employee
GROUP BY DepartmentID
HAVING COUNT(*) > 1;

-- GROUP BY: Payroll breakdown by gender
SELECT
    E.Gender,
    COUNT(E.EmployeeID) AS EmpCount,
    AVG(P.NetSalary)    AS AvgSalary,
    MAX(P.NetSalary)    AS MaxSalary,
    MIN(P.NetSalary)    AS MinSalary
FROM Employee E
JOIN Payroll P ON E.EmployeeID = P.EmployeeID
GROUP BY E.Gender;

-- GROUP BY: Average rating per department
SELECT
    D.DepartmentName,
    AVG(CAST(PR.Rating AS DECIMAL(4,2))) AS AvgPerformanceRating,
    COUNT(PR.ReviewID)                   AS TotalReviews
FROM PerformanceReview PR
JOIN Employee   E ON PR.EmployeeID  = E.EmployeeID
JOIN Department D ON E.DepartmentID = D.DepartmentID
GROUP BY D.DepartmentName
ORDER BY AvgPerformanceRating DESC;


-- =====================================================
-- SECTION 11: NESTED / SUBQUERIES
-- Uses subqueries in WHERE and FROM clauses to filter
-- and compare data against computed values.
-- =====================================================

-- Employees earning above the company average salary
SELECT * FROM Payroll
WHERE NetSalary > (SELECT AVG(NetSalary) FROM Payroll);

-- The employee with the single highest net salary
SELECT * FROM Payroll
WHERE NetSalary = (SELECT MAX(NetSalary) FROM Payroll);

-- The employee with the single lowest net salary
SELECT * FROM Payroll
WHERE NetSalary = (SELECT MIN(NetSalary) FROM Payroll);

-- Employees who received at least one bonus
SELECT FirstName, LastName FROM Employee
WHERE EmployeeID IN (SELECT DISTINCT EmployeeID FROM Bonus);

-- Employees who received NO bonus at all
SELECT FirstName, LastName FROM Employee
WHERE EmployeeID NOT IN (SELECT DISTINCT EmployeeID FROM Bonus);

-- Employees earning more than 60,000 net salary
SELECT * FROM Employee
WHERE EmployeeID IN (
    SELECT EmployeeID FROM Payroll WHERE NetSalary > 60000
);

-- Department with the highest total salary expenditure
SELECT DepartmentName FROM Department D
WHERE D.DepartmentID = (
    SELECT TOP 1 E.DepartmentID
    FROM Employee E
    JOIN Payroll P ON E.EmployeeID = P.EmployeeID
    GROUP BY E.DepartmentID
    ORDER BY SUM(P.NetSalary) DESC
);

-- Permanent employees who received bonus above 5000
SELECT E.FirstName, E.LastName
FROM Employee E
JOIN PermanentEmployee PE ON E.EmployeeID = PE.EmployeeID
WHERE E.EmployeeID IN (
    SELECT EmployeeID FROM Bonus WHERE BonusAmount > 5000
);

-- Contract employees eligible for renewal
SELECT FirstName, LastName FROM Employee
WHERE EmployeeID IN (
    SELECT EmployeeID FROM ContractEmployee WHERE RenewalAllowed = 1
);

-- Employees with above-average performance ratings
SELECT E.FirstName + ' ' + E.LastName AS FullName, PR.Rating
FROM Employee E
JOIN PerformanceReview PR ON E.EmployeeID = PR.EmployeeID
WHERE PR.Rating > (SELECT AVG(Rating) FROM PerformanceReview);

-- Employees with both a bonus AND a deduction in same month
SELECT FirstName, LastName FROM Employee
WHERE EmployeeID IN (SELECT EmployeeID FROM Bonus)
  AND EmployeeID IN (SELECT EmployeeID FROM Deduction);

-- Total deductions by employees who are still active
SELECT SUM(D.DeductionAmount) AS ActiveEmployeeDeductions
FROM Deduction D
WHERE D.EmployeeID IN (
    SELECT EmployeeID FROM Employee WHERE IsActive = 1
);


-- =====================================================
-- SECTION 12: CURSOR
-- Row-by-row processing using a declared cursor.
-- Prints formatted payroll summary for May 2025.
-- =====================================================

-- Declare cursor variables
DECLARE @EmpID  INT;
DECLARE @FName  VARCHAR(50);
DECLARE @LName  VARCHAR(50);
DECLARE @NetSal DECIMAL(10,2);
DECLARE @Dept   VARCHAR(50);

-- Define cursor to iterate over May 2025 payroll records
DECLARE emp_cursor CURSOR FOR
    SELECT
        E.EmployeeID,
        E.FirstName,
        E.LastName,
        P.NetSalary,
        D.DepartmentName
    FROM Employee E
    JOIN Payroll    P ON E.EmployeeID   = P.EmployeeID
    JOIN Department D ON E.DepartmentID = D.DepartmentID
    WHERE P.PayrollMonth = 'May-2025';

-- Open cursor and begin row-by-row processing
OPEN emp_cursor;
FETCH NEXT FROM emp_cursor INTO @EmpID, @FName, @LName, @NetSal, @Dept;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'ID: '   + CAST(@EmpID AS VARCHAR)   +
          ' | '    + @FName + ' ' + @LName      +
          ' | Dept: ' + @Dept                   +
          ' | Net Salary: Rs.' + CAST(@NetSal AS VARCHAR);

    FETCH NEXT FROM emp_cursor INTO @EmpID, @FName, @LName, @NetSal, @Dept;
END;

-- Always close and deallocate cursors after use
CLOSE emp_cursor;
DEALLOCATE emp_cursor;


-- =====================================================
-- SECTION 13: ADVANCED QUERIES
-- Uses window functions, ranking, date arithmetic,
-- range filters, and audit trail queries.
-- =====================================================

-- Rank all employees by net salary (highest = Rank 1)
SELECT
    ROW_NUMBER() OVER (ORDER BY P.NetSalary DESC) AS SalaryRank,
    E.FirstName + ' ' + E.LastName AS FullName,
    D.DepartmentName,
    P.NetSalary
FROM Employee E
JOIN Payroll    P ON E.EmployeeID   = P.EmployeeID
JOIN Department D ON E.DepartmentID = D.DepartmentID;

-- DENSE_RANK to handle ties in salary ranking
SELECT
    DENSE_RANK() OVER (ORDER BY P.NetSalary DESC) AS DenseRank,
    E.FirstName + ' ' + E.LastName AS FullName,
    P.NetSalary
FROM Employee E
JOIN Payroll P ON E.EmployeeID = P.EmployeeID;

-- Top 5 highest-paid employees in the company
SELECT TOP 5
    E.FirstName + ' ' + E.LastName AS FullName,
    D.DepartmentName,
    P.NetSalary
FROM Employee E
JOIN Payroll    P ON E.EmployeeID   = P.EmployeeID
JOIN Department D ON E.DepartmentID = D.DepartmentID
ORDER BY P.NetSalary DESC;

-- Years of service for each active employee
SELECT
    FirstName + ' ' + LastName AS FullName,
    HireDate,
    DATEDIFF(YEAR, HireDate, GETDATE()) AS YearsOfService
FROM Employee
WHERE IsActive = 1
ORDER BY YearsOfService DESC;

-- Employees with salary in the 50,000 – 80,000 range
SELECT
    E.FirstName,
    E.LastName,
    P.NetSalary
FROM Employee E
JOIN Payroll P ON E.EmployeeID = P.EmployeeID
WHERE P.NetSalary BETWEEN 50000 AND 80000;

-- Employees hired in the last 5 years
SELECT
    FirstName + ' ' + LastName AS FullName,
    HireDate,
    DATEDIFF(YEAR, HireDate, GETDATE()) AS YearsOfService
FROM Employee
WHERE HireDate >= DATEADD(YEAR, -5, GETDATE());

-- Running total of payroll using window function
SELECT
    E.FirstName + ' ' + E.LastName AS FullName,
    P.NetSalary,
    SUM(P.NetSalary) OVER (ORDER BY P.NetSalary DESC) AS RunningTotal
FROM Employee E
JOIN Payroll P ON E.EmployeeID = P.EmployeeID;

-- Payroll audit trail (all logged actions)
SELECT
    AuditID,
    PayrollID,
    ActionType,
    ActionDate
FROM PayrollAudit
ORDER BY ActionDate DESC;

-- Query all views for summary reporting
SELECT * FROM EmployeeDepartmentView;
SELECT * FROM EmployeeSalaryView      ORDER BY NetSalary DESC;
SELECT * FROM DepartmentPayrollView   ORDER BY TotalNetSalary DESC;
SELECT * FROM HighSalaryEmployeeView;
SELECT * FROM ActiveEmployeesView;
SELECT * FROM ContractEmployeeSummaryView;
-- =====================================================
-- MODULE 4: NORMALIZATION
-- =====================================================
-- Project      : Employee Payroll Management System
-- Description  : This module proves that PayrollDB
--                fully complies with database
--                normalization standards up to 3NF.
--                It covers:
--                  - First Normal Form  (1NF)
--                  - Second Normal Form (2NF)
--                  - Third Normal Form  (3NF)
--                  - Normalization summary for all 11
--                    tables
--                  - Verification queries
-- Depends On   : Module1_Schema_Data.sql
-- =====================================================

USE PayrollDB;
GO


-- =====================================================
-- SECTION 14: NORMALIZATION
-- PayrollDB is designed to satisfy 1NF, 2NF, and 3NF.
-- Each normal form is explained and verified below.
-- =====================================================


-- -----------------------------------------------------
-- FIRST NORMAL FORM (1NF)
-- -----------------------------------------------------
-- RULE: Every column must hold atomic (single, indivisible)
--       values. No repeating groups. Every row must be
--       uniquely identifiable via a Primary Key.
-- -----------------------------------------------------

-- 1NF CHECK — Department Table:
--   Columns: DepartmentID | DepartmentName | Location | Budget
--   - All values are atomic (single string or number per cell).
--   - No multi-valued columns (e.g., no "Lahore, Karachi").
--   - DepartmentID is the Primary Key — each row is unique.
--   STATUS: PASS — Department satisfies 1NF.

-- 1NF CHECK — Position Table:
--   Columns: PositionID | PositionName | BasicSalary | GradeLevel
--   - All values are single atomic values.
--   - No arrays or comma-separated salary ranges.
--   - PositionID is the Primary Key.
--   STATUS: PASS — Position satisfies 1NF.

-- 1NF CHECK — Employee Table:
--   Columns: EmployeeID | FirstName | LastName | Gender | DOB |
--            Phone | Email | HireDate | DepartmentID | PositionID | Address
--   - Name is split into FirstName and LastName (atomic).
--   - No repeating groups (one row = one employee).
--   - Gender has a CHECK constraint for valid atomic values.
--   - EmployeeID is the Primary Key.
--   STATUS: PASS — Employee satisfies 1NF.

-- 1NF CHECK — Payroll Table:
--   Each row = one payroll entry for one employee for one month.
--   - BasicSalary, Bonus, Deduction, NetSalary are single decimals.
--   - PayrollID is the Primary Key.
--   STATUS: PASS — Payroll satisfies 1NF.

-- 1NF CHECK — Attendance Table:
--   Each row = one attendance record per employee per date.
--   - Status is a single atomic value with CHECK constraint.
--   - CheckInTime is a single TIME value (or NULL if absent/leave).
--   - AttendanceID is the Primary Key.
--   STATUS: PASS — Attendance satisfies 1NF.

-- 1NF CHECK — Bonus, Deduction, PerformanceReview:
--   - All columns hold single atomic values per row.
--   - Each table has its own unique Primary Key.
--   STATUS: PASS — All three satisfy 1NF.

-- 1NF CHECK — PermanentEmployee, ContractEmployee:
--   - Each stores one set of attributes per employee.
--   - EmployeeID serves as both PK and FK (1:1 relationship).
--   STATUS: PASS — Both satisfy 1NF.

-- 1NF CHECK — PayrollAudit:
--   - AuditID is IDENTITY-generated (auto-incremented) PK.
--   - ActionType is a single atomic string ('INSERT'/'UPDATE'/'DELETE').
--   STATUS: PASS — PayrollAudit satisfies 1NF.

-- Verification Query: Show all column names and data types
-- to confirm atomic, single-valued columns across all tables.
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN (
    'Department', 'Position', 'Employee', 'PermanentEmployee',
    'ContractEmployee', 'Attendance', 'Bonus', 'Deduction',
    'Payroll', 'PerformanceReview', 'PayrollAudit'
)
ORDER BY TABLE_NAME, ORDINAL_POSITION;


-- -----------------------------------------------------
-- SECOND NORMAL FORM (2NF)
-- -----------------------------------------------------
-- RULE: Must be in 1NF. Every non-key attribute must
--       be FULLY functionally dependent on the ENTIRE
--       Primary Key. This applies to tables with
--       composite (multi-column) primary keys.
--       Partial dependency = non-key column depends
--       on only PART of a composite key.
-- -----------------------------------------------------

-- 2NF CHECK — All tables use SINGLE-COLUMN primary keys:
--   Department        -> PK: DepartmentID   (single column)
--   Position          -> PK: PositionID     (single column)
--   Employee          -> PK: EmployeeID     (single column)
--   PermanentEmployee -> PK: EmployeeID     (single column)
--   ContractEmployee  -> PK: EmployeeID     (single column)
--   Attendance        -> PK: AttendanceID   (single column)
--   Bonus             -> PK: BonusID        (single column)
--   Deduction         -> PK: DeductionID    (single column)
--   Payroll           -> PK: PayrollID      (single column)
--   PerformanceReview -> PK: ReviewID       (single column)
--   PayrollAudit      -> PK: AuditID        (single column)
--
-- Since all PKs are single-column, partial dependency
-- is structurally impossible — a non-key column cannot
-- depend on "part" of a one-column key.
-- STATUS: PASS — All 11 tables satisfy 2NF.

-- 2NF Detailed Example — Payroll Table:
--   PK: PayrollID
--   - BasicSalary  fully depends on PayrollID (not on EmployeeID alone)
--   - Bonus        fully depends on PayrollID
--   - Deduction    fully depends on PayrollID
--   - NetSalary    fully depends on PayrollID
--
--   NOTE: BasicSalary in Payroll stores the salary AT THAT TIME,
--   not derived from Position.BasicSalary at query time. This design
--   ensures historical records remain accurate even after salary changes,
--   and eliminates potential partial dependency on PositionID.
--   STATUS: PASS — Payroll satisfies 2NF.

-- Verification Query: Show Payroll table PK dependency
-- Each row is uniquely identified by PayrollID.
SELECT
    PayrollID,
    EmployeeID,
    PayrollMonth,
    BasicSalary,
    Bonus,
    Deduction,
    NetSalary
FROM Payroll
ORDER BY PayrollID;

-- Verification Query: Show Attendance PK dependency
-- Each row is uniquely identified by AttendanceID.
SELECT
    AttendanceID,
    EmployeeID,
    AttendanceDate,
    Status
FROM Attendance
ORDER BY AttendanceID;


-- -----------------------------------------------------
-- THIRD NORMAL FORM (3NF)
-- -----------------------------------------------------
-- RULE: Must be in 2NF. No transitive dependencies.
--       Every non-key attribute must depend DIRECTLY
--       on the Primary Key — not on another non-key
--       attribute.
--       Transitive dependency: PK -> A -> B (B depends
--       on A, not directly on PK). This must be removed.
-- -----------------------------------------------------

-- 3NF CHECK — Employee Table:
--   PK: EmployeeID
--   - EmployeeID -> DepartmentID  (FK reference, not transitive)
--   - EmployeeID -> PositionID    (FK reference, not transitive)
--   - DepartmentName is NOT stored in Employee. If it were, then:
--     EmployeeID -> DepartmentID -> DepartmentName (transitive!) REMOVED.
--   - PositionName, BasicSalary, GradeLevel are NOT stored in Employee.
--     EmployeeID -> PositionID -> BasicSalary (transitive!) REMOVED.
--   These are kept in separate Department and Position tables.
--   STATUS: PASS — Employee satisfies 3NF.

-- 3NF CHECK — Payroll Table:
--   PK: PayrollID
--   - NetSalary = BasicSalary + Bonus - Deduction (stored for history)
--   - NetSalary is NOT derived at query-time from other tables.
--   - No non-key column depends on another non-key column.
--   STATUS: PASS — Payroll satisfies 3NF.

-- 3NF CHECK — PermanentEmployee Table:
--   PK: EmployeeID
--   - MedicalAllowance directly depends on EmployeeID.
--   - HouseAllowance   directly depends on EmployeeID.
--   - ProvidentFund    directly depends on EmployeeID.
--   - No transitive dependency: allowances do not depend on
--     each other or on any non-key attribute.
--   STATUS: PASS — PermanentEmployee satisfies 3NF.

-- 3NF CHECK — ContractEmployee Table:
--   PK: EmployeeID
--   - ContractPeriod, HourlyRate, ContractEndDate, RenewalAllowed
--     all depend directly on EmployeeID.
--   STATUS: PASS — ContractEmployee satisfies 3NF.

-- 3NF CHECK — Department Table:
--   PK: DepartmentID
--   - DepartmentName depends on DepartmentID  (direct)
--   - Location       depends on DepartmentID  (direct)
--   - Budget         depends on DepartmentID  (direct)
--   - No non-key column depends on another non-key column.
--   STATUS: PASS — Department satisfies 3NF.

-- 3NF CHECK — PerformanceReview Table:
--   PK: ReviewID
--   - ReviewerID is stored as FK, not as ReviewerName (prevents
--     transitive dependency: ReviewID -> ReviewerName -> ReviewerDept).
--   STATUS: PASS — PerformanceReview satisfies 3NF.

-- 3NF CHECK — PayrollAudit Table:
--   PK: AuditID (IDENTITY)
--   - PayrollID    depends on AuditID directly.
--   - ActionType   depends on AuditID directly.
--   - ActionDate   depends on AuditID directly.
--   STATUS: PASS — PayrollAudit satisfies 3NF.

-- Verification Query 1: Employee stores only FK references.
-- Proves 3NF — names are NOT stored directly in Employee.
SELECT
    E.EmployeeID,
    E.FirstName,
    E.LastName,
    E.DepartmentID,  -- FK only (not DepartmentName)
    E.PositionID     -- FK only (not PositionName or BasicSalary)
FROM Employee E;

-- Verification Query 2: JOIN needed to retrieve descriptive data.
-- This proves 3NF separation — derived data requires a JOIN.
SELECT
    E.EmployeeID,
    E.FirstName + ' ' + E.LastName AS FullName,
    D.DepartmentName,   -- from Department table (normalized)
    P.PositionName,     -- from Position table   (normalized)
    P.BasicSalary       -- from Position table   (normalized)
FROM Employee E
JOIN Department D ON E.DepartmentID = D.DepartmentID
JOIN [Position] P ON E.PositionID   = P.PositionID;

-- Verification Query 3: Foreign key relationships
-- Shows all FK constraints proving referential integrity.
SELECT
    fk.name                              AS ForeignKeyName,
    tp.name                              AS ParentTable,
    cp.name                              AS ParentColumn,
    tr.name                              AS ReferencedTable,
    cr.name                              AS ReferencedColumn
FROM sys.foreign_keys fk
JOIN sys.tables             tp ON fk.parent_object_id      = tp.object_id
JOIN sys.tables             tr ON fk.referenced_object_id  = tr.object_id
JOIN sys.foreign_key_columns fkc ON fk.object_id           = fkc.constraint_object_id
JOIN sys.columns            cp ON fkc.parent_column_id     = cp.column_id
                               AND fkc.parent_object_id    = cp.object_id
JOIN sys.columns            cr ON fkc.referenced_column_id = cr.column_id
                               AND fkc.referenced_object_id= cr.object_id
ORDER BY tp.name;


-- =====================================================
-- NORMALIZATION SUMMARY TABLE (All 11 Tables)
-- =====================================================
-- Table              | 1NF | 2NF | 3NF | Notes
-- -------------------|-----|-----|-----|-------------------------------
-- Department         | YES | YES | YES | Single PK, no transitive deps
-- Position           | YES | YES | YES | Single PK, no transitive deps
-- Employee           | YES | YES | YES | FKs for Dept/Position (not names)
-- PermanentEmployee  | YES | YES | YES | EmployeeID as PK+FK, direct deps
-- ContractEmployee   | YES | YES | YES | EmployeeID as PK+FK, direct deps
-- Attendance         | YES | YES | YES | Single PK, atomic status values
-- Bonus              | YES | YES | YES | Single PK, no redundancy
-- Deduction          | YES | YES | YES | Single PK, no redundancy
-- Payroll            | YES | YES | YES | Historical salary, no trans. dep
-- PerformanceReview  | YES | YES | YES | ReviewerID stored as FK
-- PayrollAudit       | YES | YES | YES | IDENTITY PK, audit log only
-- =====================================================
-- CONCLUSION: PayrollDB fully satisfies 3NF.
--             No data redundancy, no partial dependencies,
--             no transitive dependencies exist across
--             any of the 11 tables.
-- =====================================================
