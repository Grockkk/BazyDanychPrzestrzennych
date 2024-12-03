DROP TABLE AdventureWorksDW2019.dbo.CSV_Customers

CREATE TABLE AdventureWorksDW2019.dbo.CSV_Customers (
    FirstName VARCHAR(255),
    LastName VARCHAR(255),
    EmailAddress VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(255),
    Region VARCHAR(255),
    PhoneNumber VARCHAR(50),
    CREATE_TIMESTAMP DATETIME,
    UPDATE_TIMESTAMP DATETIME
);

select * from dbo.CSV_Customers order by UPDATE_TIMESTAMP desc, CREATE_TIMESTAMP desc