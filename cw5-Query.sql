-- Same dni
SELECT OrderDate, COUNT(OrderDate) as Orders_cnt 
FROM FactInternetSales
GROUP BY OrderDate
HAVING COUNT(OrderDate) <100
ORDER BY Orders_cnt DESC;

-- Cena jednostkowa
SELECT a.OrderDate, a.UnitPrice 
FROM
	(SELECT OrderDate, UnitPrice, 
			ROW_NUMBER() OVER (PARTITION BY OrderDate ORDER BY UnitPrice DESC) as RowNumber
	 FROM FactInternetSales) a
WHERE a.RowNumber <=3