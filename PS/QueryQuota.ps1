[CmdletBinding()]
param (
    $SKUs = @('Standard_D2s_v5', `
            'Standard_E2s_v5', `
            'Standard_F2s_v2'),
    $Families = @('standardDSv5Family', `
            'standardESv5Family', `
            'standardFSv2Family'),
    $Locations = @(
        'germanywestcentral', `
        'germanynorth', `
        'westus', `
        'westus2', `
        'westus3'),
    $SubscriptionIds = @('00000000-0000-0000-0000-000000000000') # '00000000-0000-0000-0000-000000000000' is a placeholder for your subscription IDs
)

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'SilentlyContinue'

$filteredSkus = @()
foreach ($SubscriptionId in $SubscriptionIds) {
    try {
        $Subscription = Get-AzSubscription -SubscriptionId $SubscriptionId -ErrorAction SilentlyContinue
        if ($null -eq $Subscription) {
            Throw 
        }

        Select-AzSubscription -Subscription $SubscriptionId | out-null
        if ((Get-AzResourceProvider -ListAvailable | Where-Object { $_.ProviderNamespace -like 'Microsoft.Capacity' }).RegistrationState -notlike 'Registered') {
            Register-AzResourceProvider -ProviderNamespace Microsoft.Capacity
        }

        Write-Host ("Querying Subscription: {0}" -f $Subscription.Name)
        foreach ($Location in $Locations) {
            try {
                Write-Host ("    Querying Region: {0}" -f $Location)
                $computeSKUs = Get-AzComputeResourceSku -Location $Location -ErrorAction SilentlyContinue | Where-Object { $_.ResourceType -eq 'virtualMachines' }
                $vmUsage = Get-AZVMUsage -Location $Location -ErrorAction SilentlyContinue
                foreach ($SKU in $SKUs) {
                    try {
                        Write-Host ("        Querying SKU: {0}" -f $SKU)
                        $skuUsage = $vmUsage | Select-Object -ExpandProperty Name -Property CurrentValue, Limit | Where-Object { $_.Value -eq $Families[$SKUs.indexOf($SKU)] }
                        $filteredSku = $computeSKUs | `
                            Where-Object { $_.Name.ToLowerInvariant() -eq $SKU.ToLowerInvariant() -and $_.LocationInfo.Location -like $Location } | `
                            select-Object -Property SubscriptionId, SubscriptionName, Name, Location, CoresUsed, CoresTotal, Zones, RestrictedZones, RestrictedRegion, Restrictions, LocationInfo
                        $filteredSku.SubscriptionId = [string]$Subscription.SubscriptionId
                        $filteredSku.SubscriptionName = $Subscription.Name
                        $filteredSku.Location = $filteredSku.LocationInfo.Location
                        $filteredSku.Zones = $filteredSku.LocationInfo.Zones -join ","
                        $filteredSku.RestrictedRegion = 'False'
                        foreach ($restriction in $filteredSku.Restrictions) {
                            if ($restriction.Type -like "Zone") {
                                $filteredSku.RestrictedZones = $restriction.RestrictionInfo.Zones -join ","
                            }
                            elseif ($restriction.Type -like "Location") {
                                $filteredSku.RestrictedRegion = 'True'
                            }
                        }
                        $filteredSku.CoresUsed = $skuUsage.CurrentValue
                        $filteredSku.CoresTotal = $skuUsage.Limit
                        $filteredSkus += $filteredSku
                    }
                    catch {
                        Write-Host ("        Failed Querying SKU: {0}" -f $SKU) -ForegroundColor Yellow
                    }
                }
            }
            catch {
                Write-Host ("    Failed Querying Region: {0}" -f $Location) -ForegroundColor Yellow
            }


        }
    }
    catch {
        Write-Host ("Failed Querying Subscription ID: {0}" -f $SubscriptionId) -ForegroundColor Yellow
    }
}

Write-Host ("Saving {0} rows to ZoneInfo.csv" -f $filteredSkus.Count)
$filteredSkus | Select-Object SubscriptionId, SubscriptionName, Name, Location, CoresUsed, CoresTotal, Zones, RestrictedZones, RestrictedRegion | Export-Csv -force .\ZoneInfo.csv
Get-Content .\ZoneInfo.csv | ConvertFrom-Csv | Format-Table -AutoSize
