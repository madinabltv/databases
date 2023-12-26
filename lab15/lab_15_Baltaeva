use master;
go
drop database if exists Lab15_1;
go
create database Lab15_1
go


use master;
go
drop database if exists Lab15_2;
go
create database Lab15_2
go


use Lab15_1;
go
-- родитель --
DROP TABLE IF EXISTS Book;
--delete , update - need to do
CREATE TABLE Book (
    BookISBN int NOT NULL,
    Name NVARCHAR(255) NOT NULL,
);
GO
-- trigger is not necessary when we insert data to parent
INSERT INTO Book(BookISBN, Name) VALUES
(123, N'Компьютерные сети'),
(124, N'Война и мир'),
(125, N'Мы'),
(126, N'Вино из одуванчиков'),
(127, N'Над пропастью во ржи'),
(128, N'Облако в штанах'),
(129, N'Дракула');
SELECT * FROM Book;
GO

use Lab15_2;
go
-- ребенок

DROP TABLE IF EXISTS BookInfo;

CREATE TABLE BookInfo(
    BookISBN int NOT NULL,
    Location VARCHAR(20) NOT NULL,
    IssueYear SMALLINT NULL,
    Genre NVARCHAR(100) NULL,
    Language INTEGER NOT NULL
);
GO

INSERT INTO BookInfo(BookISBN, Location, IssueYear, Genre, Language) VALUES
(199, N'6A', 2012, N'Современная наука', 1 ),
(124, N'123D', 1867, N'Роман-эпопея', 1),
(125, '8765D', 1920, N'Научная фантастика роман-антиутопия', 1),
(126, N'4567K', 1957, N'Научная фантастика', 1),
(127, N'4889K', 1951, N'Роман', 1),
(128, N'86N', 1915, N'Стихотворение', 1),
(129, N'8689N', 1897, N'Роман-ужасы', 1);
GO
SELECT * from BookInfo;


-- delete родителя -- 

use Lab15_1;
go
drop trigger if exists book_delete
go
create trigger book_delete
	on Lab15_1.dbo.Book
	instead of delete
	as
	begin
		
		delete from Lab15_1.dbo.Book
			where BookISBN in (select BookISBN from deleted)

		delete from Lab15_2.dbo.BookInfo
			where BookISBN in (select BookISBN from deleted)
	end
go

delete from Book where BookISBN = '125';

select * from Book
select * from Lab15_2.dbo.BookInfo

-- update родителя --

use Lab15_1;
go
drop trigger if exists book_update
go
create trigger book_update
	on Lab15_1.dbo.Book
	instead of update
	as
	begin

		if UPDATE(BookISBN)
			RAISERROR('BookISBN can not be modified', 16, 1);

		if UPDATE(Name)
		begin
			update Book
				set Name = (select Name from inserted where inserted.BookISBN = Book.BookISBN)
				where Book.BookISBN = (select BookISBN from inserted where inserted.BookISBN = Book.BookISBN)
		end
	end
go

update Lab15_1.dbo.Book set Name = N'Час быка'  where Name = 'Дракула'


select * from Lab15_1.dbo.Book



-- insert ребенок 

use Lab15_2;
go
drop trigger if exists BookInfo_insert
go
create trigger BookInfo_insert
	on Lab15_2.dbo.BookInfo
	instead of insert
	as
	begin
	
		if exists (select BookISBN from inserted where BookISBN not in (select BookISBN from Lab15_1.dbo.Book))
		begin
			RAISERROR('reference что-то там ....', 16, 1);
		end

		else
		begin
			insert into BookInfo ( BookISBN, Location, IssueYear, Genre, Language)
				select BookISBN, Location, IssueYear, Genre, Language from inserted
		end

	end
go

insert into Lab15_1.dbo.Book values
	(130, N'Повелитель мух'),
    (140, N'a book');

insert into BookInfo (BookISBN, Location, IssueYear, Genre, Language) values
	(130, '7636H', 1980, N'антиутопия', 1);


select * from Lab15_2.dbo.BookInfo
select *from Lab15_1.dbo.Book


-- update ребенка

use Lab15_2;
go
if OBJECT_ID(N'BookInfo_update', N'TR') is not null
    drop trigger BookInfo_update
go
create trigger BookInfo_update
	on Lab15_2.dbo.BookInfo
	instead of update
	as
	begin

		if UPDATE(BookISBN)
			begin
				RAISERROR('BookISBN can not be updated', 16, 1);
			end

		if UPDATE(Location) or UPDATE(Genre) or UPDATE(IssueYear) or UPDATE(Language)
			begin
				update BookInfo
					set
						Location = (select Location from inserted where inserted.BookISBN = BookInfo.BookISBN),
						Genre = (select Genre from inserted where inserted.BookISBN = BookInfo.BookISBN),
                        IssueYear = (select IssueYear from inserted where inserted.BookISBN = BookInfo.BookISBN),
                        Language = (select Language from inserted where inserted.BookISBN = BookInfo.BookISBN)
					where BookISBN = (select BookISBN from inserted where inserted.BookISBN = BookInfo.BookISBN)
			end
	end
go

update BookInfo set Location = '7777A'
	where Location = '6A'


select * from BookInfo  
