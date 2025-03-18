
# Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MSBrett/azcapman/refs/heads/main/PS/Enable-StorageBlobLastAccessTimeTracking.ps1" -OutFile "Enable-StorageBlobLastAccessTimeTracking.ps1"; ./Enable-StorageBlobLastAccessTimeTracking.ps1

$ErrorActionPreference = "Continue"

$subscriptions = Get-AzSubscription
foreach ($subscription in $subscriptions)
{
    if ($subscription.State -ne 'Enabled' -or $subscription.name -ne 'non-prod-workloads')
    {
        Write-Output "Skipping subscription: $($subscription.Name)"
    }
    else {
        Write-Output "Processing Subscription: $($subscription.Name)"
        Set-AzContext -SubscriptionId $subscription.Id -Tenant $subscription.TenantId | Out-Null
        $resourceGroups=Get-AzResourceGroup
        foreach ($resourceGroup in $resourceGroups)
        {
            $storageAccounts = Get-AzStorageAccount -ResourceGroupName $resourceGroup.ResourceGroupName
            foreach ($storageAccount in $storageAccounts)
            {
                if($storageAccount.Kind -ne "StorageV2" -and $storageAccount.Kind -ne "Storage" -and ($storageAccount.Kind -ne "BlockBlobStorage" -and $storageAccount.Sku.Name -ne "Premium_LRS"))
                {
                    Write-Output "  Skipping Storage Account: $($storageAccount.StorageAccountName) in Resource Group: $($resourceGroup.ResourceGroupName) because it a $($storageAccount.Kind) account of type $($storageAccount.Sku.Name)"
                }
                else
                {
                    Write-Output "  Processing Storage Account: $($storageAccount.StorageAccountName) in Resource Group: $($resourceGroup.ResourceGroupName) because it a $($storageAccount.Kind) account of type $($storageAccount.Sku.Name)"
                    $ctx = New-AzStorageContext -StorageAccountName $storageAccount.StorageAccountName -UseConnectedAccount
                    $container=Get-AzStorageContainer -Context $ctx -Name "inventory"
                    if($null -ne $container)
                    {
                        $blobs = Get-AzStorageBlob -Context $ctx -Container $container.Name
                        foreach ($blob in $blobs)
                        {
                            if($blob.Name.EndsWith(".csv"))
                            {
                                Write-Output "      $($blob.Name)"
                                New-Item -Path "$env:SystemDrive\inventory\$($storageAccount.StorageAccountName)\" -ItemType Directory -Force | Out-Null
                                Get-AzStorageBlobContent -Blob $blob.Name -Container $container.Name -Context $ctx -Destination "$env:SystemDrive\inventory\$($storageAccount.StorageAccountName)\" -Force
                            }
                        }
                    }
                    else {
                        Write-Output "      Inventory container not found in Storage Account: $($storageAccount.StorageAccountName) in Resource Group: $($resourceGroup.ResourceGroupName)"
                    }
                }
                
            } 
        }
    }  
}