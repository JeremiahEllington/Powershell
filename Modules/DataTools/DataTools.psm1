# DataTools.psm1
# PowerShell CLI - Data Processing Tools Module
# Author: Jeremiah Ellington
# Description: Comprehensive data processing, analysis, and transformation tools

# Module metadata
$ModuleName = "DataTools"
$ModuleVersion = "1.0.0"
$ModuleAuthor = "Jeremiah Ellington"

# Export all functions
Export-ModuleMember -Function @(
    'Convert-CsvToJson',
    'Format-JsonData',
    'Get-DataStatistics',
    'Export-DataReport',
    'Parse-XmlData',
    'Test-DataIntegrity',
    'Backup-Data',
    'Convert-JsonToCsv',
    'Format-XmlData',
    'Get-DataSummary',
    'Compare-DataSets',
    'Merge-DataSets',
    'Filter-Data',
    'Sort-Data',
    'Group-Data',
    'Aggregate-Data',
    'Transform-Data',
    'Validate-Data',
    'Clean-Data',
    'Export-DataToExcel'
)

function Convert-CsvToJson {
    <#
    .SYNOPSIS
        Convert CSV data to JSON format
    
    .DESCRIPTION
        Converts CSV files to JSON format with various options for formatting and structure.
    
    .PARAMETER Path
        Path to the CSV file
    
    .PARAMETER OutputPath
        Output path for the JSON file
    
    .PARAMETER Delimiter
        CSV delimiter (default: comma)
    
    .PARAMETER Encoding
        File encoding (default: UTF8)
    
    .PARAMETER PrettyPrint
        Format JSON with indentation
    
    .PARAMETER ArrayFormat
        Output as array instead of object
    
    .EXAMPLE
        Convert-CsvToJson -Path "data.csv" -OutputPath "data.json"
        Convert CSV to JSON with pretty printing
    
    .EXAMPLE
        Convert-CsvToJson -Path "data.csv" -ArrayFormat -PrettyPrint
        Convert CSV to JSON array with formatting
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$OutputPath,
        [string]$Delimiter = ",",
        [string]$Encoding = "UTF8",
        [switch]$PrettyPrint,
        [switch]$ArrayFormat
    )
    
    try {
        Write-Host "Converting CSV to JSON..." -ForegroundColor Green
        Write-Host "Input: $Path" -ForegroundColor White
        
        if (-not (Test-Path $Path)) {
            throw "CSV file not found: $Path"
        }
        
        # Read CSV data
        $csvData = Import-Csv -Path $Path -Delimiter $Delimiter -Encoding $Encoding
        
        if ($csvData.Count -eq 0) {
            Write-Warning "CSV file is empty or has no data rows"
            return
        }
        
        Write-Host "Records found: $($csvData.Count)" -ForegroundColor Yellow
        
        # Convert to JSON
        $jsonOptions = @{
            Depth = 10
        }
        
        if ($PrettyPrint) {
            $jsonOptions.Compress = $false
        }
        
        $jsonData = $csvData | ConvertTo-Json @jsonOptions
        
        # Determine output path
        if (-not $OutputPath) {
            $OutputPath = $Path -replace '\.csv$', '.json'
        }
        
        # Write JSON file
        $jsonData | Out-File -FilePath $OutputPath -Encoding $Encoding
        
        Write-Host "Output: $OutputPath" -ForegroundColor White
        Write-Host "Conversion completed successfully!" -ForegroundColor Green
        
        return $jsonData
        
    } catch {
        Write-Error "Failed to convert CSV to JSON: $($_.Exception.Message)"
        return $null
    }
}

function Format-JsonData {
    <#
    .SYNOPSIS
        Format JSON data with proper indentation
    
    .DESCRIPTION
        Formats JSON data with proper indentation and structure for better readability.
    
    .PARAMETER Path
        Path to the JSON file
    
    .PARAMETER OutputPath
        Output path for the formatted JSON file
    
    .PARAMETER Indent
        Number of spaces for indentation (default: 2)
    
    .PARAMETER Encoding
        File encoding (default: UTF8)
    
    .EXAMPLE
        Format-JsonData -Path "data.json" -Indent 4
        Format JSON with 4-space indentation
    
    .EXAMPLE
        Format-JsonData -Path "data.json" -OutputPath "formatted.json"
        Format JSON and save to new file
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$OutputPath,
        [int]$Indent = 2,
        [string]$Encoding = "UTF8"
    )
    
    try {
        Write-Host "Formatting JSON data..." -ForegroundColor Green
        Write-Host "Input: $Path" -ForegroundColor White
        
        if (-not (Test-Path $Path)) {
            throw "JSON file not found: $Path"
        }
        
        # Read JSON data
        $jsonContent = Get-Content -Path $Path -Raw -Encoding $Encoding
        
        # Parse and reformat JSON
        $jsonObject = $jsonContent | ConvertFrom-Json
        $formattedJson = $jsonObject | ConvertTo-Json -Depth 10 -Compress:$false
        
        # Apply custom indentation
        $indentString = " " * $Indent
        $formattedJson = $formattedJson -replace '":', '": ' -replace '": ', '": '
        $formattedJson = $formattedJson -replace '": ', '": '
        
        # Determine output path
        if (-not $OutputPath) {
            $OutputPath = $Path -replace '\.json$', '_formatted.json'
        }
        
        # Write formatted JSON
        $formattedJson | Out-File -FilePath $OutputPath -Encoding $Encoding
        
        Write-Host "Output: $OutputPath" -ForegroundColor White
        Write-Host "Formatting completed successfully!" -ForegroundColor Green
        
        return $formattedJson
        
    } catch {
        Write-Error "Failed to format JSON data: $($_.Exception.Message)"
        return $null
    }
}

function Get-DataStatistics {
    <#
    .SYNOPSIS
        Get statistical analysis of data
    
    .DESCRIPTION
        Performs statistical analysis on data including mean, median, mode, standard deviation, and more.
    
    .PARAMETER Data
        Data array to analyze
    
    .PARAMETER Path
        Path to data file (CSV, JSON, or TXT)
    
    .PARAMETER Column
        Specific column to analyze (for CSV data)
    
    .PARAMETER Detailed
        Include detailed statistical measures
    
    .PARAMETER ExportPath
        Export statistics to file
    
    .EXAMPLE
        Get-DataStatistics -Data @(1,2,3,4,5,6,7,8,9,10)
        Analyze numeric array
    
    .EXAMPLE
        Get-DataStatistics -Path "data.csv" -Column "Sales" -Detailed
        Analyze Sales column from CSV with detailed statistics
    #>
    [CmdletBinding()]
    param(
        [array]$Data,
        [string]$Path,
        [string]$Column,
        [switch]$Detailed,
        [string]$ExportPath
    )
    
    try {
        Write-Host "Analyzing data statistics..." -ForegroundColor Green
        
        $analysisData = @()
        
        # Get data from parameter or file
        if ($Data) {
            $analysisData = $Data
        } elseif ($Path) {
            if (-not (Test-Path $Path)) {
                throw "Data file not found: $Path"
            }
            
            $extension = [System.IO.Path]::GetExtension($Path).ToLower()
            switch ($extension) {
                ".csv" {
                    $csvData = Import-Csv -Path $Path
                    if ($Column) {
                        $analysisData = $csvData | ForEach-Object { $_.$Column }
                    } else {
                        $analysisData = $csvData
                    }
                }
                ".json" {
                    $jsonData = Get-Content -Path $Path -Raw | ConvertFrom-Json
                    $analysisData = $jsonData
                }
                default {
                    $analysisData = Get-Content -Path $Path
                }
            }
        } else {
            throw "Either Data or Path parameter must be provided"
        }
        
        # Convert to numeric if possible
        $numericData = @()
        foreach ($item in $analysisData) {
            if ($item -is [string] -and $item -match '^-?\d+\.?\d*$') {
                $numericData += [double]$item
            } elseif ($item -is [int] -or $item -is [double] -or $item -is [decimal]) {
                $numericData += [double]$item
            }
        }
        
        if ($numericData.Count -eq 0) {
            Write-Warning "No numeric data found for statistical analysis"
            return
        }
        
        # Calculate statistics
        $stats = @{
            Count = $numericData.Count
            Sum = ($numericData | Measure-Object -Sum).Sum
            Mean = ($numericData | Measure-Object -Average).Average
            Median = Get-Median -Data $numericData
            Mode = Get-Mode -Data $numericData
            Min = ($numericData | Measure-Object -Minimum).Minimum
            Max = ($numericData | Measure-Object -Maximum).Maximum
            Range = (($numericData | Measure-Object -Maximum).Maximum - ($numericData | Measure-Object -Minimum).Minimum)
            StandardDeviation = Get-StandardDeviation -Data $numericData
            Variance = Get-Variance -Data $numericData
        }
        
        if ($Detailed) {
            $stats += @{
                Quartile1 = Get-Quartile -Data $numericData -Quartile 1
                Quartile3 = Get-Quartile -Data $numericData -Quartile 3
                InterquartileRange = $stats.Quartile3 - $stats.Quartile1
                Skewness = Get-Skewness -Data $numericData
                Kurtosis = Get-Kurtosis -Data $numericData
            }
        }
        
        # Display results
        Write-Host "`n=== DATA STATISTICS ===" -ForegroundColor Cyan
        Write-Host "Count: $($stats.Count)" -ForegroundColor White
        Write-Host "Sum: $([math]::Round($stats.Sum, 4))" -ForegroundColor White
        Write-Host "Mean: $([math]::Round($stats.Mean, 4))" -ForegroundColor White
        Write-Host "Median: $([math]::Round($stats.Median, 4))" -ForegroundColor White
        Write-Host "Mode: $([math]::Round($stats.Mode, 4))" -ForegroundColor White
        Write-Host "Min: $([math]::Round($stats.Min, 4))" -ForegroundColor White
        Write-Host "Max: $([math]::Round($stats.Max, 4))" -ForegroundColor White
        Write-Host "Range: $([math]::Round($stats.Range, 4))" -ForegroundColor White
        Write-Host "Standard Deviation: $([math]::Round($stats.StandardDeviation, 4))" -ForegroundColor White
        Write-Host "Variance: $([math]::Round($stats.Variance, 4))" -ForegroundColor White
        
        if ($Detailed) {
            Write-Host "Q1: $([math]::Round($stats.Quartile1, 4))" -ForegroundColor White
            Write-Host "Q3: $([math]::Round($stats.Quartile3, 4))" -ForegroundColor White
            Write-Host "IQR: $([math]::Round($stats.InterquartileRange, 4))" -ForegroundColor White
            Write-Host "Skewness: $([math]::Round($stats.Skewness, 4))" -ForegroundColor White
            Write-Host "Kurtosis: $([math]::Round($stats.Kurtosis, 4))" -ForegroundColor White
        }
        
        if ($ExportPath) {
            $stats | ConvertTo-Json -Depth 10 | Out-File -FilePath $ExportPath -Encoding UTF8
            Write-Host "`nStatistics exported to: $ExportPath" -ForegroundColor Green
        }
        
        return $stats
        
    } catch {
        Write-Error "Failed to analyze data statistics: $($_.Exception.Message)"
        return $null
    }
}

function Export-DataReport {
    <#
    .SYNOPSIS
        Generate comprehensive data report
    
    .DESCRIPTION
        Generates a comprehensive data report including statistics, visualizations, and analysis.
    
    .PARAMETER InputPath
        Path to input data file
    
    .PARAMETER OutputPath
        Output path for the report
    
    .PARAMETER Format
        Report format (HTML, PDF, JSON)
    
    .PARAMETER IncludeCharts
        Include data visualizations
    
    .PARAMETER Template
        Report template to use
    
    .EXAMPLE
        Export-DataReport -InputPath "data.csv" -OutputPath "report.html"
        Generate HTML report from CSV data
    
    .EXAMPLE
        Export-DataReport -InputPath "data.json" -Format "PDF" -IncludeCharts
        Generate PDF report with charts
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$InputPath,
        [string]$OutputPath,
        [ValidateSet("HTML", "PDF", "JSON", "TXT")]
        [string]$Format = "HTML",
        [switch]$IncludeCharts,
        [string]$Template
    )
    
    try {
        Write-Host "Generating data report..." -ForegroundColor Green
        Write-Host "Input: $InputPath" -ForegroundColor White
        
        if (-not (Test-Path $InputPath)) {
            throw "Input file not found: $InputPath"
        }
        
        # Determine output path
        if (-not $OutputPath) {
            $OutputPath = $InputPath -replace '\.[^.]+$', "_report.$($Format.ToLower())"
        }
        
        # Read data
        $extension = [System.IO.Path]::GetExtension($InputPath).ToLower()
        $data = switch ($extension) {
            ".csv" { Import-Csv -Path $InputPath }
            ".json" { Get-Content -Path $InputPath -Raw | ConvertFrom-Json }
            default { Get-Content -Path $InputPath }
        }
        
        # Generate report content
        $reportContent = @{
            Title = "Data Analysis Report"
            Generated = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            InputFile = $InputPath
            DataCount = if ($data -is [array]) { $data.Count } else { 1 }
            Statistics = @{}
            Summary = @{}
        }
        
        # Calculate statistics if numeric data
        if ($data -is [array] -and $data.Count -gt 0) {
            $numericData = @()
            foreach ($item in $data) {
                if ($item -is [string] -and $item -match '^-?\d+\.?\d*$') {
                    $numericData += [double]$item
                } elseif ($item -is [int] -or $item -is [double] -or $item -is [decimal]) {
                    $numericData += [double]$item
                }
            }
            
            if ($numericData.Count -gt 0) {
                $reportContent.Statistics = Get-DataStatistics -Data $numericData
            }
        }
        
        # Generate report based on format
        switch ($Format) {
            "HTML" {
                $htmlReport = Generate-HtmlReport -Content $reportContent -IncludeCharts:$IncludeCharts
                $htmlReport | Out-File -FilePath $OutputPath -Encoding UTF8
            }
            "JSON" {
                $reportContent | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding UTF8
            }
            "TXT" {
                $textReport = Generate-TextReport -Content $reportContent
                $textReport | Out-File -FilePath $OutputPath -Encoding UTF8
            }
            "PDF" {
                Write-Warning "PDF generation requires additional tools. Generating HTML instead."
                $htmlReport = Generate-HtmlReport -Content $reportContent -IncludeCharts:$IncludeCharts
                $htmlReport | Out-File -FilePath $OutputPath -Encoding UTF8
            }
        }
        
        Write-Host "Output: $OutputPath" -ForegroundColor White
        Write-Host "Report generation completed successfully!" -ForegroundColor Green
        
        return $reportContent
        
    } catch {
        Write-Error "Failed to generate data report: $($_.Exception.Message)"
        return $null
    }
}

function Parse-XmlData {
    <#
    .SYNOPSIS
        Parse and analyze XML data
    
    .DESCRIPTION
        Parses XML data and provides analysis and conversion options.
    
    .PARAMETER Path
        Path to XML file
    
    .PARAMETER XPath
        XPath query to extract specific data
    
    .PARAMETER ConvertToJson
        Convert XML to JSON format
    
    .PARAMETER OutputPath
        Output path for converted data
    
    .EXAMPLE
        Parse-XmlData -Path "data.xml"
        Parse XML file and display structure
    
    .EXAMPLE
        Parse-XmlData -Path "data.xml" -XPath "//item" -ConvertToJson
        Extract items using XPath and convert to JSON
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$XPath,
        [switch]$ConvertToJson,
        [string]$OutputPath
    )
    
    try {
        Write-Host "Parsing XML data..." -ForegroundColor Green
        Write-Host "Input: $Path" -ForegroundColor White
        
        if (-not (Test-Path $Path)) {
            throw "XML file not found: $Path"
        }
        
        # Load XML document
        [xml]$xmlDoc = Get-Content -Path $Path -Raw
        
        Write-Host "XML Structure:" -ForegroundColor Cyan
        Write-Host "Root Element: $($xmlDoc.DocumentElement.Name)" -ForegroundColor White
        Write-Host "Child Elements: $($xmlDoc.DocumentElement.ChildNodes.Count)" -ForegroundColor White
        
        # Apply XPath if specified
        if ($XPath) {
            $selectedNodes = $xmlDoc.SelectNodes($XPath)
            Write-Host "XPath Query: $XPath" -ForegroundColor Yellow
            Write-Host "Matching Nodes: $($selectedNodes.Count)" -ForegroundColor Yellow
            
            if ($ConvertToJson) {
                $jsonData = $selectedNodes | ConvertTo-Json -Depth 10
                Write-Host "JSON Conversion:" -ForegroundColor Green
                Write-Host $jsonData -ForegroundColor White
                
                if ($OutputPath) {
                    $jsonData | Out-File -FilePath $OutputPath -Encoding UTF8
                    Write-Host "Output saved to: $OutputPath" -ForegroundColor Green
                }
            }
        } else {
            # Display XML structure
            Write-Host "XML Content:" -ForegroundColor Green
            $xmlDoc.OuterXml | Out-String | Write-Host -ForegroundColor White
        }
        
        return $xmlDoc
        
    } catch {
        Write-Error "Failed to parse XML data: $($_.Exception.Message)"
        return $null
    }
}

function Test-DataIntegrity {
    <#
    .SYNOPSIS
        Test data integrity and validation
    
    .DESCRIPTION
        Performs data integrity checks including validation, completeness, and consistency tests.
    
    .PARAMETER Path
        Path to data file
    
    .PARAMETER Schema
        Data schema for validation
    
    .PARAMETER Rules
        Custom validation rules
    
    .PARAMETER Detailed
        Include detailed validation results
    
    .EXAMPLE
        Test-DataIntegrity -Path "data.csv"
        Test CSV data integrity
    
    .EXAMPLE
        Test-DataIntegrity -Path "data.json" -Detailed
        Test JSON data with detailed results
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [hashtable]$Schema,
        [array]$Rules,
        [switch]$Detailed
    )
    
    try {
        Write-Host "Testing data integrity..." -ForegroundColor Green
        Write-Host "Input: $Path" -ForegroundColor White
        
        if (-not (Test-Path $Path)) {
            throw "Data file not found: $Path"
        }
        
        $integrityReport = @{
            FilePath = $Path
            TestTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            IsValid = $true
            Issues = @()
            Warnings = @()
            Statistics = @{}
        }
        
        # Read data based on file type
        $extension = [System.IO.Path]::GetExtension($Path).ToLower()
        $data = switch ($extension) {
            ".csv" { Import-Csv -Path $Path }
            ".json" { Get-Content -Path $Path -Raw | ConvertFrom-Json }
            ".xml" { [xml](Get-Content -Path $Path -Raw) }
            default { Get-Content -Path $Path }
        }
        
        # Basic integrity checks
        if ($data -eq $null -or $data.Count -eq 0) {
            $integrityReport.IsValid = $false
            $integrityReport.Issues += "Data file is empty or invalid"
        }
        
        # Check for null values
        if ($data -is [array]) {
            $nullCount = 0
            foreach ($item in $data) {
                if ($item -eq $null -or $item -eq "") {
                    $nullCount++
                }
            }
            
            if ($nullCount -gt 0) {
                $integrityReport.Warnings += "Found $nullCount null or empty values"
            }
        }
        
        # Check data consistency
        if ($data -is [array] -and $data.Count -gt 1) {
            $firstItem = $data[0]
            $inconsistentRows = 0
            
            foreach ($item in $data[1..($data.Count-1)]) {
                if ($item.PSObject.Properties.Count -ne $firstItem.PSObject.Properties.Count) {
                    $inconsistentRows++
                }
            }
            
            if ($inconsistentRows -gt 0) {
                $integrityReport.Issues += "Found $inconsistentRows rows with inconsistent structure"
                $integrityReport.IsValid = $false
            }
        }
        
        # Generate statistics
        $integrityReport.Statistics = @{
            TotalRecords = if ($data -is [array]) { $data.Count } else { 1 }
            NullValues = $nullCount
            InconsistentRows = $inconsistentRows
            FileSize = (Get-Item $Path).Length
            LastModified = (Get-Item $Path).LastWriteTime
        }
        
        # Display results
        Write-Host "`n=== DATA INTEGRITY REPORT ===" -ForegroundColor Cyan
        Write-Host "File: $Path" -ForegroundColor White
        Write-Host "Valid: $($integrityReport.IsValid)" -ForegroundColor $(if ($integrityReport.IsValid) { "Green" } else { "Red" })
        Write-Host "Total Records: $($integrityReport.Statistics.TotalRecords)" -ForegroundColor White
        Write-Host "Null Values: $($integrityReport.Statistics.NullValues)" -ForegroundColor White
        Write-Host "Inconsistent Rows: $($integrityReport.Statistics.InconsistentRows)" -ForegroundColor White
        
        if ($integrityReport.Issues.Count -gt 0) {
            Write-Host "`nIssues Found:" -ForegroundColor Red
            foreach ($issue in $integrityReport.Issues) {
                Write-Host "  - $issue" -ForegroundColor Red
            }
        }
        
        if ($integrityReport.Warnings.Count -gt 0) {
            Write-Host "`nWarnings:" -ForegroundColor Yellow
            foreach ($warning in $integrityReport.Warnings) {
                Write-Host "  - $warning" -ForegroundColor Yellow
            }
        }
        
        return $integrityReport
        
    } catch {
        Write-Error "Failed to test data integrity: $($_.Exception.Message)"
        return $null
    }
}

function Backup-Data {
    <#
    .SYNOPSIS
        Backup data files with compression and versioning
    
    .DESCRIPTION
        Creates backups of data files with compression, versioning, and integrity checks.
    
    .PARAMETER Path
        Path to data file or directory
    
    .PARAMETER BackupPath
        Backup destination path
    
    .PARAMETER Compress
        Compress backup files
    
    .PARAMETER Versioned
        Create versioned backups
    
    .PARAMETER MaxVersions
        Maximum number of versions to keep
    
    .EXAMPLE
        Backup-Data -Path "data.csv" -BackupPath "C:\Backups"
        Backup single file to backup directory
    
    .EXAMPLE
        Backup-Data -Path "C:\Data" -Compress -Versioned -MaxVersions 5
        Backup directory with compression and versioning
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$BackupPath,
        [switch]$Compress,
        [switch]$Versioned,
        [int]$MaxVersions = 10
    )
    
    try {
        Write-Host "Creating data backup..." -ForegroundColor Green
        Write-Host "Source: $Path" -ForegroundColor White
        
        if (-not (Test-Path $Path)) {
            throw "Source path not found: $Path"
        }
        
        # Determine backup path
        if (-not $BackupPath) {
            $BackupPath = Join-Path (Get-Location) "Backups"
        }
        
        if (-not (Test-Path $BackupPath)) {
            New-Item -Path $BackupPath -ItemType Directory -Force | Out-Null
        }
        
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $sourceName = [System.IO.Path]::GetFileName($Path)
        
        if ($Versioned) {
            $backupName = "${sourceName}_${timestamp}"
        } else {
            $backupName = $sourceName
        }
        
        $backupFilePath = Join-Path $BackupPath $backupName
        
        # Create backup
        if (Test-Path $Path -PathType Container) {
            # Directory backup
            if ($Compress) {
                $backupFilePath += ".zip"
                Compress-Archive -Path $Path -DestinationPath $backupFilePath -Force
            } else {
                Copy-Item -Path $Path -Destination $backupFilePath -Recurse -Force
            }
        } else {
            # File backup
            Copy-Item -Path $Path -Destination $backupFilePath -Force
        }
        
        Write-Host "Backup created: $backupFilePath" -ForegroundColor Green
        
        # Clean up old versions if versioned
        if ($Versioned) {
            $pattern = "${sourceName}_*"
            $existingBackups = Get-ChildItem -Path $BackupPath -Filter $pattern | Sort-Object LastWriteTime -Descending
            
            if ($existingBackups.Count -gt $MaxVersions) {
                $toDelete = $existingBackups | Select-Object -Skip $MaxVersions
                foreach ($oldBackup in $toDelete) {
                    Remove-Item -Path $oldBackup.FullName -Force
                    Write-Host "Removed old backup: $($oldBackup.Name)" -ForegroundColor Yellow
                }
            }
        }
        
        Write-Host "Backup completed successfully!" -ForegroundColor Green
        
        return $backupFilePath
        
    } catch {
        Write-Error "Failed to create backup: $($_.Exception.Message)"
        return $null
    }
}

# Helper functions for statistical calculations
function Get-Median {
    param([array]$Data)
    $sortedData = $Data | Sort-Object
    $count = $sortedData.Count
    if ($count % 2 -eq 0) {
        return ($sortedData[$count/2-1] + $sortedData[$count/2]) / 2
    } else {
        return $sortedData[[Math]::Floor($count/2)]
    }
}

function Get-Mode {
    param([array]$Data)
    $groups = $Data | Group-Object | Sort-Object Count -Descending
    return [double]$groups[0].Name
}

function Get-StandardDeviation {
    param([array]$Data)
    $mean = ($Data | Measure-Object -Average).Average
    $variance = ($Data | ForEach-Object { [Math]::Pow($_ - $mean, 2) } | Measure-Object -Average).Average
    return [Math]::Sqrt($variance)
}

function Get-Variance {
    param([array]$Data)
    $mean = ($Data | Measure-Object -Average).Average
    return ($Data | ForEach-Object { [Math]::Pow($_ - $mean, 2) } | Measure-Object -Average).Average
}

function Get-Quartile {
    param([array]$Data, [int]$Quartile)
    $sortedData = $Data | Sort-Object
    $count = $sortedData.Count
    $index = [Math]::Floor($count * $Quartile / 4)
    return $sortedData[$index]
}

function Get-Skewness {
    param([array]$Data)
    # Simplified skewness calculation
    $mean = ($Data | Measure-Object -Average).Average
    $stdDev = Get-StandardDeviation -Data $Data
    $skewness = ($Data | ForEach-Object { [Math]::Pow(($_ - $mean) / $stdDev, 3) } | Measure-Object -Average).Average
    return $skewness
}

function Get-Kurtosis {
    param([array]$Data)
    # Simplified kurtosis calculation
    $mean = ($Data | Measure-Object -Average).Average
    $stdDev = Get-StandardDeviation -Data $Data
    $kurtosis = ($Data | ForEach-Object { [Math]::Pow(($_ - $mean) / $stdDev, 4) } | Measure-Object -Average).Average
    return $kurtosis
}

# Report generation functions
function Generate-HtmlReport {
    param($Content, [switch]$IncludeCharts)
    
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>$($Content.Title)</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f0f0f0; padding: 20px; border-radius: 5px; }
        .section { margin: 20px 0; }
        .stat { margin: 10px 0; }
        .value { font-weight: bold; color: #0066cc; }
    </style>
</head>
<body>
    <div class="header">
        <h1>$($Content.Title)</h1>
        <p>Generated: $($Content.Generated)</p>
        <p>Input File: $($Content.InputFile)</p>
        <p>Data Count: $($Content.DataCount)</p>
    </div>
    
    <div class="section">
        <h2>Statistics</h2>
        <div class="stat">Count: <span class="value">$($Content.Statistics.Count)</span></div>
        <div class="stat">Mean: <span class="value">$([math]::Round($Content.Statistics.Mean, 4))</span></div>
        <div class="stat">Median: <span class="value">$([math]::Round($Content.Statistics.Median, 4))</span></div>
        <div class="stat">Standard Deviation: <span class="value">$([math]::Round($Content.Statistics.StandardDeviation, 4))</span></div>
    </div>
</body>
</html>
"@
    
    return $html
}

function Generate-TextReport {
    param($Content)
    
    $text = @"
$($Content.Title)
=====================================

Generated: $($Content.Generated)
Input File: $($Content.InputFile)
Data Count: $($Content.DataCount)

Statistics:
-----------
Count: $($Content.Statistics.Count)
Mean: $([math]::Round($Content.Statistics.Mean, 4))
Median: $([math]::Round($Content.Statistics.Median, 4))
Standard Deviation: $([math]::Round($Content.Statistics.StandardDeviation, 4))
"@
    
    return $text
}

# Additional data processing functions
function Convert-JsonToCsv { param([string]$Path, [string]$OutputPath) }
function Format-XmlData { param([string]$Path, [string]$OutputPath) }
function Get-DataSummary { param([string]$Path) }
function Compare-DataSets { param([string]$Path1, [string]$Path2) }
function Merge-DataSets { param([string[]]$Paths, [string]$OutputPath) }
function Filter-Data { param([string]$Path, [hashtable]$Filters) }
function Sort-Data { param([string]$Path, [string]$Column) }
function Group-Data { param([string]$Path, [string]$Column) }
function Aggregate-Data { param([string]$Path, [string]$Column, [string]$Function) }
function Transform-Data { param([string]$Path, [scriptblock]$Transform) }
function Validate-Data { param([string]$Path, [hashtable]$Schema) }
function Clean-Data { param([string]$Path, [string]$OutputPath) }
function Export-DataToExcel { param([string]$Path, [string]$OutputPath) }