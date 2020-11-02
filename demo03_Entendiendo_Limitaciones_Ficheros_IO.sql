-- Scripts por Jovan Popovic
-- https://blogs.msdn.microsoft.com/sqlserverstorageengine/2018/08/20/reaching-azure-disk-storage-limit-on-general-purpose-azure-sql-database-managed-instance/

-- Creación de vista
CREATE SCHEMA mi;
GO
CREATE OR ALTER VIEW mi.master_files
AS
WITH mi_master_files AS
( SELECT *, size_gb = CAST(size * 8. / 1024 / 1024 AS decimal(12,4))
FROM sys.master_files where physical_name LIKE 'https:%')
SELECT *, azure_disk_size_gb = IIF(
database_id <> 2,
CASE WHEN size_gb <= 128 THEN 128
WHEN size_gb > 128 AND size_gb <= 256 THEN 256
WHEN size_gb > 256 AND size_gb <= 512 THEN 512
WHEN size_gb > 512 AND size_gb <= 1024 THEN 1024
WHEN size_gb > 1024 AND size_gb <= 2048 THEN 2048
WHEN size_gb > 2048 AND size_gb <= 4096 THEN 4096
ELSE 8192
END, NULL)
FROM mi_master_files;
GO

-- Espacio total por cada BBDD
SELECT db = db_name(database_id), name, size_gb, azure_disk_size_gb
from mi.master_files;

-- Suma total de discos (Máximo 35Tb)
SELECT storage_size_tb = SUM(azure_disk_size_gb) /1024.
FROM mi.master_files

-- Número máximo de ficheros que podemos tener
SELECT remaining_number_of_128gb_files = 
(35 - ROUND(SUM(azure_disk_size_gb) /1024,0)) * 8
FROM mi.master_files