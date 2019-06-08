USE manas93_BookDB

CREATE TABLE tblGenre (
	genreID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	genreName VARCHAR(256) NOT NULL,
	genreDesc VARCHAR(4096) NULL
)


CREATE TABLE tblBook (
	bookID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	bookTitle VARCHAR(256) NOT NULL,
	bookPrice SMALLMONEY NULL,
	bookDesc VARCHAR(4096) NULL,
	genreID INT FOREIGN KEY REFERENCES tblGenre(genreID)
)
GO

CREATE PROCEDURE usp_insertBook
@bookTitle VARCHAR(256),
@bookPrice SMALLMONEY,
@bookDesc VARCHAR(4096),
@genreName VARCHAR(256)
AS

IF @bookTitle IS NULL OR @bookPrice IS NULL OR @bookDesc IS NULL OR @genreName IS NULL
BEGIN
	PRINT('Required params cannot be empty')
	RAISERROR('Missing params',11,1)
	RETURN
END

DECLARE @Genre_ID INT
SET @Genre_ID = (SELECT genreID from tblGenre where genreName = @genreName)

IF @Genre_ID is Null
	BEGIN
		PRINT 'No Genre ID found for the given genre name, adding a new entry to genre table'
	
		BEGIN TRAN T1
			INSERT INTO tblGenre(genreName, genreDesc) values (@genreName, NULL)
		IF @@ERROR <> 0
			ROLLBACK TRAN T1
		ELSE
			COMMIT TRAN T1
			SET @Genre_ID = SCOPE_IDENTITY()
			BEGIN TRAN T2
				INSERT INTO tblBook (bookTitle,bookPrice, bookDesc, genreID) values (@bookTitle, @bookPrice, @bookDesc, @Genre_ID)
			IF @@ERROR <> 0
				ROLLBACK TRAN T2
			ELSE
				COMMIT TRAN T2
	END
ELSE
	BEGIN
	BEGIN TRAN T3
				INSERT INTO tblBook (bookTitle,bookPrice, bookDesc, genreID) values (@bookTitle, @bookPrice, @bookDesc, @Genre_ID)
				IF @@ERROR <> 0
					ROLLBACK TRAN T3
				ELSE
					COMMIT TRAN T3
	END
