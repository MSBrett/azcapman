
# Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MSBrett/azcapman/refs/heads/main/PS/Enable-StorageBlobLastAccessTimeTracking.ps1" -OutFile "Enable-StorageBlobLastAccessTimeTracking.ps1"; ./Enable-StorageBlobLastAccessTimeTracking.ps1

param(
    [switch]$commit
)
$ErrorActionPreference = "Continue"

function Enable-Inventory {
    param (
        [string]$rgName,
        [string]$accountName,
        [string]$containerName = "inventory"
    )
    
        $ctx = New-AzStorageContext -StorageAccountName $accountName -UseConnectedAccount
        $container=Get-AzStorageContainer -Context $ctx -Name $containerName
        if($null -eq $container)
        {
            if($commit)
            {   
                $container=New-AzStorageContainer -Context $ctx -Name $containerName
                if($null -eq $container)
                {
                    write-output "      Failed to create inventory container: $containerName in Storage Account: $accountName in Resource Group: $rgName"
                }
            }
            else {
                Write-Output "      Dry-run:  Will create inventory container: $containerName in Storage Account: $accountName in Resource Group: $rgName"
            }
        }
        else {
            Write-Output "      Found inventory container: $containerName in Storage Account: $accountName in Resource Group: $rgName"
        }
        
        if ($null -ne $container -and $commit) {
            $sa = Get-AzStorageAccount -ResourceGroupName $rgName -AccountName $accountName
            if ($sa.EnableHierarchicalNamespace)
            {
                $rule1 = New-AzStorageBlobInventoryPolicyRule -Name blobinventory -Destination $containerName -Format Csv -Schedule Daily -BlobType blockBlob, appendBlob -IncludeSnapshot -IncludeDeleted -BlobSchemaField  Name, Creation-Time, Last-Modified, ETag, Content-Length, Content-Type, Content-Encoding, Content-Language, Content-CRC64, Content-MD5, Cache-Control, Content-Disposition, BlobType, AccessTier, AccessTierChangeTime, AccessTierInferred, LastAccessTime, LeaseStatus, LeaseState, LeaseDuration, ServerEncrypted, CustomerProvidedKeySha256, RehydratePriority, ArchiveStatus, EncryptionScope, CopyId, CopyStatus, CopySource, CopyProgress, CopyCompletionTime, CopyStatusDescription, ImmutabilityPolicyUntilDate, ImmutabilityPolicyMode, LegalHold, Deleted, RemainingRetentionDays, DeletionId,Deleted,DeletedTime,RemainingRetentionDays 
            }
            else {
                $rule1 = New-AzStorageBlobInventoryPolicyRule -Name blobinventory -Destination $containerName -Format Csv -Schedule Daily -BlobType blockBlob, appendBlob -IncludeSnapshot -IncludeDeleted -BlobSchemaField  Name, Creation-Time, Last-Modified, ETag, Content-Length, Content-Type, Content-Encoding, Content-Language, Content-CRC64, Content-MD5, Cache-Control, Content-Disposition, BlobType, AccessTier, AccessTierChangeTime, AccessTierInferred, LastAccessTime, LeaseStatus, LeaseState, LeaseDuration, ServerEncrypted, CustomerProvidedKeySha256, RehydratePriority, ArchiveStatus, EncryptionScope, CopyId, CopyStatus, CopySource, CopyProgress, CopyCompletionTime, CopyStatusDescription, ImmutabilityPolicyUntilDate, ImmutabilityPolicyMode, LegalHold, Deleted, RemainingRetentionDays, Deleted, RemainingRetentionDays 
            }

            try{
                Write-Output "      Enabling Last Access Time Tracking for Storage Account: $accountName in Resource Group: $rgName"
                start-sleep -Seconds 1
                $policy = Set-AzStorageBlobInventoryPolicy -StorageAccount $sa -Rule $rule1
                Start-Sleep -Seconds 1
                Enable-AzStorageBlobLastAccessTimeTracking  -ResourceGroupName $rgName -StorageAccountName $accountName
            }
            catch{
                Write-Output "      Error enabling blob inventory for Storage Account: $accountName in Resource Group: $rgName"
            }
        }
}

$subscriptions = Get-AzSubscription
foreach ($subscription in $subscriptions)
{
    if ($subscription.State -ne 'Enabled')
    {
        Write-Output "Skipping $($subscription.State) subscription: $($subscription.Name)"
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
                    Enable-Inventory -rgName $resourceGroup.ResourceGroupName -accountName $storageAccount.StorageAccountName
                }
                
            } 
        }
    }  
}