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
    Telephone CHAR(11) NOT NULL /*UNIQUE*/ CHECK (len(Telephone) = 11),
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

select * from Lab13_1.dbo.Reader;
go
select * from Lab13_2.dbo.Reader;
go
select * from Reader_view;
go

UPDATE Reader_view set FirstName = N'Evgeniy' where ReaderID = 50;
GO
UPDATE Reader_view set ReaderID = 153 where Email = 'madina_bltv@vk.com';
go
DELETE FROM Reader_view where ReaderID = 34;
GO
DELETE FROM Reader_view where ReaderID = 155;
GO
select * from Lab13_1.dbo.Reader;
go
select * from Lab13_2.dbo.Reader;
go
select * from Reader_view;
go
