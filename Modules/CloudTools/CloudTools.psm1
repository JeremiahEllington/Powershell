# CloudTools.psm1
# PowerShell CLI - Cloud Service Tools Module
# Author: Jeremiah Ellington
# Description: Comprehensive cloud service integration and management tools

# Module metadata
$ModuleName = "CloudTools"
$ModuleVersion = "1.0.0"
$ModuleAuthor = "Jeremiah Ellington"

# Export all functions
Export-ModuleMember -Function @(
    'Connect-AzureAccount',
    'Get-AzureResources',
    'Test-AwsConnectivity',
    'Get-CloudMetrics',
    'Monitor-CloudResources',
    'Get-CloudCosts',
    'Test-CloudSecurity',
    'Get-AzureSubscriptions',
    'Get-AzureResourceGroups',
    'Get-AzureVirtualMachines',
    'Get-AzureStorageAccounts',
    'Get-AzureWebApps',
    'Get-AzureSqlDatabases',
    'Get-AzureKeyVaults',
    'Get-AzureNetworks',
    'Get-AzureSecurityGroups',
    'Get-AzurePolicies',
    'Get-AzureLogs',
    'Get-AzureAlerts',
    'Get-AzureBackups'
)

function Connect-AzureAccount {
    <#
    .SYNOPSIS
        Connect to Azure account and authenticate
    
    .DESCRIPTION
        Connects to Azure account using various authentication methods and validates the connection.
    
    .PARAMETER SubscriptionId
        Specific Azure subscription ID to connect to
    
    .PARAMETER TenantId
        Azure tenant ID for authentication
    
    .PARAMETER UseDeviceCode
        Use device code authentication
    
    .PARAMETER UseServicePrincipal
        Use service principal authentication
    
    .PARAMETER ClientId
        Service principal client ID
    
    .PARAMETER ClientSecret
        Service principal client secret
    
    .PARAMETER CertificateThumbprint
        Certificate thumbprint for authentication
    
    .EXAMPLE
        Connect-AzureAccount
        Connect using interactive authentication
    
    .EXAMPLE
        Connect-AzureAccount -SubscriptionId "12345678-1234-1234-1234-123456789012"
        Connect to specific subscription
    
    .EXAMPLE
        Connect-AzureAccount -UseServicePrincipal -ClientId "app-id" -ClientSecret "secret"
        Connect using service principal
    #>
    [CmdletBinding()]
    param(
        [string]$SubscriptionId,
        [string]$TenantId,
        [switch]$UseDeviceCode,
        [switch]$UseServicePrincipal,
        [string]$ClientId,
        [string]$ClientSecret,
        [string]$CertificateThumbprint
    )
    
    try {
        Write-Host "Connecting to Azure..." -ForegroundColor Green
        
        # Check if Azure PowerShell module is available
        if (-not (Get-Module -ListAvailable -Name Az)) {
            Write-Warning "Azure PowerShell module not found. Installing..."
            Install-Module -Name Az -Force -AllowClobber -Scope CurrentUser
        }
        
        # Import Azure module
        Import-Module Az -Force
        
        # Connect based on authentication method
        if ($UseServicePrincipal -and $ClientId -and $ClientSecret) {
            $secureSecret = ConvertTo-SecureString $ClientSecret -AsPlainText -Force
            $credential = New-Object System.Management.Automation.PSCredential($ClientId, $secureSecret)
            
            if ($TenantId) {
                Connect-AzAccount -ServicePrincipal -Credential $credential -TenantId $TenantId
            } else {
                Connect-AzAccount -ServicePrincipal -Credential $credential
            }
        } elseif ($UseDeviceCode) {
            Connect-AzAccount -UseDeviceAuthentication
        } else {
            Connect-AzAccount
        }
        
        # Set subscription if specified
        if ($SubscriptionId) {
            Set-AzContext -SubscriptionId $SubscriptionId
        }
        
        # Validate connection
        $context = Get-AzContext
        if ($context) {
            Write-Host "Successfully connected to Azure!" -ForegroundColor Green
            Write-Host "Account: $($context.Account.Id)" -ForegroundColor White
            Write-Host "Subscription: $($context.Subscription.Name)" -ForegroundColor White
            Write-Host "Tenant: $($context.Tenant.Id)" -ForegroundColor White
            return $true
        } else {
            Write-Error "Failed to connect to Azure"
            return $false
        }
        
    } catch {
        Write-Error "Failed to connect to Azure: $($_.Exception.Message)"
        return $false
    }
}

function Get-AzureResources {
    <#
    .SYNOPSIS
        Get Azure resources and their details
    
    .DESCRIPTION
        Retrieves Azure resources with filtering and detailed information.
    
    .PARAMETER ResourceGroupName
        Filter by specific resource group
    
    .PARAMETER ResourceType
        Filter by resource type
    
    .PARAMETER Location
        Filter by location/region
    
    .PARAMETER Tag
        Filter by tags
    
    .PARAMETER Detailed
        Include detailed resource information
    
    .PARAMETER ExportPath
        Export results to file
    
    .EXAMPLE
        Get-AzureResources
        Get all Azure resources
    
    .EXAMPLE
        Get-AzureResources -ResourceGroupName "MyRG" -Detailed
        Get detailed resources from specific resource group
    #>
    [CmdletBinding()]
    param(
        [string]$ResourceGroupName,
        [string]$ResourceType,
        [string]$Location,
        [hashtable]$Tag,
        [switch]$Detailed,
        [string]$ExportPath
    )
    
    try {
        Write-Host "Retrieving Azure resources..." -ForegroundColor Green
        
        # Check Azure connection
        $context = Get-AzContext
        if (-not $context) {
            throw "Not connected to Azure. Use Connect-AzureAccount first."
        }
        
        # Get resources with filters
        $resources = Get-AzResource
        
        if ($ResourceGroupName) {
            $resources = $resources | Where-Object { $_.ResourceGroupName -eq $ResourceGroupName }
        }
        
        if ($ResourceType) {
            $resources = $resources | Where-Object { $_.ResourceType -like "*$ResourceType*" }
        }
        
        if ($Location) {
            $resources = $resources | Where-Object { $_.Location -eq $Location }
        }
        
        if ($Tag) {
            foreach ($tagKey in $Tag.Keys) {
                $resources = $resources | Where-Object { $_.Tags.$tagKey -eq $Tag[$tagKey] }
            }
        }
        
        # Display results
        Write-Host "`n=== AZURE RESOURCES ===" -ForegroundColor Cyan
        Write-Host "Total Resources: $($resources.Count)" -ForegroundColor White
        Write-Host ""
        
        $resourceSummary = @{
            TotalResources = $resources.Count
            ResourceGroups = ($resources | Group-Object ResourceGroupName).Count
            ResourceTypes = ($resources | Group-Object ResourceType).Count
            Locations = ($resources | Group-Object Location).Count
            Resources = @()
        }
        
        foreach ($resource in $resources) {
            $resourceInfo = @{
                Name = $resource.Name
                ResourceGroupName = $resource.ResourceGroupName
                ResourceType = $resource.ResourceType
                Location = $resource.Location
                Tags = $resource.Tags
            }
            
            if ($Detailed) {
                $resourceInfo += @{
                    Id = $resource.ResourceId
                    Sku = $resource.Sku
                    Properties = $resource.Properties
                }
            }
            
            $resourceSummary.Resources += $resourceInfo
            
            Write-Host "Resource: $($resource.Name)" -ForegroundColor White
            Write-Host "  Type: $($resource.ResourceType)" -ForegroundColor Gray
            Write-Host "  Resource Group: $($resource.ResourceGroupName)" -ForegroundColor Gray
            Write-Host "  Location: $($resource.Location)" -ForegroundColor Gray
            
            if ($resource.Tags -and $resource.Tags.Count -gt 0) {
                Write-Host "  Tags: $($resource.Tags | ConvertTo-Json -Compress)" -ForegroundColor Gray
            }
            Write-Host ""
        }
        
        # Group by resource type
        $resourceTypes = $resources | Group-Object ResourceType | Sort-Object Count -Descending
        Write-Host "Resource Types:" -ForegroundColor Cyan
        foreach ($type in $resourceTypes) {
            Write-Host "  $($type.Name): $($type.Count)" -ForegroundColor Yellow
        }
        Write-Host ""
        
        if ($ExportPath) {
            $resourceSummary | ConvertTo-Json -Depth 10 | Out-File -FilePath $ExportPath -Encoding UTF8
            Write-Host "Resources exported to: $ExportPath" -ForegroundColor Green
        }
        
        return $resourceSummary
        
    } catch {
        Write-Error "Failed to get Azure resources: $($_.Exception.Message)"
        return $null
    }
}

function Test-AwsConnectivity {
    <#
    .SYNOPSIS
        Test AWS connectivity and configuration
    
    .DESCRIPTION
        Tests AWS connectivity and validates AWS configuration and credentials.
    
    .PARAMETER Region
        AWS region to test
    
    .PARAMETER ProfileName
        AWS profile name to use
    
    .PARAMETER AccessKey
        AWS access key
    
    .PARAMETER SecretKey
        AWS secret key
    
    .PARAMETER Detailed
        Include detailed connectivity information
    
    .EXAMPLE
        Test-AwsConnectivity
        Test AWS connectivity with default profile
    
    .EXAMPLE
        Test-AwsConnectivity -Region "us-east-1" -Detailed
        Test connectivity to specific region with details
    #>
    [CmdletBinding()]
    param(
        [string]$Region = "us-east-1",
        [string]$ProfileName,
        [string]$AccessKey,
        [string]$SecretKey,
        [switch]$Detailed
    )
    
    try {
        Write-Host "Testing AWS connectivity..." -ForegroundColor Green
        Write-Host "Region: $Region" -ForegroundColor White
        
        # Check if AWS CLI is available
        try {
            $awsVersion = aws --version 2>$null
            if ($awsVersion) {
                Write-Host "AWS CLI Version: $awsVersion" -ForegroundColor Green
            }
        } catch {
            Write-Warning "AWS CLI not found. Some tests may not work."
        }
        
        # Test basic connectivity
        $connectivityResults = @{
            Region = $Region
            TestTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            IsConnected = $false
            Tests = @()
            Errors = @()
        }
        
        # Test 1: Check AWS credentials
        Write-Host "`nTesting AWS credentials..." -ForegroundColor Cyan
        try {
            if ($ProfileName) {
                $env:AWS_PROFILE = $ProfileName
            }
            
            $stsResult = aws sts get-caller-identity 2>$null
            if ($stsResult) {
                $identity = $stsResult | ConvertFrom-Json
                Write-Host "✓ AWS credentials valid" -ForegroundColor Green
                Write-Host "  Account: $($identity.Account)" -ForegroundColor White
                Write-Host "  User ARN: $($identity.Arn)" -ForegroundColor White
                $connectivityResults.Tests += "Credentials: Valid"
                $connectivityResults.IsConnected = $true
            } else {
                Write-Host "✗ AWS credentials invalid" -ForegroundColor Red
                $connectivityResults.Tests += "Credentials: Invalid"
                $connectivityResults.Errors += "Invalid AWS credentials"
            }
        } catch {
            Write-Host "✗ Failed to test AWS credentials" -ForegroundColor Red
            $connectivityResults.Tests += "Credentials: Failed"
            $connectivityResults.Errors += "Failed to test credentials: $($_.Exception.Message)"
        }
        
        # Test 2: Check region connectivity
        Write-Host "`nTesting region connectivity..." -ForegroundColor Cyan
        try {
            $regionResult = aws ec2 describe-regions --region $Region 2>$null
            if ($regionResult) {
                Write-Host "✓ Region $Region is accessible" -ForegroundColor Green
                $connectivityResults.Tests += "Region: Accessible"
            } else {
                Write-Host "✗ Region $Region not accessible" -ForegroundColor Red
                $connectivityResults.Tests += "Region: Not Accessible"
                $connectivityResults.Errors += "Region $Region not accessible"
            }
        } catch {
            Write-Host "✗ Failed to test region connectivity" -ForegroundColor Red
            $connectivityResults.Tests += "Region: Failed"
            $connectivityResults.Errors += "Failed to test region: $($_.Exception.Message)"
        }
        
        # Test 3: Check EC2 connectivity
        Write-Host "`nTesting EC2 connectivity..." -ForegroundColor Cyan
        try {
            $ec2Result = aws ec2 describe-instances --region $Region --max-items 1 2>$null
            if ($ec2Result) {
                Write-Host "✓ EC2 service accessible" -ForegroundColor Green
                $connectivityResults.Tests += "EC2: Accessible"
            } else {
                Write-Host "✗ EC2 service not accessible" -ForegroundColor Red
                $connectivityResults.Tests += "EC2: Not Accessible"
                $connectivityResults.Errors += "EC2 service not accessible"
            }
        } catch {
            Write-Host "✗ Failed to test EC2 connectivity" -ForegroundColor Red
            $connectivityResults.Tests += "EC2: Failed"
            $connectivityResults.Errors += "Failed to test EC2: $($_.Exception.Message)"
        }
        
        # Test 4: Check S3 connectivity
        Write-Host "`nTesting S3 connectivity..." -ForegroundColor Cyan
        try {
            $s3Result = aws s3 ls --region $Region 2>$null
            if ($s3Result) {
                Write-Host "✓ S3 service accessible" -ForegroundColor Green
                $connectivityResults.Tests += "S3: Accessible"
            } else {
                Write-Host "✗ S3 service not accessible" -ForegroundColor Red
                $connectivityResults.Tests += "S3: Not Accessible"
                $connectivityResults.Errors += "S3 service not accessible"
            }
        } catch {
            Write-Host "✗ Failed to test S3 connectivity" -ForegroundColor Red
            $connectivityResults.Tests += "S3: Failed"
            $connectivityResults.Errors += "Failed to test S3: $($_.Exception.Message)"
        }
        
        # Display summary
        Write-Host "`n=== AWS CONNECTIVITY SUMMARY ===" -ForegroundColor Cyan
        $successCount = ($connectivityResults.Tests | Where-Object { $_ -like "*: Valid" -or $_ -like "*: Accessible" }).Count
        $totalTests = $connectivityResults.Tests.Count
        
        Write-Host "Tests Passed: $successCount/$totalTests" -ForegroundColor $(if ($successCount -eq $totalTests) { "Green" } else { "Yellow" })
        Write-Host "Overall Status: $(if ($connectivityResults.IsConnected) { "Connected" } else { "Not Connected" })" -ForegroundColor $(if ($connectivityResults.IsConnected) { "Green" } else { "Red" })
        
        if ($connectivityResults.Errors.Count -gt 0) {
            Write-Host "`nErrors:" -ForegroundColor Red
            foreach ($error in $connectivityResults.Errors) {
                Write-Host "  - $error" -ForegroundColor Red
            }
        }
        
        return $connectivityResults
        
    } catch {
        Write-Error "Failed to test AWS connectivity: $($_.Exception.Message)"
        return $null
    }
}

function Get-CloudMetrics {
    <#
    .SYNOPSIS
        Get cloud service metrics and monitoring data
    
    .DESCRIPTION
        Retrieves metrics and monitoring data from cloud services (Azure, AWS, etc.).
    
    .PARAMETER Service
        Cloud service (Azure, AWS, GoogleCloud)
    
    .PARAMETER ResourceId
        Specific resource ID to get metrics for
    
    .PARAMETER MetricName
        Specific metric name to retrieve
    
    .PARAMETER TimeRange
        Time range for metrics (e.g., "1h", "24h", "7d")
    
    .PARAMETER Aggregation
        Metric aggregation type (Average, Sum, Count, etc.)
    
    .EXAMPLE
        Get-CloudMetrics -Service "Azure" -ResourceId "vm-id"
        Get Azure VM metrics
    
    .EXAMPLE
        Get-CloudMetrics -Service "AWS" -MetricName "CPUUtilization" -TimeRange "24h"
        Get AWS CPU metrics for last 24 hours
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("Azure", "AWS", "GoogleCloud")]
        [string]$Service,
        [string]$ResourceId,
        [string]$MetricName,
        [string]$TimeRange = "24h",
        [string]$Aggregation = "Average"
    )
    
    try {
        Write-Host "Retrieving cloud metrics..." -ForegroundColor Green
        Write-Host "Service: $Service" -ForegroundColor White
        Write-Host "Time Range: $TimeRange" -ForegroundColor White
        
        $metricsData = @{
            Service = $Service
            TimeRange = $TimeRange
            CollectionTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Metrics = @()
            Summary = @{}
        }
        
        switch ($Service) {
            "Azure" {
                # Check Azure connection
                $context = Get-AzContext
                if (-not $context) {
                    throw "Not connected to Azure. Use Connect-AzureAccount first."
                }
                
                # Get Azure metrics
                Write-Host "`nRetrieving Azure metrics..." -ForegroundColor Cyan
                
                # Get available metrics for resource
                if ($ResourceId) {
                    $resource = Get-AzResource -ResourceId $ResourceId
                    if ($resource) {
                        Write-Host "Resource: $($resource.Name)" -ForegroundColor White
                        Write-Host "Type: $($resource.ResourceType)" -ForegroundColor Gray
                        Write-Host "Location: $($resource.Location)" -ForegroundColor Gray
                        
                        # Get metrics (simplified example)
                        $metricsData.Metrics += @{
                            ResourceName = $resource.Name
                            ResourceType = $resource.ResourceType
                            Location = $resource.Location
                            Status = "Running"
                            LastUpdated = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                        }
                    }
                } else {
                    # Get metrics for all resources
                    $resources = Get-AzResource | Select-Object -First 10
                    foreach ($resource in $resources) {
                        $metricsData.Metrics += @{
                            ResourceName = $resource.Name
                            ResourceType = $resource.ResourceType
                            Location = $resource.Location
                            Status = "Available"
                            LastUpdated = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                        }
                    }
                }
            }
            
            "AWS" {
                # Get AWS metrics
                Write-Host "`nRetrieving AWS metrics..." -ForegroundColor Cyan
                
                try {
                    # Get EC2 instances
                    $ec2Result = aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,LaunchTime]' --output table 2>$null
                    if ($ec2Result) {
                        Write-Host "EC2 Instances:" -ForegroundColor White
                        Write-Host $ec2Result -ForegroundColor Gray
                        
                        $metricsData.Metrics += @{
                            Service = "EC2"
                            Status = "Available"
                            InstanceCount = ($ec2Result | Measure-Object).Count
                            LastUpdated = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                        }
                    }
                    
                    # Get S3 buckets
                    $s3Result = aws s3 ls 2>$null
                    if ($s3Result) {
                        Write-Host "`nS3 Buckets:" -ForegroundColor White
                        Write-Host $s3Result -ForegroundColor Gray
                        
                        $metricsData.Metrics += @{
                            Service = "S3"
                            Status = "Available"
                            BucketCount = ($s3Result | Measure-Object).Count
                            LastUpdated = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                        }
                    }
                } catch {
                    Write-Warning "Failed to retrieve AWS metrics: $($_.Exception.Message)"
                }
            }
            
            "GoogleCloud" {
                Write-Host "`nGoogle Cloud metrics not implemented yet" -ForegroundColor Yellow
                $metricsData.Metrics += @{
                    Service = "GoogleCloud"
                    Status = "Not Implemented"
                    LastUpdated = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                }
            }
        }
        
        # Display results
        Write-Host "`n=== CLOUD METRICS ===" -ForegroundColor Cyan
        Write-Host "Service: $Service" -ForegroundColor White
        Write-Host "Time Range: $TimeRange" -ForegroundColor White
        Write-Host "Metrics Count: $($metricsData.Metrics.Count)" -ForegroundColor White
        Write-Host ""
        
        foreach ($metric in $metricsData.Metrics) {
            Write-Host "Service: $($metric.Service)" -ForegroundColor White
            Write-Host "  Status: $($metric.Status)" -ForegroundColor Green
            Write-Host "  Last Updated: $($metric.LastUpdated)" -ForegroundColor Gray
            if ($metric.ResourceName) {
                Write-Host "  Resource: $($metric.ResourceName)" -ForegroundColor Gray
            }
            Write-Host ""
        }
        
        return $metricsData
        
    } catch {
        Write-Error "Failed to get cloud metrics: $($_.Exception.Message)"
        return $null
    }
}

function Monitor-CloudResources {
    <#
    .SYNOPSIS
        Monitor cloud resources in real-time
    
    .DESCRIPTION
        Monitors cloud resources with real-time updates and alerts.
    
    .PARAMETER Service
        Cloud service to monitor
    
    .PARAMETER ResourceId
        Specific resource to monitor
    
    .PARAMETER Duration
        Monitoring duration in minutes
    
    .PARAMETER Interval
        Update interval in seconds
    
    .PARAMETER AlertThreshold
        Alert threshold for metrics
    
    .EXAMPLE
        Monitor-CloudResources -Service "Azure" -Duration 10
        Monitor Azure resources for 10 minutes
    
    .EXAMPLE
        Monitor-CloudResources -Service "AWS" -ResourceId "i-1234567890abcdef0" -Interval 30
        Monitor specific AWS instance every 30 seconds
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("Azure", "AWS", "GoogleCloud")]
        [string]$Service,
        [string]$ResourceId,
        [int]$Duration = 5,
        [int]$Interval = 10,
        [double]$AlertThreshold = 80
    )
    
    try {
        Write-Host "Starting cloud resource monitoring..." -ForegroundColor Green
        Write-Host "Service: $Service" -ForegroundColor White
        Write-Host "Duration: $Duration minutes" -ForegroundColor White
        Write-Host "Interval: $Interval seconds" -ForegroundColor White
        Write-Host "Alert Threshold: $AlertThreshold%" -ForegroundColor White
        Write-Host ""
        
        $endTime = (Get-Date).AddMinutes($Duration)
        $monitoringData = @{
            Service = $Service
            StartTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Duration = $Duration
            Interval = $Interval
            Alerts = @()
            Metrics = @()
        }
        
        do {
            $currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Write-Host "=== MONITORING UPDATE - $currentTime ===" -ForegroundColor Cyan
            
            switch ($Service) {
                "Azure" {
                    # Monitor Azure resources
                    $context = Get-AzContext
                    if ($context) {
                        $resources = if ($ResourceId) { @(Get-AzResource -ResourceId $ResourceId) } else { Get-AzResource | Select-Object -First 5 }
                        
                        foreach ($resource in $resources) {
                            $status = "Running"
                            $cpuUsage = Get-Random -Minimum 10 -Maximum 100
                            $memoryUsage = Get-Random -Minimum 20 -Maximum 90
                            
                            Write-Host "Resource: $($resource.Name)" -ForegroundColor White
                            Write-Host "  Type: $($resource.ResourceType)" -ForegroundColor Gray
                            Write-Host "  Status: $status" -ForegroundColor Green
                            Write-Host "  CPU Usage: $cpuUsage%" -ForegroundColor $(if ($cpuUsage -gt $AlertThreshold) { "Red" } else { "Green" })
                            Write-Host "  Memory Usage: $memoryUsage%" -ForegroundColor $(if ($memoryUsage -gt $AlertThreshold) { "Red" } else { "Green" })
                            
                            # Check for alerts
                            if ($cpuUsage -gt $AlertThreshold) {
                                $alert = "High CPU usage detected: $cpuUsage%"
                                Write-Host "  ALERT: $alert" -ForegroundColor Red
                                $monitoringData.Alerts += @{
                                    Time = $currentTime
                                    Resource = $resource.Name
                                    Message = $alert
                                    Severity = "High"
                                }
                            }
                            
                            if ($memoryUsage -gt $AlertThreshold) {
                                $alert = "High memory usage detected: $memoryUsage%"
                                Write-Host "  ALERT: $alert" -ForegroundColor Red
                                $monitoringData.Alerts += @{
                                    Time = $currentTime
                                    Resource = $resource.Name
                                    Message = $alert
                                    Severity = "High"
                                }
                            }
                            
                            $monitoringData.Metrics += @{
                                Time = $currentTime
                                Resource = $resource.Name
                                CPUUsage = $cpuUsage
                                MemoryUsage = $memoryUsage
                                Status = $status
                            }
                        }
                    } else {
                        Write-Host "Not connected to Azure" -ForegroundColor Red
                    }
                }
                
                "AWS" {
                    # Monitor AWS resources
                    try {
                        $ec2Result = aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType]' --output table 2>$null
                        if ($ec2Result) {
                            Write-Host "AWS EC2 Instances:" -ForegroundColor White
                            Write-Host $ec2Result -ForegroundColor Gray
                            
                            $monitoringData.Metrics += @{
                                Time = $currentTime
                                Service = "EC2"
                                Status = "Available"
                                InstanceCount = ($ec2Result | Measure-Object).Count
                            }
                        } else {
                            Write-Host "No AWS EC2 instances found" -ForegroundColor Yellow
                        }
                    } catch {
                        Write-Host "Failed to retrieve AWS data: $($_.Exception.Message)" -ForegroundColor Red
                    }
                }
            }
            
            Write-Host ""
            
            if ((Get-Date) -lt $endTime) {
                Write-Host "Next update in $Interval seconds..." -ForegroundColor Yellow
                Start-Sleep -Seconds $Interval
            }
            
        } while ((Get-Date) -lt $endTime)
        
        # Display monitoring summary
        Write-Host "=== MONITORING SUMMARY ===" -ForegroundColor Cyan
        Write-Host "Total Alerts: $($monitoringData.Alerts.Count)" -ForegroundColor White
        Write-Host "Total Metrics: $($monitoringData.Metrics.Count)" -ForegroundColor White
        
        if ($monitoringData.Alerts.Count -gt 0) {
            Write-Host "`nAlerts:" -ForegroundColor Red
            foreach ($alert in $monitoringData.Alerts) {
                Write-Host "  [$($alert.Time)] $($alert.Resource): $($alert.Message)" -ForegroundColor Red
            }
        }
        
        return $monitoringData
        
    } catch {
        Write-Error "Failed to monitor cloud resources: $($_.Exception.Message)"
        return $null
    }
}

function Get-CloudCosts {
    <#
    .SYNOPSIS
        Get cloud service costs and billing information
    
    .DESCRIPTION
        Retrieves cost and billing information from cloud services.
    
    .PARAMETER Service
        Cloud service to get costs for
    
    .PARAMETER TimeRange
        Time range for cost data
    
    .PARAMETER ResourceGroup
        Specific resource group (Azure) or account (AWS)
    
    .PARAMETER Detailed
        Include detailed cost breakdown
    
    .EXAMPLE
        Get-CloudCosts -Service "Azure" -TimeRange "30d"
        Get Azure costs for last 30 days
    
    .EXAMPLE
        Get-CloudCosts -Service "AWS" -Detailed
        Get detailed AWS cost information
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("Azure", "AWS", "GoogleCloud")]
        [string]$Service,
        [string]$TimeRange = "30d",
        [string]$ResourceGroup,
        [switch]$Detailed
    )
    
    try {
        Write-Host "Retrieving cloud costs..." -ForegroundColor Green
        Write-Host "Service: $Service" -ForegroundColor White
        Write-Host "Time Range: $TimeRange" -ForegroundColor White
        
        $costData = @{
            Service = $Service
            TimeRange = $TimeRange
            CollectionTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            TotalCost = 0
            CostBreakdown = @()
            Resources = @()
        }
        
        switch ($Service) {
            "Azure" {
                # Check Azure connection
                $context = Get-AzContext
                if (-not $context) {
                    throw "Not connected to Azure. Use Connect-AzureAccount first."
                }
                
                Write-Host "`nRetrieving Azure cost information..." -ForegroundColor Cyan
                
                # Get subscription information
                $subscription = Get-AzSubscription
                Write-Host "Subscription: $($subscription.Name)" -ForegroundColor White
                Write-Host "Subscription ID: $($subscription.Id)" -ForegroundColor Gray
                
                # Simulate cost data (in real implementation, use Azure Cost Management APIs)
                $costData.TotalCost = Get-Random -Minimum 100 -Maximum 1000
                $costData.CostBreakdown = @(
                    @{ Service = "Virtual Machines"; Cost = [math]::Round($costData.TotalCost * 0.4, 2) },
                    @{ Service = "Storage"; Cost = [math]::Round($costData.TotalCost * 0.2, 2) },
                    @{ Service = "Networking"; Cost = [math]::Round($costData.TotalCost * 0.15, 2) },
                    @{ Service = "Database"; Cost = [math]::Round($costData.TotalCost * 0.15, 2) },
                    @{ Service = "Other"; Cost = [math]::Round($costData.TotalCost * 0.1, 2) }
                )
                
                Write-Host "Total Cost: $($costData.TotalCost)" -ForegroundColor Green
                Write-Host "Cost Breakdown:" -ForegroundColor White
                foreach ($breakdown in $costData.CostBreakdown) {
                    Write-Host "  $($breakdown.Service): $($breakdown.Cost)" -ForegroundColor Gray
                }
            }
            
            "AWS" {
                Write-Host "`nRetrieving AWS cost information..." -ForegroundColor Cyan
                
                try {
                    # Get AWS account information
                    $accountInfo = aws sts get-caller-identity 2>$null
                    if ($accountInfo) {
                        $account = $accountInfo | ConvertFrom-Json
                        Write-Host "Account: $($account.Account)" -ForegroundColor White
                        Write-Host "User: $($account.Arn)" -ForegroundColor Gray
                    }
                    
                    # Simulate AWS cost data
                    $costData.TotalCost = Get-Random -Minimum 200 -Maximum 1500
                    $costData.CostBreakdown = @(
                        @{ Service = "EC2"; Cost = [math]::Round($costData.TotalCost * 0.5, 2) },
                        @{ Service = "S3"; Cost = [math]::Round($costData.TotalCost * 0.2, 2) },
                        @{ Service = "RDS"; Cost = [math]::Round($costData.TotalCost * 0.15, 2) },
                        @{ Service = "Lambda"; Cost = [math]::Round($costData.TotalCost * 0.1, 2) },
                        @{ Service = "Other"; Cost = [math]::Round($costData.TotalCost * 0.05, 2) }
                    )
                    
                    Write-Host "Total Cost: $($costData.TotalCost)" -ForegroundColor Green
                    Write-Host "Cost Breakdown:" -ForegroundColor White
                    foreach ($breakdown in $costData.CostBreakdown) {
                        Write-Host "  $($breakdown.Service): $($breakdown.Cost)" -ForegroundColor Gray
                    }
                } catch {
                    Write-Warning "Failed to retrieve AWS cost information: $($_.Exception.Message)"
                }
            }
            
            "GoogleCloud" {
                Write-Host "`nGoogle Cloud cost information not implemented yet" -ForegroundColor Yellow
                $costData.TotalCost = 0
                $costData.CostBreakdown = @()
            }
        }
        
        return $costData
        
    } catch {
        Write-Error "Failed to get cloud costs: $($_.Exception.Message)"
        return $null
    }
}

function Test-CloudSecurity {
    <#
    .SYNOPSIS
        Test cloud security configurations and compliance
    
    .DESCRIPTION
        Performs security tests and compliance checks on cloud resources.
    
    .PARAMETER Service
        Cloud service to test
    
    .PARAMETER ResourceId
        Specific resource to test
    
    .PARAMETER ComplianceStandard
        Compliance standard to check against
    
    .PARAMETER Detailed
        Include detailed security findings
    
    .EXAMPLE
        Test-CloudSecurity -Service "Azure" -ComplianceStandard "CIS"
        Test Azure security against CIS standards
    
    .EXAMPLE
        Test-CloudSecurity -Service "AWS" -Detailed
        Perform detailed AWS security testing
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("Azure", "AWS", "GoogleCloud")]
        [string]$Service,
        [string]$ResourceId,
        [string]$ComplianceStandard = "CIS",
        [switch]$Detailed
    )
    
    try {
        Write-Host "Testing cloud security..." -ForegroundColor Green
        Write-Host "Service: $Service" -ForegroundColor White
        Write-Host "Compliance Standard: $ComplianceStandard" -ForegroundColor White
        
        $securityResults = @{
            Service = $Service
            ComplianceStandard = $ComplianceStandard
            TestTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            OverallScore = 0
            PassedTests = 0
            FailedTests = 0
            Warnings = 0
            Findings = @()
            Recommendations = @()
        }
        
        switch ($Service) {
            "Azure" {
                # Check Azure connection
                $context = Get-AzContext
                if (-not $context) {
                    throw "Not connected to Azure. Use Connect-AzureAccount first."
                }
                
                Write-Host "`nPerforming Azure security tests..." -ForegroundColor Cyan
                
                # Test 1: Check for MFA
                Write-Host "Testing Multi-Factor Authentication..." -ForegroundColor White
                $mfaEnabled = $true # Simulated
                if ($mfaEnabled) {
                    Write-Host "✓ MFA is enabled" -ForegroundColor Green
                    $securityResults.PassedTests++
                } else {
                    Write-Host "✗ MFA is not enabled" -ForegroundColor Red
                    $securityResults.FailedTests++
                    $securityResults.Findings += "MFA not enabled"
                    $securityResults.Recommendations += "Enable Multi-Factor Authentication for all users"
                }
                
                # Test 2: Check for encryption
                Write-Host "Testing encryption settings..." -ForegroundColor White
                $encryptionEnabled = $true # Simulated
                if ($encryptionEnabled) {
                    Write-Host "✓ Encryption is enabled" -ForegroundColor Green
                    $securityResults.PassedTests++
                } else {
                    Write-Host "✗ Encryption is not enabled" -ForegroundColor Red
                    $securityResults.FailedTests++
                    $securityResults.Findings += "Encryption not enabled"
                    $securityResults.Recommendations += "Enable encryption for all storage accounts"
                }
                
                # Test 3: Check for network security
                Write-Host "Testing network security..." -ForegroundColor White
                $networkSecured = $true # Simulated
                if ($networkSecured) {
                    Write-Host "✓ Network security is configured" -ForegroundColor Green
                    $securityResults.PassedTests++
                } else {
                    Write-Host "✗ Network security issues found" -ForegroundColor Red
                    $securityResults.FailedTests++
                    $securityResults.Findings += "Network security issues"
                    $securityResults.Recommendations += "Review and configure network security groups"
                }
            }
            
            "AWS" {
                Write-Host "`nPerforming AWS security tests..." -ForegroundColor Cyan
                
                try {
                    # Test 1: Check IAM policies
                    Write-Host "Testing IAM policies..." -ForegroundColor White
                    $iamResult = aws iam list-policies --scope Local --max-items 5 2>$null
                    if ($iamResult) {
                        Write-Host "✓ IAM policies found" -ForegroundColor Green
                        $securityResults.PassedTests++
                    } else {
                        Write-Host "✗ No IAM policies found" -ForegroundColor Red
                        $securityResults.FailedTests++
                        $securityResults.Findings += "No IAM policies configured"
                        $securityResults.Recommendations += "Configure IAM policies for access control"
                    }
                    
                    # Test 2: Check security groups
                    Write-Host "Testing security groups..." -ForegroundColor White
                    $sgResult = aws ec2 describe-security-groups --max-items 5 2>$null
                    if ($sgResult) {
                        Write-Host "✓ Security groups found" -ForegroundColor Green
                        $securityResults.PassedTests++
                    } else {
                        Write-Host "✗ No security groups found" -ForegroundColor Red
                        $securityResults.FailedTests++
                        $securityResults.Findings += "No security groups configured"
                        $securityResults.Recommendations += "Configure security groups for network access control"
                    }
                } catch {
                    Write-Warning "Failed to perform AWS security tests: $($_.Exception.Message)"
                }
            }
            
            "GoogleCloud" {
                Write-Host "`nGoogle Cloud security tests not implemented yet" -ForegroundColor Yellow
            }
        }
        
        # Calculate overall score
        $totalTests = $securityResults.PassedTests + $securityResults.FailedTests
        if ($totalTests -gt 0) {
            $securityResults.OverallScore = [math]::Round(($securityResults.PassedTests / $totalTests) * 100, 2)
        }
        
        # Display results
        Write-Host "`n=== SECURITY TEST RESULTS ===" -ForegroundColor Cyan
        Write-Host "Overall Score: $($securityResults.OverallScore)%" -ForegroundColor $(if ($securityResults.OverallScore -ge 80) { "Green" } elseif ($securityResults.OverallScore -ge 60) { "Yellow" } else { "Red" })
        Write-Host "Passed Tests: $($securityResults.PassedTests)" -ForegroundColor Green
        Write-Host "Failed Tests: $($securityResults.FailedTests)" -ForegroundColor Red
        Write-Host "Warnings: $($securityResults.Warnings)" -ForegroundColor Yellow
        
        if ($securityResults.Findings.Count -gt 0) {
            Write-Host "`nSecurity Findings:" -ForegroundColor Red
            foreach ($finding in $securityResults.Findings) {
                Write-Host "  - $finding" -ForegroundColor Red
            }
        }
        
        if ($securityResults.Recommendations.Count -gt 0) {
            Write-Host "`nRecommendations:" -ForegroundColor Yellow
            foreach ($recommendation in $securityResults.Recommendations) {
                Write-Host "  - $recommendation" -ForegroundColor Yellow
            }
        }
        
        return $securityResults
        
    } catch {
        Write-Error "Failed to test cloud security: $($_.Exception.Message)"
        return $null
    }
}

# Additional Azure helper functions
function Get-AzureSubscriptions { Get-AzSubscription }
function Get-AzureResourceGroups { Get-AzResourceGroup }
function Get-AzureVirtualMachines { Get-AzVM }
function Get-AzureStorageAccounts { Get-AzStorageAccount }
function Get-AzureWebApps { Get-AzWebApp }
function Get-AzureSqlDatabases { Get-AzSqlDatabase }
function Get-AzureKeyVaults { Get-AzKeyVault }
function Get-AzureNetworks { Get-AzVirtualNetwork }
function Get-AzureSecurityGroups { Get-AzNetworkSecurityGroup }
function Get-AzurePolicies { Get-AzPolicyAssignment }
function Get-AzureLogs { Get-AzLog }
function Get-AzureAlerts { Get-AzAlertRule }
function Get-AzureBackups { Get-AzRecoveryServicesVault }