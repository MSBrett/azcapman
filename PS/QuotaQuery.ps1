[CmdletBinding()]
param (
    $SKUs = @(),
    $Locations = @(),
    $SubscriptionIds = @(),
    [string]$outputFile = "QuotaQuery.csv"
)

[string]$meterDataUri = "https://ccmstorageprod.blob.core.windows.net/costmanagementconnector-data/AutofitComboMeterData.csv"
[string]$meterDataFile = "AutofitComboMeterData.csv"

if(([string]::IsNullOrEmpty($SKUs)) -or ($SKUs.Count -eq 0))
{
    Write-Host ("Downloading VM SKU Details")
    Invoke-WebRequest -Uri $meterDataUri -OutFile $meterDataFile
    $meterData = Get-Content $meterDataFile | ConvertFrom-Csv
    $SKUs = ($meterData | Select-Object -Property NormalizedSKU -Unique | Where-Object { $_.NormalizedSKU -notlike "*sql*" }).NormalizedSKU
}

if(([string]::IsNullOrEmpty($SubscriptionIds)) -or ($SubscriptionIds.Count -eq 0))
{
    Write-Host ("List Subscriptions")
    $SubscriptionIds = (Get-AzSubscription -TenantId ((Get-AzContext).Tenant.TenantId) | Select-Object SubscriptionId).SubscriptionId
}

if(([string]::IsNullOrEmpty($Locations)) -or ($Locations.Count -eq 0))
{
    Write-Host ("List Locations")
    $Locations = (Get-AzLocation | Where-Object { $_.RegionType -eq 'Physical' -and $_.PhysicalLocation -ne "" -and $_.Location } | Select-Object -Property Location -Unique).Location
}


$ErrorActionPreference = 'Stop'
$VerbosePreference = 'SilentlyContinue'
$csvHeaderString = "TenantId,SubscriptionId,SubscriptionName,Location,Family,Size,RegionRestricted,ZonesPresent,ZonesRestricted,CoresUsed,CoresTotal"
$csvHeaderString | Out-File -Force -FilePath .\$outputFile
foreach ($SubscriptionId in $SubscriptionIds) {
    try {
        $Subscription = Get-AzSubscription -SubscriptionId $SubscriptionId -WarningAction SilentlyContinue
        if ($null -eq $Subscription) {
            Throw 
        }

        Set-AzContext -SubscriptionId $Subscription.Id -WarningAction SilentlyContinue | out-null
        if ((Get-AzResourceProvider -ListAvailable | Where-Object { $_.ProviderNamespace -like 'Microsoft.Capacity' }).RegistrationState -notlike 'Registered') {
            try {
                Register-AzResourceProvider -ProviderNamespace Microsoft.Capacity
            }
            catch {
                Write-Host ("Failed Registering Resource Provider: Microsoft.Capacity") -ForegroundColor Yellow
            }
        }

        Write-Host ("Querying Subscription: {0}" -f $Subscription.Name)
        foreach ($Location in $Locations) {
            Write-Host ("    Querying Region: {0}" -f $Location)
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
        Write-Host ("Failed Querying Subscription ID: {0}" -f $SubscriptionId) -ForegroundColor Yellow
    }
}

Get-Content $outputFile | ConvertFrom-Csv | Format-Table -AutoSize
