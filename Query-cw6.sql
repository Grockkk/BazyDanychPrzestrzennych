
-- dodawanie tabeli stg_dimemp
DROP TABLE IF EXISTS dbo.stg_dimemp;


SELECT EmployeeKey, FirstName, LastName, Title
INTO dbo.stg_dimemp
FROM dbo.DimEmployee
WHERE EmployeeKey BETWEEN 270 AND 275;



-- Dodawanie tabeli scd_dimemp

DROP TABLE IF EXISTS dbo.scd_dimemp;

CREATE TABLE dbo.scd_dimemp (
    EmployeeKey int,
    FirstName nvarchar(50) NOT NULL,
    LastName nvarchar(50) NOT NULL,
    Title nvarchar(50),
    StartDate datetime,
    EndDate datetime
);
SELECT EmployeeKey, FirstName, LastName, Title, StartDate, EndDate
FROM dbo.DimEmployee
WHERE EmployeeKey >=  270 AND EmployeeKey <= 275;

SELECT * FROM stg_dimemp


-- 5:

-- a)
--"Insert Destination" wrote 6 rows.
-- SSIS Package ... finished: Success.

update STG_DimEmp 
set LastName = 'Nowak' 
where EmployeeKey = 270; 
update STG_DimEmp 
set TITLE = 'Senior Design Engineer' 
where EmployeeKey = 274; 

-- b)
-- (1 row affected)

-- (1 row affected)

-- Completion time: 2024-11-26T21:07:20.8416478+01:00

-- "Insert Destination" wrote 1 rows.
-- SSIS Package ... finished: Success.

-- c)
update STG_DimEmp 
set FIRSTNAME = 'Ryszard' 
where EmployeeKey = 275 

-- (1 row affected)

-- Completion time: 2024-11-26T21:08:44.5245784+01:00

-- Error: 0xC020803C at cw6, Slowly Changing Dimension [107]: If the FailOnFixedAttributeChange property is set to TRUE, the transformation will fail when a fixed attribute change is detected. To send rows to the Fixed Attribute output, set the FailOnFixedAttributeChange property to FALSE.
-- Error: 0xC0047022 at cw6, SSIS.Pipeline: SSIS Error Code DTS_E_PROCESSINPUTFAILED.  The ProcessInput method on component "Slowly Changing Dimension" (107) failed with error code 0xC020803C while processing input "Slowly Changing Dimension Input" (118). The identified component returned an error from the ProcessInput method. The error is specific to the component, but the error is fatal and will cause the Data Flow task to stop running.  There may be error messages posted before this with more information about the failure.

-- "Insert Destination" wrote 0 rows.
-- Warning: 0x80019002 at Package: SSIS Warning Code DTS_W_MAXIMUMERRORCOUNTREACHED.  The Execution method succeeded, but the number of errors raised (2) reached the maximum allowed (1); resulting in failure. This occurs when the number of errors reaches the number specified in MaximumErrorCount. Change the MaximumErrorCount or fix the errors.
-- SSIS package ... finished: Failure.

-- 6

-- w przypadku 5b, zaimplementowano Typ 1 (Lastname, update rekordu) oraz Typ 2 (Title, dodanie nowego rekordu)
-- dla 5c zaimplementowano typ 0, poniewa¿ nie dosz³o do zmian z racji na erorr

-- 7
-- w kwerendzie 5c error by³ spowodowany przez FailOnFixedAttributeChange property is set to TRUE, poniewa¿ staramy siê zmieniæ Fixed attribute jakim jest FIRSTNAME