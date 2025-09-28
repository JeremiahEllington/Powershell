# NetworkTools.psm1
# PowerShell CLI - Network Diagnostics Tools Module
# Author: Jeremiah Ellington
# Description: Comprehensive network diagnostics and connectivity tools

# Module metadata
$ModuleName = "NetworkTools"
$ModuleVersion = "1.0.0"
$ModuleAuthor = "Jeremiah Ellington"

# Export all functions
Export-ModuleMember -Function @(
    'Test-NetworkConnectivity',
    'Test-Port',
    'Get-NetworkInfo',
    'Test-DnsResolution',
    'Get-NetworkStatistics',
    'Test-Ping',
    'Test-TraceRoute',
    'Get-NetworkAdapters',
    'Get-NetworkRoutes',
    'Get-NetworkConnections',
    'Test-NetworkLatency',
    'Get-NetworkTraffic',
    'Test-SslCertificate',
    'Get-NetworkFirewall',
    'Test-NetworkBandwidth',
    'Get-NetworkTopology',
    'Test-NetworkSecurity',
    'Get-NetworkProtocols',
    'Test-NetworkQos',
    'Get-NetworkDiagnostics'
)

function Test-NetworkConnectivity {
    <#
    .SYNOPSIS
        Test network connectivity to specified targets
    
    .DESCRIPTION
        Tests network connectivity to one or more targets using various methods.
    
    .PARAMETER Target
        Single target hostname or IP address
    
    .PARAMETER Targets
        Array of target hostnames or IP addresses
    
    .PARAMETER Port
        Specific port to test (default: 80)
    
    .PARAMETER Timeout
        Connection timeout in seconds (default: 5)
    
    .PARAMETER Method
        Test method: Ping, TCP, HTTP, or All
    
    .PARAMETER Continuous
        Continuous monitoring mode
    
    .PARAMETER Interval
        Interval between tests in seconds (for continuous mode)
    
    .EXAMPLE
        Test-NetworkConnectivity -Target "google.com"
        Test connectivity to google.com
    
    .EXAMPLE
        Test-NetworkConnectivity -Targets @("google.com", "github.com") -Method "All"
        Test multiple targets using all methods
    
    .EXAMPLE
        Test-NetworkConnectivity -Target "server.com" -Port 443 -Method "TCP"
        Test TCP connectivity to server.com on port 443
    #>
    [CmdletBinding()]
    param(
        [string]$Target,
        [string[]]$Targets,
        [int]$Port = 80,
        [int]$Timeout = 5,
        [ValidateSet("Ping", "TCP", "HTTP", "All")]
        [string]$Method = "All",
        [switch]$Continuous,
        [int]$Interval = 10
    )
    
    try {
        $testTargets = if ($Targets) { $Targets } elseif ($Target) { @($Target) } else { @("google.com", "github.com", "microsoft.com") }
        
        do {
            Clear-Host
            Write-Host "=== NETWORK CONNECTIVITY TEST ===" -ForegroundColor Cyan
            Write-Host "Test Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Green
            Write-Host "Method: $Method" -ForegroundColor Green
            Write-Host ""
            
            foreach ($testTarget in $testTargets) {
                Write-Host "Testing: $testTarget" -ForegroundColor White
                Write-Host "----------------------------------------" -ForegroundColor DarkGray
                
                $results = @{
                    Target = $testTarget
                    Ping = $null
                    TCP = $null
                    HTTP = $null
                    DNS = $null
                }
                
                # DNS Resolution Test
                try {
                    $dnsResult = Resolve-DnsName -Name $testTarget -ErrorAction Stop
                    $results.DNS = "Resolved to: $($dnsResult[0].IPAddress)"
                    Write-Host "DNS: ✓ $($results.DNS)" -ForegroundColor Green
                } catch {
                    $results.DNS = "Failed: $($_.Exception.Message)"
                    Write-Host "DNS: ✗ $($results.DNS)" -ForegroundColor Red
                }
                
                # Ping Test
                if ($Method -eq "Ping" -or $Method -eq "All") {
                    try {
                        $pingResult = Test-Connection -ComputerName $testTarget -Count 1 -Quiet
                        if ($pingResult) {
                            $pingTime = (Test-Connection -ComputerName $testTarget -Count 1).ResponseTime
                            $results.Ping = "Success ($pingTime ms)"
                            Write-Host "Ping: ✓ $($results.Ping)" -ForegroundColor Green
                        } else {
                            $results.Ping = "Failed"
                            Write-Host "Ping: ✗ $($results.Ping)" -ForegroundColor Red
                        }
                    } catch {
                        $results.Ping = "Failed: $($_.Exception.Message)"
                        Write-Host "Ping: ✗ $($results.Ping)" -ForegroundColor Red
                    }
                }
                
                # TCP Test
                if ($Method -eq "TCP" -or $Method -eq "All") {
                    try {
                        $tcpClient = New-Object System.Net.Sockets.TcpClient
                        $connect = $tcpClient.BeginConnect($testTarget, $Port, $null, $null)
                        $wait = $connect.AsyncWaitHandle.WaitOne($Timeout * 1000, $false)
                        
                        if ($wait) {
                            $tcpClient.EndConnect($connect)
                            $results.TCP = "Success (Port $Port)"
                            Write-Host "TCP: ✓ $($results.TCP)" -ForegroundColor Green
                        } else {
                            $results.TCP = "Timeout (Port $Port)"
                            Write-Host "TCP: ✗ $($results.TCP)" -ForegroundColor Red
                        }
                        $tcpClient.Close()
                    } catch {
                        $results.TCP = "Failed: $($_.Exception.Message)"
                        Write-Host "TCP: ✗ $($results.TCP)" -ForegroundColor Red
                    }
                }
                
                # HTTP Test
                if ($Method -eq "HTTP" -or $Method -eq "All") {
                    try {
                        $httpClient = New-Object System.Net.WebClient
                        $httpClient.Timeout = $Timeout * 1000
                        $response = $httpClient.DownloadString("http://$testTarget")
                        $results.HTTP = "Success (HTTP)"
                        Write-Host "HTTP: ✓ $($results.HTTP)" -ForegroundColor Green
                    } catch {
                        try {
                            $httpsClient = New-Object System.Net.WebClient
                            $httpsClient.Timeout = $Timeout * 1000
                            $response = $httpsClient.DownloadString("https://$testTarget")
                            $results.HTTP = "Success (HTTPS)"
                            Write-Host "HTTP: ✓ $($results.HTTP)" -ForegroundColor Green
                        } catch {
                            $results.HTTP = "Failed: $($_.Exception.Message)"
                            Write-Host "HTTP: ✗ $($results.HTTP)" -ForegroundColor Red
                        }
                    }
                }
                
                Write-Host ""
            }
            
            if ($Continuous) {
                Write-Host "Press Ctrl+C to stop monitoring..." -ForegroundColor Red
                Write-Host "Next test in $Interval seconds..." -ForegroundColor Yellow
                Start-Sleep -Seconds $Interval
            }
            
        } while ($Continuous)
        
    } catch {
        Write-Error "Failed to test network connectivity: $($_.Exception.Message)"
    }
}

function Test-Port {
    <#
    .SYNOPSIS
        Test port connectivity on specified hosts
    
    .DESCRIPTION
        Tests connectivity to specific ports on one or more hosts.
    
    .PARAMETER Host
        Target hostname or IP address
    
    .PARAMETER Ports
        Array of ports to test
    
    .PARAMETER Timeout
        Connection timeout in seconds
    
    .PARAMETER ScanRange
        Scan a range of ports (e.g., "1-1000")
    
    .PARAMETER CommonPorts
        Test only common ports (HTTP, HTTPS, SSH, etc.)
    
    .EXAMPLE
        Test-Port -Host "localhost" -Ports @(80, 443, 22)
        Test specific ports on localhost
    
    .EXAMPLE
        Test-Port -Host "server.com" -CommonPorts
        Test common ports on server.com
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Host,
        [int[]]$Ports,
        [int]$Timeout = 3,
        [string]$ScanRange,
        [switch]$CommonPorts
    )
    
    try {
        Write-Host "=== PORT SCAN ===" -ForegroundColor Cyan
        Write-Host "Target: $Host" -ForegroundColor Green
        Write-Host ""
        
        $portsToTest = @()
        
        if ($CommonPorts) {
            $portsToTest = @(21, 22, 23, 25, 53, 80, 110, 143, 443, 993, 995, 3389, 5432, 3306, 1433)
        } elseif ($ScanRange) {
            $range = $ScanRange.Split('-')
            $start = [int]$range[0]
            $end = [int]$range[1]
            $portsToTest = $start..$end
        } elseif ($Ports) {
            $portsToTest = $Ports
        } else {
            $portsToTest = @(80, 443, 22, 3389, 21, 25, 53, 110, 143, 993, 995)
        }
        
        $openPorts = @()
        $closedPorts = @()
        
        foreach ($port in $portsToTest) {
            try {
                $tcpClient = New-Object System.Net.Sockets.TcpClient
                $connect = $tcpClient.BeginConnect($Host, $port, $null, $null)
                $wait = $connect.AsyncWaitHandle.WaitOne($Timeout * 1000, $false)
                
                if ($wait) {
                    $tcpClient.EndConnect($connect)
                    $openPorts += $port
                    Write-Host "Port $port : OPEN" -ForegroundColor Green
                } else {
                    $closedPorts += $port
                    Write-Host "Port $port : CLOSED" -ForegroundColor Red
                }
                $tcpClient.Close()
            } catch {
                $closedPorts += $port
                Write-Host "Port $port : CLOSED" -ForegroundColor Red
            }
        }
        
        Write-Host ""
        Write-Host "Summary:" -ForegroundColor Cyan
        Write-Host "Open Ports: $($openPorts -join ', ')" -ForegroundColor Green
        Write-Host "Closed Ports: $($closedPorts.Count)" -ForegroundColor Red
        
    } catch {
        Write-Error "Failed to test ports: $($_.Exception.Message)"
    }
}

function Get-NetworkInfo {
    <#
    .SYNOPSIS
        Get comprehensive network configuration information
    
    .DESCRIPTION
        Retrieves detailed network configuration including adapters, IP addresses, routes, and DNS settings.
    
    .PARAMETER Detailed
        Include detailed adapter information
    
    .PARAMETER ExportPath
        Export network information to file
    
    .EXAMPLE
        Get-NetworkInfo
        Get basic network configuration
    
    .EXAMPLE
        Get-NetworkInfo -Detailed -ExportPath "C:\NetworkInfo.json"
        Get detailed network info and export to file
    #>
    [CmdletBinding()]
    param(
        [switch]$Detailed,
        [string]$ExportPath
    )
    
    try {
        Write-Host "=== NETWORK CONFIGURATION ===" -ForegroundColor Cyan
        Write-Host ""
        
        $networkInfo = @{
            ComputerName = $env:COMPUTERNAME
            Domain = $env:USERDOMAIN
            CollectionTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Adapters = @()
            Routes = @()
            DNS = @()
            Connections = @()
        }
        
        # Get network adapters
        Write-Host "Network Adapters:" -ForegroundColor Green
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        foreach ($adapter in $adapters) {
            $adapterInfo = @{
                Name = $adapter.Name
                InterfaceDescription = $adapter.InterfaceDescription
                Status = $adapter.Status
                LinkSpeed = $adapter.LinkSpeed
                MacAddress = $adapter.MacAddress
                IPAddresses = @()
                Subnets = @()
                Gateways = @()
            }
            
            # Get IP configuration
            $ipConfig = Get-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
            if ($ipConfig) {
                $adapterInfo.IPAddresses += $ipConfig.IPAddress
                $adapterInfo.Subnets += $ipConfig.PrefixLength
            }
            
            # Get gateway
            $gateway = Get-NetRoute -InterfaceIndex $adapter.InterfaceIndex -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue
            if ($gateway) {
                $adapterInfo.Gateways += $gateway.NextHop
            }
            
            $networkInfo.Adapters += $adapterInfo
            
            Write-Host "  Adapter: $($adapter.Name)" -ForegroundColor White
            Write-Host "    Description: $($adapter.InterfaceDescription)" -ForegroundColor Gray
            Write-Host "    Status: $($adapter.Status)" -ForegroundColor Gray
            Write-Host "    Speed: $($adapter.LinkSpeed)" -ForegroundColor Gray
            Write-Host "    MAC: $($adapter.MacAddress)" -ForegroundColor Gray
            if ($adapterInfo.IPAddresses.Count -gt 0) {
                Write-Host "    IP: $($adapterInfo.IPAddresses -join ', ')" -ForegroundColor Gray
            }
            if ($adapterInfo.Gateways.Count -gt 0) {
                Write-Host "    Gateway: $($adapterInfo.Gateways -join ', ')" -ForegroundColor Gray
            }
            Write-Host ""
        }
        
        # Get routing table
        Write-Host "Routing Table:" -ForegroundColor Green
        $routes = Get-NetRoute | Where-Object { $_.DestinationPrefix -ne "0.0.0.0/0" } | Select-Object -First 10
        foreach ($route in $routes) {
            $routeInfo = @{
                Destination = $route.DestinationPrefix
                NextHop = $route.NextHop
                Interface = $route.InterfaceAlias
                Metric = $route.RouteMetric
            }
            $networkInfo.Routes += $routeInfo
            
            Write-Host "  $($route.DestinationPrefix) -> $($route.NextHop) via $($route.InterfaceAlias)" -ForegroundColor White
        }
        Write-Host ""
        
        # Get DNS configuration
        Write-Host "DNS Configuration:" -ForegroundColor Green
        $dnsServers = Get-DnsClientServerAddress -AddressFamily IPv4
        foreach ($dns in $dnsServers) {
            $dnsInfo = @{
                Interface = $dns.InterfaceAlias
                Servers = $dns.ServerAddresses
            }
            $networkInfo.DNS += $dnsInfo
            
            Write-Host "  $($dns.InterfaceAlias): $($dns.ServerAddresses -join ', ')" -ForegroundColor White
        }
        Write-Host ""
        
        # Get active connections
        if ($Detailed) {
            Write-Host "Active Connections:" -ForegroundColor Green
            $connections = Get-NetTCPConnection | Where-Object { $_.State -eq "Established" } | Select-Object -First 10
            foreach ($conn in $connections) {
                $connInfo = @{
                    LocalAddress = $conn.LocalAddress
                    LocalPort = $conn.LocalPort
                    RemoteAddress = $conn.RemoteAddress
                    RemotePort = $conn.RemotePort
                    State = $conn.State
                    OwningProcess = $conn.OwningProcess
                }
                $networkInfo.Connections += $connInfo
                
                Write-Host "  $($conn.LocalAddress):$($conn.LocalPort) -> $($conn.RemoteAddress):$($conn.RemotePort) ($($conn.State))" -ForegroundColor White
            }
            Write-Host ""
        }
        
        if ($ExportPath) {
            $networkInfo | ConvertTo-Json -Depth 10 | Out-File -FilePath $ExportPath -Encoding UTF8
            Write-Host "Network information exported to: $ExportPath" -ForegroundColor Green
        }
        
        return $networkInfo
        
    } catch {
        Write-Error "Failed to get network information: $($_.Exception.Message)"
        return $null
    }
}

function Test-DnsResolution {
    <#
    .SYNOPSIS
        Test DNS resolution for specified domains
    
    .DESCRIPTION
        Tests DNS resolution for one or more domains and displays resolution details.
    
    .PARAMETER Domain
        Single domain to test
    
    .PARAMETER Domains
        Array of domains to test
    
    .PARAMETER RecordType
        DNS record type to query (A, AAAA, MX, CNAME, etc.)
    
    .PARAMETER DnsServer
        Specific DNS server to use
    
    .EXAMPLE
        Test-DnsResolution -Domain "google.com"
        Test DNS resolution for google.com
    
    .EXAMPLE
        Test-DnsResolution -Domains @("google.com", "github.com") -RecordType "A"
        Test A records for multiple domains
    #>
    [CmdletBinding()]
    param(
        [string]$Domain,
        [string[]]$Domains,
        [string]$RecordType = "A",
        [string]$DnsServer
    )
    
    try {
        Write-Host "=== DNS RESOLUTION TEST ===" -ForegroundColor Cyan
        Write-Host ""
        
        $testDomains = if ($Domains) { $Domains } elseif ($Domain) { @($Domain) } else { @("google.com", "github.com", "microsoft.com") }
        
        foreach ($testDomain in $testDomains) {
            Write-Host "Testing: $testDomain" -ForegroundColor White
            Write-Host "----------------------------------------" -ForegroundColor DarkGray
            
            try {
                $dnsParams = @{
                    Name = $testDomain
                    Type = $RecordType
                }
                
                if ($DnsServer) {
                    $dnsParams.Server = $DnsServer
                }
                
                $dnsResult = Resolve-DnsName @dnsParams
                
                Write-Host "DNS Resolution: ✓" -ForegroundColor Green
                foreach ($record in $dnsResult) {
                    if ($record.Type -eq 1) { # A record
                        Write-Host "  A: $($record.IPAddress)" -ForegroundColor Green
                    } elseif ($record.Type -eq 28) { # AAAA record
                        Write-Host "  AAAA: $($record.IPAddress)" -ForegroundColor Green
                    } elseif ($record.Type -eq 5) { # CNAME record
                        Write-Host "  CNAME: $($record.NameHost)" -ForegroundColor Green
                    } elseif ($record.Type -eq 15) { # MX record
                        Write-Host "  MX: $($record.NameExchange) (Priority: $($record.Preference))" -ForegroundColor Green
                    }
                }
                
            } catch {
                Write-Host "DNS Resolution: ✗ Failed" -ForegroundColor Red
                Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
            }
            
            Write-Host ""
        }
        
    } catch {
        Write-Error "Failed to test DNS resolution: $($_.Exception.Message)"
    }
}

function Get-NetworkStatistics {
    <#
    .SYNOPSIS
        Get network statistics and traffic information
    
    .DESCRIPTION
        Retrieves network statistics including bytes sent/received, packets, errors, and performance metrics.
    
    .PARAMETER Duration
        Duration in seconds to collect statistics
    
    .PARAMETER Interface
        Specific network interface to monitor
    
    .PARAMETER Continuous
        Continuous monitoring mode
    
    .PARAMETER Interval
        Collection interval in seconds
    
    .EXAMPLE
        Get-NetworkStatistics -Duration 60
        Collect network statistics for 60 seconds
    
    .EXAMPLE
        Get-NetworkStatistics -Interface "Ethernet" -Continuous
        Continuously monitor Ethernet interface
    #>
    [CmdletBinding()]
    param(
        [int]$Duration = 30,
        [string]$Interface,
        [switch]$Continuous,
        [int]$Interval = 5
    )
    
    try {
        Write-Host "=== NETWORK STATISTICS ===" -ForegroundColor Cyan
        Write-Host ""
        
        $endTime = (Get-Date).AddSeconds($Duration)
        
        do {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Write-Host "Collection Time: $timestamp" -ForegroundColor Green
            Write-Host ""
            
            $adapters = Get-NetAdapter | Where-Object { 
                if ($Interface) { 
                    $_.Name -like "*$Interface*" 
                } else { 
                    $_.Status -eq "Up" 
                } 
            }
            
            foreach ($adapter in $adapters) {
                $stats = Get-NetAdapterStatistics -Name $adapter.Name
                
                Write-Host "Interface: $($adapter.Name)" -ForegroundColor White
                Write-Host "  Bytes Received: $($stats.BytesReceived)" -ForegroundColor Green
                Write-Host "  Bytes Sent: $($stats.BytesSent)" -ForegroundColor Green
                Write-Host "  Packets Received: $($stats.PacketsReceived)" -ForegroundColor Yellow
                Write-Host "  Packets Sent: $($stats.PacketsSent)" -ForegroundColor Yellow
                Write-Host "  Unicast Packets Received: $($stats.UnicastPacketsReceived)" -ForegroundColor Gray
                Write-Host "  Unicast Packets Sent: $($stats.UnicastPacketsSent)" -ForegroundColor Gray
                Write-Host "  Discarded Packets: $($stats.DiscardedPackets)" -ForegroundColor Red
                Write-Host "  Errors: $($stats.Errors)" -ForegroundColor Red
                Write-Host ""
            }
            
            if ($Continuous) {
                Write-Host "Next collection in $Interval seconds..." -ForegroundColor Yellow
                Start-Sleep -Seconds $Interval
            }
            
        } while ($Continuous -and (Get-Date) -lt $endTime)
        
    } catch {
        Write-Error "Failed to get network statistics: $($_.Exception.Message)"
    }
}

function Test-Ping {
    <#
    .SYNOPSIS
        Enhanced ping test with detailed statistics
    
    .DESCRIPTION
        Performs ping tests with detailed statistics and analysis.
    
    .PARAMETER Target
        Target hostname or IP address
    
    .PARAMETER Count
        Number of ping packets to send
    
    .PARAMETER Interval
        Interval between pings in seconds
    
    .PARAMETER Timeout
        Timeout for each ping in milliseconds
    
    .PARAMETER Continuous
        Continuous ping mode
    
    .EXAMPLE
        Test-Ping -Target "google.com" -Count 10
        Ping google.com 10 times
    
    .EXAMPLE
        Test-Ping -Target "8.8.8.8" -Continuous
        Continuously ping 8.8.8.8
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Target,
        [int]$Count = 4,
        [int]$Interval = 1,
        [int]$Timeout = 1000,
        [switch]$Continuous
    )
    
    try {
        Write-Host "=== PING TEST ===" -ForegroundColor Cyan
        Write-Host "Target: $Target" -ForegroundColor Green
        Write-Host ""
        
        $pingCount = 0
        $successCount = 0
        $totalTime = 0
        $minTime = [double]::MaxValue
        $maxTime = 0
        
        do {
            $pingCount++
            Write-Host "Ping #$pingCount to $Target" -ForegroundColor White
            
            try {
                $pingResult = Test-Connection -ComputerName $Target -Count 1 -TimeoutSeconds ($Timeout / 1000)
                if ($pingResult) {
                    $successCount++
                    $responseTime = $pingResult.ResponseTime
                    $totalTime += $responseTime
                    $minTime = [Math]::Min($minTime, $responseTime)
                    $maxTime = [Math]::Max($maxTime, $responseTime)
                    
                    Write-Host "  Reply from $($pingResult.Address): time=$responseTime ms" -ForegroundColor Green
                } else {
                    Write-Host "  Request timed out" -ForegroundColor Red
                }
            } catch {
                Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
            }
            
            if (-not $Continuous -and $pingCount -ge $Count) {
                break
            }
            
            if ($Continuous -or $pingCount -lt $Count) {
                Start-Sleep -Seconds $Interval
            }
            
        } while ($Continuous)
        
        # Statistics
        if ($successCount -gt 0) {
            $avgTime = [Math]::Round($totalTime / $successCount, 2)
            $successRate = [Math]::Round(($successCount / $pingCount) * 100, 2)
            
            Write-Host ""
            Write-Host "Ping Statistics:" -ForegroundColor Cyan
            Write-Host "  Packets: Sent = $pingCount, Received = $successCount, Lost = $($pingCount - $successCount)" -ForegroundColor White
            Write-Host "  Success Rate: $successRate%" -ForegroundColor Green
            Write-Host "  Round-trip times: Min = $minTime ms, Max = $maxTime ms, Average = $avgTime ms" -ForegroundColor Yellow
        }
        
    } catch {
        Write-Error "Failed to perform ping test: $($_.Exception.Message)"
    }
}

function Test-TraceRoute {
    <#
    .SYNOPSIS
        Perform traceroute to specified target
    
    .DESCRIPTION
        Performs traceroute to show the path packets take to reach the target.
    
    .PARAMETER Target
        Target hostname or IP address
    
    .PARAMETER MaxHops
        Maximum number of hops to trace
    
    .PARAMETER Timeout
        Timeout for each hop in milliseconds
    
    .EXAMPLE
        Test-TraceRoute -Target "google.com"
        Trace route to google.com
    
    .EXAMPLE
        Test-TraceRoute -Target "8.8.8.8" -MaxHops 20
        Trace route to 8.8.8.8 with max 20 hops
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Target,
        [int]$MaxHops = 30,
        [int]$Timeout = 1000
    )
    
    try {
        Write-Host "=== TRACEROUTE ===" -ForegroundColor Cyan
        Write-Host "Target: $Target" -ForegroundColor Green
        Write-Host "Max Hops: $MaxHops" -ForegroundColor Green
        Write-Host ""
        
        for ($hop = 1; $hop -le $MaxHops; $hop++) {
            Write-Host "$hop " -NoNewline -ForegroundColor White
            
            $hopTimes = @()
            $hopReached = $false
            
            # Send 3 packets for each hop
            for ($packet = 1; $packet -le 3; $packet++) {
                try {
                    $pingResult = Test-Connection -ComputerName $Target -Count 1 -TimeoutSeconds ($Timeout / 1000) -Ttl $hop
                    if ($pingResult) {
                        $hopTimes += $pingResult.ResponseTime
                        $hopReached = $true
                        Write-Host "$($pingResult.ResponseTime) ms " -NoNewline -ForegroundColor Green
                    } else {
                        Write-Host "* " -NoNewline -ForegroundColor Red
                    }
                } catch {
                    Write-Host "* " -NoNewline -ForegroundColor Red
                }
            }
            
            if ($hopReached) {
                $avgTime = [Math]::Round(($hopTimes | Measure-Object -Average).Average, 2)
                Write-Host "($avgTime ms avg)" -ForegroundColor Yellow
                
                # Check if we reached the target
                if ($pingResult.Address -eq $Target -or $pingResult.Address -eq (Resolve-DnsName -Name $Target -Type A).IPAddress) {
                    Write-Host "Trace complete." -ForegroundColor Green
                    break
                }
            } else {
                Write-Host "Request timed out" -ForegroundColor Red
            }
            
            Start-Sleep -Milliseconds 100
        }
        
    } catch {
        Write-Error "Failed to perform traceroute: $($_.Exception.Message)"
    }
}

# Additional helper functions
function Get-NetworkAdapters { Get-NetAdapter }
function Get-NetworkRoutes { Get-NetRoute }
function Get-NetworkConnections { Get-NetTCPConnection }
function Test-NetworkLatency { Test-Connection }
function Get-NetworkTraffic { Get-NetAdapterStatistics }
function Test-SslCertificate { Get-ChildItem -Path "Cert:\LocalMachine\My" }
function Get-NetworkFirewall { Get-NetFirewallRule }
function Test-NetworkBandwidth { Get-NetAdapterStatistics }
function Get-NetworkTopology { Get-NetRoute }
function Test-NetworkSecurity { Get-NetFirewallProfile }
function Get-NetworkProtocols { Get-NetTransportFilter }
function Test-NetworkQos { Get-NetQosPolicy }
function Get-NetworkDiagnostics { Get-NetAdapter | Get-NetAdapterStatistics }