drop table if exists Reader
go
create table Reader
(
	ReaderID int identity(1,1) primary key,
	Name varchar(255),
	Telephone char(11)
);
go

insert into Reader (Name, Telephone) values
	('Kseniya', '89253080955'),
	('Ekaterina', '89995679877'),
	('Madina', '86547890933')
go



-- begin transaction
-- 	select * from Reader
-- 	update Reader
-- 		set Telephone = '000'
-- 		where Name = 'Kseniya'
-- 	waitfor delay '00:00:05'
-- 	select resource_type , resource_subtype, request_type, request_mode from sys.dm_tran_locks where request_session_id = @@SPID
-- 	ROLLBACK;
-- 	select * from Reader



set transaction isolation level 
	read uncommitted
	--repeatable read
begin transaction
	select * from Reader
	waitfor delay '00:00:05'
	select * from sys.dm_tran_locks where request_session_id = @@SPID

	select * from Reader
	rollback




set transaction isolation level 
	--repeatable read --мгновенное выполнение
	serializable --ожидание выполнения первой транзакции
begin transaction
	select * from Reader
	waitfor delay '00:00:05'
	select resource_type ,request_type, resource_subtype ,request_mode from sys.dm_tran_locks where request_session_id = @@SPID
	select * from Reader
 commit

/*Потерянное обновление  Эффект проявляется при одновременном изменении одного блока данных разными 
транзакциями. Причём одно из изменений может теряться.


Неповторяющееся чтение (non-repeatable read)
Проявляется, когда при повторном чтении в рамках одной транзакции,
ранее прочитанные данные, оказываются изменёнными.

Можно наблюдать, когда одна транзакция в ходе своего выполнения несколько раз
выбирает множество строк по одним и тем же критериям. При этом другая транзакция 
в интервалах между этими выборками добавляет или удаляет строки, или изменяет 
столбцы некоторых строк, используемых в критериях выборки первой транзакции, 
и успешно заканчивается. В результате получится, что одни и те же выборки в
первой транзакции дают разные множества строк.*/
