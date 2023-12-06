
USE Lab6_Madi

IF OBJECT_ID(N'Student_view') IS NOT NULL
        DROP VIEW Student_View;
GO


--1. Создать представление на основе одной из таблиц задания 6
CREATE VIEW Student_View AS
        SELECT *
        FROM Student
        WHERE RoomID = 1007;
GO

SELECT * FROM Student_View;
--2. Создать представление на основе полей обеих связанных таблиц задания 6

IF OBJECT_ID(N'Student_view_joined') IS NOT NULL     
        DROP VIEW Student_view_joined;
GO
CREATE VIEW Student_view_joined AS
        SELECT
                S.SecondName + ' ' + s.FirstName AS StudentName,
                'room ' + CAST(r.RoomID AS VARCHAR)+ ' ' + CAST(r.Floor as varchar) + ' floor' as RoomDescription
        FROM Student s
        INNER JOIN Room r        
                ON s.RoomID = r.RoomID
GO

SELECT * FROM Student_view_joined;
GO

--3. Создать индекс для одной из таблиц задания 6, включив в него дополнительные неключевые поля.

IF EXISTS (SELECT NAME FROM sys.indexes 
			WHERE NAME = N'IndexStudentDateOfBirth')
	DROP INDEX IndexStudentDateOfBirth ON Student;

GO
CREATE INDEX IndexStudentDateOfBirth
        ON Student (Telephone)
        INCLUDE (DateOfBirth);
GO

SELECT * FROM Student WHERE YEAR(DateOfBirth) = 2003

--4. Создать индексированное представление.
IF OBJECT_ID(N'RoomIndexView') IS NOT NULL 
        DROP VIEW RoomIndexView;
GO
--Предложение SCHEMABINDING привязывает представление к схеме таблицы,
-- по которой оно создается. 
CREATE VIEW RoomIndexView
        WITH SCHEMABINDING
        AS SELECT FirstName, DateOfBirth
        FROM dbo.Student
        WHERE RoomID = 1007;
GO

IF EXISTS (SELECT NAME FROM sys.indexes WHERE NAME = N'RoomIndexView')
        DROP INDEX RoomIndexView on Student;

GO
--индексировать представление можно, создав для него
--уникальный кластеризованный индекс:
CREATE UNIQUE INDEX IndexStudDateOfBirth
        ON RoomIndexView(FirstName, DateOfBirth);
GO
SELECT * FROM RoomIndexView;
/*

кластеризованные индексы сортируют и хранят строки данных в таблицах
или представлениях на основе их ключевых значений (т.е. значений
столбцов, включенных в определение индекса);
существует только один кластеризованный индекс для каждой таблицы;*/

Use master
GO