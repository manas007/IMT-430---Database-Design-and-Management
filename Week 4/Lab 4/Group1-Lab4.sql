-- Submission by Group 1 

CREATE DATABASE group1_lab4

USE group1_lab4

-- Creation of the tables
CREATE TABLE tblCustomer
(
	CustID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Fname varchar(30) not null,
    Lname varchar(30) not null,
    BirthDate date not null,
    StreetAddress varchar(100) not null,
    City varchar(30) not null,
    CustState varchar(30) not null,
    Zip int not null 
)

CREATE TABLE tblProduct
(
    ProductID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    ProductName VARCHAR(30) not null,
    Price NUMERIC(8,2) NOT NULL,
    ProductDescr VARCHAR(100) not null,
)

CREATE TABLE tblOrder
(
    OrderID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    CustID INT FOREIGN KEY REFERENCES tblCustomer(CustID) NOT NULL,
    OrderDate date not null,
    OrderTotal NUMERIC(12,2) NOT NULL
)

CREATE TABLE tblLine_Item
(
    OrderProductID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    OrderID INT FOREIGN KEY REFERENCES tblOrder(OrderID) NOT NULL,
    ProductID INT FOREIGN KEY REFERENCES tblProduct(ProductID) NOT NULL,
    Quantity INT NOT NULL,
    PriceExtended NUMERIC(12,2) NOT NULL
)

CREATE Table tblCart
(
    CartID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    CustID INT FOREIGN KEY REFERENCES tblCustomer(CustID) NOT NULL,
    ProductID INT FOREIGN KEY REFERENCES tblProduct(ProductID) NOT NULL,
    Quantity INT NOT NULL
)


-- Procedure for populating the tblCustomer
GO
CREATE PROCEDURE populatetblCustomer(@CustFname VARCHAR(30), @CustLname VARCHAR(30), @Date date, @Street VARCHAR(100), @City VARCHAR(30), @State VARCHAR(30), @Zip INT)
AS
    IF @CustFname IS NULL
        BEGIN
        RAISERROR('Customer FName cannot be NULL',11,1)
        RETURN
        END

    IF @CustLName IS NULL
        BEGIN
        RAISERROR('Customer Last Name cannot be NULL',11,1)
        RETURN
        END
    
    IF @Date IS NULL
        BEGIN
        RAISERROR('Date cannot be NULL',11,1)
        RETURN
        END
    IF @Street IS NULL
        BEGIN
        RAISERROR('Street cannot be NULL',11,1)
        RETURN
        END

    IF @City IS NULL
        BEGIN
        RAISERROR('City cannot be NULL',11,1)
        RETURN
        END

    IF @State IS NULL
        BEGIN
        RAISERROR('State cannot be NULL',11,1)
        RETURN
        END
    IF @Zip IS NULL
        BEGIN
        RAISERROR('Zip cannot be NULL',11,1)
        RETURN
        END
BEGIN TRAN G1
    INSERT INTO tblCustomer ([FName], [Lname], [BirthDate], [StreetAddress], [City], [CustState], [Zip])
    VALUES(@CustFname, @CustLname, @Date, @Street, @City, @State, @Zip)
IF @@ERROR <> 0
	ROLLBACK TRAN new_order
ELSE
	COMMIT TRAN new_order
GO

-- Inserting 5 rows to tblCustomer
EXECUTE populatetblCustomer
@CustFname='Apurva',
@CustLname='Saksena',
@Date='11-May-1996',
@Street = 'Versova',
@city='Mumbai',
@State='Maharashtra',
@Zip = '400061'

EXECUTE populatetblCustomer
@CustFname='Manas',
@CustLname='Tripathi',
@Date='16-Mar-1993',
@Street = 'Steel City',
@city='Bokaro',
@State='Jharkhand',
@Zip = '400065'

EXECUTE populatetblCustomer
@CustFname='Vishal',
@CustLname='Khatri',
@Date='08-Dec-1992',
@Street = 'Ullhasnagar',
@city='Mumbai',
@State='Maharashtra',
@Zip = '400062'

EXECUTE populatetblCustomer
@CustFname='Pranit',
@CustLname='Jiaswal',
@Date='2-Feb-1996',
@Street = 'Chembur',
@city='Mumbai',
@State='Maharashtra',
@Zip = '400063'

EXECUTE populatetblCustomer
@CustFname='Cristiano',
@CustLname='Ronaldo',
@Date='08-Feb-1986',
@Street = 'Bernebau',
@city='Lisbon',
@State='Madrid',
@Zip = '400067'


-- Procedure for Populating tblProduct
GO
CREATE PROCEDURE populateTblProduct
@ProductName VARCHAR(30),
@Price NUMERIC(8,2),
@ProductDescr VARCHAR(100)
	
AS 

IF @ProductName IS NULL OR @ProductName = ''
BEGIN 
PRINT 'Product Name is null'
RAISERROR ('Inserting Blank Product Name is not allowed', 11,1)
RETURN
END

IF @Price IS NULL OR @Price < 0
BEGIN 
PRINT 'Price is be null or negative'
RAISERROR ('Inserting Price as null or negative is not allowed', 11,1)
RETURN
END

IF @ProductDescr IS NULL
BEGIN
PRINT 'No Product Description'
RAISERROR ('Product must have some description' , 11 , 1)
RETURN
END

BEGIN TRAN populateProduct
INSERT INTO tblProduct (ProductName, Price, ProductDescr)
VALUES (@ProductName, @Price, @ProductDescr)
IF @@ERROR <> 0
	ROLLBACK TRAN populateProduct
ELSE 
	COMMIT TRAN populateProduct

-- Inserting 5 rows in the tblProduct
EXECUTE populateTblProduct
@ProductName = 'Head and Shoulders',
@Price = 12,
@ProductDescr = 'Anti Dandruff Shampoo' 

EXECUTE populateTblProduct
@ProductName = 'Rice',
@Price = 6.49,
@ProductDescr = 'Basmati Rice' 

EXECUTE populateTblProduct
@ProductName = 'Towel',
@Price = 12.99,
@ProductDescr = 'Pack of two bathroom towels' 

EXECUTE populateTblProduct
@ProductName = 'Sugar',
@Price = 4.5,
@ProductDescr = 'Cane Sugar Fine Grained' 

EXECUTE populateTblProduct
@ProductName = 'Wheat Bread',
@Price = 1.99,
@ProductDescr = 'Fresh Bakes wheat bread' 


-- Procedure for getting the customer ID 

GO 
CREATE PROCEDURE getCustomerID
@CustFname VARCHAR(30),
@CustLname VARCHAR(30),
@CustDOB DATE,
@CustomerID INT OUTPUT

AS

SET @CustomerID = (SELECT CustID from tblCustomer where Fname = @CustFname and Lname = @CustLname and BirthDate = @CustDOB)


-- Procedure for getting the Product ID 

GO 
CREATE PROCEDURE getProductID
@ProdName VARCHAR(30),
@ProductID INT OUTPUT

AS

SET @ProductID = (SELECT ProductID from tblProduct where ProductName = @ProdName)

-- Procedure for tblCart
GO
CREATE PROCEDURE populatetblCart2(@Fname VARCHAR(30), @Lname VARCHAR(30), @BirthDate date, @ProductName varchar(30), @quantity INT)
AS
    DECLARE @CID INT
    DECLARE @PID INT

    EXEC getCustomerID 
    @CustFname=@Fname,
    @CustLname=@Lname,
    @CustDOB= @BirthDate,
    @CustomerID = @CID OUTPUT

    IF @CID IS NULL
        BEGIN
        RAISERROR('CUSTOMER ID cannot be NULL',11,1)
        RETURN
        END
    
    EXEC getProductID
    @ProdName = @ProductName,
    @ProductID = @PID OUTPUT

    IF @PID IS NULL
        BEGIN
        RAISERROR('Product ID cannot be NULL',11,1)
        RETURN
        END

BEGIN TRAN G2
    INSERT INTO tblCart([CustID], [ProductID], [Quantity])
    VALUES (@CID, @PID, @quantity)
IF @@ERROR <> 0
	ROLLBACK TRAN G2
ELSE
	COMMIT TRAN G2



-- Procedure to populate tblOrder and tblLineItems
GO
CREATE PROCEDURE populateTableOrderAndLineItem
@CustomerFName VARCHAR(30),
@CustomerLName VARCHAR(30),
@CustomerDOB DATE

AS

DECLARE @CustID INT 

EXEC getCustomerID

@CustFname = @CustomerFName,
@CustLname  = @CustomerLName,
@CustDOB = @CustomerDOB,
@CustomerID = @CustID OUTPUT

IF @CustID IS NULL
BEGIN
PRINT 'No Cust Id Found'
RAISERROR ('Must Have Customer ID' , 11 , 1)
END

DECLARE @OrderTotal NUMERIC(12,2)
SET @OrderTotal = (SELECT SUM(P.Price * C.Quantity) FROM tblProduct P inner join tblCart C on P.ProductID = C.ProductID where C.CustID = @CustID)

DECLARE @OrdDate DATE
SET @OrdDate = GETDATE() - CEILING(RAND() * 100)

BEGIN TRAN ordinsert
INSERT INTO tblOrder (CustID, OrderDate, OrderTotal) VALUES (@CustID, @OrdDate, @OrderTotal)
IF @@ERROR <> 0
	ROLLBACK TRAN ordinsert
ELSE
	COMMIT TRAN ordinsert

DECLARE @currOrdID INT
SET @currOrdID = SCOPE_IDENTITY()

SELECT crt.CustID , crt.ProductID, sum(crt.Quantity) as totalQnt into #tempDetails from tblCart crt where crt.CustID = @CustID GROUP BY crt.CustID , crt.ProductID




DECLARE @ProdCount INT 
SET @ProdCount = (select count(distinct ProductID) from #tempDetails where CustID = @CustID)

WHILE @ProdCount > 0 
	BEGIN
	DECLARE  @Qty INT, @PID INT , @PriceExtended NUMERIC (12,2)
	
	SET @PID = (select top 1 ProductID from #tempDetails)

	SET @Qty = (select totalQnt from #tempDetails where ProductID = @PID )

	SET @PriceExtended = (select @Qty * (select Price from tblProduct P where P.ProductID = @PID))

	BEGIN TRAN insertLineItems
		INSERT INTO tblLine_Item (OrderID, ProductID, Quantity, PriceExtended)
		values (@currOrdID , @PID, @Qty, @PriceExtended)

		IF @@ERROR <> 0
			ROLLBACK TRAN insertLineItems
		ELSE
			COMMIT TRAN insertLineItems 

			DELETE FROM #tempDetails where ProductID = @PID

			SET @ProdCount = @ProdCount - 1
	END
	
DELETE FROM tblCart where CustID = @CustID




-- Testing the cart population, order and lineitems

Exec populatetblCart2
@Fname = 'Manas',
@Lname = 'Tripathi',
@BirthDate = '16-Mar-1993',
@ProductName = 'Rice',
@quantity = 2

Exec populatetblCart2
@Fname = 'Manas',
@Lname = 'Tripathi',
@BirthDate = '16-Mar-1993',
@ProductName = 'Towel',
@quantity = 4

Exec populatetblCart2
@Fname = 'Manas',
@Lname = 'Tripathi',
@BirthDate = '16-Mar-1993',
@ProductName = 'Sugar',
@quantity = 3


Exec populatetblCart2
@Fname = 'Vishal',
@Lname = 'Khatri',
@BirthDate = '08-Dec-1992',
@ProductName = 'Sugar',
@quantity = 6

Exec populatetblCart2
@Fname = 'Vishal',
@Lname = 'Khatri',
@BirthDate = '08-Dec-1992',
@ProductName = 'Towel',
@quantity = 10


Exec populateTableOrderAndLineItem
@CustomerFName = 'Vishal',
@CustomerLName = 'Khatri',
@CustomerDOB = '08-Dec-1992'


Exec populateTableOrderAndLineItem
@CustomerFName = 'Manas',
@CustomerLName = 'Tripathi',
@CustomerDOB = '16-Mar-1993'



