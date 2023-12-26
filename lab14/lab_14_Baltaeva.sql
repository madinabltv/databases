USE master;
GO

IF DB_ID(N'Lab14_1') IS NOT NULL
    DROP DATABASE Lab14_1;
GO

IF DB_ID(N'Lab14_2') IS NOT NULL
    DROP DATABASE Lab14_2;
GO

CREATE DATABASE Lab14_1
ON ( NAME = Lab14_1_dat, FILENAME = '/Users/madina/Databases/Lab14_1.dat', SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5% )
LOG ON ( NAME = Lab14_1_log, FILENAME = '/Users/madina/Databases/Lab14_1.ldf', SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB );
GO

CREATE DATABASE Lab14_2
ON ( NAME = Lab14_2_dat, FILENAME = '/Users/madina/Databases/Lab14_2.dat', SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5% )
LOG ON ( NAME = Lab14_2_log, FILENAME = '/Users/madina/Databases/Lab14_2.ldf', SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB );
GO

USE Lab14_1;
GO

DROP TABLE IF EXISTS Reader;
CREATE TABLE Reader(
    ReaderID INT NOT NULL PRIMARY KEY ,
    FirstName NVARCHAR(255) NOT NULL, 
    SecondName NVARCHAR(255) NOT NULL,    
    DateOfBirth Date NOT NULL
);
GO

INSERT INTO Reader ( ReaderID, FirstName, SecondName, DateOfBirth) VALUES
(25,N'Madina', 'Baltaeva','2003-07-09'),
(100,N'Valeria','Potrebina', '2003-07-24'),
(34,N'Shevyrov','Arkadiy', '2004-02-17'),
(95,N'Velichko',' Egor', '2002-09-09');
GO
-- select * from Reader;
-- go

Use Lab14_2;
go

DROP TABLE IF EXISTS Reader;
CREATE TABLE Reader(
    ReaderID INT NOT NULL PRIMARY KEY,
    Telephone CHAR(11) NOT NULL CHECK (len(Telephone) = 11),
    Email VARCHAR(254) UNIQUE NOT NULL,
);
GO

INSERT INTO Reader ( ReaderID, Telephone, Email) VALUES
(25,'89253080955', 'madina_bltv@vk.com'),
(100,'89026730962', 'Valery@gmail.com'),
(34,'89999258452', 'shrv@gmail.com'),
(95,'89999258456', 'velichkoegor@icloud.com');
go 

-- select * from Reader;
-- go

Create view Reader_view 
AS 
    select r.ReaderID, r.FirstName, r.SecondName, r.DateOfBirth, 
    rr.Telephone, rr.Email from Lab14_1.dbo.Reader r, Lab14_2.dbo.Reader rr
    where r.ReaderID = rr.ReaderID
--if insert without trigger -error 
GO
SELECT * from reader_view
GO

if OBJECT_ID(N'view_insert') is not NULL
    drop trigger view_insert
GO

CREATE TRIGGER view_insert 
    on Reader_view
    INSTEAD of insert 
    AS
        BEGIN
            INSERT INTO Lab14_1.dbo.Reader( ReaderID, FirstName, SecondName, DateOfBirth)
            select ReaderID, FirstName, SecondName, DateOfBirth from inserted
            INSERT INTO Lab14_2.dbo.Reader( ReaderID, Telephone, Email)
            select  ReaderID, Telephone, Email from inserted 
        END
GO
INSERT INTO Reader_view( ReaderID,FirstName, SecondName, Telephone, DateOfBirth, Email) VALUES
(101,N'Kseniya', 'Andreeva','89253080955', '2003-09-16', 'ksnv@vk.com'),
(102, N'Ksusha', 'Andreeva', '89253080955', '2003-09-16', 'ksnv@vk.ru');
GO
-- select * from Reader_view;
-- GO
-- Select * from Lab14_1.dbo.Reader;
-- GO
-- Select * from Lab14_2.dbo.Reader;
-- GO

if OBJECT_ID(N'view_update') is not NULL
    drop trigger view_update
GO

CREATE TRIGGER view_update 
    on Reader_view
    INSTEAD of update
    AS
        BEGIN
            IF UPDATE (ReaderID)
                BEGIN
                    RAISERROR('ReaderID can not be changed ', 16, 1)
                    ROLLBACK TRANSACTION;
                END
            IF UPDATE (FirstName) or UPDATE (SecondName) or UPDATE (DateOfBirth)
                BEGIN
                    Update Lab14_1.dbo.Reader set 
                        FirstName = inserted.FirstName, 
                        SecondName = inserted.SecondName,
                        DateOfBirth = inserted.DateOfBirth
                        from inserted
                        where inserted.ReaderID = Reader.ReaderID
                END
            IF UPDATE (Telephone) or UPDATE ( Email)
                BEGIN
                    Update Lab14_2.dbo.Reader SET
                        Telephone = inserted.Telephone, 
                        Email = inserted.Email
                        from inserted
                        where inserted.ReaderID = Reader.ReaderID
                END
        END
GO

Update Reader_view set ReaderID = 50, FirstName = N'abobab' , Telephone = '10000000000' where SecondName = ' Egor';
GO

if OBJECT_ID(N'view_delete') is not NULL
    drop trigger view_delete
GO

CREATE TRIGGER view_delete 
    on Reader_view
    INSTEAD of delete 
    AS
        BEGIN
            Delete from Lab14_1.dbo.Reader 
            where ReaderID in (select ReaderID from deleted)
            Delete from Lab14_2.dbo.Reader 
            where ReaderID in (select ReaderID from deleted)
        END
GO

Delete from Reader_view where SecondName = 'Andreeva';
go

select * from Reader_view;
GO
Select * from Lab14_1.dbo.Reader;
GO
Select * from Lab14_2.dbo.Reader;
GO
