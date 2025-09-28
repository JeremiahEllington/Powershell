# SystemMonitoring.ps1
# Example script demonstrating system monitoring capabilities
# Author: Jeremiah Ellington
# Description: Comprehensive system monitoring example using PowerShell CLI tools

# Import required modules
Import-Module .\Modules\SystemTools\SystemTools.psm1 -Force
Import-Module .\Modules\NetworkTools\NetworkTools.psm1 -Force

Write-Host "=== SYSTEM MONITORING EXAMPLE ===" -ForegroundColor Cyan
Write-Host "This example demonstrates comprehensive system monitoring" -ForegroundColor Green
Write-Host ""

# 1. Get comprehensive system information
Write-Host "1. Getting System Information..." -ForegroundColor Yellow
$systemInfo = Get-SystemInfo -Detailed
Write-Host "System information collected successfully!" -ForegroundColor Green
Write-Host ""

# 2. Monitor processes
Write-Host "2. Monitoring Top Processes..." -ForegroundColor Yellow
Get-ProcessInfo -Top 10
Write-Host ""

# 3. Check disk usage
Write-Host "3. Checking Disk Usage..." -ForegroundColor Yellow
Get-DiskUsage -Threshold 80 -Alert
Write-Host ""

# 4. Monitor network connectivity
Write-Host "4. Testing Network Connectivity..." -ForegroundColor Yellow
Test-NetworkConnectivity -Targets @("google.com", "github.com", "microsoft.com") -Method "All"
Write-Host ""

# 5. Get network statistics
Write-Host "5. Getting Network Statistics..." -ForegroundColor Yellow
Get-NetworkStatistics -Duration 10
Write-Host ""

# 6. Perform system health check
Write-Host "6. Performing System Health Check..." -ForegroundColor Yellow
$healthReport = Test-SystemHealth -Detailed -ExportReport "C:\Temp\HealthReport.json"
Write-Host ""

# 7. Monitor performance metrics
Write-Host "7. Monitoring Performance Metrics..." -ForegroundColor Yellow
Get-PerformanceMetrics -Duration 15 -Interval 5
Write-Host ""

# 8. Check service status
Write-Host "8. Checking Service Status..." -ForegroundColor Yellow
Get-ServiceStatus -Status "Running" | Select-Object -First 10
Write-Host ""

# 9. Analyze event logs
Write-Host "9. Analyzing Event Logs..." -ForegroundColor Yellow
Get-EventLogs -LogName "System" -EntryType "Error" -Count 5
Write-Host ""

# 10. Generate monitoring report
Write-Host "10. Generating Monitoring Report..." -ForegroundColor Yellow
$reportData = @{
    SystemInfo = $systemInfo
    HealthReport = $healthReport
    CollectionTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    MonitoringDuration = "15 minutes"
}

$reportPath = "C:\Temp\SystemMonitoringReport.json"
$reportData | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "Monitoring report saved to: $reportPath" -ForegroundColor Green

Write-Host ""
Write-Host "=== MONITORING COMPLETE ===" -ForegroundColor Cyan
Write-Host "System monitoring example completed successfully!" -ForegroundColor Green
Write-Host "Check the generated reports for detailed information." -ForegroundColor Yellow