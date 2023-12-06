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
/*
4. Модифицировать хранимую процедуру п.2. таким образом, чтобы выборка 
формировалась с помощью табличной функции.*/
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
    SET @reader_cursor = CURSOR FORWARD_ONLY STATIC FOR 
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


IF OBJECT_ID(N'dbo.getAdults', N'FN') IS NOT NULL            
    DROP FUNCTION dbo.getAdults
GO

CREATE FUNCTION dbo.getAdults()
RETURNS TABLE
AS
RETURN (
    SELECT ReaderID, dbo.GetReaderNames(FirstName, SecondName) AS FullName, dbo.GetAge(DateOfBirth) AS Age
    FROM Reader
    WHERE dbo.GetAge(DateOfBirth) > 18
);
GO
