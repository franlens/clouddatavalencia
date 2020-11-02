-- Demo 01 --

-- Query 1 (Versión SQL Server)
select @@version

-- Query 2 (TraceFlags)
DBCC TRACESTATUS

-- Query 3 (TEMPDB)
use tempdb;
go
Select * from sysfiles;


-- Query 4 (Databases)
use master
go
select name, compatibility_level, collation_name from sys.databases;

-- Query 4.1 (MDF & LDF)
use test
go
select name, filename from sysfiles;
