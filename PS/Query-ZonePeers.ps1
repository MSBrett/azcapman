[CmdletBinding()]
param (

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

function Get-ZonePeers {
    param (
        [string]$SubscriptionId
    )
    $uri = "{0}subscriptions/{1}/locations?api-version=2022-12-01" -f $resourceManagerUrl, $SubscriptionId
    $response = Invoke-AzRest -Method GET -Uri $uri
    return ($response.Content | ConvertFrom-Json).value
}

# Main script execution
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'SilentlyContinue'
$csvHeaderString = "TenantId,SubscriptionId,SubscriptionName,Location,LogicalZone,PhysicalZone,PhysicalZoneName"
$csvHeaderString | Out-File -Force -FilePath $OutputFile
$resourceManagerUrl = (Get-AzContext).Environment.ResourceManagerUrl

if ($SubscriptionIds.Count -eq 0) {
    $SubscriptionIds = Get-SubscriptionIds
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
        LogicalZone      = $mapping.logicalZone
        PhysicalZone     = Get-LastChar($mapping.physicalZone)
        PhysicalZoneName = $mapping.physicalZone
        }
        
        $zoneMaps += $zoneMap
    }
}

$zoneMaps | ConvertTo-Csv -NoHeader | Out-File -Force -Append -FilePath $OutputFile