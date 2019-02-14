---- Integrating managed code (.NET CLR) in the database
 
EXEC sp_configure 'clr enabled' ,1
GO
Reconfigure

--1. create 3 objects from visualStudio:
--   MyNewClr calls the new methods

--a. AddNewTableProcedure method creates a procedure called NewTable that creates a table called myTable

drop proc  if exists MyNewClr
drop proc  if exists NewTable
drop table if exists MyTable

create proc MyNewClr
as
external name MyNewClr.Class2.AddNewTable
go

exec MyNewClr 
go

exec newtable

select * from sys.procedures where name = 'newtable' 
select * from sys.tables where name = 'MyTable'

--b. InsertIntoNewTableProcedure method creates a procedure called InsertToNewTable that inserts a row into the table

drop proc  if exists MyNewClr
drop proc  if exists InsertToNewTable

create proc MyNewClr
as
external name MyNewClr.Class2.InsertIntoNewTable
go

exec MyNewClr 
go

select * from sys.procedures where name = 'InsertToNewTable' 

exec InsertToNewTable

--c. SelectFromTable method creates a procedure called SelectNewTable that select from orders table

drop proc  if exists MyNewClr
drop proc  if exists SelectNewTable

create proc MyNewClr
as
external name MyNewClr.Class2.SelectFromTable
go

exec MyNewClr 
go

select * from sys.procedures where name = 'SelectNewTable' 

--try the newly created procedure
exec SelectNewTable


--2. create a table EMP, add methods clr_update, clr_delete

--create EMP table
drop proc  if exists MyNewClr
drop proc  if exists NewTableEMP

create proc MyNewClr
as
external name MyNewClr.Class2.AddEMPTable
go

exec MyNewClr 
go

select * from sys.procedures where name = 'NewTableEMP' 

exec NewTableEMP

select * from sys.tables where name = 'EMP'

--create insert procedures
drop proc  if exists MyNewClr
drop proc  if exists clr_insert

create proc MyNewClr
as
external name MyNewClr.Class2.InsertEMPTable
go

exec MyNewClr 
go

select * from sys.procedures where name = 'clr_insert'

exec clr_insert

--create update procedure
drop proc  if exists MyNewClr
drop proc  if exists clr_update

create proc MyNewClr
as
external name MyNewClr.Class2.UpdateEMPTable
go

exec MyNewClr 
go

select * from sys.procedures where name = 'clr_update'

exec clr_update

--create delete procedure
drop proc  if exists MyNewClr
drop proc  if exists clr_delete

create proc MyNewClr
as
external name MyNewClr.Class2.DeleteEMPTable
go

exec MyNewClr 
go

select * from sys.procedures where name = 'clr_delete'

exec clr_delete

--c. create trigger called SampleTrigger that wakes for each DML on employees table
--and adds new row in EMP table
CREATE TRIGGER SampleTrigger_trig
  ON [dbo].[Employees]
AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
	Declare @Username varchar(100)
    SET NOCOUNT ON
	SELECT @Username =  CURRENT_USER
    -- Check if this is an INSERT, UPDATE or DELETE Action.
    IF EXISTS(SELECT * FROM INSERTED)  AND EXISTS(SELECT * FROM DELETED) 
		BEGIN insert into EMP (Datemodified, Usename, type)  values (getdate(), @Username, 'UPDATE') END 
    ELSE IF EXISTS(SELECT * FROM INSERTED)  AND NOT EXISTS(SELECT * FROM DELETED) 
        BEGIN insert into EMP (Datemodified, Usename, type)  values (getdate(), @Username, 'INSERT') END 
    ELSE IF EXISTS(SELECT * FROM DELETED) AND NOT EXISTS(SELECT * FROM INSERTED)
        BEGIN insert into EMP (Datemodified, Usename, type)  values (getdate(), @Username, 'DELETED') END
END


INSERT INTO [dbo].[Employees]
           ([LastName],[FirstName] ,[Title],[TitleOfCourtesy],[BirthDate],[HireDate],[Address]
           ,[City],[Region],[PostalCode],[Country],[HomePhone],[Extension],[Photo],[Notes]
           ,[ReportsTo],[PhotoPath])
     VALUES
           ('ben','avi',null,null,null,null,null ,null,null,null,null,null,null,null
           ,null,null,null)

UPDATE [dbo].[Employees]
   SET [LastName] = 'fff'
 WHERE firstname='avi'
GO

delete from [dbo].[Employees]
where firstname='avi'

SELECT *
  FROM [Northwind].[dbo].[EMP]


--3. script in vs to see all details on procedures in worldwideimporters db
use WideWorldImporters
--add into vs the following:
SELECT * FROM WideWorldImporters.INFORMATION_SCHEMA.ROUTINES 
--test it
--B. STAORED PROCEDURE:
CREATE PROCEDURE [dbo].[SelectSPData] @DBname nvarchar(100) 
AS 
BEGIN
	DECLARE @SQL nvarchar(MAX)  
	SET @SQL= 'SELECT * from ' + @DBname + '. sys.procedures'
	exec(@sql)
END

--C. created in VS

drop proc  if exists MyNewClr
drop proc  if exists SelectSPData

create proc MyNewClr
as
external name MyNewClr.Class1.ProcedureInfo
go

exec MyNewClr 
go

--call new sp
SelectSPData 'WideWorldImporters'







