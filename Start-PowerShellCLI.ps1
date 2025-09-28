# Start-PowerShellCLI.ps1
# PowerShell CLI Launcher Script
# Author: Jeremiah Ellington
# Description: Easy launcher for the PowerShell CLI tools

param(
    [switch]$Help,
    [switch]$Version,
    [string]$Command = "",
    [string[]]$Arguments = @()
)

# Script metadata
$ScriptVersion = "1.0.0"
$ScriptAuthor = "Jeremiah Ellington"

# Display help
if ($Help) {
    Write-Host "PowerShell CLI Tools - Launcher" -ForegroundColor Cyan
    Write-Host "Version: $ScriptVersion" -ForegroundColor Green
    Write-Host "Author: $ScriptAuthor" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\Start-PowerShellCLI.ps1 [options]" -ForegroundColor White
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -Help                 Show this help message" -ForegroundColor White
    Write-Host "  -Version              Show version information" -ForegroundColor White
    Write-Host "  -Command <string>     Execute specific command" -ForegroundColor White
    Write-Host "  -Arguments <array>    Arguments for the command" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\Start-PowerShellCLI.ps1" -ForegroundColor White
    Write-Host "  .\Start-PowerShellCLI.ps1 -Command 'system-info'" -ForegroundColor White
    Write-Host "  .\Start-PowerShellCLI.ps1 -Command 'network-test' -Arguments @('google.com')" -ForegroundColor White
    Write-Host ""
    Write-Host "Available Commands:" -ForegroundColor Yellow
    Write-Host "  system-info          Get system information" -ForegroundColor White
    Write-Host "  network-test         Test network connectivity" -ForegroundColor White
    Write-Host "  data-convert         Convert data formats" -ForegroundColor White
    Write-Host "  cloud-status         Check cloud service status" -ForegroundColor White
    Write-Host ""
    exit 0
}

# Display version
if ($Version) {
    Write-Host "PowerShell CLI Tools" -ForegroundColor Cyan
    Write-Host "Version: $ScriptVersion" -ForegroundColor Green
    Write-Host "Author: $ScriptAuthor" -ForegroundColor Green
    Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor Green
    Write-Host "OS: $($PSVersionTable.OS)" -ForegroundColor Green
    exit 0
}

# Check if CLI directory exists
if (-not (Test-Path "CLI\PowerShellCLI.ps1")) {
    Write-Error "PowerShell CLI not found. Please ensure you're in the correct directory."
    exit 1
}

# Launch the CLI
try {
    if ($Command -ne "") {
        # Execute specific command
        & ".\CLI\PowerShellCLI.ps1" -Command $Command -Arguments $Arguments
    } else {
        # Launch interactive mode
        & ".\CLI\PowerShellCLI.ps1" -Interactive
    }
} catch {
    Write-Error "Failed to launch PowerShell CLI: $($_.Exception.Message)"
    exit 1
}