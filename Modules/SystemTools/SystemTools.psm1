# SystemTools.psm1
# PowerShell CLI - System Administration Tools Module
# Author: Jeremiah Ellington
# Description: Comprehensive system administration and monitoring tools

# Module metadata
$ModuleName = "SystemTools"
$ModuleVersion = "1.0.0"
$ModuleAuthor = "Jeremiah Ellington"

# Export all functions
Export-ModuleMember -Function @(
    'Get-SystemInfo',
    'Get-ProcessInfo', 
    'Get-DiskUsage',
    'Get-ServiceStatus',
    'Get-EventLogs',
    'Get-PerformanceMetrics',
    'Test-SystemHealth',
    'Get-InstalledSoftware',
    'Get-SystemUpdates',
    'Get-UserAccounts',
    'Get-StartupPrograms',
    'Get-SystemDrivers',
    'Get-NetworkAdapters',
    'Get-SystemBios',
    'Get-MemoryInfo',
    'Get-CpuInfo',
    'Get-GpuInfo',
    'Get-MotherboardInfo',
    'Get-PowerInfo',
    'Get-TemperatureInfo'
)

function Get-SystemInfo {
    <#
    .SYNOPSIS
        Get comprehensive system information
    
    .DESCRIPTION
        Retrieves detailed system information including hardware, software, and configuration details.
    
    .PARAMETER Detailed
        Include detailed hardware and software information
    
    .PARAMETER ExportPath
        Export results to a file
    
    .EXAMPLE
        Get-SystemInfo
        Get basic system information
    
    .EXAMPLE
        Get-SystemInfo -Detailed
        Get detailed system information including hardware specs
    
    .EXAMPLE
        Get-SystemInfo -ExportPath "C:\SystemInfo.json"
        Export system information to JSON file
    #>
    [CmdletBinding()]
    param(
        [switch]$Detailed,
        [string]$ExportPath
    )
    
    try {
        Write-Host "Collecting system information..." -ForegroundColor Green
        
        $systemInfo = @{
            ComputerName = $env:COMPUTERNAME
            UserName = $env:USERNAME
            Domain = $env:USERDOMAIN
            OS = (Get-WmiObject -Class Win32_OperatingSystem).Caption
            OSVersion = (Get-WmiObject -Class Win32_OperatingSystem).Version
            Architecture = (Get-WmiObject -Class Win32_OperatingSystem).OSArchitecture
            InstallDate = (Get-WmiObject -Class Win32_OperatingSystem).InstallDate
            LastBootTime = (Get-WmiObject -Class Win32_OperatingSystem).LastBootUpTime
            TotalMemory = [math]::Round((Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
            Processor = (Get-WmiObject -Class Win32_Processor).Name
            ProcessorCores = (Get-WmiObject -Class Win32_Processor).NumberOfCores
            ProcessorThreads = (Get-WmiObject -Class Win32_Processor).NumberOfLogicalProcessors
            SystemType = (Get-WmiObject -Class Win32_ComputerSystem).SystemType
            Manufacturer = (Get-WmiObject -Class Win32_ComputerSystem).Manufacturer
            Model = (Get-WmiObject -Class Win32_ComputerSystem).Model
            SerialNumber = (Get-WmiObject -Class Win32_ComputerSystem).SerialNumber
            UUID = (Get-WmiObject -Class Win32_ComputerSystem).UUID
            PowerShellVersion = $PSVersionTable.PSVersion.ToString()
            PowerShellEdition = $PSVersionTable.PSEdition
            PowerShellHost = $PSVersionTable.PSCompatibleVersions
            CollectionTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
        
        if ($Detailed) {
            $systemInfo += @{
                Bios = Get-SystemBios
                Memory = Get-MemoryInfo
                CPU = Get-CpuInfo
                GPU = Get-GpuInfo
                Motherboard = Get-MotherboardInfo
                Power = Get-PowerInfo
                Temperature = Get-TemperatureInfo
                NetworkAdapters = Get-NetworkAdapters
                Drivers = Get-SystemDrivers
                Software = Get-InstalledSoftware
                Updates = Get-SystemUpdates
                Users = Get-UserAccounts
                Startup = Get-StartupPrograms
            }
        }
        
        # Display results
        Write-Host "`n=== SYSTEM INFORMATION ===" -ForegroundColor Cyan
        Write-Host "Computer Name: $($systemInfo.ComputerName)" -ForegroundColor White
        Write-Host "User Name: $($systemInfo.UserName)" -ForegroundColor White
        Write-Host "Domain: $($systemInfo.Domain)" -ForegroundColor White
        Write-Host "Operating System: $($systemInfo.OS)" -ForegroundColor White
        Write-Host "OS Version: $($systemInfo.OSVersion)" -ForegroundColor White
        Write-Host "Architecture: $($systemInfo.Architecture)" -ForegroundColor White
        Write-Host "Last Boot: $($systemInfo.LastBootTime)" -ForegroundColor White
        Write-Host "Total Memory: $($systemInfo.TotalMemory) GB" -ForegroundColor White
        Write-Host "Processor: $($systemInfo.Processor)" -ForegroundColor White
        Write-Host "Cores: $($systemInfo.ProcessorCores)" -ForegroundColor White
        Write-Host "Threads: $($systemInfo.ProcessorThreads)" -ForegroundColor White
        Write-Host "Manufacturer: $($systemInfo.Manufacturer)" -ForegroundColor White
        Write-Host "Model: $($systemInfo.Model)" -ForegroundColor White
        Write-Host "PowerShell Version: $($systemInfo.PowerShellVersion)" -ForegroundColor White
        
        if ($ExportPath) {
            $systemInfo | ConvertTo-Json -Depth 10 | Out-File -FilePath $ExportPath -Encoding UTF8
            Write-Host "`nSystem information exported to: $ExportPath" -ForegroundColor Green
        }
        
        return $systemInfo
        
    } catch {
        Write-Error "Failed to collect system information: $($_.Exception.Message)"
        return $null
    }
}

function Get-ProcessInfo {
    <#
    .SYNOPSIS
        Get detailed process information
    
    .DESCRIPTION
        Retrieves comprehensive process information including CPU, memory usage, and performance metrics.
    
    .PARAMETER ProcessName
        Filter by specific process name
    
    .PARAMETER Top
        Show only top N processes by CPU usage
    
    .PARAMETER Continuous
        Continuously monitor processes
    
    .PARAMETER Interval
        Refresh interval in seconds for continuous monitoring
    
    .EXAMPLE
        Get-ProcessInfo
        Get information for all processes
    
    .EXAMPLE
        Get-ProcessInfo -ProcessName "chrome" -Top 10
        Get top 10 Chrome processes by CPU usage
    
    .EXAMPLE
        Get-ProcessInfo -Continuous -Interval 5
        Monitor all processes every 5 seconds
    #>
    [CmdletBinding()]
    param(
        [string]$ProcessName,
        [int]$Top = 20,
        [switch]$Continuous,
        [int]$Interval = 5
    )
    
    try {
        do {
            Clear-Host
            Write-Host "=== PROCESS INFORMATION ===" -ForegroundColor Cyan
            Write-Host "Collection Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Green
            Write-Host ""
            
            $processes = Get-Process | Where-Object {
                if ($ProcessName) {
                    $_.ProcessName -like "*$ProcessName*"
                } else {
                    $true
                }
            } | Sort-Object CPU -Descending | Select-Object -First $Top
            
            $processes | ForEach-Object {
                $cpuPercent = [math]::Round(($_.CPU / 100), 2)
                $memoryMB = [math]::Round($_.WorkingSet / 1MB, 2)
                
                Write-Host "Process: $($_.ProcessName)" -ForegroundColor White
                Write-Host "  PID: $($_.Id)" -ForegroundColor Gray
                Write-Host "  CPU: $cpuPercent seconds" -ForegroundColor Yellow
                Write-Host "  Memory: $memoryMB MB" -ForegroundColor Yellow
                Write-Host "  Start Time: $($_.StartTime)" -ForegroundColor Gray
                Write-Host "  Threads: $($_.Threads.Count)" -ForegroundColor Gray
                Write-Host "  Handles: $($_.HandleCount)" -ForegroundColor Gray
                Write-Host ""
            }
            
            if ($Continuous) {
                Write-Host "Press Ctrl+C to stop monitoring..." -ForegroundColor Red
                Start-Sleep -Seconds $Interval
            }
            
        } while ($Continuous)
        
    } catch {
        Write-Error "Failed to get process information: $($_.Exception.Message)"
    }
}

function Get-DiskUsage {
    <#
    .SYNOPSIS
        Get disk usage information and analysis
    
    .DESCRIPTION
        Analyzes disk usage across all drives and provides detailed statistics.
    
    .PARAMETER Drive
        Specific drive to analyze (e.g., C:, D:)
    
    .PARAMETER Threshold
        Alert threshold percentage for disk usage
    
    .PARAMETER Alert
        Show alerts for drives above threshold
    
    .PARAMETER Detailed
        Include detailed file and folder analysis
    
    .EXAMPLE
        Get-DiskUsage
        Get disk usage for all drives
    
    .EXAMPLE
        Get-DiskUsage -Drive "C:" -Threshold 80 -Alert
        Check C: drive with alerts if usage > 80%
    
    .EXAMPLE
        Get-DiskUsage -Detailed
        Get detailed disk usage analysis
    #>
    [CmdletBinding()]
    param(
        [string]$Drive,
        [int]$Threshold = 85,
        [switch]$Alert,
        [switch]$Detailed
    )
    
    try {
        Write-Host "=== DISK USAGE ANALYSIS ===" -ForegroundColor Cyan
        Write-Host ""
        
        $drives = if ($Drive) { @($Drive) } else { Get-WmiObject -Class Win32_LogicalDisk }
        
        foreach ($disk in $drives) {
            $driveLetter = if ($Drive) { $Drive } else { $disk.DeviceID }
            $totalSize = [math]::Round($disk.Size / 1GB, 2)
            $freeSpace = [math]::Round($disk.FreeSpace / 1GB, 2)
            $usedSpace = $totalSize - $freeSpace
            $usagePercent = [math]::Round(($usedSpace / $totalSize) * 100, 2)
            
            $status = if ($usagePercent -gt $Threshold) { "WARNING" } else { "OK" }
            $color = if ($usagePercent -gt $Threshold) { "Red" } else { "Green" }
            
            Write-Host "Drive: $driveLetter" -ForegroundColor White
            Write-Host "  Total Size: $totalSize GB" -ForegroundColor Gray
            Write-Host "  Used Space: $usedSpace GB" -ForegroundColor Gray
            Write-Host "  Free Space: $freeSpace GB" -ForegroundColor Gray
            Write-Host "  Usage: $usagePercent%" -ForegroundColor $color
            Write-Host "  Status: $status" -ForegroundColor $color
            Write-Host ""
            
            if ($Alert -and $usagePercent -gt $Threshold) {
                Write-Warning "ALERT: Drive $driveLetter is $usagePercent% full (threshold: $Threshold%)"
            }
        }
        
        if ($Detailed) {
            Write-Host "=== DETAILED ANALYSIS ===" -ForegroundColor Cyan
            # Add detailed folder analysis here
            Write-Host "Detailed analysis feature coming soon..." -ForegroundColor Yellow
        }
        
    } catch {
        Write-Error "Failed to get disk usage information: $($_.Exception.Message)"
    }
}

function Get-ServiceStatus {
    <#
    .SYNOPSIS
        Get service status and management information
    
    .DESCRIPTION
        Retrieves service status, configuration, and management information.
    
    .PARAMETER ServiceName
        Specific service name to check
    
    .PARAMETER Status
        Filter by service status (Running, Stopped, etc.)
    
    .PARAMETER StartType
        Filter by start type (Automatic, Manual, Disabled)
    
    .EXAMPLE
        Get-ServiceStatus
        Get status of all services
    
    .EXAMPLE
        Get-ServiceStatus -ServiceName "Spooler" -Status "Running"
        Check if Spooler service is running
    #>
    [CmdletBinding()]
    param(
        [string]$ServiceName,
        [string]$Status,
        [string]$StartType
    )
    
    try {
        Write-Host "=== SERVICE STATUS ===" -ForegroundColor Cyan
        Write-Host ""
        
        $services = Get-Service | Where-Object {
            $match = $true
            if ($ServiceName) { $match = $match -and ($_.Name -like "*$ServiceName*") }
            if ($Status) { $match = $match -and ($_.Status -eq $Status) }
            $match
        } | Sort-Object Name
        
        $services | ForEach-Object {
            $color = switch ($_.Status) {
                "Running" { "Green" }
                "Stopped" { "Red" }
                "Paused" { "Yellow" }
                default { "Gray" }
            }
            
            Write-Host "Service: $($_.Name)" -ForegroundColor White
            Write-Host "  Display Name: $($_.DisplayName)" -ForegroundColor Gray
            Write-Host "  Status: $($_.Status)" -ForegroundColor $color
            Write-Host "  Start Type: $($_.StartType)" -ForegroundColor Gray
            Write-Host ""
        }
        
    } catch {
        Write-Error "Failed to get service status: $($_.Exception.Message)"
    }
}

function Get-EventLogs {
    <#
    .SYNOPSIS
        Get and analyze event logs
    
    .DESCRIPTION
        Retrieves and analyzes Windows event logs for system monitoring and troubleshooting.
    
    .PARAMETER LogName
        Specific log name (Application, System, Security, etc.)
    
    .PARAMETER EntryType
        Filter by entry type (Error, Warning, Information)
    
    .PARAMETER Count
        Number of recent entries to retrieve
    
    .PARAMETER Hours
        Get entries from last N hours
    
    .EXAMPLE
        Get-EventLogs -LogName "System" -EntryType "Error" -Count 10
        Get last 10 error entries from System log
    #>
    [CmdletBinding()]
    param(
        [string]$LogName = "System",
        [string]$EntryType,
        [int]$Count = 50,
        [int]$Hours = 24
    )
    
    try {
        Write-Host "=== EVENT LOG ANALYSIS ===" -ForegroundColor Cyan
        Write-Host "Log: $LogName" -ForegroundColor Green
        Write-Host "Time Range: Last $Hours hours" -ForegroundColor Green
        Write-Host ""
        
        $after = (Get-Date).AddHours(-$Hours)
        
        $events = Get-WinEvent -LogName $LogName -MaxEvents $Count | Where-Object {
            $_.TimeCreated -gt $after -and
            (if ($EntryType) { $_.LevelDisplayName -eq $EntryType } else { $true })
        }
        
        $events | ForEach-Object {
            $color = switch ($_.LevelDisplayName) {
                "Error" { "Red" }
                "Warning" { "Yellow" }
                "Information" { "Green" }
                default { "White" }
            }
            
            Write-Host "Time: $($_.TimeCreated)" -ForegroundColor Gray
            Write-Host "Level: $($_.LevelDisplayName)" -ForegroundColor $color
            Write-Host "Source: $($_.ProviderName)" -ForegroundColor White
            Write-Host "Message: $($_.Message)" -ForegroundColor Gray
            Write-Host "---" -ForegroundColor DarkGray
        }
        
    } catch {
        Write-Error "Failed to get event logs: $($_.Exception.Message)"
    }
}

function Get-PerformanceMetrics {
    <#
    .SYNOPSIS
        Get system performance metrics
    
    .DESCRIPTION
        Retrieves real-time system performance metrics including CPU, memory, and disk usage.
    
    .PARAMETER Duration
        Duration in seconds to collect metrics
    
    .PARAMETER Interval
        Collection interval in seconds
    
    .EXAMPLE
        Get-PerformanceMetrics -Duration 60 -Interval 5
        Collect performance metrics for 60 seconds every 5 seconds
    #>
    [CmdletBinding()]
    param(
        [int]$Duration = 30,
        [int]$Interval = 5
    )
    
    try {
        Write-Host "=== PERFORMANCE METRICS ===" -ForegroundColor Cyan
        Write-Host "Duration: $Duration seconds" -ForegroundColor Green
        Write-Host "Interval: $Interval seconds" -ForegroundColor Green
        Write-Host ""
        
        $endTime = (Get-Date).AddSeconds($Duration)
        
        while ((Get-Date) -lt $endTime) {
            $cpu = Get-WmiObject -Class Win32_Processor | Measure-Object -Property LoadPercentage -Average
            $memory = Get-WmiObject -Class Win32_OperatingSystem
            $disk = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "C:" }
            
            $memoryUsed = [math]::Round((($memory.TotalVisibleMemorySize - $memory.FreePhysicalMemory) / $memory.TotalVisibleMemorySize) * 100, 2)
            $diskUsed = [math]::Round((($disk.Size - $disk.FreeSpace) / $disk.Size) * 100, 2)
            
            Write-Host "Time: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor White
            Write-Host "  CPU Usage: $($cpu.Average)%" -ForegroundColor Yellow
            Write-Host "  Memory Usage: $memoryUsed%" -ForegroundColor Yellow
            Write-Host "  Disk Usage: $diskUsed%" -ForegroundColor Yellow
            Write-Host ""
            
            Start-Sleep -Seconds $Interval
        }
        
    } catch {
        Write-Error "Failed to get performance metrics: $($_.Exception.Message)"
    }
}

function Test-SystemHealth {
    <#
    .SYNOPSIS
        Perform comprehensive system health check
    
    .DESCRIPTION
        Performs a comprehensive system health check including hardware, software, and configuration validation.
    
    .PARAMETER Detailed
        Include detailed health information
    
    .PARAMETER ExportReport
        Export health report to file
    
    .EXAMPLE
        Test-SystemHealth
        Perform basic system health check
    
    .EXAMPLE
        Test-SystemHealth -Detailed -ExportReport "C:\HealthReport.json"
        Perform detailed health check and export report
    #>
    [CmdletBinding()]
    param(
        [switch]$Detailed,
        [string]$ExportReport
    )
    
    try {
        Write-Host "=== SYSTEM HEALTH CHECK ===" -ForegroundColor Cyan
        Write-Host ""
        
        $healthReport = @{
            CheckTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            OverallStatus = "Healthy"
            Issues = @()
            Warnings = @()
            Recommendations = @()
        }
        
        # Check disk space
        Write-Host "Checking disk space..." -ForegroundColor Green
        $drives = Get-WmiObject -Class Win32_LogicalDisk
        foreach ($drive in $drives) {
            $usagePercent = [math]::Round((($drive.Size - $drive.FreeSpace) / $drive.Size) * 100, 2)
            if ($usagePercent -gt 90) {
                $healthReport.Issues += "Drive $($drive.DeviceID) is $usagePercent% full"
                $healthReport.OverallStatus = "Warning"
            } elseif ($usagePercent -gt 80) {
                $healthReport.Warnings += "Drive $($drive.DeviceID) is $usagePercent% full"
            }
        }
        
        # Check memory usage
        Write-Host "Checking memory usage..." -ForegroundColor Green
        $memory = Get-WmiObject -Class Win32_OperatingSystem
        $memoryUsed = [math]::Round((($memory.TotalVisibleMemorySize - $memory.FreePhysicalMemory) / $memory.TotalVisibleMemorySize) * 100, 2)
        if ($memoryUsed -gt 90) {
            $healthReport.Issues += "Memory usage is $memoryUsed%"
            $healthReport.OverallStatus = "Warning"
        }
        
        # Check critical services
        Write-Host "Checking critical services..." -ForegroundColor Green
        $criticalServices = @("Spooler", "RpcSs", "LanmanServer", "LanmanWorkstation")
        foreach ($service in $criticalServices) {
            $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
            if ($svc -and $svc.Status -ne "Running") {
                $healthReport.Issues += "Critical service $service is not running"
                $healthReport.OverallStatus = "Warning"
            }
        }
        
        # Check Windows updates
        Write-Host "Checking Windows updates..." -ForegroundColor Green
        $updates = Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 1
        $daysSinceUpdate = (Get-Date) - $updates.InstalledOn
        if ($daysSinceUpdate.Days -gt 30) {
            $healthReport.Warnings += "Last Windows update was $($daysSinceUpdate.Days) days ago"
        }
        
        # Display results
        $statusColor = switch ($healthReport.OverallStatus) {
            "Healthy" { "Green" }
            "Warning" { "Yellow" }
            "Critical" { "Red" }
        }
        
        Write-Host "Overall Status: $($healthReport.OverallStatus)" -ForegroundColor $statusColor
        Write-Host ""
        
        if ($healthReport.Issues.Count -gt 0) {
            Write-Host "Issues Found:" -ForegroundColor Red
            foreach ($issue in $healthReport.Issues) {
                Write-Host "  - $issue" -ForegroundColor Red
            }
            Write-Host ""
        }
        
        if ($healthReport.Warnings.Count -gt 0) {
            Write-Host "Warnings:" -ForegroundColor Yellow
            foreach ($warning in $healthReport.Warnings) {
                Write-Host "  - $warning" -ForegroundColor Yellow
            }
            Write-Host ""
        }
        
        if ($ExportReport) {
            $healthReport | ConvertTo-Json -Depth 10 | Out-File -FilePath $ExportReport -Encoding UTF8
            Write-Host "Health report exported to: $ExportReport" -ForegroundColor Green
        }
        
        return $healthReport
        
    } catch {
        Write-Error "Failed to perform system health check: $($_.Exception.Message)"
        return $null
    }
}

# Additional helper functions
function Get-SystemBios { Get-WmiObject -Class Win32_BIOS }
function Get-MemoryInfo { Get-WmiObject -Class Win32_PhysicalMemory }
function Get-CpuInfo { Get-WmiObject -Class Win32_Processor }
function Get-GpuInfo { Get-WmiObject -Class Win32_VideoController }
function Get-MotherboardInfo { Get-WmiObject -Class Win32_BaseBoard }
function Get-PowerInfo { Get-WmiObject -Class Win32_Battery }
function Get-TemperatureInfo { Get-WmiObject -Class Win32_TemperatureProbe }
function Get-NetworkAdapters { Get-WmiObject -Class Win32_NetworkAdapter }
function Get-SystemDrivers { Get-WmiObject -Class Win32_SystemDriver }
function Get-InstalledSoftware { Get-WmiObject -Class Win32_Product }
function Get-SystemUpdates { Get-HotFix }
function Get-UserAccounts { Get-WmiObject -Class Win32_UserAccount }
function Get-StartupPrograms { Get-WmiObject -Class Win32_StartupCommand }