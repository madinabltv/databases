USE master;
GO 
IF DB_ID (N'Library') IS NOT NULL
drop database Library;
GO

CREATE DATABASE Library
    ON  ( NAME = Library_dat, FILENAME =
        "/Users/madina/Databases/librarydat.mdf", 
        SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5% )
    LOG ON ( NAME = Library_log, FILENAME = 
        "/Users/madina/Databases/librarylog.ldf",
        SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB );

GO

USE Library;
GO

CREATE TABLE Department(
    dcode CHAR(8) NOT NULL PRIMARY KEY, 
    Contact CHAR(11) NULL,
    Email VARCHAR(254) NULL,
    Address VARCHAR(100) NOT NULL);

GO

INSERT INTO Department(dcode, Contact, Email, Address) VALUES
  ('09072003', '89253080955', 'madina_bltv@vk.com', 'Nikulinskaya street');



ALTER DATABASE Library ADD
    FILEGROUP DepartmentFileGroup

GO

ALTER DATABASE Library ADD FILE(
  name="DepFileMod", FILENAME="/Users/madina/Databases/DepFileMod"
) TO FILEGROUP DepartmentFileGroup;

GO

ALTER DATABASE Library 
  MODIFY FILEGROUP DepartmentFileGroup DEFAULT;
GO

CREATE SCHEMA DepartmentSchema;
GO

ALTER SCHEMA DepartmentSchema TRANSFER dbo.Department;
GO

DROP TABLE DepartmentSchema.Department
GO
DROP SCHEMA DepartmentSchema
GO