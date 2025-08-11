declare @start DATE = '2011-05-01'
declare @end DATE = '2011-08-01'

;with months (date)
AS
(
    SELECT @start
    UNION ALL
    SELECT DATEADD(month,1,date)
    from months
    where DATEADD(month,1,date)<=@end
)
select * from months