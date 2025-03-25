[CmdletBinding()]
param (
    [Parameter(Mandatory = $false, HelpMessage = "e.g. @('Standard_D2s_v3', 'Standard_D4s_v3')")]
    [string[]]$SKUs = @(),

    [Parameter(Mandatory = $false, HelpMessage = "e.g. @('eastus', 'westus')")]
    [string[]]$Locations = @(),

    [Parameter(Mandatory = $false, HelpMessage = "e.g. @('00000000-0000-0000-0000-000000000000')")]
    [string[]]$SubscriptionIds = @(),

    [Parameter(Mandatory = $false, HelpMessage = "Location to download normalized list of VM SKUs")]
    [string]$MeterDataUri = "https://ccmstorageprod.blob.core.windows.net/costmanagementconnector-data/AutofitComboMeterData.csv",

    [Parameter(Mandatory = $false, HelpMessage = "Normalize output to physical availability zones")]
    [switch]$UsePhysicalZones = $false,

    [Parameter(Mandatory = $false, HelpMessage = "Concurrent threads to use.  Set to '0' for auto-detect")]
    [ValidateRange(0, 40)]
    [int]$Threads = 2,

    [Parameter(Mandatory = $false, HelpMessage = "Output file name")]
    [string]$OutputFile = "QuotaQuery.csv"
)

function Get-SKUDetails {
    Write-Host "Downloading VM SKU Details"
    [string]$meterDataFile = $MeterDataUri.Split('/')[-1]
    Invoke-WebRequest -Uri $MeterDataUri -OutFile $meterDataFile
    $meterData = Get-Content $meterDataFile | ConvertFrom-Csv
    return ($meterData | Select-Object -Property NormalizedSKU -Unique | Where-Object { $_.NormalizedSKU -notlike "*sql*" }).NormalizedSKU
}

function Get-SubscriptionIds {
    Write-Host "Listing Subscriptions"
    return (Get-AzSubscription -TenantId ((Get-AzContext).Tenant.TenantId) | Select-Object -ExpandProperty SubscriptionId)
}

function Get-LastChar {
    param (
        [string]$inputString
    )
    
    if ([string]::IsNullOrEmpty($inputString)) {
        return ""
    }
    return $inputString[-1]
}

function Get-Locations {
    Write-Host "Listing Locations"
    return (Get-AzLocation | Where-Object { $_.RegionType -eq 'Physical' -and $_.PhysicalLocation -ne "" -and $_.Location } | Select-Object -Property Location -Unique).Location
}

function Get-ZonePeers {
    param (
        [string]$SubscriptionId
    )
    Write-Host "Get Zone Peering Information for subscription $SubscriptionId"
    $uri = "{0}subscriptions/{1}/locations?api-version=2022-12-01" -f (Get-AzContext).Environment.ResourceManagerUrl, $SubscriptionId
    $response = Invoke-AzRest -Method GET -Uri $uri
    return ($response.Content | ConvertFrom-Json).value
}

function Get-QuotaDetails {
    param (
        [string]$SubscriptionId,
        [string[]]$Locations,
        [string[]]$SKUs,
        [string]$OutputFile
    )

    $start = Get-Date
    try {
        $Subscription = Get-AzSubscription -SubscriptionId $SubscriptionId -WarningAction SilentlyContinue
        if ($null -eq $Subscription) {
            throw "Subscription not found"
        }

        Set-AzContext -SubscriptionId $Subscription.Id -WarningAction SilentlyContinue | Out-Null

        if($UsePhysicalZones)
        {
            $zonePeers = Get-ZonePeers -SubscriptionId $SubscriptionId
            if ($zonePeers.Count -eq 0) {
                Write-Host "No Zone Peering Information found for subscription $SubscriptionId" -ForegroundColor Yellow
            }
        }

        #"Querying: $SubscriptionId - $($Subscription.Name)"
        #$computeSKUs = Get-AzComputeResourceSku -ErrorAction SilentlyContinue | Where-Object { $_.ResourceType -eq 'virtualMachines' } | Sort-Object -Property Name, LocationInfo.Location
        foreach ($Location in $Locations) {
            "Querying: $SubscriptionId - $($Subscription.Name) - $Location"
            $computeSKUs = Get-AzComputeResourceSku -Location $Location -ErrorAction SilentlyContinue | Where-Object { $_.ResourceType -eq 'virtualMachines' } #| Sort-Object -Property Name, LocationInfo.Location
            $vmUsage = Get-AZVMUsage -Location $Location -ErrorAction SilentlyContinue
            $availabilityZoneMappings = ($zonePeers | Where-Object { $_.name -like $Location -and $_.type -eq "Region"}).availabilityZoneMappings
            foreach ($SKU in $SKUs) {
                $filteredSku = $computeSKUs | Where-Object { $_.Name.ToLowerInvariant() -eq $SKU.ToLowerInvariant() -and $_.LocationInfo.Location -like $Location }
                $skuUsage = $vmUsage | Select-Object -ExpandProperty Name -Property CurrentValue, Limit | Where-Object { $_.Value -eq $filteredSku.Family }
                if ($null -eq $filteredSku ) {
                    #Write-Host "filteredSku not found for $SKU in $Location" -ForegroundColor Yellow
                    continue
                }

                if ($null -eq $skuUsage) {
                    #Write-Host "skuUsage not found for $SKU in $Location" -ForegroundColor Yellow
                    continue
                }

                $zones = @($filteredSku.LocationInfo.Zones)
                if($UsePhysicalZones)
                {
                    for ($i = 0; $i -lt $zones.Length; $i++) {
                        $zones[$i] = Get-LastChar(($availabilityZoneMappings | Where-Object {$_.LogicalZone -like $zones[$i]}).physicalZone)
                    }
                }
                
                $auditedSku = [PSCustomObject]@{
                    TenantId         = $Subscription.TenantId
                    SubscriptionId   = $Subscription.Id
                    SubscriptionName = $Subscription.Name
                    Location         = $Location
                    Family           = $skuUsage.LocalizedValue
                    Size             = $filteredSku.Name
                    RegionRestricted = 'False'
                    ZonesPresent     = ($zones | Sort-Object) -join ","
                    ZonesRestricted  = ''
                    CoresUsed        = $skuUsage.CurrentValue
                    CoresTotal       = $skuUsage.Limit
                    CoresRequested   = ''
                    ZonesRequested  = ''
                }

                foreach ($restriction in $filteredSku.Restrictions) {
                    if ($restriction.Type -like "Zone") {
                        $zoneRestrictions = @($restriction.RestrictionInfo.Zones)
                        if($UsePhysicalZones)
                        {
                            for ($i = 0; $i -lt $zoneRestrictions.Length; $i++) {
                                $zoneRestrictions[$i] = Get-LastChar(($availabilityZoneMappings | Where-Object {$_.LogicalZone -like $zoneRestrictions[$i]}).physicalZone)
                            }
                        }
                        $auditedSku.ZonesRestricted = ($zoneRestrictions | Sort-Object) -join ","
                    }
                    elseif ($restriction.Type -like "Location") {
                        $auditedSku.RegionRestricted = 'True'
                    }
                }

                $auditedSku | ConvertTo-Csv -NoHeader | Out-File -Force -Append -FilePath .\$OutputFile
            }
        }
    }
    catch {
        Write-Host "Failed Querying Subscription ID: $SubscriptionId" -ForegroundColor Yellow
        $_.Exception.Message
    }
    finally {
        $end = Get-Date
        "Processed: $SubscriptionId - $($Subscription.Name) in $([math]::Round((New-TimeSpan -Start $start -End $end).TotalSeconds, 2)) seconds"
    }
}

# Main script execution
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'SilentlyContinue'
$begin = Get-Date
$csvHeaderString = "TenantId,SubscriptionId,SubscriptionName,Location,Family,Size,RegionRestricted,ZonesPresent,ZonesRestricted,CoresUsed,CoresTotal,CoresRequested,ZonesRequested"

if($Threads -eq 0)
{
    try {
        $spec = Get-WmiObject -Class Win32_Processor | Select-Object -Property NumberOfCores, NumberOfLogicalProcessors
        if($spec.NumberOfLogicalProcessors -gt $spec.NumberOfCores) {
            # Hyper-threading is enabled.  Exclude e-cores.
            $Threads = $spec.NumberOfLogicalProcessors - $spec.NumberOfCores
        }
        else {
            # Hyper-threading is disabled.  Use all cores.
            $Threads = $spec.NumberOfCores
        }
    }
    catch {
        $Threads = 1
    }
}

if ($SKUs.Count -eq 0) {
    $SKUs = Get-SKUDetails
}

if ($SubscriptionIds.Count -eq 0) {
    $SubscriptionIds = Get-SubscriptionIds
}

if ($Locations.Count -eq 0) {
    $Locations = Get-Locations | Sort-Object
} else {
    $Locations = $Locations | Sort-Object
}

if($UsePhysicalZones)
{
    Write-Host "Output will be normalized to physical availability zones"
}
else {
    Write-Host "Output will not be normalized to physical availability zones"
}

Write-Host "Querying $($SubscriptionIds.Count) subscriptions with $($SKUs.Count) SKUs in $($Locations.Count) locations using $Threads threads"
$funcDef = ${function:Get-QuotaDetails}.ToString()
$SubscriptionIds | Foreach-Object -ThrottleLimit $Threads -Parallel {
    ${function:Get-QuotaDetails} = $using:funcDef
    if($USING:Threads -gt 1) { $outFile = "QuotaQuery_{0}.csv" -f $PSItem } else { $outFile = $USING:OutputFile }
    $USING:csvHeaderString | Out-File -Force $outFile
    Get-QuotaDetails -SubscriptionId $_ -Locations $USING:Locations -SKUs $USING:SKUs -outputFile $outFile
}


# Merge CSV files if multiple threads are used
if($Threads -gt 1) {
    Write-Host "Merging CSV files"
    $csvHeaderString | Out-File -Force -FilePath $OutputFile
    Get-ChildItem -Path .\QuotaQuery_*.csv | ForEach-Object {
        Get-Content $_.FullName | Select-Object -Skip 1 | Add-Content $OutputFile
        Remove-Item $_.FullName
    }
}

Write-Host "Output written to $OutputFile"
$end = Get-Date
Write-Host "Processed $($SubscriptionIds.Count) subscriptions in $([math]::Round((New-TimeSpan -Start $begin -End $end).TotalSeconds, 2)) seconds"