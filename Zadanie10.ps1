# ------------------- CHANGELOG ---------------------
# Script Name: Zadanie10.ps1
# Author: Paweł Dela
# Created: MM/DD/YYYY
# Last Updated: MM/DD/YYYY
# --------------------------------------------------

# ------------------- PARAMETERS -------------------
$INDEX_NUMBER = "408302" # Replace with your index number
$TIMESTAMP = Get-Date -Format "MMddyyyy"
$LOG_FILE = "process_data_${TIMESTAMP}.log"
$FILE_URL = "http://home.agh.edu.pl/~wsarlej/dyd/bdp2/materialy/cw10/InternetSales_new.zip"
$ZIP_ENCODED_PASSWORD = "YmRwMmFnaA=="
$ZIP_PASSWORD = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($ZIP_ENCODED_PASSWORD))

$DB_HOST = "127.0.0.1"
$DB_USER = "root"

$DB_ENCODED_PASS = "TXlTcWxQYXNzMiM="
$DB_PASSWORD = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($DB_ENCODED_PASS))

$DB_NAME = "bazy"
$TABLE_NAME = "CUSTOMERS_${INDEX_NUMBER}"
$CSV_OUTPUT = "${TIMESTAMP}_customers.csv"
$VALID_FILE = "InternetSales_new.txt"

# Ensure required directories
if (-not (Test-Path -Path "TEMP")) {
    mkdir -Path "TEMP"
}
if (-not (Test-Path -Path "PROCESSED")) {
    mkdir -Path "PROCESSED"
}

# Function to log messages
function Log-Message {
    param(
        [string]$Step,
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $logMessage = "$timestamp - $Step - $Message"
    Write-Host $logMessage
    Add-Content -Path $LOG_FILE -Value $logMessage
}

# Load MySql.Data.dll
$mysqlDllPath = "C:\Program Files (x86)\MySQL\MySQL Connector NET 9.1\MySql.Data.dll"
if (-not (Test-Path -Path $mysqlDllPath)) {
    Write-Host "MySql.Data.dll not found at path: $mysqlDllPath"
    exit 1
}
Add-Type -Path $mysqlDllPath

# Step A: Download the file
Log-Message -Step "Step A" -Message "Starting file download."
Invoke-WebRequest -Uri $FILE_URL -OutFile "TEMP/InternetSales_new.zip"
if ($?) {
    Log-Message -Step "Step A" -Message "File downloaded successfully."
} else {
    Log-Message -Step "Step A" -Message "File download failed."
    exit 1
}

# Step B: Unzip the file
Log-Message -Step "Step B" -Message "Unzipping file"
$zipPath = "TEMP/InternetSales_new.zip"
$extractPath = "TEMP"
$7zipPath = "C:\Program Files\7-Zip\7z.exe"

Start-Process -FilePath $7zipPath -ArgumentList "x `"$zipPath`" -o`"$extractPath`" -p$ZIP_PASSWORD" -NoNewWindow -Wait
if ($?) {
    Log-Message -Step "Step B" -Message "File unzipped successfully"
} else {
    Log-Message -Step "Step B" -Message "Unzipping failed."
    exit 1
}

# Step C: Validate and process the file
# Input and Output file paths
$RAW_FILE = "TEMP/InternetSales_new.txt"
$VALIDATED_FILE = "InternetSales_new_cleaned.txt"
$BAD_FILE = "PROCESSED/InternetSales_new.bad_$TIMESTAMP.txt"

Log-Message -Step "Step C" -Message "Validating file."

# Read the header
$HEADER = Get-Content -Path $RAW_FILE -TotalCount 1

# Write the header to validated and bad files
$HEADER | Out-File -FilePath $VALIDATED_FILE
$HEADER | Out-File -FilePath $BAD_FILE

# Count the number of columns
$HEADER_COL_COUNT = ($HEADER -split '\|').Count

# Initialize a hash table to track duplicates
$SeenLines = @{}

# Validate the file line by line
Get-Content -Path $RAW_FILE | ForEach-Object {
    $Line = $_

    # Skip header
    if ($Line -eq $HEADER) { return }

    # Skip duplicate rows
    if ($SeenLines.ContainsKey($Line)) { return }
    $SeenLines[$Line] = $true

    # Skip empty rows
    if ([string]::IsNullOrWhiteSpace($Line)) { return }

    # Split the line into fields
    $Fields = $Line -split '\|'

    # Check column count
    if ($Fields.Count -ne $HEADER_COL_COUNT) {
        $Fields[7] = "" # Clear SecretCode if exists
        ($Fields -join '|') | Out-File -FilePath $BAD_FILE -Append
        return
    }

    # Check OrderQuantity <= 100
    if ([int]$Fields[4] -gt 100) {
        $Fields[7] = "" # Clear SecretCode if exists
        ($Fields -join '|') | Out-File -FilePath $BAD_FILE -Append
        return
    }

    # Check if SecretCode is not empty
    if (-not [string]::IsNullOrWhiteSpace($Fields[7])) {
        $Fields[7] = "" # Clear SecretCode if exists
        ($Fields -join '|') | Out-File -FilePath $BAD_FILE -Append
        return
    }

    # Check last name and first name format
    $CustomerName = $Fields[2] -replace '"', ''
    $NameParts = $CustomerName -split ','
    if ($NameParts.Count -ne 2 -or [string]::IsNullOrWhiteSpace($NameParts[0]) -or [string]::IsNullOrWhiteSpace($NameParts[1])) {
        $Fields[7] = "" # Clear SecretCode if exists
        ($Fields -join '|') | Out-File -FilePath $BAD_FILE -Append
        return
    }

    # Reformat first and last name
    $FirstName = $NameParts[1].Trim()
    $LastName = $NameParts[0].Trim()
    $Fields[2] = "$FirstName|$LastName"

    # Save into validated file
    ($Fields -join '|') | Out-File -FilePath $VALIDATED_FILE -Append
}

# Check exit status
if ($?) {
    Log-Message -Step "Step C" -Message "File validated successfully."
} else {
    Log-Message -Step "Step C" -Message "File validation failed."
}

# Step D: Create database table
Log-Message -Step "Step D" -Message "Creating database table."

$connection = New-Object MySql.Data.MySqlClient.MySqlConnection
$connection.ConnectionString = "Server=$DB_HOST;Database=$DB_NAME;Uid=$DB_USER;Pwd=$DB_PASSWORD;"

try {
    $connection.Open()
    $query = @"
DROP TABLE IF EXISTS `customers_408302`;
CREATE TABLE `customers_408302` (
    ProductKey VARCHAR(100),
    CurrencyAlternateKey VARCHAR(100),
    FIRST_NAME VARCHAR(100),
    LAST_NAME VARCHAR(100),
    OrderDateKey VARCHAR(100),
    OrderQuantity INT,
    UnitPrice VARCHAR(100),
    SecretCode VARCHAR(255)
);
"@
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $command.ExecuteNonQuery()
    Log-Message -Step "Step D" -Message "Table created successfully."
} catch {
    Log-Message -Step "Step D" -Message "Table creation failed: $_"
} finally {
    $connection.Close()
}

# Step E: Load data into database
Log-Message -Step "Step E" -Message "Loading data into database."

try {
    $connection.Open()
    $validData = Import-Csv -Path $VALIDATED_FILE -Delimiter "|"
foreach ($row in $validData) {
    # Przygotowanie danych
    $row
    $ProductKey = [MySql.Data.MySqlClient.MySqlHelper]::EscapeString($row.ProductKey)
    $CurrencyAlternateKey = [MySql.Data.MySqlClient.MySqlHelper]::EscapeString($row.CurrencyAlternateKey)
    $FirstName = [MySql.Data.MySqlClient.MySqlHelper]::EscapeString($row.Customer_Name)
    $LastName = [MySql.Data.MySqlClient.MySqlHelper]::EscapeString($row.OrderDateKey)
    $OrderDateKey = [MySql.Data.MySqlClient.MySqlHelper]::EscapeString($row.OrderQuantity)
    $OrderQuantity = [int]$row.UnitPrice
    $UnitPrice = [MySql.Data.MySqlClient.MySqlHelper]::EscapeString($row.SecretCode)
    $SecretCode = "0"

    # Budowanie zapytania
    $query = @"
INSERT INTO `customers_408302` (ProductKey,CurrencyAlternateKey, FIRST_NAME, LAST_NAME,OrderDateKey, OrderQuantity,UnitPrice, SecretCode)
VALUES ('$ProductKey', '$CurrencyAlternateKey', '$FirstName', '$LastName','$OrderDateKey', $OrderQuantity,'$UnitPrice', '$SecretCode');
"@

    # Wykonanie zapytania
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $command.ExecuteNonQuery()
}
    Log-Message -Step "Step E" -Message "Data loaded successfully."
} catch {
    Log-Message -Step "Step E" -Message "Data loading failed: $_"
} finally {
    $connection.Close()
}

# Step F: Archive processed file
Log-Message -Step "Step F" -Message "Archiving processed file."
Move-Item -Path "$VALIDATED_FILE" -Destination "PROCESSED/${TIMESTAMP}_InternetSales_new_cleaned.txt"
if ($?) {
    Log-Message -Step "Step F" -Message "File archived successfully."
} else {
    Log-Message -Step "Step F" -Message "Archiving failed."
}

# Step G: Update SecretCode with random values
Log-Message -Step "Step G" -Message "Updating SecretCode with random values."

try {
    $connection.Open()
    $query = "UPDATE `customers_408302` SET SecretCode = SUBSTRING(MD5(RAND()), 1, 10);"
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $command.ExecuteNonQuery()
    Log-Message -Step "Step G" -Message "SecretCode updated successfully."
} catch {
    Log-Message -Step "Step G" -Message "SecretCode update failed: $_"
} finally {
    $connection.Close()
}

# Step H: Export table to CSV
Log-Message -Step "Step H" -Message "Exporting table to CSV."

try {
    $connection.Open()
    $query = "SELECT * FROM `customers_408302`;"
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $reader = $command.ExecuteReader()
    $dataTable = New-Object System.Data.DataTable
    $dataTable.Load($reader)
    $dataTable | Export-Csv -Path $CSV_OUTPUT -NoTypeInformation
    Log-Message -Step "Step H" -Message "CSV exported successfully."
} catch {
    Log-Message -Step "Step H" -Message "CSV export failed: $_"
} finally {
    $connection.Close()
}

# Step I: Compress CSV file
Log-Message -Step "Step I" -Message "Compressing file"
$csvFilePath = "$CSV_OUTPUT" 
$zipOutputPath = "$csvFilePath.zip" 
$7zipPath = "C:\Program Files\7-Zip\7z.exe"  

Start-Process -FilePath $7zipPath -ArgumentList "a `"$zipOutputPath`" `"$csvFilePath`"" -NoNewWindow -Wait

if ($?) {
    Log-Message -Step "Step I" -Message "File compressed successfully"
} else {
    Log-Message -Step "Step I" -Message "Compression failed."
    exit 1
}

# Completion
Log-Message -Step "Complete" -Message "All steps completed successfully."
Write-Host "Script completed. Check $LOG_FILE for details."
