Use manas93_Lab6

--Customer table
CREATE TABLE tblCUSTOMER
(
CustId INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
CustFname varchar(30) NOT NULL,
CustLname varchar(30) NOT NULL,
CustDOB Date NULL
)

-- ProductTypeTable
CREATE TABLE tblPRODUCT_TYPE
(
ProductTypeID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
ProductTypeName varchar(50) NOT NULL,
ProductTypeDesc varchar(500) NOT NULL
)

-- Product Table
CREATE TABLE tblPRODUCT
(
ProductID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
ProductName varchar(50) NOT NULL,
Price Numeric(8,2) NOT NULL,
ProdDescr varchar(500) NULL,
ProductTypeID INT FOREIGN KEY REFERENCES tblPRODUCT_TYPE(ProductTypeID) NOT NULL
)


-- Order Table
CREATE TABLE tblORDER
(
OrderId INT IDENTITY(1,1) primary key NOT NULL,
OrderDate Date NOT NULL,
CustID INT FOREIGN KEY REFERENCES tblCUSTOMER(CustID) NOT NULL,
ProductID INT FOREIGN KEY REFERENCES tblPRODUCT(ProductID) NOT NULL,
Quantity INT NOT NULL,
CHECK (Quantity>0)
)


-- Add data to lookup table
INSERT INTO tblPRODUCT_TYPE (ProductTypeName, ProductTypeDesc)
VALUES ('Food', 'Anything people eat'), ('Clothing', 'Anything people wear'), ('Furniture', 'Anything people sit on in their house')
GO

INSERT INTO tblPRODUCT (ProductName, ProductTypeID, Price)
VALUES ('Leather Sofa', 
(SELECT ProductTypeID 
FROM tblPRODUCT_TYPE 
WHERE ProductTypeName = 'Furniture'), 435.99),
('Blue Easy Chair', 
(SELECT ProductTypeID 
FROM tblPRODUCT_TYPE 
WHERE ProductTypeName = 'Furniture'), 135.99),
('Stand-Up 3-Bulb Lamp', 
(SELECT ProductTypeID 
FROM tblPRODUCT_TYPE 
WHERE ProductTypeName = 'Furniture'), 79.99),
('Leather Jacket', 
(SELECT ProductTypeID 
FROM tblPRODUCT_TYPE 
WHERE ProductTypeName = 'Clothing'), 685.99),
('Wool Socks', 
(SELECT ProductTypeID 
FROM tblPRODUCT_TYPE 
WHERE ProductTypeName = 'Clothing'), 5.99),
('Winter Ski Jacket', 
(SELECT ProductTypeID 
FROM tblPRODUCT_TYPE 
WHERE ProductTypeName = 'Clothing'), 185.99),
('Basketball Shoes', 
(SELECT ProductTypeID 
FROM tblPRODUCT_TYPE 
WHERE ProductTypeName = 'Clothing'), 88.99),
('Veggie Pizza', 
(SELECT ProductTypeID 
FROM tblPRODUCT_TYPE 
WHERE ProductTypeName = 'Food'), 15.99),
('Turkey Sandwich', 
(SELECT ProductTypeID 
FROM tblPRODUCT_TYPE 
WHERE ProductTypeName = 'Food'), 7.99),
('Ham Sandwich', 
(SELECT ProductTypeID 
FROM tblPRODUCT_TYPE 
WHERE ProductTypeName = 'Food'), 8.99)

GO

INSERT INTO tblCUSTOMER (CustFname, CustLname, CustDOB) SELECT TOP 1000 C.CustomerFname, C.CustomerLname, C.DateOfBirth FROM CUSTOMER_BUILD.dbo.tblCUSTOMER C
Go
CREATE PROCEDURE GetCustID 
@CustFirstname varchar(30),
@CustLastname varchar(30),
@CustBirtDate Date,
@CustomerID INT OUTPUT
AS

SET @CustomerID = (SELECT cust.CustId from tblCUSTOMER cust where cust.CustFname = @CustFirstname and cust.CustLname = @CustLastname)

GO
CREATE PROCEDURE GetProdID 
@ProdName Varchar(50),
@ProdId INT OUTPUT
AS
SET @ProdId = (SELECT prd.ProductID from tblPRODUCT prd where prd.ProductName = @ProdName)

GO

CREATE PROCEDURE uspNewOrder 
@OrdDate Date, 
@CFirstname Varchar(30), 
@CLastName Varchar(30), 
@CBirthDate Date,
@ProductName Varchar(50), 
@Quant INT

AS

DECLARE @CId INT
DECLARE @PId INT

EXEC GetCustID
@CustFirstname = @CFirstname,
@CustLastname = @CLastName,
@CustBirtDate = @CBirthDate,
@CustomerID = @CId OUTPUT

IF @CId IS NULL
	BEGIN
	RAISERROR('Please Enter a Valid Customer First Name and Last Name combination',11,1)
	RETURN
	END

EXEC GetProdID
@ProdName = @ProductName,
@ProdId = @PId OUTPUT


IF @PId IS NULL
	BEGIN
	RAISERROR('Please Enter a Valid Product Name',11,1)
	RETURN
	END

BEGIN TRAN OrdIns1

INSERT INTO tblORDER
(
OrderDate,
CustID,
ProductID,
Quantity
)
VALUES
(
@OrdDate,
@CId,
@PId,
@Quant
)

IF @@ERROR <> 0
	ROLLBACK TRAN OrdIns1
ELSE
	COMMIT TRAN OrdIns1


GO
-- Synthetic Transaction Procedure
CREATE PROCEDURE wrapper_uspNewOrder
@RUN INT
AS

DECLARE @Fname varchar(30)
DECLARE @Lname varchar(30)
DECLARE @BDate Date
DECLARE @PrdName varchar(50)
DECLARE @OrderDt Date = (SELECT GetDate())
DECLARE @Quantity INT

DECLARE @CustCnt INT = (SELECT COUNT(*) FROM tblCUSTOMER)
DECLARE @ProdCnt INT = (SELECT COUNT(*) FROM tblPRODUCT)

DECLARE @CustPK INT
DECLARE @ProdPK INT

WHILE @RUN > 0
BEGIN

SET @CustPK = (SELECT @CustCnt * RAND())
SET @ProdPK = (SELECT @ProdCnt * RAND())

IF @ProdPK < 1 
BEGIN
SET @ProdPK = 2
END

SET @Fname = (SELECT CustFname FROM tblCUSTOMER WHERE CustID = @CustPK)
SET @Lname = (SELECT CustLname FROM tblCUSTOMER WHERE CustID = @CustPK)
SET @BDate = (SELECT CustDOB FROM tblCUSTOMER WHERE CustID = @CustPK)
SET @PrdName = (SELECT ProductName FROM tblPRODUCT WHERE ProductID = @ProdPK)
SET @Quantity = (SELECT 100 * Rand())
IF @Quantity < 1 
BEGIN
SET @Quantity = 1
END

EXEC uspNewOrder
@OrdDate = @OrderDt, 
@CFirstname = @Fname, 
@CLastName = @Lname, 
@CBirthDate = @BDate,
@ProductName  = @PrdName, 
@Quant = @Quantity

SET @RUN = @RUN -1
END

Go


Exec wrapper_uspNewOrder
@RUN = 2000

-- Results
Select count(*) from tblORDER
