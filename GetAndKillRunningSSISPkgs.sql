USE SSISDB
GO

--Exec catalog.stop_operation  @operation_id =  15828

select * from catalog.executions Where end_time is null 