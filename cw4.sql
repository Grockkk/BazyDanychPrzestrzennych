U�ywaj�c odpowiedniej kwerendy sprawd� definicj� tabeli AdventureWorksDW2019.dbo.FactInternetSales 

a) w jaki spos�b wy�wietli� definicj� tabeli w bazie Oracle, 
SELECT * FROM ALL_TAB_COLUMNS WHERE TABLE_NAME = 'FactInternetSales';

b) w jaki spos�b wy�wietli� definicj� tabeli w bazie PostgreSQL, 
SELECT * FROM information_schema.columns WHERE table_name = 'FactInternetSales';

c) w jaki spos�b wy�wietli� definicj� tabeli w bazie MySQL, 
SELECT * FROM information_schema.columns WHERE table_name = 'FactInternetSales';