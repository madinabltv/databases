USE master;
GO

IF DB_ID(N'Lab9') IS NOT NULL
    DROP DATABASE Lab9;
GO

CREATE DATABASE Lab9
ON ( NAME = Lab9_dat, FILENAME = '/Users/madina/Databases/Lab9.dat', SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5% )
LOG ON ( NAME = Lab9_log, FILENAME = '/Users/madina/Databases/Lab9.ldf', SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB );
GO

USE Lab9;

DROP TABLE IF EXISTS Reader;
CREATE TABLE Reader(
    ReaderID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(255) NOT NULL, 
    SecondName NVARCHAR(255) NOT NULL,
    Telephone CHAR(11) NOT NULL UNIQUE CHECK (len(Telephone) = 11),
    Email VARCHAR(254) UNIQUE NOT NULL,
    DateOfBirth Date NOT NULL,
    RegistrationDate DATETIME DEFAULT CURRENT_TIMESTAMP, 
);
GO

INSERT INTO Reader ( FirstName, SecondName, Telephone, DateOfBirth, Email) VALUES
(N'Madina', 'Baltaeva','89253080955', '2003-07-09', 'madina_bltv@vk.com'),
(N'Valeria','Potrebina','89026730962', '2003-07-24', 'Valery@gmail.com'),
(N'Shevyrov','Arkadiy','89999258452', '2004-02-17', 'shrv@gmail.com'),
(N'Velichko',' Egor','89999258456', '2002-09-09', 'velichkoegor@icloud.com');

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
(N'Дракула', N'8689N', 1897, N'Роман-ужасы', 1,  '98547632');

SELECT * FROM BookInstance;
GO

DROP TABLE IF EXISTS Author;
CREATE TABLE Author(
    AuthorID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(255) NOT NULL, 
    LastName NVARCHAR(255) NOT NULL,
    BirthDate datetime NULL,
    AuthorCountry CHAR(3) NULL
);
GO

INSERT INTO Author (FirstName, LastName) VALUES 
(N'Эндрю', N'Таненбаум'),
(N'Лев', N'Толстой'),
(N'Евгений', N'Замятин'),
(N'Рэй', N'Бредбэри'),
(N'Джером', N'Селинджер'),
(N'Владимир', N'Маяковский'),
(N'Брэм', N'Стокер');

SELECT * FROM Author;
GO

CREATE TABLE BookOfAuthor (
    AuthorID INT NOT NULL IDENTITY(1,1) FOREIGN KEY REFERENCES Author(AuthorID),
    BookISBN UNIQUEIDENTIFIER DEFAULT NEWID() NOT NULL FOREIGN KEY REFERENCES BookInstance(BookISBN)
);
GO
------
-- 1. Для одной из таблиц пункта 2 задания 7 создать триггеры на вставку,
--  удаление и добавление, при выполнении заданных условий один из триггеров 
--  должен инициировать возникновение ошибки (RAISERROR / THROW).

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
