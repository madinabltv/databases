USE master;
go

IF DB_ID (N'Lab8') IS NOT NULL
drop database Lab8;
GO

CREATE DATABASE Lab8
ON ( NAME = Lab8_dat, FILENAME = '/Users/madina/Databases/Lab8.dat', SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5% )
LOG ON ( NAME = Lab8_log, FILENAME = '/Users/madina/Databases/Lab8.ldf', SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB );
GO

USE Lab8;
GO

--1. Создать хранимую процедуру, производящую выборку из некоторой 
--таблицы и возвращающую результат выборки в виде курсора.
DROP TABLE IF EXISTS Reader
CREATE TABLE Reader(
    ReaderID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(255) NOT NULL, 
    SecondName NVARCHAR(255) NOT NULL,
    Telephone CHAR(11) NOT NULL UNIQUE CHECK (len(Telephone) = 11),
    Email VARCHAR(254) UNIQUE NOT NULL,
    DateOfBirth Date CHECK (DateOfBirth < DATEADD(year, -12, GETDATE())) DEFAULT DATEADD(year, -12, GETDATE()),
    RegistrationDate DATETIME DEFAULT CURRENT_TIMESTAMP,
);
GO

INSERT INTO Reader ( FirstName, SecondName, Telephone, DateOfBirth, Email) VALUES
(N'Madina', 'Baltaeva','89253080955', '2003-07-09', 'madina_bltv@vk.com'),
(N'Valeria','Potrebina','89026730962', '2003-07-24', 'Valery@gmail.com'),
(N'Arkadiy','Shevyrov','89999258452', '2004-02-17', 'shrv@gmail.com'),
(N'Egor','Velichko','89999258456', '2002-09-09', 'velichkoegor@icloud.com'),
(N'Darya','Vasilovskaya','89212560513', '2001-12-07', 'vslvsky@gmail.com');

SELECT * FROM Reader;
GO

IF OBJECT_ID ('reader_proc', N'P') IS NOT NULL
    DROP PROCEDURE reader_proc
GO

CREATE PROCEDURE reader_proc
    @reader_cursor CURSOR VARYING OUTPUT
AS 
    SET @reader_cursor = CURSOR
    FORWARD_ONLY STATIC FOR 
        SELECT ReaderID, FirstName--, SecondName
        FROM Reader
    
    OPEN @reader_cursor;
GO

DECLARE @reader_cursor CURSOR;
EXEC reader_proc @reader_cursor = @reader_cursor OUTPUT;


FETCH NEXT FROM @reader_cursor;
WHILE (@@FETCH_STATUS = 0)
BEGIN
    FETCH NEXT FROM @reader_cursor;
END;

CLOSE @reader_cursor;
DEALLOCATE @reader_cursor; 
GO
GO


--2 Модифицировать хранимую процедуру п.1. таким образом, чтобы выборка 
-- осуществлялась с формированием столбца, значение которого
-- формируется пользовательской функцией

CREATE FUNCTION dbo.GetReaderNames (
    @FirstName NVARCHAR(255),
    @SecondName NVARCHAR(255)
) RETURNS NVARCHAR(512)
AS 
BEGIN
    RETURN @FirstName + ' ' + @SecondName;
END
GO

ALTER PROCEDURE reader_proc
    @reader_cursor CURSOR VARYING OUTPUT
AS 
BEGIN   

    SET @reader_cursor = CURSOR 
    FORWARD_ONLY STATIC FOR 
        SELECT ReaderID, dbo.GetReaderNames(FirstName, SecondName) AS FullName
        FROM Reader
    OPEN @reader_cursor
END
GO

DECLARE @reader_cursor CURSOR;
EXECUTE reader_proc @reader_cursor = @reader_cursor OUTPUT;

FETCH NEXT FROM @reader_cursor;
WHILE (@@FETCH_STATUS = 0)
BEGIN
FETCH NEXT FROM @reader_cursor;
END;
CLOSE @reader_cursor; 
DEALLOCATE @reader_cursor; 
GO

--3. Создать хранимую процедуру, вызывающую процедуру п.1., осуществляющую прокрутку возвращаемого
-- курсора и выводящую сообщения, сформированные из записей при выполнении условия, заданного еще одной
-- пользовательской функцией.

IF OBJECT_ID(N'dbo.GetAge', N'FN') IS NOT NULL
    DROP FUNCTION dbo.GetAge
GO

CREATE FUNCTION dbo.GetAge(@birthdate date)
    RETURNS INT
    WITH EXECUTE AS CALLER
    AS
    BEGIN
        DECLARE @current_date datetime = GETDATE();
        DECLARE @current_year INT, @calculated_age INT;
        SET @current_year = YEAR(@current_date);
        SET @calculated_age = @current_year - YEAR(@birthdate);
        RETURN @calculated_age;
    END
GO

IF OBJECT_ID(N'dbo.compare_ages', N'FN') is not null
	drop function dbo.compare_ages;
go
create function dbo.compare_ages(@compare_what int, @compare_to int)
	returns int
	with execute as caller
	as
	begin
		declare @retval int;

		if (@compare_what >= @compare_to)
			set @retval = 1;
		else 
			set @retval = 0;

		return @retval;
	end
go


IF OBJECT_ID(N'dbo.sub_proc_for_3point', N'P') IS NOT NULL
	DROP PROCEDURE dbo.sub_proc_for_3point
GO
CREATE PROCEDURE dbo.sub_proc_for_3point
	@curs CURSOR VARYING OUTPUT
AS
    SET @curs = CURSOR
    FORWARD_ONLY STATIC FOR
		SELECT FirstName, SecondName, dbo.GetAge(DateOfBirth)
		FROM dbo.Reader
	OPEN @curs;
GO

IF OBJECT_ID(N'ext_proc', N'P') IS NOT NULL
    DROP PROC ext_proc;
GO

CREATE PROCEDURE ext_proc
AS 
BEGIN
    DECLARE @ext_cursor CURSOR;
    EXECUTE dbo.sub_proc_for_3point @curs = @ext_cursor OUTPUT;
    DECLARE @r_fstnm NVARCHAR(255)
    DECLARE @r_sndnm NVARCHAR(255)
    DECLARE @r_age INT
    
    FETCH NEXT FROM @ext_cursor 
    INTO @r_fstnm, @r_sndnm, @r_age
	PRINT 'First Fetch: "' + @r_fstnm + '"'

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
	IF (dbo.compare_ages(@r_age, 18) = 1)
		print @r_fstnm + ' ' + @r_sndnm + ' is ' + CAST(@r_age as varchar) + ' years '
	FETCH NEXT FROM @ext_cursor
	INTO @r_fstnm, @r_sndnm, @r_age;
	END;


	CLOSE @ext_cursor
	DEALLOCATE @ext_cursor
END
GO

EXEC ext_proc
GO


/* 4. Модифицировать хранимую процедуру п.2. таким образом, чтобы выборка 
формировалась с помощью табличной функции. */

IF OBJECT_ID(N'dbo.getAdults_inline', N'FN') IS NOT NULL            
    DROP FUNCTION dbo.getAdults_inline
GO

CREATE FUNCTION dbo.getAdults_inline()
RETURNS TABLE
AS
RETURN (
    SELECT dbo.GetReaderNames(FirstName, SecondName) AS FullName, dbo.GetAge(DateOfBirth) AS Age
    FROM Reader
    WHERE dbo.GetAge(DateOfBirth) > 18
);
GO 

IF OBJECT_ID(N'dbo.Adults', N'FN') IS NOT NULL            
    DROP PROCEDURE dbo.Adults
GO

CREATE PROCEDURE Adults
    @adults_cur CURSOR VARYING OUTPUT
AS
    SET @adults_cur = CURSOR
        FORWARD_ONLY FOR
        SELECT FullName, 
               Age FROM dbo.getAdults_inline();
        OPEN @adults_cur;
GO

DECLARE @adults_cur CURSOR;
EXEC Adults @adults_cur = @adults_cur OUTPUT;

DECLARE 
    @fullname NVARCHAR(512),
    @r_age int;
FETCH NEXT FROM @adults_cur INTO @fullname, @r_age;

WHILE (@@FETCH_STATUS = 0)
BEGIN
    PRINT @fullname + ' is up to eighteen, his/her age is ' + CAST(@r_age as varchar);
    FETCH NEXT FROM @adults_cur INTO @fullname, @r_age;
END;

CLOSE @adults_cur;
DEALLOCATE @adults_cur;
GO
