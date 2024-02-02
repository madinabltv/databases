USE master;
GO

IF DB_ID(N'Lab11') IS NOT NULL
    DROP DATABASE Lab11;
GO

CREATE DATABASE Lab11
ON ( NAME = Lab11_dat, FILENAME = '/Users/madina/Databases/Lab11.dat', SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5% )
LOG ON ( NAME = Lab11_log, FILENAME = '/Users/madina/Databases/Lab11.ldf', SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB );
GO

USE Lab11;
--определение значений по умолчанию 
--назначение ограничений целостности (PRIMARY KEY, NULL/NOT
-- NULL/UNIQUE, CHECK и т.п.);

DROP TABLE IF EXISTS Reader;
CREATE TABLE Reader(
    ReaderID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(255) NOT NULL, 
    SecondName NVARCHAR(255) NOT NULL,
    Telephone CHAR(11) NOT NULL UNIQUE CHECK (len(Telephone) = 11),
    Email VARCHAR(254) UNIQUE NOT NULL,
    DateOfBirth Date NOT NULL,
    RegistrationDate DATETIME DEFAULT CURRENT_TIMESTAMP
);
GO

INSERT INTO Reader ( FirstName, SecondName, Telephone, DateOfBirth, Email) VALUES
(N'Madina', 'Baltaeva','89253080955', '2003-07-09', 'madina_bltv@vk.com'),
(N'Valeria','Potrebina','89026730962', '2003-07-24', 'Valery@gmail.com'),
(N'Arkadiy','Shevyrov','89999258452', '2004-02-17', 'shrv@gmail.com'),
(N'Egor','Velichko','89999258456', '2002-09-09', 'velichkoegor@icloud.com'),
(N'Igor','Vishnyakov','89999269456', '2003-09-09', 'igor@icloud.com');

SELECT * FROM Reader;
GO

DELETE FROM Reader WHERE SecondName = 'Vishnyakov';
GO
--Between:
SELECT * FROM Reader WHERE ReaderID BETWEEN 2 AND 4;
--Like:
SELECT * FROM Reader WHERE Email LIKE '%@icloud.com';

--count
select count(ReaderID) from Reader;


UPDATE Reader SET SecondName = 'Baltayeva' WHERE FirstName = 'Madina';
go

SELECT * FROM Reader;
GO

DROP TABLE IF EXISTS BookOfAuthor;
DROP TABLE IF EXISTS BookInstance;
DROP TABLE IF EXISTS Department;

CREATE TABLE Department(
    DepartmentCode CHAR(8) NOT NULL PRIMARY KEY ,
    Contact CHAR(11) NULL,
    Mail VARCHAR(254) NULL,
    Address VARCHAR(100) NULL
);
GO

CREATE TABLE BookInstance(
    BookISBN UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL,
    Location VARCHAR(20) NOT NULL,
    IssueYear SMALLINT NULL,
    Genre NVARCHAR(100) NULL,
    Language INTEGER NOT NULL,
    DepartmentCode CHAR(8) NOT NULL FOREIGN KEY REFERENCES Department(DepartmentCode) 
        ON UPDATE CASCADE
);
GO

INSERT INTO Department (DepartmentCode) VALUES
('12345678'),
('19072003'),
('16092003'),
('98547632');

SELECT * FROM Department;
GO

INSERT INTO BookInstance (Name, Location, IssueYear, Genre, Language,  DepartmentCode) VALUES
(N'Компьютерные сети', N'6A', 2012, N'Современная наука', 1, '12345678'),
(N'Война и мир', N'123D', 1867, N'Роман-эпопея', 1,  '12345678'),
(N'Мы', '8765D', 1920, N'Научная фантастика роман-антиутопия', 1, '19072003'),
(N'Вино из одуванчиков', N'4567K', 1957, N'Научная фантастика', 1,  '16092003'),
(N'Над пропастью во ржи', N'4889K', 1951, N'Роман', 1,  '16092003'),
(N'Облако в штанах', N'86N', 1915, N'Стихотворение', 1,  '98547632'),
(N'Дракула', N'8689N', 1897, N'Роман-ужасы', 1,  '98547632'),
(N'Дракула', N'8679N', 1898, N'Роман-ужасы', 1,  '16092003');

-- in 
SELECT * FROM BookInstance WHERE DepartmentCode IN ( '16092003', '98547632');
SELECT * FROM BookInstance;
-- Group by + having

SELECT COUNT(Name), DepartmentCode FROM BookInstance
GROUP BY DepartmentCode HAVING COUNT(Name) > 1;
-- вложенные запросы
SELECT * FROM BookInstance WHERE Name IN 
(SELECT Name FROM  BookInstance WHERE Language = 1);

SELECT * FROM BookInstance WHERE Name IN 
(SELECT Name FROM BookInstance WHERE Language = 1);
------

DROP TABLE IF EXISTS Author;
CREATE TABLE Author(
    AuthorID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(255) NOT NULL, 
    LastName NVARCHAR(255) NOT NULL,
    BirthDate datetime NULL,
);
GO

--Alter

alter table Author
	add AuthorCountry CHAR(3) null;
go

INSERT INTO Author (FirstName, LastName) VALUES 
(N'Эндрю', N'Таненбаум'),
(N'Лев', N'Толстой'),
(N'Евгений', N'Замятин'),
(N'Рэй', N'Бредбэри'),
(N'Джером', N'Селинджер'),
(N'Владимир', N'Маяковский'),
(N'Брэм', N'Стокер'),
(N'Брэм', N'Стокер');

select distinct FirstName, LastName from Author;
go
--Null operator
SELECT * FROM Author WHERE BirthDate IS NULL;
--desc asc :
SELECT * FROM Author ORDER BY FirstName DESC;
GO
SELECT * FROM Author ORDER BY LastName ASC;
GO


CREATE TABLE BookOfAuthor (
    AuthorID INT NOT NULL IDENTITY(1,1) FOREIGN KEY REFERENCES Author(AuthorID),
    BookISBN UNIQUEIDENTIFIER DEFAULT NEWID() NOT NULL FOREIGN KEY REFERENCES BookInstance(BookISBN)
);
GO

--view and indexes

IF OBJECT_ID ('Book_View') IS NOT NULL
    DROP VIEW Book_View
GO

CREATE VIEW Book_View AS
        SELECT *
        FROM BookInstance
        WHERE DepartmentCode = '98547632';
GO

SELECT * FROM Book_View;
-- представление на основе полей обеих связанных таблиц

IF OBJECT_ID(N'Book_view_joined') IS NOT NULL     
        DROP VIEW Book_view_joined;
GO
CREATE VIEW Book_view_joined AS
        SELECT
                CAST(b.Name as nvarchar)+ ' is located in the department ' + CAST(d.DepartmentCode AS VARCHAR) AS bookDescription
        FROM BookInstance b
        INNER JOIN Department d        
                ON b.DepartmentCode = d.DepartmentCode
GO

SELECT * FROM Book_view_joined;
GO


IF EXISTS (SELECT NAME FROM sys.indexes 
			WHERE NAME = N'IndexDateOfBirth')
	DROP INDEX IndexDateOfBirth ON Reader;

GO
CREATE INDEX IndexDateOfBirth
        ON Reader (Telephone)
        INCLUDE (DateOfBirth);
GO

SELECT * FROM Reader WHERE YEAR(DateOfBirth) = 2003

--хранимые процедуры 

IF OBJECT_ID ('reader_proc', N'P') IS NOT NULL
    DROP PROCEDURE reader_proc
GO

CREATE PROCEDURE reader_proc
    @reader_cursor CURSOR VARYING OUTPUT
AS 
    SET @reader_cursor = CURSOR
    FORWARD_ONLY STATIC FOR 
        SELECT ReaderID, FirstName --, SecondName
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

--функции 

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
--функции


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

--triggers триггеры

if OBJECT_ID(N'trigger_insert') is not NULL
    drop trigger trigger_insert
GO

CREATE TRIGGER trigger_insert on Reader
after insert AS
BEGIN
    declare @allowed_age INT = YEAR(DATEADD(year, -14, getdate()));
    if exists(select * from inserted
                WHERE not( year(inserted.DateOfBirth)<@allowed_age))
                BEGIN
                    delete from Reader where not (year(DateOfBirth)< @allowed_age)
                    RAISERROR('Reader must be 14 years old', 2, 1);
                END
END
GO

INSERT INTO Reader ( FirstName, SecondName, Telephone, DateOfBirth, Email) VALUES
(N'Kseniya', 'Andreeva','89164679678', '2015-09-16', 'ksurrealism@vk.com');

select * from Reader
GO

If OBJECT_ID(N'trigger_update') IS NOT NULL
    drop TRIGGER trigger_update 
GO

Create trigger trigger_update on Reader
after update AS
    print 'Reader table has been updated'
GO

UPDATE Reader set DateOfBirth = '2000-08-09' where SecondName = N'Potrebina'
GO
select * from Reader

IF OBJECT_ID(N'trigger_delete') is not NULL
    drop trigger trigger_delete
GO

create trigger trigger_delete on Reader 
after delete AS
    print 'This reader has been deleted'
GO

delete from Reader where SecondName = N'Baltaeva'
Select * from Reader
GO

disable trigger trigger_insert on Reader;
disable trigger trigger_update on Reader;
disable trigger trigger_delete on Reader;

-- 2. Для представления пункта 2 задания 7 создать триггеры на вставку, удаление 
-- и добавление, обеспечивающие возможность выполнения операций с данными 
-- непосредственно через представление.

if OBJECT_ID(N'Contacts') is not null
	drop table Contacts
go

IF OBJECT_ID (N'LibraryEmployee') IS NOT NULL
DROP TABLE LibraryEmployee

CREATE TABLE LibraryEmployee(
	EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
	Name NVARCHAR(70) NOT NULL check (len(Name) > 1),
	DateOfBirth DATE NOT NULL
)
GO

create Table Contacts(
	ContID int NOT NULL unique foreign key references LibraryEmployee(EmployeeID),
	Phone char(11) Null,
	Email varchar(256) null
)


if OBJECT_ID(N'ExampleView') is NOT NULL
    drop view ExampleView;
GO

CREATE VIEW ExampleView AS
    SELECT
        l.EmployeeID,
        l.Name,
        l.DateOfBirth,
        c.Phone,
        c.Email
    from LibraryEmployee l
    inner join Contacts c on 
    l.EmployeeID = c.ContID
GO

if OBJECT_ID(N'trigger2_insert') is not NULL
    drop trigger trigger2_insert
GO

CREATE TRIGGER trigger2_insert on ExampleView instead of insert AS
BEGIN
    declare @name NVARCHAR(70);
    declare @birthdate  date;
    declare @phone CHAR(11);
    declare @email varchar(254);
    declare cursor1 cursor for 
        select Name, DateOfBirth, Phone, Email from inserted;
    open cursor1;
    fetch next from cursor1 into @name, @birthdate, @phone, @email;
    while @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO LibraryEmployee (Name, DateOfBirth) VALUES (@name, @birthdate);
        INSERT INTO Contacts(ContID, Phone, Email) VALUES (SCOPE_IDENTITY(), @phone, @email);
        FETCH next from cursor1 into @name, @birthdate, @phone, @email;
    END
    CLOSE cursor1
END
GO

insert into ExampleView ( Name, DateOfBirth, Phone, Email) VALUES
('Oleg Lomakin', '2001-02-17', '89263090777', 'lmkn@icloud.com'),
('Polina Smirnova', '2003-07-15', '89293292888', 'smrnv@icloud.com'),
('Polina Stelmah', '2003-02-26', '89348992888', 'stelmah@gmail.com'),
('Nikita Maslennikov', '2003-01-21', '89348792888', 'mslnkv@gmail.com');

--Join
SELECT EmployeeID, Name, DateOfBirth
FROM LibraryEmployee
JOIN Contacts ON Contacts.ContID = LibraryEmployee.EmployeeID;
-- exists
SELECT Name
FROM LibraryEmployee
WHERE EXISTS (SELECT Phone FROM Contacts WHERE LibraryEmployee.EmployeeID = Contacts.ContID AND YEAR(LibraryEmployee.DateOfBirth)>=2003);

SELECT * from LibraryEmployee
SELECT * from Contacts
SELECT * from ExampleView

GO

If OBJECT_ID('trigger2_delete') IS NOT NULL
    drop trigger trigger2_delete
GO

CREATE TRIGGER trigger2_delete ON ExampleView INSTEAD OF DELETE AS 
BEGIN
    DELETE FROM Contacts WHERE Contacts.ContID IN (SELECT d.EmployeeID FROM deleted as d)
    DELETE FROM LibraryEmployee WHERE LibraryEmployee.EmployeeID in (select d.EmployeeID from deleted as D)
END
GO

Delete from ExampleView 
    where Name='Nikita Maslennikov'

SELECT * from LibraryEmployee
SELECT * from Contacts
SELECT * from ExampleView

IF OBJECT_ID('trigger2_update') IS NOT NULL
    drop TRIGGER trigger2_update
GO

CREATE trigger trigger2_update 
    on ExampleView 
    INSTEAD OF update AS 
    BEGIN
        if update (EmployeeID)
            RAISERROR('ID can not be modified', 16, 2)
        ELSE
            BEGIN
            UPDATE LibraryEmployee
                set Name = (select Name FROM inserted 
                where LibraryEmployee.EmployeeID=inserted.EmployeeID),
                    DateOfBirth = 
                    (select DateOfBirth FROM inserted WHERE
                    LibraryEmployee.EmployeeID=inserted.EmployeeID)
                WHERE
                LibraryEmployee.EmployeeID in (select EmployeeID from inserted)
            UPDATE Contacts
            set Phone = (select Phone FROM inserted 
            where Contacts.ContID=inserted.EmployeeID),
                Email = (select Email 
                FROM inserted WHERE Contacts.ContID = inserted.EmployeeID)
            WHERE
            Contacts.ContID in (select EmployeeID FROM inserted)
        END
    END
GO

INSERT INTO ExampleView (Name, DateOfBirth, Phone, Email) VALUES
('Alexey Kvilitaya', '2000-06-15', '89134575339', 'kvlty@gmail.com')

Select * from ExampleView
UPDATE ExampleView SET EmployeeID = EmployeeID+1
Select * from ExampleView

UPDATE ExampleView set Phone = '85645282727' WHERE Name=N'Alexey Kvilitaya'

SELECT * from LibraryEmployee
SELECT * from Contacts
SELECT * from ExampleView

--- Union all
USE master;
GO

IF DB_ID(N'Lab13_1') IS NOT NULL
    DROP DATABASE Lab13_1;
GO

IF DB_ID(N'Lab13_2') IS NOT NULL
    DROP DATABASE Lab13_2;
GO

CREATE DATABASE Lab13_1
ON ( NAME = Lab13_1_dat, FILENAME = '/Users/madina/Databases/Lab13_1.dat', SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5% )
LOG ON ( NAME = Lab13_1_log, FILENAME = '/Users/madina/Databases/Lab13_1.ldf', SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB );
GO

CREATE DATABASE Lab13_2
ON ( NAME = Lab13_2_dat, FILENAME = '/Users/madina/Databases/Lab13_2.dat', SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5% )
LOG ON ( NAME = Lab13_2_log, FILENAME = '/Users/madina/Databases/Lab13_2.ldf', SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB );
GO

USE Lab13_1;
GO

DROP TABLE IF EXISTS Reader;
CREATE TABLE Reader(
    ReaderID INT NOT NULL PRIMARY KEY check(ReaderID BETWEEN 0 and 100),
    FirstName NVARCHAR(255) NOT NULL, 
    SecondName NVARCHAR(255) NOT NULL,
    Telephone CHAR(11) NOT NULL CHECK (len(Telephone) = 11),
    Email VARCHAR(254) UNIQUE NOT NULL,
    DateOfBirth Date NOT NULL
);
GO

INSERT INTO Reader ( ReaderID, FirstName, SecondName, Telephone, DateOfBirth, Email) VALUES
(25,N'Madina', 'Baltaeva','89253080955', '2003-07-09', 'madina_bltv@vk.com'),
(100,N'Valeria','Potrebina','89026730962', '2003-07-24', 'Valery@gmail.com'),
(34,N'Shevyrov','Arkadiy','89999258452', '2004-02-17', 'shrv@gmail.com'),
(95,N'Velichko',' Egor','89999258456', '2002-09-09', 'velichkoegor@icloud.com');
GO
select * from Reader;
go

USE Lab13_2;
GO

DROP TABLE IF EXISTS Reader;
CREATE TABLE Reader(
    ReaderID INT NOT NULL PRIMARY KEY check (ReaderID between 101 and 200) ,
    FirstName NVARCHAR(255) NOT NULL, 
    SecondName NVARCHAR(255) NOT NULL,
    Telephone CHAR(11) NOT NULL /*UNIQUE*/ CHECK (len(Telephone) = 11),
    Email VARCHAR(254) UNIQUE NOT NULL,
    DateOfBirth Date NOT NULL
);
GO
INSERT INTO Reader ( ReaderID,FirstName, SecondName, Telephone, DateOfBirth, Email) VALUES
(101,N'Kseniya', 'Andreeva','89253080955', '2003-09-16', 'ksnv@vk.com'),
(105,N'Darya','Vasilovskaya','89026730962', '2002-07-24', 'Vslcky@gail.com'),
(156,N'Oleg','Lomakin','89999258452', '2004-02-17', 'lmkn@gmal.com'),
(123,N'Nikita','Maslennikov','89999258456', '2002-09-09', 'mslnvk@icloud.com');
GO

SELECT * from Reader;
GO
if OBJECT_ID('Reader_view') is not null
    drop view Reader_view;
GO

create view Reader_view 
AS
    select * from Lab13_1.dbo.Reader
UNION ALL SELECT * from 
Lab13_2.dbo.Reader
GO

select * from Reader_view;
go

INSERT INTO Reader_view (ReaderID,FirstName, SecondName, Telephone, DateOfBirth, Email) VALUES
(50,N'Vera', 'Vera','89253080955', '2003-07-09', 'moigjhjkv@vk.com'),
(155,N'Ekaterina', 'Duzheeva','89253080955', '2003-07-09', 'mhuhgv@vk.com');
GO