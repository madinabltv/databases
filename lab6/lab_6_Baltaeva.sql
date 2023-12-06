Use master
GO

IF DB_ID (N'Lab6_Madi') IS NOT NULL
drop database Lab6_Madi;
GO

CREATE DATABASE Lab6_Madi
ON ( NAME = Lab6_Madina_dat, FILENAME = '/Users/madina/Databases/Lab6_Madina.dat', SIZE = 10, MAXSIZE = UNLIMITED, FILEGROWTH = 5% )
LOG ON ( NAME = Lab6_Madinalog, FILENAME = '/Users/madina/Databases/Lab6_Madina.ldf', SIZE = 5MB, MAXSIZE = 25MB, FILEGROWTH = 5MB );
GO

USE Lab6_Madi;
GO

/*
1. Создать таблицу с автоинкрементным первичным ключом. Изучить функции, предназначенные для
получения сгенерированного значения IDENTITY.

2. Добавить поля, для которых используются ограничения (CHECK), значения по умолчанию
(DEFAULT), также использовать встроенные функции для вычисления значений.
*/
DROP TABLE IF EXISTS Readers_M;
CREATE TABLE Readers_M(
    ReaderID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(255) NOT NULL, 
    SecondName NVARCHAR(255) NOT NULL,
    Telephone CHAR(11) NOT NULL UNIQUE CHECK (len(Telephone) = 11),
    Email VARCHAR(254) UNIQUE NOT NULL,
    DateOfBirth Date CHECK (DateOfBirth < DATEADD(year, -12, GETDATE())) DEFAULT DATEADD(year, -12, GETDATE()),
    RegistrationDate DATETIME DEFAULT CURRENT_TIMESTAMP, 
);
GO

INSERT INTO Readers_M ( FirstName, SecondName, Telephone, DateOfBirth, Email) VALUES
(N'Madina', 'Baltaeva','89253080955', '2003-07-09', 'madina_bltv@vk.com'),
(N'Valeria','Potrebina','89026730962', '2003-07-24', 'Valery@gmail.com'),
(N'Shevyrov','Arkadiy','89999258452', '2004-02-17', 'shrv@gmail.com'),
(N'Velichko',' Egor','89999258456', '2002-09-09', 'velichkoegor@icloud.com');

SELECT * FROM Readers_M;

/*
INSERT INTO Readers_M(...)
VALUES ("");
DECLARE @GeneratedID INT;
SET @GeneratedID = SCOPE_IDENTITY();
@GeneratedID - содержит теперь сгенерированное значение IDENTITY


select @@IDENTITY as id;
select SCOPE_IDENTITY() as scope_id;
select IDENT_CURRENT('Readers_M') as id_current;

@@IDENTITY - не ограничивается никакой областью
SCOPE_IDENTITY - ограничивается областью
Разница состоит в том, что функция SCOPE_IDENTITY возвращает значение identity 
для последнего оператора INSERT, выполненного в той же сессии и области 
действия (scope). Напротив, функция @@IDENTITY возвращает последнее вставленное 
значение независимо от области действия.
*/

--3. Создать таблицу с первичным ключом на основе глобального уникального идентификатора.
DROP TABLE IF EXISTS Authors_M;
CREATE TABLE Authors_M(
    AuthorID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY, 
    FirstName NVARCHAR(255) NOT NULL, 
    LastName NVARCHAR(255) NOT NULL
);
GO

INSERT INTO Authors_M (FirstName, LastName ) VALUES 
(N'Tolstoy', 'Lev'),
(N'Gorkiy', 'Maksim'),
(N'King', 'Steven'),
(N'Stoker', 'Bram');

SELECT * FROM Authors_M;

--SEQUENCE – это объект, а IDENTITY – это свойство
--EQUENCE – это объект, который создается отдельно, и он не привязан ни к одной таблице, 
--т.е. мы его можем использовать в нескольких таблицах.
--IDENTITY – это свойство одной конкретной таблицы, и оно, соответственно, привязано к этой таблице.
-- 4. Создание таблицы с первичным ключом на основе последовательности


DROP SEQUENCE IF EXISTS Example_Sequence;
CREATE SEQUENCE Example_Sequence 
    START WITH 1 
    INCREMENT BY 1
    MAXVALUE 15;
GO

DROP TABLE IF EXISTS ExampleTableSequence_M;
CREATE TABLE ExampleTableSequence_M (
    ID INT PRIMARY KEY DEFAULT NEXT VALUE FOR Example_Sequence,
    Data VARCHAR(50)
);
GO
--5. Создать две связанные таблицы, и протестировать на них различные варианты действий для
--ограничений ссылочной целостности (NO ACTION | CASCADE | SET | SET DEFAULT).
DROP TABLE IF EXISTS Student
DROP TABLE IF EXISTS Room
CREATE TABLE Room(
	RoomID INT PRIMARY KEY,
	Floor INT
);


CREATE TABLE Student(
	StudentID INT IDENTITY(1,1) PRIMARY KEY,
	FirstName NVARCHAR(60) NOT NULL,
    SecondName NVARCHAR(60) NOT NULL,
	Telephone CHAR(11) NOT NULL UNIQUE CHECK (len(Telephone) = 11),
	DateOfBirth Date CHECK (DateOfBirth < DATEADD(year, -12, GETDATE())) DEFAULT DATEADD(year, -12, GETDATE()),
	RoomID INT
	CONSTRAINT FK_RoomID FOREIGN KEY (RoomID) REFERENCES Room (RoomID)
		ON UPDATE CASCADE --каскадное изменение ссылающихся таблиц;
		--ON UPDATE NO ACTION --выдаст ошибку при удалении/изменении
		--ON UPDATE SET NULL --установка NULL для ссылающихся внешних ключей;
		--ON UPDATE SET DEFAULT --установка значений по умолчанию для ссылающихся внешних ключей;
		ON DELETE SET NULL --Указывает, что дочерние данные устанавливаются в NULL при удалении родительских данных
		--ON DELETE NO ACTION --строка в родительской таблице может быть удалена, если от нее не зависит другая строка
		--ON DELETE SET DEFAULT
		--ON DELETE CASCADE 
)
GO

INSERT INTO Room (RoomID, Floor) VALUES
(1007, 10),
(845, 8),
(108, 1),
(987, 9);

INSERT INTO Student (FirstName, SecondName, Telephone, DateOfBirth, RoomID) VALUES
(N'Madina', 'Baltaeva','89253080965', '2003-07-09', '1007'),
(N'Valeria','Potrebina','89026730962', '2003-07-24', '845'),
(N'Shevyrov','Arkadiy','98999258452', '2004-02-17', '108'),
(N'Velichko',' Egor','89851740041', '2002-09-09', '987');

SELECT * FROM Room;
SELECT * FROM Student;


/*действия CASCADE, SET и SET DEFAULT позволяют удалять и
обновлять значения ключей, влияющие на таблицы, в которых
определены связи внешних ключей, приводящие к таблице, в которую
вносятся изменения:
–
CASCADE: каскадное изменение ссылающихся таблиц;
–
SET NULL: установка для ссылающихся внешних ключей;
–
SET DEFAULT: установка значений по умолчанию для ссылающихся
внешних ключей;*/

use master
go