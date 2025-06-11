---
layout: default
title: Tools & Scripts
nav_order: 4
has_children: true
---

# Tools & Scripts

Complete automation toolkit for Azure quota and capacity management. These PowerShell scripts and tools help ISVs efficiently analyze, monitor, and optimize their Azure resource usage.

## Quick Start

### Prerequisites
- **Azure PowerShell Module**: `Install-Module -Name Az -Force`
- **Authenticated Session**: `Connect-AzAccount`
- **Appropriate Permissions**: Reader access to target subscriptions

### One-Line Quota Analysis
Get started immediately with this command that analyzes VM quota usage for common SKUs:

```powershell
# Download and run quota analysis for popular VM SKUs across all accessible subscriptions
iwr "https://raw.githubusercontent.com/MSBrett/azcapman/main/scripts/quota/Query-AzQuota.ps1" -OutFile "QuotaQuery.ps1"
.\QuotaQuery.ps1 -SKUs @('Standard_D2s_v5','Standard_E4s_v5','Standard_F4s_v2') -Locations @('eastus','westus2','centralus')
```

## Core Tool Categories

### 🔍 [Quota Management](scripts/quota/)
**Primary Goal**: Analyze current VM quota usage and availability zone restrictions across subscriptions

- **Query-AzQuota.ps1** - Multi-threaded script that queries VM quota usage, availability zones, and regional restrictions
- **Query-ZonePeers.ps1** - Maps logical availability zones to physical zones across subscriptions
- **QuotaQuery.pbit** - Power BI template for visualizing quota data

**Key Use Cases**:
- Understanding current VM quota consumption vs limits
- Identifying which VM SKUs are restricted in specific zones/regions
- Cross-subscription availability zone alignment planning
- Capacity planning before large deployments

### 💰 [Benefits Analysis](scripts/benefits/)
**Primary Goal**: Analyze compute usage patterns to identify Azure savings plan opportunities

- **Get-BenefitRecommendations.ps1** - Queries Cost Management API for compute savings plan recommendations

**Key Use Cases**:
- Analyzing historical compute usage for cost optimization
- Getting savings plan recommendations (1-year or 3-year terms)
- Building business case for Azure cost commitments
- Understanding potential savings from usage patterns



## Real-World Scenarios

### Scenario 1: Understanding VM Quota Usage Across Tenant
```powershell
# Analyze current quota usage for common VM types across all subscriptions
$allSubs = (Get-AzSubscription).Id
.\QuotaQuery.ps1 -SubscriptionIds $allSubs -SKUs @('Standard_D4s_v5','Standard_E4s_v5') -Threads 4
```

### Scenario 2: Zone Restriction Analysis Before Deployment
```powershell
# Check for zone restrictions in target regions before deployment
.\QuotaQuery.ps1 -SKUs @('Standard_D8s_v5') -Locations @('eastus','westus2','centralus') -UsePhysicalZones
```

### Scenario 3: Cross-Subscription Zone Alignment
```powershell
# Map logical zones to physical zones for multi-subscription deployments
.\Query-ZonePeers.ps1 -SubscriptionIds @('sub1-id','sub2-id') -OutputFile "ZoneAlignment.csv"
```

## Power BI Integration

### Automated Dashboard Updates
1. **Generate Data**: Run quota scripts with `-OutputFile` parameter
2. **Load Template**: Open `QuotaQuery.pbit` in Power BI Desktop
3. **Refresh Data**: Point to your generated CSV files
4. **Publish**: Share insights across your organization

### Dashboard Features
- **Quota Utilization Views**: Visual representation of used vs. available quota by region/SKU
- **Zone Restriction Analysis**: Identify SKUs with availability zone limitations
- **Cross-Subscription Comparisons**: Compare quota allocation across multiple subscriptions
- **Physical Zone Mapping**: Understand logical-to-physical zone relationships

## Advanced Usage

### Custom SKU Analysis
Target specific workload requirements:

```powershell
# GPU workloads - check availability and restrictions
$gpuSKUs = @('Standard_NC6s_v3', 'Standard_ND40rs_v2')
.\QuotaQuery.ps1 -SKUs $gpuSKUs -Locations @('eastus','westus2')

# Memory-optimized workloads - include zone mapping
$memorySKUs = @('Standard_E16s_v5', 'Standard_M32s')
.\QuotaQuery.ps1 -SKUs $memorySKUs -UsePhysicalZones
```

### Understanding Script Output
The quota scripts produce CSV files with these key columns:
- **CoresUsed/CoresTotal**: Current usage vs. quota limit
- **ZonesPresent**: Available zones for the SKU in that region
- **ZonesRestricted**: Zones where the SKU is restricted
- **RegionRestricted**: Whether the entire region restricts this SKU

## Performance Tips

- **Use Threading**: Set `-Threads 4` or higher for faster multi-subscription analysis
- **Target Specific Regions**: Limit `-Locations` to reduce API calls and focus analysis
- **Physical Zone Mapping**: Use `-UsePhysicalZones` when planning cross-subscription deployments
- **Save Results**: Always use `-OutputFile` to preserve data for trending and comparison

## Troubleshooting

### Common Issues
- **Authentication Errors**: Ensure `Connect-AzAccount` is current and has access to target subscriptions
- **Permission Issues**: Scripts require Reader access to subscriptions and VMs
- **Rate Limiting**: Reduce thread count if experiencing API throttling
- **Empty Results**: Verify subscription access and region availability

### Script-Specific Help
- Quota Analysis: `Get-Help .\Query-AzQuota.ps1 -Detailed`
- Zone Mapping: `Get-Help .\Query-ZonePeers.ps1 -Detailed`
- Benefits: Requires billing account scope parameter

---

Ready to understand your Azure quota utilization? Start with the [Quota Management](scripts/quota/) tools to analyze current usage and identify capacity constraints.
