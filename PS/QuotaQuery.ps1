[CmdletBinding()]
param (
    [Parameter(Mandatory = $false, HelpMessage = "e.g. @('Standard_D2s_v3', 'Standard_D4s_v3')")]
    [string[]]$SKUs = @(),

    [Parameter(Mandatory = $false, HelpMessage = "e.g. @('eastus', 'westus')")]
    [string[]]$Locations = @(),

    [Parameter(Mandatory = $false, HelpMessage = "e.g. @('00000000-0000-0000-0000-000000000000')")]
    [string[]]$SubscriptionIds = @(),

    [Parameter(Mandatory = $false, HelpMessage = "Location to download normalized list of VM SKUs")]
    [string]$meterDataUri = "https://ccmstorageprod.blob.core.windows.net/costmanagementconnector-data/AutofitComboMeterData.csv",
    
    [Parameter(Mandatory = $false, HelpMessage = "e.g. @('00000000-0000-0000-0000-000000000000')")]
    [string]$outputFile = "QuotaQuery.csv"
)

function Get-SKUDetails {
    Write-Host "Downloading VM SKU Details"
    [string]$meterDataFile = $meterDataUri.Split('/')[$meterDataUri.Split('/').Length - 1]
    Invoke-WebRequest -Uri $meterDataUri -OutFile $meterDataFile
    $meterData = Get-Content $meterDataFile | ConvertFrom-Csv
    return ($meterData | Select-Object -Property NormalizedSKU -Unique | Where-Object { $_.NormalizedSKU -notlike "*sql*" }).NormalizedSKU
}

function Get-SubscriptionIds {
    Write-Host "Listing Subscriptions"
    return (Get-AzSubscription -TenantId ((Get-AzContext).Tenant.TenantId) | Select-Object -ExpandProperty SubscriptionId)
}

function Get-Locations {
    Write-Host "Listing Locations"
    return (Get-AzLocation | Where-Object { $_.RegionType -eq 'Physical' -and $_.PhysicalLocation -ne "" -and $_.Location } | Select-Object -Property Location -Unique).Location
}

function Get-QuotaDetails {
    param (
        [string]$SubscriptionId,
        [string[]]$Locations,
        [string[]]$SKUs,
        [string]$outputFile
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

        Write-Host "Querying Subscription: $($Subscription.Name)"
        foreach ($Location in $Locations) {
            Write-Host "    Querying Region: $Location"
            $computeSKUs = Get-AzComputeResourceSku -Location $Location -ErrorAction SilentlyContinue | Where-Object { $_.ResourceType -eq 'virtualMachines' }
            $vmUsage = Get-AZVMUsage -Location $Location -ErrorAction SilentlyContinue
            foreach ($SKU in $SKUs) {
                Write-Host -NoNewline "."
                $filteredSku = $computeSKUs | Where-Object { $_.Name.ToLowerInvariant() -eq $SKU.ToLowerInvariant() -and $_.LocationInfo.Location -like $Location }
                $skuUsage = $vmUsage | Select-Object -ExpandProperty Name -Property CurrentValue, Limit | Where-Object { $_.Value -eq $filteredSku.Family }
                if ($null -eq $filteredSku) {
                    continue
                }

                $auditedSku = [PSCustomObject]@{
                    TenantId         = $Subscription.TenantId
                    SubscriptionId   = $Subscription.Id
                    SubscriptionName = $Subscription.Name
                    Location         = $Location
                    Family           = $skuUsage.LocalizedValue
                    Size             = $filteredSku.Name
                    RegionRestricted = 'False'
                    ZonesPresent     = ($filteredSku.LocationInfo.Zones -join ",")
                    ZonesRestricted  = ''
                    CoresUsed        = $skuUsage.CurrentValue
                    CoresTotal       = $skuUsage.Limit
                }

                foreach ($restriction in $filteredSku.Restrictions) {
                    if ($restriction.Type -like "Zone") {
                        $auditedSku.ZonesRestricted = $restriction.RestrictionInfo.Zones -join ","
                    }
                    elseif ($restriction.Type -like "Location") {
                        $auditedSku.RegionRestricted = 'True'
                    }
                }

                $auditedSku | ConvertTo-Csv -NoHeader | Out-File -Force -Append -FilePath .\$outputFile
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
$csvHeaderString | Out-File -Force -FilePath $outputFile

if ($SKUs.Count -eq 0) {
    $SKUs = Get-SKUDetails
}

if ($SubscriptionIds.Count -eq 0) {
    $SubscriptionIds = Get-SubscriptionIds
}

if ($Locations.Count -eq 0) {
    $Locations = Get-Locations
}

foreach ($SubscriptionId in $SubscriptionIds) {
    Get-QuotaDetails -SubscriptionId $SubscriptionId -Locations $Locations -SKUs $SKUs -outputFile $outputFile
}

Write-Host ""
Get-Content $outputFile | ConvertFrom-Csv | Format-Table -AutoSize