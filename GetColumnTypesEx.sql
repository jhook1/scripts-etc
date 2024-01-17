use PVS
go



SELECT TOP(100) *
FROM PVS.INFORMATION_SCHEMA.Columns
WHERE DATA_TYPE in ('image','binary','varbinary')