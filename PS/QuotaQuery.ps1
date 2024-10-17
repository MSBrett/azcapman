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
    
    [Parameter(Mandatory = $false, HelpMessage = "e.g. @('00000000-0000-0000-0000-000000000000')")]
    [string]$OutputFile = "QuotaQuery.csv",

    [Parameter(Mandatory = $false, HelpMessage = "Normalize output to physical availability zones")]
    [switch]$UsePhysicalZones = $false
)

function Get-SKUDetails {
    Write-Host "Downloading VM SKU Details"
    [string]$meterDataFile = $MeterDataUri.Split('/')[$MeterDataUri.Split('/').Length - 1]
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
    if ($inputString.Length -lt 1) {
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
    $uri = "{0}subscriptions/{1}/locations?api-version=2022-12-01" -f $resourceManagerUrl, $SubscriptionId
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

    try {
        $Subscription = Get-AzSubscription -SubscriptionId $SubscriptionId -WarningAction SilentlyContinue
        if ($null -eq $Subscription) {
            throw "Subscription not found"
        }

        Set-AzContext -SubscriptionId $Subscription.Id -WarningAction SilentlyContinue | Out-Null
        if ((Get-AzResourceProvider -ListAvailable | Where-Object { $_.ProviderNamespace -like 'Microsoft.Capacity' }).RegistrationState -notlike 'Registered') {
            try {
                Register-AzResourceProvider -ProviderNamespace Microsoft.Capacity
            }
            catch {
                Write-Host "Failed Registering Resource Provider: Microsoft.Capacity" -ForegroundColor Yellow
            }
        }

        if($UsePhysicalZones)
        {
            $zonePeers = Get-ZonePeers -SubscriptionId $SubscriptionId
            if ($zonePeers.Count -eq 0) {
                Write-Host "No Zone Peering Information found for subscription $SubscriptionId" -ForegroundColor Yellow
            }
        }
    
        Write-Host "Querying Subscription: $($Subscription.Name)"
        foreach ($Location in $Locations) {
            Write-Host "    Querying Region: $Location"
            $computeSKUs = Get-AzComputeResourceSku -Location $Location -ErrorAction SilentlyContinue | Where-Object { $_.ResourceType -eq 'virtualMachines' }
            $vmUsage = Get-AZVMUsage -Location $Location -ErrorAction SilentlyContinue
            $availabilityZoneMappings = ($zonePeers | Where-Object { $_.name -like $Location -and $_.type -eq "Region"}).availabilityZoneMappings
            foreach ($SKU in $SKUs) {
                Write-Host -NoNewline "."
                $filteredSku = $computeSKUs | Where-Object { $_.Name.ToLowerInvariant() -eq $SKU.ToLowerInvariant() -and $_.LocationInfo.Location -like $Location }
                $skuUsage = $vmUsage | Select-Object -ExpandProperty Name -Property CurrentValue, Limit | Where-Object { $_.Value -eq $filteredSku.Family }
                if ($null -eq $filteredSku) {
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
            Write-Host ""
        }
    }
    catch {
        Write-Host "Failed Querying Subscription ID: $SubscriptionId" -ForegroundColor Yellow
        $_.Exception.Message
    }
}

# Main script execution
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'SilentlyContinue'
$csvHeaderString = "TenantId,SubscriptionId,SubscriptionName,Location,Family,Size,RegionRestricted,ZonesPresent,ZonesRestricted,CoresUsed,CoresTotal"
$csvHeaderString | Out-File -Force -FilePath $OutputFile
$resourceManagerUrl = (Get-AzContext).Environment.ResourceManagerUrl

if ($SKUs.Count -eq 0) {
    $SKUs = Get-SKUDetails
}

if ($SubscriptionIds.Count -eq 0) {
    $SubscriptionIds = Get-SubscriptionIds
}

if ($Locations.Count -eq 0) {
    $Locations = Get-Locations
}

if($UsePhysicalZones)
{
    Write-Host "Output will be normalized to physical availability zones"
}
else {
    Write-Host "Output will not be normalized to physical availability zones"
}

foreach ($SubscriptionId in $SubscriptionIds) {
    Get-QuotaDetails -SubscriptionId $SubscriptionId -Locations $Locations -SKUs $SKUs -outputFile $OutputFile
}

Write-Host ""
Get-Content $OutputFile | ConvertFrom-Csv | Format-Table -AutoSize