# SystemTools.Tests.ps1
# Pester tests for SystemTools module
# Author: Jeremiah Ellington
# Description: Comprehensive test suite for system administration tools

# Import Pester module
Import-Module Pester -Force

# Import the module under test
Import-Module .\Modules\SystemTools\SystemTools.psm1 -Force

Describe "SystemTools Module Tests" {
    
    Context "Module Loading" {
        It "Should load the SystemTools module successfully" {
            $module = Get-Module -Name SystemTools
            $module | Should -Not -BeNullOrEmpty
            $module.Name | Should -Be "SystemTools"
        }
        
        It "Should export all expected functions" {
            $exportedFunctions = (Get-Module -Name SystemTools).ExportedFunctions.Keys
            $expectedFunctions = @(
                'Get-SystemInfo',
                'Get-ProcessInfo',
                'Get-DiskUsage',
                'Get-ServiceStatus',
                'Get-EventLogs',
                'Get-PerformanceMetrics',
                'Test-SystemHealth'
            )
            
            foreach ($function in $expectedFunctions) {
                $exportedFunctions | Should -Contain $function
            }
        }
    }
    
    Context "Get-SystemInfo Function" {
        It "Should return system information without errors" {
            $result = Get-SystemInfo
            $result | Should -Not -BeNullOrEmpty
            $result.ComputerName | Should -Not -BeNullOrEmpty
            $result.OS | Should -Not -BeNullOrEmpty
            $result.Processor | Should -Not -BeNullOrEmpty
        }
        
        It "Should include detailed information when Detailed switch is used" {
            $result = Get-SystemInfo -Detailed
            $result | Should -Not -BeNullOrEmpty
            $result.ComputerName | Should -Not -BeNullOrEmpty
        }
        
        It "Should export to file when ExportPath is specified" {
            $exportPath = "TestDrive:\SystemInfo.json"
            $result = Get-SystemInfo -ExportPath $exportPath
            Test-Path $exportPath | Should -Be $true
        }
    }
    
    Context "Get-ProcessInfo Function" {
        It "Should return process information without errors" {
            $result = Get-ProcessInfo -Top 5
            $result | Should -Not -BeNullOrEmpty
        }
        
        It "Should filter by process name when specified" {
            $result = Get-ProcessInfo -ProcessName "powershell" -Top 5
            $result | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Get-DiskUsage Function" {
        It "Should return disk usage information without errors" {
            $result = Get-DiskUsage
            $result | Should -Not -BeNullOrEmpty
        }
        
        It "Should check specific drive when specified" {
            $result = Get-DiskUsage -Drive "C:"
            $result | Should -Not -BeNullOrEmpty
        }
        
        It "Should show alerts when threshold is exceeded" {
            $result = Get-DiskUsage -Threshold 10 -Alert
            $result | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Get-ServiceStatus Function" {
        It "Should return service status without errors" {
            $result = Get-ServiceStatus
            $result | Should -Not -BeNullOrEmpty
        }
        
        It "Should filter by service name when specified" {
            $result = Get-ServiceStatus -ServiceName "Spooler"
            $result | Should -Not -BeNullOrEmpty
        }
        
        It "Should filter by status when specified" {
            $result = Get-ServiceStatus -Status "Running"
            $result | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Get-EventLogs Function" {
        It "Should return event logs without errors" {
            $result = Get-EventLogs -LogName "System" -Count 5
            $result | Should -Not -BeNullOrEmpty
        }
        
        It "Should filter by entry type when specified" {
            $result = Get-EventLogs -LogName "System" -EntryType "Error" -Count 5
            $result | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Get-PerformanceMetrics Function" {
        It "Should return performance metrics without errors" {
            $result = Get-PerformanceMetrics -Duration 5 -Interval 2
            $result | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Test-SystemHealth Function" {
        It "Should perform system health check without errors" {
            $result = Test-SystemHealth
            $result | Should -Not -BeNullOrEmpty
            $result.CheckTime | Should -Not -BeNullOrEmpty
            $result.OverallStatus | Should -Not -BeNullOrEmpty
        }
        
        It "Should include detailed health information when Detailed switch is used" {
            $result = Test-SystemHealth -Detailed
            $result | Should -Not -BeNullOrEmpty
        }
        
        It "Should export health report when ExportReport is specified" {
            $exportPath = "TestDrive:\HealthReport.json"
            $result = Test-SystemHealth -ExportReport $exportPath
            Test-Path $exportPath | Should -Be $true
        }
    }
    
    Context "Error Handling" {
        It "Should handle errors gracefully" {
            # Test with invalid parameters
            { Get-SystemInfo -InvalidParameter } | Should -Not -Throw
        }
    }
}

Describe "SystemTools Integration Tests" {
    
    Context "End-to-End System Monitoring" {
        It "Should perform complete system monitoring workflow" {
            # Test the complete workflow
            $systemInfo = Get-SystemInfo
            $systemInfo | Should -Not -BeNullOrEmpty
            
            $processInfo = Get-ProcessInfo -Top 5
            $processInfo | Should -Not -BeNullOrEmpty
            
            $diskUsage = Get-DiskUsage
            $diskUsage | Should -Not -BeNullOrEmpty
            
            $healthCheck = Test-SystemHealth
            $healthCheck | Should -Not -BeNullOrEmpty
        }
    }
}

Describe "SystemTools Performance Tests" {
    
    Context "Function Performance" {
        It "Should complete Get-SystemInfo within reasonable time" {
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            Get-SystemInfo
            $stopwatch.Stop()
            $stopwatch.ElapsedMilliseconds | Should -BeLessThan 10000
        }
        
        It "Should complete Get-ProcessInfo within reasonable time" {
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            Get-ProcessInfo -Top 10
            $stopwatch.Stop()
            $stopwatch.ElapsedMilliseconds | Should -BeLessThan 5000
        }
    }
}