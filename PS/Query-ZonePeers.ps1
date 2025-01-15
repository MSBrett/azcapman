[CmdletBinding()]
param (

    [Parameter(Mandatory = $false, HelpMessage = "e.g. @('eastus', 'westus')")]
    [string[]]$Locations = @(),

    [Parameter(Mandatory = $false, HelpMessage = "e.g. @('00000000-0000-0000-0000-000000000000')")]
    [string[]]$SubscriptionIds = @(),
    
    [Parameter(Mandatory = $false, HelpMessage = "e.g. @('00000000-0000-0000-0000-000000000000')")]
    [string]$OutputFile = "ZonePeers.csv"
)
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

# Main script execution
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'SilentlyContinue'
$csvHeaderString = "TenantId,SubscriptionId,SubscriptionName,Location,AzName,LogicalZone,PhysicalZone"
$csvHeaderString | Out-File -Force -FilePath $OutputFile
$resourceManagerUrl = (Get-AzContext).Environment.ResourceManagerUrl

if ($SubscriptionIds.Count -eq 0) {
    $SubscriptionIds = Get-SubscriptionIds
}

if ($Locations.Count -eq 0) {
    $Locations = Get-Locations
}

$zoneMaps = @()
ForEach ($subscriptionId in $SubscriptionIds){
    Write-Output "Get zone peer details for $subscriptionId"
    $zonePeers = Get-ZonePeers -SubscriptionId $subscriptionId
    $zoneMappings = ($zonePeers | Where-Object { $_.type -eq "Region"}).availabilityZoneMappings
    $subscription = Get-AzSubscription -SubscriptionId $subscriptionId

    foreach($mapping in $zoneMappings) {
        if([string]::IsNullOrEmpty($mapping.logicalZone) -or [string]::IsNullOrEmpty($mapping.physicalZone)) {
            continue
        }
        $zoneMap = [PSCustomObject]@{
        TenantId         = $Subscription.TenantId
        SubscriptionId   = $Subscription.Id
        SubscriptionName = $Subscription.Name
        Location         = $mapping.physicalZone.Split("-")[0]
        AzName           = $mapping.physicalZone
        LogicalZone      = $mapping.logicalZone
        PhysicalZone     = Get-LastChar($mapping.physicalZone)
        }
        
        $zoneMaps += $zoneMap
    }
}

$zoneMaps | ConvertTo-Csv -NoHeader | Out-File -Force -Append -FilePath $OutputFile