# PowerShell CLI Tools

A comprehensive collection of PowerShell command-line interface tools and utilities for system administration, automation, and development tasks.

## 🚀 Features

- **Interactive CLI Interface** - User-friendly command-line interface with menu-driven options
- **System Administration Tools** - File management, process monitoring, and system information
- **Network Utilities** - Network diagnostics, connectivity testing, and monitoring
- **Development Helpers** - Code formatting, project templates, and automation scripts
- **Data Processing** - CSV manipulation, JSON processing, and data transformation
- **Cloud Integration** - Azure, AWS, and other cloud service utilities

## 📁 Project Structure

```
Powershell/
├── README.md                          # This file
├── CLI/                               # Main CLI interface
│   ├── PowerShellCLI.ps1             # Main CLI entry point
│   └── CLI-Menu.ps1                  # Menu system
├── Modules/                           # PowerShell modules
│   ├── SystemTools/                  # System administration tools
│   ├── NetworkTools/                 # Network utilities
│   ├── DataTools/                    # Data processing utilities
│   └── CloudTools/                   # Cloud service utilities
├── Scripts/                           # Standalone scripts
│   ├── Examples/                     # Example usage scripts
│   └── Utilities/                    # Utility scripts
├── Tests/                            # Pester test files
└── Docs/                             # Documentation
```

## 🛠️ Installation

1. Clone the repository:
```powershell
git clone https://github.com/JeremiahEllington/Powershell.git
cd Powershell
```

2. Set execution policy (if needed):
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

3. Import the main CLI module:
```powershell
Import-Module .\CLI\PowerShellCLI.ps1
```

## 🚀 Quick Start

### Interactive CLI Mode
```powershell
# Launch the interactive CLI
.\CLI\PowerShellCLI.ps1

# Or use the menu system
.\CLI\CLI-Menu.ps1
```

### Direct Module Usage
```powershell
# Import specific modules
Import-Module .\Modules\SystemTools\
Import-Module .\Modules\NetworkTools\

# Use the functions
Get-SystemInfo
Test-NetworkConnectivity -Target "google.com"
```

## 📋 Available Commands

### System Tools
- `Get-SystemInfo` - Comprehensive system information
- `Get-ProcessInfo` - Detailed process monitoring
- `Get-DiskUsage` - Disk space analysis
- `Get-ServiceStatus` - Service monitoring and management

### Network Tools
- `Test-NetworkConnectivity` - Network connectivity testing
- `Get-NetworkInfo` - Network configuration details
- `Test-Port` - Port availability testing
- `Get-NetworkStatistics` - Network usage statistics

### Data Tools
- `Convert-CsvToJson` - CSV to JSON conversion
- `Format-JsonData` - JSON data formatting
- `Get-DataStatistics` - Data analysis and statistics
- `Export-DataReport` - Generate data reports

### Cloud Tools
- `Connect-AzureAccount` - Azure authentication
- `Get-AzureResources` - Azure resource listing
- `Test-AwsConnectivity` - AWS connectivity testing
- `Get-CloudMetrics` - Cloud resource metrics

## 📖 Usage Examples

### System Monitoring
```powershell
# Get comprehensive system information
Get-SystemInfo -Detailed

# Monitor specific processes
Get-ProcessInfo -ProcessName "chrome" -Continuous

# Check disk usage with alerts
Get-DiskUsage -Threshold 80 -Alert
```

### Network Diagnostics
```powershell
# Test connectivity to multiple hosts
Test-NetworkConnectivity -Targets @("google.com", "github.com", "microsoft.com")

# Check specific ports
Test-Port -Host "localhost" -Ports @(80, 443, 22, 3389)

# Get network statistics
Get-NetworkStatistics -Duration 60
```

### Data Processing
```powershell
# Convert CSV to JSON
Convert-CsvToJson -Path "data.csv" -OutputPath "data.json"

# Format JSON data
Format-JsonData -Path "config.json" -Indent 2

# Generate data report
Export-DataReport -InputPath "data.csv" -OutputPath "report.html"
```

## 🧪 Testing

Run the test suite:
```powershell
# Run all tests
Invoke-Pester .\Tests\

# Run specific test categories
Invoke-Pester .\Tests\ -Tag "System"
Invoke-Pester .\Tests\ -Tag "Network"
```

## 📚 Documentation

- [System Tools Documentation](Docs/SystemTools.md)
- [Network Tools Documentation](Docs/NetworkTools.md)
- [Data Tools Documentation](Docs/DataTools.md)
- [Cloud Tools Documentation](Docs/CloudTools.md)
- [API Reference](Docs/API-Reference.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- Create an [issue](https://github.com/JeremiahEllington/Powershell/issues) for bug reports
- Start a [discussion](https://github.com/JeremiahEllington/Powershell/discussions) for questions
- Check the [documentation](Docs/) for detailed guides

## 🔄 Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes and updates.

---

**Made with ❤️ using PowerShell**