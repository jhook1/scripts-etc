SELECT GETDATE() AS CurrTime, DATEADD(MINUTE,DATEPART(tz,SYSDATETIMEOFFSET()),GETUTCDATE()) AS TZCurrTime

SELECT GETUTCDATE() AS CurrTime, DATEADD(MINUTE,-DATEPART(tz,SYSDATETIMEOFFSET()),GETDATE()) AS UTCCurrTime
