

param(
    [string]$meterDataUri = "https://ccmstorageprod.blob.core.windows.net/costmanagementconnector-data/AutofitComboMeterData.csv",
    [string]$tenantId = (Get-AzContext).Tenant.Id,
    [string]$outputFile = "ZoneInfo.csv"
)

$ErrorActionPreference = 'Continue'
$VerbosePreference = 'SilentlyContinue'

$csvHeaderString = "TenantId,SubscriptionId,SubscriptionName,Location,Family,Size,RegionRestricted,ZonesPresent,ZonesRestricted,CoresUsed,CoresTotal"
$meterDataFile = "AutofitComboMeterData.csv"

Invoke-WebRequest -Uri $meterDataUri -OutFile $meterDataFile
$csvHeaderString | Out-File -Force -FilePath .\$outputFile
$meterData = Get-Content $meterDataFile | ConvertFrom-Csv
$vmSkus = $meterData | Select-Object -Property NormalizedSKU -Unique | Where-Object { $_.NormalizedSKU -notlike "*sql*" }
$subscriptions = Get-AzSubscription -tenantId $tenantId
$locations = Get-AzLocation | Where-Object { $_.RegionType -eq 'Physical' -and $_.PhysicalLocation -ne "" -and $_.Location } | Sort-Object -Property Location
foreach ($subscription in $subscriptions) {
    Set-AzContext -SubscriptionId $Subscription.Id -Tenant $tenantId | out-null
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
        Write-Host -NoNewline ("    Querying Region: {0}" -f $Location.DisplayName)
        $computeSKUs = Get-AzComputeResourceSku -Location $Location.Location -ErrorAction SilentlyContinue | Where-Object { $_.ResourceType -eq 'virtualMachines' }
        $vmUsage = Get-AZVMUsage -Location $Location.Location -ErrorAction SilentlyContinue
        foreach ($vmSku in $vmSkus) {
            Write-Host -NoNewline "."
            $filteredSku = $computeSKUs | Where-Object { $_.Name.ToLowerInvariant() -eq $vmSku.NormalizedSKU.ToLowerInvariant() -and $_.LocationInfo.Location -like $Location.Location }
            $skuUsage = $vmUsage | Select-Object -ExpandProperty Name -Property CurrentValue, Limit | Where-Object { $_.Value -eq $filteredSku.Family }
            if ($null -eq $filteredSku) {
                continue
            }
            
            $auditedSku = [PSCustomObject]@{
                TenantId         = $Subscription.TenantId
                SubscriptionId   = $Subscription.Id
                SubscriptionName = $Subscription.Name
                Location         = $Location.DisplayName
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

Get-Content .\$outputFile | ConvertFrom-Csv | Format-Table -AutoSize