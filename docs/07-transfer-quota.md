---
layout: page
title: Transfer Operations
parent: Implementation
nav_order: 4
---

# Transfer quota within quota group

---

## Azure portal

### Transfer quota from subscription to group (deallocate)

1. Sign in to the Azure portal and enter "quotas" into the search box, then select **Quotas**
2. Under **Settings** in the left-hand side, select **Quota groups**
3. Select the **Management Group filter** and choose the management group containing your quota group
4. From the list of quota groups, select the quota group where you want to transfer quota
5. In the **Quota Group resources** view, you'll see quota allocations by region and VM family
6. Use the filters to select **Region** and/or **VM Family** to find the specific quota you want to transfer
7. Select the checkbox next to the quota resource you want to deallocate from a subscription
8. Select **Transfer quota** from the top menu
9. In the **Transfer quota** blade:
   - **Source**: Select the subscription you want to transfer quota FROM
   - **Destination**: Select "Group" to transfer TO the quota group
   - **Amount**: Enter the number of cores to transfer from subscription to group
   - Review the current subscription limit and available quota
10. Select **Transfer** to complete the deallocation
11. The quota will be moved from the subscription to the group, reducing the subscription's limit and increasing the group's available quota

---

### Transfer quota from group to subscription (allocate)

1. Follow steps 1-6 above to navigate to your quota group resources
2. Select the checkbox next to the quota resource you want to allocate to a subscription
3. Select **Transfer quota** from the top menu
4. In the **Transfer quota** blade:
   - **Source**: Select "Group" to transfer FROM the quota group
   - **Destination**: Select the target subscription you want to transfer quota TO
   - **Amount**: Enter the number of cores to transfer from group to subscription
   - Review the group's available quota and target subscription's current limit
5. Select **Transfer** to complete the allocation
6. The quota will be moved from the group to the subscription, increasing the subscription's limit and reducing the group's available quota

---

### View quota allocation snapshot

1. Navigate to your quota group following the steps above
2. In the **Quota Group resources** view, you can see:
   - **Current group quota**: Total quota available at the group level
   - **Allocated quota**: Quota currently allocated to subscriptions
   - **Available quota**: Remaining quota that can be allocated
3. Select a specific quota resource to view detailed allocation information including:
   - **Limit**: Current subscription limit for each subscription in the group
   - **Shareable quota**: Amount transferred from subscription to group (negative values indicate cores given to group)

---

## REST API

> **Note:** Azure Quota Groups is a generally available (GA) feature using API version 2025-03-01.

### View quota allocation snapshot for subscription in quota group

- Limit = current subscription limit
- Shareable quota = how many cores have been deallocated/transferred from sub to group '-5' = 5 cores were given from sub to group

```
GET https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/subscriptions/{subscriptionId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/resourceProviders/Microsoft.Compute/quotaAllocations/{location}?api-version=2025-03-01
```

Example using `az rest`: My new subscription limit is 50 cores for standarddv4family in centralus and my shareable quota is -10 because I gave 10 cores to my Quota group.

```
az rest --method get --url "https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/subscriptions/075216c4-f88b-4a82-b9f8-cdebf9cc097a/providers/Microsoft.Quota/groupQuotas/{groupquota}/resourceProviders/Microsoft.Compute/quotaAllocations/eastus?api-version=2025-03-01&\$filter=resourceName eq 'standardddv4family'" --debug
Response content

{
  "id": "/providers/Microsoft.Management/managementGroups/{managementGroupId}/subscriptions/075216c4-f88b-4a82-b9f8-cdebf9cc097a/providers/Microsoft.Quota/groupQuotas/{groupquota}/resourceProviders/Microsoft.Compute/quotaAllocations/eastus",
  "name": "eastus",
  "provisioningState": "Succeeded",
  "type": "Microsoft.Quota/groupQuotas/quotaAllocations",
  "value": [
    {
      "properties": {
        "limit": 50,
        "name": {
          "localizedValue": "standardddv4family",
          "value": "standardddv4family"
        },
        "resourceName": "standardddv4family",
        "shareableQuota": -10
      }
    }
  ]
}
```

---

## REST API

### Transfer quota between subscriptions and groups

- Transfer unused quota from your subscription to a Quota Group or from a Quota Group to a subscription
- Once your quota group's created and subscriptions are added, you can transfer quota between subscriptions by transferring quota from source subscription to group. First, deallocate quota from the source subscription and return it to the group. Then, allocate that quota from the group to the target subscription
- To allocate or transfer quota from group to target subscription, update subID to target subscription, then set the limit property to the new desired subscription limit. If your current subscription quota is 10 and you want to transfer 10 cores from group to target subscription, set the new limit to 20. This applies to a specific region and VM family
- You can view quota allocation snapshot for subscription in Quota Group or view group limit to validate transfer and stamping of cores at group level
- To view your existing subscription usage for a given region, please use the [Compute Usages API](https://learn.microsoft.com/en-us/rest/api/compute/usage/list?view=rest-compute-2023-07-01&tabs=HTTP&tryIt=true&source=docs#code-try-0)

```
PATCH https://management.azure.com/"providers/Microsoft.Management/managementGroups/{managementGroupId}/subscriptions/{subscriptionId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/resourceProviders/Microsoft.Compute/quotaAllocations/{location}?api-version=2025-03-01"
```

Request body:

```
{
  "properties": {
    "value": [{
        "properties": {
          "limit": 50,
          "resourceName": "standardddv4family"
        }
      }]
  }
}
```

Example using `az rest`: I transfer 10 cores of standarddv4family in centralus from subscription to group by setting limit to 50

```
az rest –method patch –url "https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/subscriptions/{subscriptionId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/resourceProviders/Microsoft.Compute/quotaAllocations/{location}?api-version=2025-03-01" –body '{
  "properties": {
    "value": [
      {
        "properties": {
          "limit": 50,
          "resourceName": "standardddv4family"
        }
      }
    ]
  }
}' –debug
```

---

## View quota allocation snapshot for subscription in quota group

To view the current quota allocation for a subscription within a quota group:

```
GET https://management.azure.com/subscriptions/{subscription-id}/providers/Microsoft.Quota/groupQuotas/{groupQuotaName}/resourceProviders/{resourceProviderName}/groupQuotaRequests/{allocationRequestId}?api-version=2025-03-01
```

This will return the details of the quota allocation including:
- Current allocated quota
- Quota request status
- Resource details (region, VM family, etc.)

---

## Important: Manual transfers only

**Azure Quota Groups do not provide automatic quota balancing or failover.** All quota transfers must be initiated manually. If a subscription exhausts its allocated quota:
- It will NOT automatically borrow from the group
- Deployments will fail until you manually transfer additional quota
- There are no built-in alerts when quota is exhausted

Consider implementing your own monitoring and automation for quota management.

---

## Understanding shareable quota

When working with quota transfers, you may encounter **negative values** in the shareable quota. This occurs when:

1. **Over-allocation**: A subscription has been allocated more quota than it currently has available
2. **Active resources**: The subscription is using quota that exceeds its individual subscription limit
3. **Pending transfers**: Quota has been deallocated but the transfer hasn't completed

### Example scenario with negative shareable quota:

If a subscription has:
- Individual subscription quota: 100 cores
- Allocated from group: 150 cores
- Currently in use: 120 cores

The shareable quota would be: 100 - 150 = **-50 cores**

This negative value indicates that the subscription is relying on the group quota allocation and cannot share any quota until:
- Its individual quota is increased, OR
- Some of the group allocation is deallocated

---

## Troubleshooting transfer issues

### Common issues and solutions:

1. **"Insufficient quota available"**
   - Check the source subscription's shareable quota
   - Ensure the source has unused quota to transfer
   - Verify the quota isn't locked by running VMs

2. **"Subscription not found in quota group"**
   - Confirm both subscriptions are members of the same quota group
   - Check subscription membership using the status API

3. **"Invalid resource provider or quota name"**
   - Verify the exact resource provider name (e.g., `Microsoft.Compute`)
   - Confirm the quota resource name matches the API format

4. **"Transfer request stuck in 'InProgress'"**
   - Check for any service health issues in the region
   - If the transfer remains in 'InProgress' state for an extended period, open a support ticket

### Best practices for quota transfers:

1. **Plan transfers during low-usage periods** to minimize impact
2. **Monitor quota usage** before and after transfers
3. **Document transfer reasons** for audit purposes
4. **Set up alerts** for quota utilization thresholds
5. **Use automation** for regular transfer patterns

## Next steps

- [Request quota increases](08-increase-request.md) for the entire group
- [Monitor quota status](09-get-status.md) across all subscriptions
- [Create support tickets](10-support-ticket.md) for complex scenarios
