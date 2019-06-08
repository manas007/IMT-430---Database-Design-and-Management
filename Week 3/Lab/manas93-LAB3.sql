CREATE DATABASE manas93_Lab3


-- Creating all the tables
CREATE TABLE PET_TYPE (
PetTypeID INT IDENTITY(1,1) PRIMARY KEY,
PetTypeName VARCHAR(50)
)

CREATE TABLE COUNTRY (
CountryID INT IDENTITY(1,1) PRIMARY KEY,
CountryName VARCHAR(50)
)


CREATE TABLE TEMPERAMENT (
TempID INT IDENTITY(1,1) PRIMARY KEY,
TempName VARCHAR(50)
)

CREATE TABLE GENDER (
GenderID INT IDENTITY(1,1) PRIMARY KEY,
GenderName VARCHAR(50)
)


CREATE TABLE PET(
PetID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
PetName varchar(50) NOT NULL, 
PetTypeID INT FOREIGN KEY REFERENCES PET_TYPE(PetTypeID) NOT NULL,
CountryID INT FOREIGN KEY REFERENCES COUNTRY(CountryID) NOT NULL,
TempID INT FOREIGN KEY REFERENCES TEMPERAMENT(TempID) NOT NULL,
GenderID INT FOREIGN KEY REFERENCES GENDER(GenderID) NOT NULL,
DOB DATE)


-- Creating the Working table that will have the copy of excel data without null values

CREATE TABLE [dbo].[Working_Pets_Tbl](
	PK_ID INT IDENTITY(1,1) primary key,
	[PETNAME] [nvarchar](255) NULL,
	[PET_TYPE] [nvarchar](255) NULL,
	[TEMPERAMENT] [nvarchar](255) NULL,
	[COUNTRY] [nvarchar](255) NULL,
	[DATE_BIRTH] [datetime] NULL,
	[GENDER] [nvarchar](255) NULL
) ON [PRIMARY]
GO


insert into Working_Pets_Tbl (PETNAME, PET_TYPE, TEMPERAMENT, COUNTRY, DATE_BIRTH, GENDER)
select PETNAME, PET_TYPE, TEMPERAMENT, COUNTRY, DATE_BIRTH, GENDER from New_Pets_Tbl


insert into TEMPERAMENT (TempName)
select DISTINCT(TEMPERAMENT) from Working_Pets_Tbl


insert into COUNTRY(CountryName)
select DISTINCT(COUNTRY) from Working_Pets_Tbl


insert into GENDER(GenderName)
select DISTINCT(GENDER) from Working_Pets_Tbl



insert into PET_TYPE(PetTypeName)
select DISTINCT(PET_TYPE) from Working_Pets_Tbl


-- creating yet another copy of working data, because we need to delete rows from the table
CREATE TABLE [dbo].[Copy_of_Working_Pets_Tbl](
	PK_ID INT IDENTITY(1,1) primary key,
	[PETNAME] [nvarchar](255) NULL,
	[PET_TYPE] [nvarchar](255) NULL,
	[TEMPERAMENT] [nvarchar](255) NULL,
	[COUNTRY] [nvarchar](255) NULL,
	[DATE_BIRTH] [datetime] NULL,
	[GENDER] [nvarchar](255) NULL
) ON [PRIMARY]
GO


insert into Copy_of_Working_Pets_Tbl (PETNAME, PET_TYPE, TEMPERAMENT, COUNTRY, DATE_BIRTH, GENDER)
select PETNAME, PET_TYPE, TEMPERAMENT, COUNTRY, DATE_BIRTH, GENDER from Working_Pets_Tbl


-- creating procedures to get all the look up ids
GO
CREATE PROCEDURE GET_TEMPERAMENT_ID 
@Temp Varchar(50),
@TempId INT OUTPUT
AS
SET @TempId = (SELECT T.TempID FROM TEMPERAMENT T WHERE T.TempName = @Temp)


GO
CREATE PROCEDURE GET_PET_TYPE_ID 
@PName Varchar(50),
@PTypeId INT OUTPUT
AS
SET @PTypeId = (SELECT P.PetTypeID FROM PET_TYPE P WHERE P.PetTypeName = @PName)

GO
CREATE PROCEDURE GET_COUNTRY_ID 
@CName Varchar(50),
@CId INT OUTPUT
AS
SET @CId = (SELECT C.CountryID FROM COUNTRY C WHERE C.CountryName = @CName)

GO
CREATE PROCEDURE GET_GENDER_ID 
@GName Varchar(50),
@GId INT OUTPUT
AS
SET @GId = (SELECT G.GenderID FROM GENDER G WHERE G.GenderName = @GName)



-- Main prodedure

GO
ALTER PROCEDURE MAIN_PROC
@petname varchar(50),
@pet_type varchar(50),
@temperament varchar(50),
@country varchar(50),
@dob Date,
@gender varchar(50) 
AS

DECLARE @P_ID INT, @T_ID INT, @C_ID INT, @G_ID INT

EXEC GET_PET_TYPE_ID
@PName = @pet_type,
@PTypeId = @P_ID OUTPUT

IF @P_ID IS NULL

BEGIN
PRINT 'PET_TYPE_ID is null.'
RAISERROR ('@P_ID cannot be NULL', 11, 1)
RETURN
END

EXEC GET_TEMPERAMENT_ID 
@Temp = @temperament,
@TempId = @T_ID OUTPUT

IF @T_ID IS NULL
BEGIN
PRINT 'TEMPERAMENT_ID is null.'
RAISERROR ('@T_ID cannot be NULL', 11, 1)
RETURN
END


EXEC GET_COUNTRY_ID 
@CName = @country,
@CId = @C_ID OUTPUT

IF @C_ID IS NULL
BEGIN
PRINT 'COUNTRY_ID is null.'
RAISERROR ('@C_ID cannot be NULL', 11, 1)
RETURN
END


EXEC GET_GENDER_ID 
@GName = @gender,
@GId = @G_ID OUTPUT

IF @G_ID IS NULL
BEGIN
PRINT 'GENDER_ID is null.'
RAISERROR ('@G_ID cannot be NULL', 11, 1)
RETURN
END



BEGIN TRANSACTION T1


INSERT INTO PET (
PetName, 
PetTypeID,
CountryID,
TempID,
GenderID,
DOB)
VALUES
(
@petname,
@P_ID,
@C_ID,
@T_ID,
@G_ID,
@dob
)


IF @@ERROR <> 0 
ROLLBACK TRAN T1
ELSE 
COMMIT TRAN T1

-----


BEGIN

DECLARE @PETNAME_VAL varchar(50)
DECLARE @PET_TYPE_VAL varchar(50)
DECLARE @TEMPERAMENT_VAL varchar(50)
DECLARE @COUNTRY_VAL varchar(50)
DECLARE @DOB_VAL Date
DECLARE @GENDER_VAL varchar(50)
DECLARE @MIN_PK INT

DECLARE @RUN INT = (SELECT COUNT(*) FROM Copy_of_Working_Pets_Tbl)

WHILE @RUN > 0

BEGIN

SET @MIN_PK = (SELECT MIN(PK_ID) FROM Copy_of_Working_Pets_Tbl);


SET @PETNAME_VAL = (SELECT P.PETNAME FROM Copy_of_Working_Pets_Tbl P WHERE P.PK_ID = @MIN_PK)
SET @PET_TYPE_VAL= (SELECT P.PET_TYPE FROM Copy_of_Working_Pets_Tbl P WHERE P.PK_ID = @MIN_PK)
SET @TEMPERAMENT_VAL = (SELECT P.TEMPERAMENT FROM Copy_of_Working_Pets_Tbl P WHERE P.PK_ID = @MIN_PK)
SET @COUNTRY_VAL = (SELECT P.COUNTRY FROM Copy_of_Working_Pets_Tbl P WHERE P.PK_ID = @MIN_PK)
SET @DOB_VAL = (SELECT P.DATE_BIRTH FROM Copy_of_Working_Pets_Tbl P WHERE P.PK_ID = @MIN_PK)
SET @GENDER_VAL = (SELECT P.GENDER FROM Copy_of_Working_Pets_Tbl P WHERE P.PK_ID = @MIN_PK)




EXEC MAIN_PROC
@petname = @PETNAME_VAL,
@pet_type = @PET_TYPE_VAL,
@temperament = @TEMPERAMENT_VAL,
@country = @COUNTRY_VAL,
@dob = @DOB_VAL,
@gender = @GENDER_VAL;

DELETE FROM Copy_of_Working_Pets_Tbl WHERE PK_ID = @MIN_PK;

SET @RUN = @RUN - 1;
END  

END


select * from PET