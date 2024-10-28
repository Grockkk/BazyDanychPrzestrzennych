USE AdventureWorksDW2019;
GO

CREATE PROCEDURE GetCurrencyRatesByYearsAgo
    @YearsAgo INT
AS BEGIN
    SELECT 
        fcr.*,
        dc.CurrencyAlternateKey
    FROM 
        FactCurrencyRate AS fcr
    INNER JOIN 
        DimCurrency AS dc ON fcr.CurrencyKey = dc.CurrencyKey
    WHERE 
    CONVERT(DATE, CONVERT(VARCHAR, fcr.DateKey)) <= DATEADD(YEAR, -@YearsAgo, GETDATE())
    AND dc.CurrencyAlternateKey IN ('GBP', 'EUR')
END;

EXEC GetCurrencyRatesByYearsAgo @YearsAgo = 10;