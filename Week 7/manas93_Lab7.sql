USE manas93_Lab7

-- Database creations (STUDENT, UNIT, BUILDING and LEASE)

CREATE TABLE tblBUILDING(
BuildID INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
BuildName VARCHAR(50) NOT NULL,
BuildDescr VARCHAR(500) NULL
)
GO

CREATE TABLE tblUNIT(
UnitID INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
UnitName VARCHAR(50) NOT NULL,
BuildID INT FOREIGN KEY REFERENCES tblBUILDING(BuildID)
)
GO

CREATE TABLE tblSTUDENT(
StudentID INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
StudentFname VARCHAR(50) NOT NULL,
StudentLname VARCHAR(50) NOT NULL,
BirthDate DATE NOT NULL
)
GO

CREATE TABLE tblLEASE(
LeaseID INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
LeaseBeginDate DATE NOT NULL,
LeaseMonthPay NUMERIC(8, 2) NOT NULL,
LeaseEndDate DATE NOT NULL,
StudentID INT FOREIGN KEY REFERENCES tblSTUDENT(StudentID),
UnitID INT FOREIGN KEY REFERENCES tblUNIT(UnitID)
)
GO


-- Populating the look-up tables with 3 rows each
INSERT INTO tblBUILDING(BuildName, BuildDescr)
VALUES ('2222', 'Built in 2222'),
		('1111', 'Built in 1111'),
		('0000', 'Built in 0000')

INSERT INTO tblUNIT(UnitName, BuildID)
VALUES ('Unit1', (SELECT BuildID FROM tblBUILDING WHERE BuildName = '2222')),
		('Unit2', (SELECT BuildID FROM tblBUILDING WHERE BuildName = '1111')),
		('Unit3', (SELECT BuildID FROM tblBUILDING WHERE BuildName = '0000'))

INSERT INTO tblSTUDENT(StudentFname, StudentLname, BirthDate)
VALUES ('Ashutosh', 'Anand', 'February 25, 1993'),
		('Hrishi', 'Raj', 'January 5, 1992'),
		('Manas', 'Pripathi', 'March 16, 1993')
GO



-- Get StudentID Procedure
CREATE PROCEDURE getStudID
@StudFname VARCHAR(50),
@StudLname VARCHAR(50),
@DOB DATE,
@StudID INT OUTPUT
AS
SET @StudID = (SELECT StudentID 
				FROM tblSTUDENT
				WHERE StudentFname = @StudFname
				AND StudentLname = @StudLname
				AND BirthDate = @DOB)
GO

-- Get UnitID Procedure
CREATE PROCEDURE getUnitID
@UnName VARCHAR(50),
@UnID INT OUTPUT
AS
SET @UnID = (SELECT UnitID
			 FROM tblUNIT
			 WHERE UnitName = @UnName)
GO


/*
Explicit transaction to INSERT INTO the LEASE table
*/
CREATE PROCEDURE insertIntoPOP
@Fname VARCHAR(50),
@Lname VARCHAR(50),
@BDate DATE,
@UName VARCHAR(50),
@BeginDate DATE,
@MonthlyPayment NUMERIC(8, 2),
@EndDate DATE
AS

IF (@BDate >= (SELECT GETDATE() - 365.25 * 21))
	BEGIN
	PRINT 'Checking for student age'
	IF (DATEDIFF(dd, @BeginDate, @EndDate) > 365)
	BEGIN
	RAISERROR('Lease greater than 1 year and student is younger than 21 years', 11, 1)
	RETURN
	END
	PRINT 'Student old enough'
	END

DECLARE @S_ID INT
DECLARE @U_ID INT

EXEC getStudID
@StudFname = @Fname,
@StudLname = @Lname,
@DOB = @BDate,
@StudID = @S_ID OUTPUT

IF @S_ID IS NULL
	BEGIN
	RAISERROR('Student ID cannot be null', 11, 1)
	RETURN
	END

EXEC getUnitID
@UnName = @Uname,
@UnID = @U_ID OUTPUT

IF @U_ID IS NULL
	BEGIN
	RAISERROR('Unit ID cannot be null', 11, 1)
	RETURN
	END

BEGIN TRAN T1
INSERT INTO tblLEASE(LeaseBeginDate, LeaseMonthPay, LeaseEndDate, StudentID, UnitID)
VALUES (@BeginDate, @MonthlyPayment, @EndDate, @S_ID, @U_ID)
IF @@ERROR<> 0
	ROLLBACK TRAN T1
ELSE
	COMMIT TRAN T1
GO

EXEC insertIntoPOP
@Fname = 'Ashutosh',
@Lname = 'Anand',
@BDate = '02/25/1993',
@UName = 'Unit1',
@BeginDate = 'May 24, 2019',
@MonthlyPayment = 2000,
@EndDate = 'July 1, 2020'


