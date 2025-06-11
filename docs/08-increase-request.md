---
layout: page
title: Request Increases
parent: Operations & Support
nav_order: 1
---

# Submit quota group limit increase request

One of the key benefits of Quota Group offering is the ability to submit Quota Group limit increase requests rather than at the per subscription level. If your group limit request's approved, you can then follow steps to allocate/transfer quota from group to target subscriptions for a given region × VM family.

- Require GroupQuota Request Operator role on the Management Group to submit Quota Group limit increase request
- Customers can submit Quota Group limit increase requests for a region × VM family combination, and if approved, quota will be stamped on the specified Quota Group ID
- Quota Group limit increase requests undergo the same checks as subscription level requests. Value should be absolute value of the new desired amount
- If Quota Group limit request is rejected, then customer must submit support ticket via the self-serve Quota Group request blade
- Support tickets for Quota Groups will be created based on a preselected subscription ID within the group, the customer has the ability to edit the sub ID when updating request details

---

## Azure portal

To submit a Quota Group limit increase request using the Azure portal:

1. Sign in to the Azure portal and enter "quotas" into the search box, then select **Quotas**
2. Under **Settings** in the left-hand side, select **Quota groups**
3. Select the **Management Group filter** and choose the management group containing your quota group
4. From the list of quota groups, select the quota group for which you want to request an increase
5. In the **Quota Group resources** view, you'll see a list of quota group resources by region and VM family
6. Use the filters to select **Region** and/or **VM Family**, or search for specific regions and VM families in the search bar
7. Select the checkbox next to the desired quota group resource, then select **Increase group quota** button at the top of the page
8. In the **New quota request** blade on the right side:
   - Review the selected region(s) at the top
   - View details of the selected quota group resource
   - See the **Current group quota** value
   - Under **New group quota** column, enter the absolute value of the desired new group limit (e.g., enter "20" if you want 20 cores total for the VM family in that region)
9. Select **Submit** button
10. You'll see a notification: "We are reviewing your request to adjust the quota. This may take up to ~3 minutes to complete"
11. If successful, the **New quota request** view will show:
    - The selected quota group resource by location
    - Status of the request
    - The increase value
    - New limit
12. Refresh the **Quota Group resources** view to see the latest group quota/group limit
13. If the quota group limit increase is rejected, you'll see a notification: "We were unable to adjust your quota"
14. If rejected, select **Generate a support ticket** button to create a support request (see file 10-support-ticket.md for detailed portal support ticket process)

---

## REST API

To submit a Quota Group limit increase request:

```
PATCH https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/resourceProviders/Microsoft.Compute/groupQuotaLimits/{location}?api-version=2025-03-01
```

Request body:

```
{
  "properties": {
    "value": [
      {
        "properties": {
          "resourceName": "standardddv4family",
          "limit": 50,
          "comment": "comments"
        }
      }
    ]
  }
}
```

Example using `az rest`:

- I submit PATCH Quota Group limit increase request of 50 cores for standardddv4family in centralus
- Use the groupQuotaOperationsStatus ID in my response header to validate the status of request in next section

```
az rest --method patch --uri "https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/resourceProviders/Microsoft.Compute/groupQuotaLimits/centralus?api-version=2025-03-01" --body '{"properties":{"value":[{"properties":{"resourceName":"standardddv4family","limit":20,"comment":"comments"}}]}}' --verbose
```

```
{
  "properties": {
    "value": [
      {
        "properties": {
          "resourceName": "standardddv4family",
          "limit": 50,
          "comment": "comments"
        }
      }
    ]
  }
}
```

Example response Quota Group increase request

```
Status code: 202
Response header:
Location: https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/groupQuotaOperationsStatus/6c1cdfb8-d1ba-4ade-8a5f-2496f0845ce2?api-version=2025-03-01
Retry-After: 30 
Response Content
```
