# DataProcessing.ps1
# Example script demonstrating data processing capabilities
# Author: Jeremiah Ellington
# Description: Comprehensive data processing example using PowerShell CLI tools

# Import required modules
Import-Module .\Modules\DataTools\DataTools.psm1 -Force

Write-Host "=== DATA PROCESSING EXAMPLE ===" -ForegroundColor Cyan
Write-Host "This example demonstrates comprehensive data processing capabilities" -ForegroundColor Green
Write-Host ""

# 1. Create sample CSV data
Write-Host "1. Creating Sample Data..." -ForegroundColor Yellow
$sampleData = @(
    @{ Name = "John Doe"; Age = 30; Salary = 50000; Department = "IT" },
    @{ Name = "Jane Smith"; Age = 25; Salary = 45000; Department = "HR" },
    @{ Name = "Bob Johnson"; Age = 35; Salary = 60000; Department = "IT" },
    @{ Name = "Alice Brown"; Age = 28; Salary = 55000; Department = "Finance" },
    @{ Name = "Charlie Wilson"; Age = 32; Salary = 52000; Department = "IT" },
    @{ Name = "Diana Davis"; Age = 29; Salary = 48000; Department = "HR" },
    @{ Name = "Eve Miller"; Age = 31; Salary = 58000; Department = "Finance" },
    @{ Name = "Frank Garcia"; Age = 27; Salary = 47000; Department = "IT" },
    @{ Name = "Grace Lee"; Age = 33; Salary = 62000; Department = "Finance" },
    @{ Name = "Henry Taylor"; Age = 26; Salary = 43000; Department = "HR" }
)

$csvPath = "C:\Temp\SampleData.csv"
$sampleData | Export-Csv -Path $csvPath -NoTypeInformation
Write-Host "Sample CSV data created: $csvPath" -ForegroundColor Green
Write-Host ""

# 2. Convert CSV to JSON
Write-Host "2. Converting CSV to JSON..." -ForegroundColor Yellow
$jsonPath = "C:\Temp\SampleData.json"
Convert-CsvToJson -Path $csvPath -OutputPath $jsonPath -PrettyPrint
Write-Host "CSV converted to JSON: $jsonPath" -ForegroundColor Green
Write-Host ""

# 3. Format JSON data
Write-Host "3. Formatting JSON Data..." -ForegroundColor Yellow
$formattedJsonPath = "C:\Temp\FormattedData.json"
Format-JsonData -Path $jsonPath -OutputPath $formattedJsonPath -Indent 4
Write-Host "JSON data formatted: $formattedJsonPath" -ForegroundColor Green
Write-Host ""

# 4. Analyze data statistics
Write-Host "4. Analyzing Data Statistics..." -ForegroundColor Yellow
$salaryData = $sampleData | ForEach-Object { $_.Salary }
$stats = Get-DataStatistics -Data $salaryData -Detailed
Write-Host "Data statistics calculated successfully!" -ForegroundColor Green
Write-Host ""

# 5. Test data integrity
Write-Host "5. Testing Data Integrity..." -ForegroundColor Yellow
$integrityReport = Test-DataIntegrity -Path $csvPath -Detailed
Write-Host "Data integrity test completed!" -ForegroundColor Green
Write-Host ""

# 6. Generate data report
Write-Host "6. Generating Data Report..." -ForegroundColor Yellow
$reportPath = "C:\Temp\DataReport.html"
Export-DataReport -InputPath $csvPath -OutputPath $reportPath -Format "HTML" -IncludeCharts
Write-Host "Data report generated: $reportPath" -ForegroundColor Green
Write-Host ""

# 7. Create data backup
Write-Host "7. Creating Data Backup..." -ForegroundColor Yellow
$backupPath = Backup-Data -Path $csvPath -Compress -Versioned -MaxVersions 3
Write-Host "Data backup created: $backupPath" -ForegroundColor Green
Write-Host ""

# 8. Parse XML data (create sample XML)
Write-Host "8. Parsing XML Data..." -ForegroundColor Yellow
$xmlData = @"
<?xml version="1.0" encoding="UTF-8"?>
<employees>
    <employee id="1">
        <name>John Doe</name>
        <age>30</age>
        <salary>50000</salary>
        <department>IT</department>
    </employee>
    <employee id="2">
        <name>Jane Smith</name>
        <age>25</age>
        <salary>45000</salary>
        <department>HR</department>
    </employee>
</employees>
"@

$xmlPath = "C:\Temp\SampleData.xml"
$xmlData | Out-File -FilePath $xmlPath -Encoding UTF8
$xmlResult = Parse-XmlData -Path $xmlPath -XPath "//employee" -ConvertToJson
Write-Host "XML data parsed successfully!" -ForegroundColor Green
Write-Host ""

# 9. Demonstrate data filtering and sorting
Write-Host "9. Demonstrating Data Operations..." -ForegroundColor Yellow
Write-Host "Filtering IT department employees:" -ForegroundColor White
$itEmployees = $sampleData | Where-Object { $_.Department -eq "IT" }
$itEmployees | ForEach-Object { Write-Host "  $($_.Name) - $($_.Salary)" -ForegroundColor Gray }

Write-Host "`nSorting by salary (descending):" -ForegroundColor White
$sortedBySalary = $sampleData | Sort-Object Salary -Descending
$sortedBySalary | Select-Object -First 5 | ForEach-Object { Write-Host "  $($_.Name) - $($_.Salary)" -ForegroundColor Gray }
Write-Host ""

# 10. Generate comprehensive data analysis report
Write-Host "10. Generating Comprehensive Analysis..." -ForegroundColor Yellow
$analysisReport = @{
    CollectionTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    DataSource = $csvPath
    RecordCount = $sampleData.Count
    Statistics = $stats
    IntegrityReport = $integrityReport
    DepartmentBreakdown = $sampleData | Group-Object Department | ForEach-Object { @{ Department = $_.Name; Count = $_.Count; AvgSalary = [math]::Round(($_.Group | Measure-Object Salary -Average).Average, 2) } }
    AgeAnalysis = @{
        MinAge = ($sampleData | Measure-Object Age -Minimum).Minimum
        MaxAge = ($sampleData | Measure-Object Age -Maximum).Maximum
        AvgAge = [math]::Round(($sampleData | Measure-Object Age -Average).Average, 2)
    }
    SalaryAnalysis = @{
        MinSalary = ($sampleData | Measure-Object Salary -Minimum).Minimum
        MaxSalary = ($sampleData | Measure-Object Salary -Maximum).Maximum
        AvgSalary = [math]::Round(($sampleData | Measure-Object Salary -Average).Average, 2)
    }
}

$analysisPath = "C:\Temp\DataAnalysisReport.json"
$analysisReport | ConvertTo-Json -Depth 10 | Out-File -FilePath $analysisPath -Encoding UTF8
Write-Host "Comprehensive analysis report generated: $analysisPath" -ForegroundColor Green
Write-Host ""

# Display summary
Write-Host "=== DATA PROCESSING SUMMARY ===" -ForegroundColor Cyan
Write-Host "Total Records Processed: $($sampleData.Count)" -ForegroundColor White
Write-Host "Departments: $($analysisReport.DepartmentBreakdown.Count)" -ForegroundColor White
Write-Host "Average Age: $($analysisReport.AgeAnalysis.AvgAge)" -ForegroundColor White
Write-Host "Average Salary: $($analysisReport.SalaryAnalysis.AvgSalary)" -ForegroundColor White
Write-Host "Data Integrity: $(if ($integrityReport.IsValid) { 'Valid' } else { 'Issues Found' })" -ForegroundColor $(if ($integrityReport.IsValid) { 'Green' } else { 'Red' })
Write-Host ""

Write-Host "=== PROCESSING COMPLETE ===" -ForegroundColor Cyan
Write-Host "Data processing example completed successfully!" -ForegroundColor Green
Write-Host "Check the generated files for detailed results:" -ForegroundColor Yellow
Write-Host "  - CSV: $csvPath" -ForegroundColor Gray
Write-Host "  - JSON: $jsonPath" -ForegroundColor Gray
Write-Host "  - Formatted JSON: $formattedJsonPath" -ForegroundColor Gray
Write-Host "  - XML: $xmlPath" -ForegroundColor Gray
Write-Host "  - Report: $reportPath" -ForegroundColor Gray
Write-Host "  - Analysis: $analysisPath" -ForegroundColor Gray
Write-Host "  - Backup: $backupPath" -ForegroundColor Gray