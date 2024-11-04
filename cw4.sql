U¿ywaj¹c odpowiedniej kwerendy sprawdŸ definicjê tabeli AdventureWorksDW2019.dbo.FactInternetSales 

a) w jaki sposób wyœwietliæ definicjê tabeli w bazie Oracle, 
SELECT * FROM ALL_TAB_COLUMNS WHERE TABLE_NAME = 'FactInternetSales';

b) w jaki sposób wyœwietliæ definicjê tabeli w bazie PostgreSQL, 
SELECT * FROM information_schema.columns WHERE table_name = 'FactInternetSales';

c) w jaki sposób wyœwietliæ definicjê tabeli w bazie MySQL, 
SELECT * FROM information_schema.columns WHERE table_name = 'FactInternetSales';