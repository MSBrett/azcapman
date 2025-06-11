---
layout: default
title: Quota Management
parent: Tools & Scripts
nav_order: 2
---

# Quota Management Scripts

These scripts are intended to analyze quota usage across subscriptions and regions in scenarios where Quota Groups **have not** been implemented.

---

## What you'll need

Here's what you'll need to get started:

1. **Azure PowerShell Module**: Install the latest version
   ```powershell
   Install-Module -Name Az -Repository PSGallery -Force
   ```

2. **Authentication**: Sign in to your Azure account
   ```powershell
   Connect-AzAccount
   ```

3. **Permissions**: Reader access to target subscriptions

4. **PowerShell Version**: 
   - PowerShell 5.1+ for single-threaded scripts
   - PowerShell 7+ recommended for best performance

---

## Available Scripts

### Get-AzVMQuotaUsage.ps1 (Recommended)

**Multi-threaded quota analysis** - Fast parallel processing across multiple subscriptions.

**Requirements**: Azure PowerShell module, PowerShell 7+ for multi-threading  
**Best for**: Large-scale analysis

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MSBrett/azcapman/main/scripts/quota/Get-AzVMQuotaUsage.ps1" -OutFile "Get-AzVMQuotaUsage.ps1"
.\Get-AzVMQuotaUsage.ps1 -SKUs @('Standard_D2s_v5', 'Standard_E2s_v5') -Locations @('eastus', 'westus2') -Threads 4
```

What you'll get:
- Current quota usage vs. limits for VM families
- Available and restricted availability zones per SKU
- Region-level restrictions for specific VM SKUs
- Physical vs. logical availability zone mappings
- Multi-threading for faster processing

**Script Output:**

|TenantId|SubscriptionId|SubscriptionName|Location|Family|Size|RegionRestricted|ZonesPresent|ZonesRestricted|CoresUsed|CoresTotal|
|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|
|...|...|...|eastus|standardDSv5Family|Standard_D2s_v5|False|1,2,3||0|100|
|...|...|...|westus2|standardESv5Family|Standard_E2s_v5|False|1,2,3||0|100|
|...|...|...|westus3|standardFSv2Family|Standard_F2s_v2|True|1,2,3|1,2,3|0|100|

**What each column means:**
- **TenantId**: Your Azure AD tenant ID
- **SubscriptionId**: Your subscription ID
- **SubscriptionName**: Friendly name you've given your subscription
- **Location**: Azure region name
- **Family**: VM family (used for quota calculations)
- **Size**: Specific VM SKU name
- **RegionRestricted**: Whether the SKU has regional restrictions
- **ZonesPresent**: Available availability zones for the SKU
- **ZonesRestricted**: Restricted availability zones for the SKU
- **CoresUsed**: vCPU cores you're currently using
- **CoresTotal**: Total vCPU cores available to you

---

### Show-AzVMQuotaReport.ps1 (Single-threaded)
**Simple quota analysis** - Single-threaded version for smaller projects.

**Requirements**: Azure PowerShell module, PowerShell 5.1+  
**Best for**: Smaller analysis or learning

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MSBrett/azcapman/main/scripts/quota/Show-AzVMQuotaReport.ps1" -OutFile "Show-AzVMQuotaReport.ps1"
.\Show-AzVMQuotaReport.ps1 -SKUs @('Standard_D2s_v5', 'Standard_E2s_v5') -Locations @('eastus', 'westus2')
```

This script provides:
- Sequential processing across subscriptions
- Formatted table display of results
- Same core functionality as the multi-threaded version
- Streamlined for educational purposes

**Script Output:**

|TenantId|SubscriptionId|SubscriptionName|Location|Family|Size|RegionRestricted|ZonesPresent|ZonesRestricted|CoresUsed|CoresTotal|
|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|
|...|...|...|eastus|standardDSv5Family|Standard_D2s_v5|False|1,2,3||0|100|
|...|...|...|westus2|standardESv5Family|Standard_E2s_v5|False|1,2,3||0|100|
|...|...|...|westus3|standardFSv2Family|Standard_F2s_v2|True|1,2,3|1,2,3|0|100|

---

### Get-AzAvailabilityZoneMapping.ps1 (Zone Analysis)
**Zone mapping analysis** - Shows how logical zones map to physical zones across subscriptions.

**Requirements**: Azure PowerShell module, Reader access to target subscriptions  
**Best for**: Cross-subscription deployment planning

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MSBrett/azcapman/main/scripts/quota/Get-AzAvailabilityZoneMapping.ps1" -OutFile "Get-AzAvailabilityZoneMapping.ps1"
.\Get-AzAvailabilityZoneMapping.ps1 -SubscriptionIds @('sub1-id','sub2-id') -OutputFile "ZoneMappings.csv"
```

This script provides:
- Logical to physical zone mappings per subscription
- Physical zone identifiers and names
- Essential data for multi-subscription architectures
- Compliance with data residency requirements

**Script Output:**

|TenantId|SubscriptionId|SubscriptionName|Location|LogicalZone|PhysicalZone|PhysicalZoneName|
|--------|--------|--------|--------|--------|--------|--------|
|...|...|...|eastus|1|A|eastus-az1|
|...|...|...|eastus|2|B|eastus-az2|
|...|...|...|eastus|3|C|eastus-az3|

---

## Manual Quota Analysis Examples

### Check your current quota

```powershell
$Location = 'West US 2'
$VMSize = 'Standard_D4d_v4'
$SKU = Get-AzComputeResourceSku -Location $Location | Where-Object ResourceType -eq "virtualMachines" | Select-Object Name,Family
$VMFamily = ($SKU | Where-Object Name -eq $VMSize | Select-Object -Property Family).Family
$Usage = Get-AzVMUsage -Location $Location | Where-Object { $_.Name.Value -eq $VMFamily }
```

---

### Create quota requests automatically
```powershell
$QuotaPercentageThreshold = "80"
$NewLimitIncrement = "25"
$Location = 'EastUS'
$VMSize = 'Standard_B2ms'

$SKU = Get-AzComputeResourceSku -Location $Location | Where-Object ResourceType -eq "virtualMachines" | Select-Object Name,Family
$VMFamily = ($SKU | Where-Object Name -eq $VMSize | Select-Object -Property Family).Family
$Usage = Get-AzVMUsage -Location $Location | Where-Object { $_.Name.Value -eq $VMFamily } | Select-Object @{label="Name";expression={$_.name.LocalizedValue}},currentvalue,limit, @{label="PercentageUsed";expression={[math]::Round(($_.currentvalue/$_.limit)*100,1)}}
$NewLimit = $Usage.Limit + $NewLimitIncrement

#Ticket Details
$TicketName =  "Quota Request"
$TicketTitle = "Quota Request"
$TicketDescription = "Quota request for $VMSize"
$Severity = "Critical" #Minimal, Moderate, Critical, HighestCriticalImpact
$ContactFirstName = "[Your First Name]"
$ContactLastName = "[Your Last Name]"
$TimeZone = "pacific standard time"
$Language = "en-us"
$Country = "USA"
$PrimaryEmail = "[your-email@company.com]"
$AdditionalEmail = "[additional-email@company.com]"
$ServiceNameGUID = "06bfd9d3-516b-d5c6-5802-169c800dec89" 
$ProblemClassificationGUID = "599a339a-a959-d783-24fc-81a42d3fd5fb"

Write-Output "$($Usage.Name.LocalizedValue): You've consumed $($Usage.PercentageUsed)% | $($Usage.CurrentValue) /$($Usage.Limit) of available quota"

if ($($Usage.PercentageUsed) -gt $QuotaPercentageThreshold) {
    Write-Output "Creating support case"
    New-AzSupportTicket `
        -Name "$TicketName" `
        -Title "$TicketTitle" `
        -Description "$TicketDescription" `
        -Severity "$Severity" `
        -ProblemClassificationId "/providers/Microsoft.Support/services/$ServiceNameGUID/problemClassifications/$ProblemClassificationGUID" `
        -QuotaTicketDetail @{QuotaChangeRequestVersion = "1.0" ; QuotaChangeRequests = (@{Region = "$Location"; Payload = "{`"VMFamily`":`"$VMSize`",`"NewLimit`":$NewLimit}"})} -CustomerContactDetail @{FirstName = "$ContactFirstName" ; LastName = "$ContactLastName" ; PreferredTimeZone = "$TimeZone" ; PreferredSupportLanguage = "$Language" ; Country = "$Country" ; PreferredContactMethod = "Email" ; PrimaryEmailAddress = "$PrimaryEmail" ; AdditionalEmailAddress = "$AdditionalEmail"}
}
else {
    Write-Output "Nothing to do here, exiting"
    Exit
}
```

---

## Script Parameters

### Common Parameters (All Scripts)

- **SKUs**: Array of VM SKU names to analyze (e.g., `@('Standard_D2s_v5', 'Standard_E4s_v5')`)
- **Locations**: Array of Azure regions (e.g., `@('eastus', 'westus2')`)
- **SubscriptionIds**: Array of subscription IDs to analyze
- **OutputFile**: Name of the output CSV file

---

### Get-AzVMQuotaUsage.ps1 Specific Parameters

- **Threads**: Number of concurrent threads (default: 2, set to 0 for auto-detect)
- **UsePhysicalZones**: Switch to normalize output to physical zones
- **MeterDataUri**: URL for downloading VM SKU list

---

### Get-AzAvailabilityZoneMapping.ps1 Specific Parameters

- **OutputFile**: Default filename is "ZonePeers.csv"

You'll need Azure PowerShell installed and signed in to use these scripts.

---

## Troubleshooting

### Common Issues

**Authentication Errors**:
```powershell
# Ensure you're signed in
Connect-AzAccount
# Verify current context
Get-AzContext
```

**Permission Denied**:
- Verify you have Reader access to target subscriptions
- Check if the subscription is in a different tenant

**Empty Results**:
- Confirm the specified regions support the requested VM SKUs
- Verify subscription IDs are correct
- Check if regions have restricted access

**Multi-threading Issues** (Get-AzVMQuotaUsage.ps1):
- Reduce the number of threads if hitting API limits
- Use PowerShell 7+ for optimal multi-threading support

**Rate Limiting**:
- Reduce concurrent operations
- Add delays between API calls if necessary

### Getting Help

For issues with these scripts:
1. Check the [Azure PowerShell documentation](https://docs.microsoft.com/en-us/powershell/azure/)
2. Review Azure subscription and quota limits
3. Contact Azure support for quota increase requests

## Script Versions

These scripts are maintained in the [azcapman repository](https://github.com/MSBrett/azcapman). Check for updates regularly to get the latest features and bug fixes.
