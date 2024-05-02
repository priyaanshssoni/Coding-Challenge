
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'CareerHub')
 CREATE DATABASE CareerHub

USE CareerHub;


-- Create Companies table
CREATE TABLE Companies (
    CompanyID INT PRIMARY KEY identitiy(1,1,
    CompanyName VARCHAR(255) NOT NULL,
    Location VARCHAR(255) NOT NULL
)

-- Create Jobs table
CREATE TABLE Jobs (
    JobID INT PRIMARY KEY identity(1,1),
    CompanyID INT,
    JobTitle VARCHAR(255) NOT NULL,
    JobDescription TEXT,
    JobLocation VARCHAR(255) NOT NULL,
    Salary DECIMAL(10, 2) NOT NULL,
    JobType VARCHAR(50),
    PostedDate DATETIME,
    FOREIGN KEY (CompanyID) REFERENCES Companies(CompanyID)
)

-- Create Applicants table
CREATE TABLE Applicants (
    ApplicantID INT PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Email VARCHAR(255) NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    Resume TEXT
)

-- Create Applications table
CREATE TABLE Applications (
    ApplicationID INT PRIMARY KEY,
    JobID INT,
    ApplicantID INT,
    ApplicationDate DATETIME,
    CoverLetter TEXT,
    FOREIGN KEY (JobID) REFERENCES Jobs(JobID),
    FOREIGN KEY (ApplicantID) REFERENCES Applicants(ApplicantID)
)

-- Count the number of applications received for each job listing
SELECT j.JobTitle, COUNT(a.ApplicationID) AS ApplicationCount
FROM Jobs j
LEFT JOIN Applications a ON j.JobID = a.JobID
GROUP BY j.JobID, j.JobTitle

-- Retrieve job listings within a specified salary range
DECLARE @MinSalary DECIMAL(10, 2) = 60000
DECLARE @MaxSalary DECIMAL(10, 2) = 80000

SELECT j.JobTitle, c.CompanyName, j.JobLocation, j.Salary
FROM Jobs j
INNER JOIN Companies c ON j.CompanyID = c.CompanyID
WHERE j.Salary BETWEEN @MinSalary AND @MaxSalary

-- Retrieve job application history for a specific applicant
DECLARE @ApplicantID INT = 1
SELECT j.JobTitle, c.CompanyName, a.ApplicationDate
FROM Applications a
INNER JOIN Jobs j ON a.JobID = j.JobID
INNER JOIN Companies c ON j.CompanyID = c.CompanyID
WHERE a.ApplicantID = @ApplicantID;

-- Calculate and display the average salary offered by all companies
SELECT AVG(Salary) AS AverageSalary
FROM Jobs
WHERE Salary > 0

--Identify the company that has posted the most job listings
SELECT TOP 1 c.CompanyName, COUNT(j.JobID) AS JobCount
FROM Companies c
LEFT JOIN Jobs j ON c.CompanyID = j.CompanyID
GROUP BY c.CompanyID, c.CompanyName
ORDER BY COUNT(j.JobID) DESC

-- Find applicants with 3 years of experience in 'CityX'
SELECT  A.*
FROM Applicants A INNER JOIN Applications AP ON A.ApplicantID = AP.ApplicantID
INNER JOIN Jobs J ON AP.JobID = J.JobID
INNER JOIN Companies C ON J.CompanyID = C.CompanyID
WHERE C.Location = 'CityX'
    AND TRY_CONVERT(INT, SUBSTRING(Resume, CHARINDEX('Experience:', Resume) + LEN('Experience:'), 
                                   CHARINDEX('years', Resume) - (CHARINDEX('Experience:', Resume) + LEN('Experience:')))) >= 3

                                

-- Retrieve a list of distinct job titles with salaries between $60,000 and $80,000
SELECT DISTINCT JobTitle
FROM Jobs
WHERE Salary BETWEEN 60000 AND 80000

-- Find jobs that have not received any applications
SELECT JobTitle
FROM Jobs
WHERE JobID NOT IN (SELECT DISTINCT JobID FROM Applications)

-- Retrieve a list of job applicants along with the companies and positions they have applied for
SELECT a.FirstName, a.LastName, c.CompanyName, j.JobTitle
FROM Applicants a
JOIN Applications ap ON a.ApplicantID = ap.ApplicantID
JOIN Jobs j ON ap.JobID = j.JobID
JOIN Companies c ON j.CompanyID = c.CompanyID

--  Retrieve a list of companies along with the count of jobs they have posted
SELECT c.CompanyName, COUNT(j.JobID) AS JobCount
FROM Companies c
LEFT JOIN Jobs j ON c.CompanyID = j.CompanyID
GROUP BY c.CompanyName;

--  List all applicants along with the companies and positions they have applied for
SELECT a.FirstName, a.LastName, c.CompanyName, j.JobTitle
FROM Applicants a
LEFT JOIN Applications ap ON a.ApplicantID = ap.ApplicantID
LEFT JOIN Jobs j ON ap.JobID = j.JobID
LEFT JOIN Companies c ON j.CompanyID = c.CompanyID

--  Find companies that have posted jobs with a salary higher than the average salary of all jobs
SELECT c.CompanyName
FROM Companies c
JOIN Jobs j ON c.CompanyID = j.CompanyID
WHERE j.Salary > (SELECT AVG(Salary) FROM Jobs WHERE Salary > 0)

-- Display a list of applicants with their names and a concatenated string of their city and state
SELECT a.FirstName, a.LastName, c.Location
FROM Applicants a
JOIN Applications ap ON a.ApplicantID = ap.ApplicantID
JOIN Jobs j ON ap.JobID = j.JobID
JOIN Companies c ON j.CompanyID = c.CompanyID

-- Retrieve a list of jobs with titles containing either 'Developer' or 'Engineer'
SELECT JobTitle
FROM Jobs
WHERE JobTitle LIKE '%Developer%' OR JobTitle LIKE '%Engineer%'

-- Retrieve a list of applicants and the jobs they have applied for, including those who have not applied and jobs without applicants
SELECT a.FirstName, a.LastName, c.CompanyName, j.JobTitle
FROM Applicants a
FULL JOIN Applications ap ON a.ApplicantID = ap.ApplicantID
FULL JOIN Jobs j ON ap.JobID = j.JobID
FULL JOIN Companies c ON j.CompanyID = c.CompanyID

--  List all combinations of applicants and companies where the company is in a specific city and the applicant has more than 2 years of experience
SELECT a.FirstName, a.LastName, c.CompanyName, c.Location
FROM Applicants a
JOIN Applications ap ON a.ApplicantID = ap.ApplicantID
JOIN Jobs j ON ap.JobID = j.JobID
JOIN Companies c ON j.CompanyID = c.CompanyID
WHERE c.Location = 'Chennai' and TRY_CONVERT(INT, SUBSTRING(Resume, CHARINDEX('Experience:', Resume) + LEN('Experience:'), 
                                   CHARINDEX('years', Resume) - (CHARINDEX('Experience:', Resume) + LEN('Experience:')))) > 2
