# PowerShell CLI - Main Entry Point
# Author: Jeremiah Ellington
# Description: Interactive command-line interface for PowerShell tools and utilities

param(
    [string]$Command = "",
    [string[]]$Arguments = @(),
    [switch]$Help,
    [switch]$Version,
    [switch]$Interactive
)

# Set up error handling
$ErrorActionPreference = "Continue"

# CLI Configuration
$Script:CLI_VERSION = "1.0.0"
$Script:CLI_TITLE = "PowerShell CLI Tools"
$Script:CLI_AUTHOR = "Jeremiah Ellington"

# Color scheme
$Script:COLORS = @{
    Header = "Cyan"
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Info = "Blue"
    Prompt = "Magenta"
    Menu = "White"
}

# Main CLI Functions
function Show-Header {
    param([string]$Title = $Script:CLI_TITLE)
    
    Clear-Host
    Write-Host "=" * 60 -ForegroundColor $Script:COLORS.Header
    Write-Host " $Title" -ForegroundColor $Script:COLORS.Header
    Write-Host " Version: $Script:CLI_VERSION" -ForegroundColor $Script:COLORS.Info
    Write-Host " Author: $Script:CLI_AUTHOR" -ForegroundColor $Script:COLORS.Info
    Write-Host "=" * 60 -ForegroundColor $Script:COLORS.Header
    Write-Host ""
}

function Show-MainMenu {
    Show-Header
    
    Write-Host "Main Menu" -ForegroundColor $Script:COLORS.Menu
    Write-Host "--------" -ForegroundColor $Script:COLORS.Menu
    Write-Host ""
    
    $menuOptions = @(
        @{Key = "1"; Text = "System Tools"; Description = "System administration and monitoring tools" },
        @{Key = "2"; Text = "Network Tools"; Description = "Network diagnostics and connectivity tools" },
        @{Key = "3"; Text = "Data Tools"; Description = "Data processing and analysis tools" },
        @{Key = "4"; Text = "Cloud Tools"; Description = "Cloud service integration tools" },
        @{Key = "5"; Text = "File Operations"; Description = "File and directory management tools" },
        @{Key = "6"; Text = "Security Tools"; Description = "Security and compliance tools" },
        @{Key = "7"; Text = "Development Tools"; Description = "Development and automation tools" },
        @{Key = "8"; Text = "Settings"; Description = "CLI configuration and preferences" },
        @{Key = "9"; Text = "Help"; Description = "Show help and documentation" },
        @{Key = "0"; Text = "Exit"; Description = "Exit the CLI" }
    )
    
    foreach ($option in $menuOptions) {
        Write-Host " [$($option.Key)] $($option.Text)" -ForegroundColor $Script:COLORS.Menu
        Write-Host "     $($option.Description)" -ForegroundColor $Script:COLORS.Info
        Write-Host ""
    }
}

function Get-UserChoice {
    param([string]$Prompt = "Enter your choice")
    
    do {
        Write-Host "$Prompt : " -NoNewline -ForegroundColor $Script:COLORS.Prompt
        $choice = Read-Host
    } while ($choice -eq "")
    
    return $choice
}

function Show-SystemToolsMenu {
    Show-Header "System Tools"
    
    Write-Host "System Administration Tools" -ForegroundColor $Script:COLORS.Menu
    Write-Host "---------------------------" -ForegroundColor $Script:COLORS.Menu
    Write-Host ""
    
    $systemOptions = @(
        @{Key = "1"; Text = "System Information"; Function = "Get-SystemInfo" },
        @{Key = "2"; Text = "Process Monitor"; Function = "Get-ProcessInfo" },
        @{Key = "3"; Text = "Disk Usage Analysis"; Function = "Get-DiskUsage" },
        @{Key = "4"; Text = "Service Management"; Function = "Get-ServiceStatus" },
        @{Key = "5"; Text = "Event Log Viewer"; Function = "Get-EventLogs" },
        @{Key = "6"; Text = "Performance Monitor"; Function = "Get-PerformanceMetrics" },
        @{Key = "7"; Text = "System Health Check"; Function = "Test-SystemHealth" },
        @{Key = "0"; Text = "Back to Main Menu"; Function = "Show-MainMenu" }
    )
    
    foreach ($option in $systemOptions) {
        Write-Host " [$($option.Key)] $($option.Text)" -ForegroundColor $Script:COLORS.Menu
    }
    Write-Host ""
}

function Show-NetworkToolsMenu {
    Show-Header "Network Tools"
    
    Write-Host "Network Diagnostics Tools" -ForegroundColor $Script:COLORS.Menu
    Write-Host "------------------------" -ForegroundColor $Script:COLORS.Menu
    Write-Host ""
    
    $networkOptions = @(
        @{Key = "1"; Text = "Connectivity Test"; Function = "Test-NetworkConnectivity" },
        @{Key = "2"; Text = "Port Scanner"; Function = "Test-Port" },
        @{Key = "3"; Text = "Network Configuration"; Function = "Get-NetworkInfo" },
        @{Key = "4"; Text = "DNS Resolution"; Function = "Test-DnsResolution" },
        @{Key = "5"; Text = "Network Statistics"; Function = "Get-NetworkStatistics" },
        @{Key = "6"; Text = "Ping Test"; Function = "Test-Ping" },
        @{Key = "7"; Text = "Traceroute"; Function = "Test-TraceRoute" },
        @{Key = "0"; Text = "Back to Main Menu"; Function = "Show-MainMenu" }
    )
    
    foreach ($option in $networkOptions) {
        Write-Host " [$($option.Key)] $($option.Text)" -ForegroundColor $Script:COLORS.Menu
    }
    Write-Host ""
}

function Show-DataToolsMenu {
    Show-Header "Data Tools"
    
    Write-Host "Data Processing Tools" -ForegroundColor $Script:COLORS.Menu
    Write-Host "--------------------" -ForegroundColor $Script:COLORS.Menu
    Write-Host ""
    
    $dataOptions = @(
        @{Key = "1"; Text = "CSV to JSON Converter"; Function = "Convert-CsvToJson" },
        @{Key = "2"; Text = "JSON Formatter"; Function = "Format-JsonData" },
        @{Key = "3"; Text = "Data Statistics"; Function = "Get-DataStatistics" },
        @{Key = "4"; Text = "Data Report Generator"; Function = "Export-DataReport" },
        @{Key = "5"; Text = "XML Parser"; Function = "Parse-XmlData" },
        @{Key = "6"; Text = "Data Validator"; Function = "Test-DataIntegrity" },
        @{Key = "7"; Text = "Data Backup"; Function = "Backup-Data" },
        @{Key = "0"; Text = "Back to Main Menu"; Function = "Show-MainMenu" }
    )
    
    foreach ($option in $dataOptions) {
        Write-Host " [$($option.Key)] $($option.Text)" -ForegroundColor $Script:COLORS.Menu
    }
    Write-Host ""
}

function Show-CloudToolsMenu {
    Show-Header "Cloud Tools"
    
    Write-Host "Cloud Service Tools" -ForegroundColor $Script:COLORS.Menu
    Write-Host "-----------------" -ForegroundColor $Script:COLORS.Menu
    Write-Host ""
    
    $cloudOptions = @(
        @{Key = "1"; Text = "Azure Authentication"; Function = "Connect-AzureAccount" },
        @{Key = "2"; Text = "Azure Resources"; Function = "Get-AzureResources" },
        @{Key = "3"; Text = "AWS Connectivity"; Function = "Test-AwsConnectivity" },
        @{Key = "4"; Text = "Cloud Metrics"; Function = "Get-CloudMetrics" },
        @{Key = "5"; Text = "Resource Monitoring"; Function = "Monitor-CloudResources" },
        @{Key = "6"; Text = "Cost Analysis"; Function = "Get-CloudCosts" },
        @{Key = "7"; Text = "Security Scan"; Function = "Test-CloudSecurity" },
        @{Key = "0"; Text = "Back to Main Menu"; Function = "Show-MainMenu" }
    )
    
    foreach ($option in $cloudOptions) {
        Write-Host " [$($option.Key)] $($option.Text)" -ForegroundColor $Script:COLORS.Menu
    }
    Write-Host ""
}

function Show-Help {
    Show-Header "Help & Documentation"
    
    Write-Host "PowerShell CLI Help" -ForegroundColor $Script:COLORS.Menu
    Write-Host "==================" -ForegroundColor $Script:COLORS.Menu
    Write-Host ""
    
    Write-Host "Usage:" -ForegroundColor $Script:COLORS.Info
    Write-Host "  .\PowerShellCLI.ps1 [options]" -ForegroundColor $Script:COLORS.Success
    Write-Host ""
    
    Write-Host "Options:" -ForegroundColor $Script:COLORS.Info
    Write-Host "  -Command <string>     Execute a specific command" -ForegroundColor $Script:COLORS.Success
    Write-Host "  -Arguments <array>    Arguments for the command" -ForegroundColor $Script:COLORS.Success
    Write-Host "  -Help                 Show this help message" -ForegroundColor $Script:COLORS.Success
    Write-Host "  -Version              Show version information" -ForegroundColor $Script:COLORS.Success
    Write-Host "  -Interactive          Start in interactive mode" -ForegroundColor $Script:COLORS.Success
    Write-Host ""
    
    Write-Host "Examples:" -ForegroundColor $Script:COLORS.Info
    Write-Host "  .\PowerShellCLI.ps1 -Interactive" -ForegroundColor $Script:COLORS.Success
    Write-Host "  .\PowerShellCLI.ps1 -Command 'system-info'" -ForegroundColor $Script:COLORS.Success
    Write-Host "  .\PowerShellCLI.ps1 -Command 'network-test' -Arguments @('google.com')" -ForegroundColor $Script:COLORS.Success
    Write-Host ""
    
    Write-Host "Available Commands:" -ForegroundColor $Script:COLORS.Info
    Write-Host "  system-info          Get system information" -ForegroundColor $Script:COLORS.Success
    Write-Host "  network-test         Test network connectivity" -ForegroundColor $Script:COLORS.Success
    Write-Host "  data-convert         Convert data formats" -ForegroundColor $Script:COLORS.Success
    Write-Host "  cloud-status         Check cloud service status" -ForegroundColor $Script:COLORS.Success
    Write-Host ""
    
    Write-Host "For more information, visit:" -ForegroundColor $Script:COLORS.Info
    Write-Host "  https://github.com/JeremiahEllington/Powershell" -ForegroundColor $Script:COLORS.Success
    Write-Host ""
}

function Show-Version {
    Show-Header
    Write-Host "PowerShell CLI Tools" -ForegroundColor $Script:COLORS.Menu
    Write-Host "Version: $Script:CLI_VERSION" -ForegroundColor $Script:COLORS.Info
    Write-Host "Author: $Script:CLI_AUTHOR" -ForegroundColor $Script:COLORS.Info
    Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor $Script:COLORS.Info
    Write-Host "OS: $($PSVersionTable.OS)" -ForegroundColor $Script:COLORS.Info
    Write-Host ""
}

function Start-InteractiveMode {
    do {
        Show-MainMenu
        $choice = Get-UserChoice "Select an option"
        
        switch ($choice) {
            "1" { 
                Show-SystemToolsMenu
                $subChoice = Get-UserChoice "Select system tool"
                # Handle system tools
                Write-Host "System tool selected: $subChoice" -ForegroundColor $Script:COLORS.Success
                Read-Host "Press Enter to continue"
            }
            "2" { 
                Show-NetworkToolsMenu
                $subChoice = Get-UserChoice "Select network tool"
                # Handle network tools
                Write-Host "Network tool selected: $subChoice" -ForegroundColor $Script:COLORS.Success
                Read-Host "Press Enter to continue"
            }
            "3" { 
                Show-DataToolsMenu
                $subChoice = Get-UserChoice "Select data tool"
                # Handle data tools
                Write-Host "Data tool selected: $subChoice" -ForegroundColor $Script:COLORS.Success
                Read-Host "Press Enter to continue"
            }
            "4" { 
                Show-CloudToolsMenu
                $subChoice = Get-UserChoice "Select cloud tool"
                # Handle cloud tools
                Write-Host "Cloud tool selected: $subChoice" -ForegroundColor $Script:COLORS.Success
                Read-Host "Press Enter to continue"
            }
            "5" {
                Write-Host "File Operations - Coming Soon!" -ForegroundColor $Script:COLORS.Warning
                Read-Host "Press Enter to continue"
            }
            "6" {
                Write-Host "Security Tools - Coming Soon!" -ForegroundColor $Script:COLORS.Warning
                Read-Host "Press Enter to continue"
            }
            "7" {
                Write-Host "Development Tools - Coming Soon!" -ForegroundColor $Script:COLORS.Warning
                Read-Host "Press Enter to continue"
            }
            "8" {
                Write-Host "Settings - Coming Soon!" -ForegroundColor $Script:COLORS.Warning
                Read-Host "Press Enter to continue"
            }
            "9" { 
                Show-Help
                Read-Host "Press Enter to continue"
            }
            "0" { 
                Write-Host "Thank you for using PowerShell CLI Tools!" -ForegroundColor $Script:COLORS.Success
                break
            }
            default { 
                Write-Host "Invalid option. Please try again." -ForegroundColor $Script:COLORS.Error
                Start-Sleep -Seconds 2
            }
        }
    } while ($true)
}

function Invoke-Command {
    param(
        [string]$Command,
        [string[]]$Arguments
    )
    
    switch ($Command.ToLower()) {
        "system-info" {
            Write-Host "Getting system information..." -ForegroundColor $Script:COLORS.Info
            # Call system info function
            Get-SystemInfo
        }
        "network-test" {
            Write-Host "Testing network connectivity..." -ForegroundColor $Script:COLORS.Info
            # Call network test function
            Test-NetworkConnectivity -Target $Arguments[0]
        }
        "data-convert" {
            Write-Host "Converting data..." -ForegroundColor $Script:COLORS.Info
            # Call data conversion function
            Convert-CsvToJson -Path $Arguments[0]
        }
        "cloud-status" {
            Write-Host "Checking cloud status..." -ForegroundColor $Script:COLORS.Info
            # Call cloud status function
            Get-CloudMetrics
        }
        default {
            Write-Host "Unknown command: $Command" -ForegroundColor $Script:COLORS.Error
            Write-Host "Use -Help to see available commands." -ForegroundColor $Script:COLORS.Info
        }
    }
}

# Main execution logic
if ($Help) {
    Show-Help
    exit 0
}

if ($Version) {
    Show-Version
    exit 0
}

if ($Command -ne "") {
    Invoke-Command -Command $Command -Arguments $Arguments
    exit 0
}

if ($Interactive -or ($Command -eq "" -and $Arguments.Count -eq 0)) {
    Start-InteractiveMode
    exit 0
}

# If no parameters provided, show help
Show-Help