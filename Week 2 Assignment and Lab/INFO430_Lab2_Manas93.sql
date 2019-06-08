-- table Customer creation
CREATE TABLE tblCUSTOMER(
CustID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
CustFname VARCHAR(50),
CustLname VARCHAR(50),
CustDOB DATE
)
GO

-- table Product_type creation
CREATE TABLE tblPRODUCT_TYPE(
ProdTypeID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
ProdTypeName VARCHAR(50),
ProdTypeDescr VARCHAR(50),
)
GO

-- table Product creation
CREATE TABLE tblPRODUCT(
ProdID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
ProdName VARCHAR(50),
ProdTypeID INT FOREIGN KEY REFERENCES tblPRODUCT_TYPE(ProdTypeID),
Price numeric(10,3),
ProdDescr VARCHAR(50)
)
GO

-- table Employee creation
CREATE TABLE tblEMPLOYEE(
EmpID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
EmpFname VARCHAR(50),
EmpLname VARCHAR(50),
EmpDOB DATE
)
GO

-- table Order creation
CREATE TABLE tblORDER(
OrderID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
OrderDate DATE,
CustID INT FOREIGN KEY REFERENCES tblCUSTOMER(CustID),
ProductID INT FOREIGN KEY REFERENCES tblPRODUCT(ProdID),
EmpID INT FOREIGN KEY REFERENCES tblEMPLOYEE(EmpID),
Quantity INT
)
GO

-- insert values 
INSERT INTO tblCUSTOMER values ('Manas', 'Tripathi','03/16/1993'), ('Pranit', 'Jaiswal','05/23/1995') ,('Vishal', 'Khatri','01/12/1992') 

INSERT INTO tblPRODUCT_TYPE values ('Guitar','Electronic and hawaiin guitars'), ('Drum Kit','roll the drums') ,('Electric basses','the best basses') , ('Pianos','You will love them')


INSERT INTO tblPRODUCT values ('Acoustic Guitar', (select ProdTypeID from tblPRODUCT_TYPE where ProdTypeName = 'Guitar'), 300, 'Awesome acoustic guitar to get started'),
('Small Piano', (select ProdTypeID from tblPRODUCT_TYPE where ProdTypeName = 'Pianos'), 600, 'Light weight and small piano'),
('7 set Drum Kit', (select ProdTypeID from tblPRODUCT_TYPE where ProdTypeName = 'Drum Kit'), 800, 'Perfect drum kit for beginner')


INSERT INTO tblEMPLOYEE values ('Apurva', 'Saksena', '04-26-1996'), ('Aditya', 'Nayak', '07-13-1993'), ('Rohit', 'Singhal', '09-21-1992')


INSERT INTO tblORDER values ('04-12-2019', (select CustID from tblCUSTOMER where CustFname = 'Manas'), (select ProdID from tblPRODUCT where ProdName = 'Small Piano'),
(select EmpID from tblEMPLOYEE where EmpFname = 'Apurva'), 1) , ('04-10-2019', (select CustID from tblCUSTOMER where CustFname = 'Vishal'), (select ProdID from tblPRODUCT where ProdName = '7 set Drum Kit'),
(select EmpID from tblEMPLOYEE where EmpFname = 'Rohit'), 3), ('04-06-2019', (select CustID from tblCUSTOMER where CustFname = 'Pranit'), (select ProdID from tblPRODUCT where ProdName = 'Acoustic Guitar'),
(select EmpID from tblEMPLOYEE where EmpFname = 'Aditya'), 10)


-- creating stored procedure
GO
CREATE PROC orderEntryProc
-- parameters
@DateOfOrder DATE,
@CustFName VARCHAR(50),
@CustLName VARCHAR(50),
@CustDOB DATE,
@ProductName VARCHAR(50),
@EmpFName VARCHAR(50),
@EmpLName VARCHAR(50),
@EmpDOB DATE,
@Qnt INT

AS 

-- declaring variables to be used
DECLARE
@CustID INT

DECLARE 
@ProdID INT

DECLARE
@EmpID INT

SET @CustID = (SELECT c.CustID FROM tblCUSTOMER c WHERE c.CustFname = @CustFName and C.CustLname = @CustLName and c.CustDOB = @CustDOB)
-- error handling
IF @CustID IS NULL
BEGIN 
PRINT 'Customer ID is null'
RAISERROR ('Cannot complete the order without valid customer id', 11,1)
RETURN
END

SET @ProdID = (SELECT p.ProdID FROM tblPRODUCT p WHERE p.ProdName = @ProductName)
-- error handling
IF @ProdID IS NULL
BEGIN 
PRINT 'Product ID is null'
RAISERROR ('Cannot complete the order without valid Product id', 11,1)
RETURN
END


SET @EmpID = (SELECT e.EmpID FROM tblEMPLOYEE e WHERE e.EmpFname = @EmpFName and e.EmpLname = @EmpLName and e.EmpDOB = @EmpDOB)
-- error handling
IF @EmpID IS NULL
BEGIN 
PRINT 'Employee ID is null'
RAISERROR ('Cannot complete the order without valid Employee id', 11,1)
RETURN
END


BEGIN TRAN orderEntryTransaction 
INSERT INTO tblORDER (OrderDate, CustID, ProductID, EmpID, Quantity)
VALUES (@DateOfOrder, @CustID, @ProdID, @EmpID, @Qnt)
IF @@ERROR <> 0
	ROLLBACK TRAN orderEntryTransaction
ELSE 
	COMMIT TRAN orderEntryTransaction

-- insert using procedure
EXECUTE orderEntryProc
@DateOfOrder = '04-13-2019',
@CustFName = 'Manas',
@CustLName = 'Tripathi',
@CustDOB = '03-16-1993',
@ProductName = 'Acoustic Guitar',
@EmpFName = 'Apurva',
@EmpLName = 'Saksena',
@EmpDOB = '04-26-1996',
@Qnt = 4

-- insert using procedure
EXECUTE orderEntryProc
@DateOfOrder = '04-13-2019',
@CustFName = 'Manas',
@CustLName = 'Tripathi',
@CustDOB = '03-16-1993',
@ProductName = 'Acoustic Guitar',
@EmpFName = 'Apurva',
@EmpLName = 'Saksena',
@EmpDOB = '04-26-1996',
@Qnt = 20
