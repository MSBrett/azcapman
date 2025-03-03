

param(
    [bool]$commit=$false
)

function Enable-LastAccessTimeTracking {
    param (
        [string]$rgName,
        [string]$accountName,
        [bool]$commit
    )
    
    Write-Output "Enabling Last Access Time Tracking for Storage Account: $accountName in Resource Group: $rgName"
    if($commit)
    {
        Enable-AzStorageBlobLastAccessTimeTracking  -ResourceGroupName $rgName `
        -StorageAccountName $accountName `
        -PassThru
    }
}


$subscriptions = Get-AzSubscription
foreach ($subscription in $subscriptions)
{
    Write-Output "Processing Subscription: $($subscription.Name)"
    Set-AzContext -SubscriptionId $subscription.Id | Out-Null
    $resourceGroups=Get-AzResourceGroup

    foreach ($resourceGroup in $resourceGroups)
    {
        $storageAccounts = Get-AzStorageAccount -ResourceGroupName $resourceGroup.ResourceGroupName
        foreach ($storageAccount in $storageAccounts)
        {
            Enable-LastAccessTimeTracking -rgName $resourceGroup.ResourceGroupName -accountName $storageAccount.StorageAccountName -commit $commit
        } 
    }
}