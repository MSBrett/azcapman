# GET groupQuotaLimit request status

## Azure portal

### View quota group limits and status

1. Sign in to the Azure portal and enter "quotas" into the search box, then select **Quotas**
2. Under **Settings** in the left-hand side, select **Quota groups**
3. Select the **Management Group filter** and choose the management group containing your quota group
4. From the list of quota groups, select the quota group you want to check
5. In the **Quota Group resources** view, you can see:
   - **Current group quota**: Total quota available at the group level
   - **Available limit**: How many cores you have at group level to distribute
   - **Allocated quota**: Quota currently allocated to subscriptions
6. Use the filters to select **Region** and/or **VM Family** to view specific quota allocations
7. Select a specific quota resource to view detailed information including:
   - **Limit**: Cores explicitly requested and approved/stamped on your group via quota increase requests
   - **Quota allocated**: Cores allocated to subscriptions (negative values indicate cores de-allocated from subscription to group)

### Check quota increase request status

1. Navigate to your quota group following steps 1-4 above
2. Select **Request history** or **Requests** tab to view submitted quota requests
3. You can see the status of recent quota increase requests:
   - **In Progress**: Request is being reviewed
   - **Approved**: Request was approved and quota has been allocated
   - **Rejected**: Request was denied (you can create a support ticket)
4. For approved requests, refresh the **Quota Group resources** view to see updated group limits

## REST API

### GET groupQuotaLimits

Validate that the correct number of cores were transferred from source subscription to group or that your group limit increase request was approved. Consider the below when interpreting the API response.

- Available limit = how many cores do I have at group level to distribute
- Limit = how many cores have been explicitly requested and approved/stamped on your group via quota increase requests
- Quota allocated = how many cores the sub has been allocated from group, '-' value indicates cores have been de-allocated from sub to group

```
GET https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/resourceProviders/Microsoft.Compute/groupQuotaLimits/{location}?api-version=2025-03-01&$filter=resourceName eq standarddv4family" -verbose
```

Example using `az rest`:

```
GET https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/resourceProviders/Microsoft.Compute/groupQuotaLimits/{location}?api-version=2025-03-01&$filter=resourceName eq standarddv4family" -verbose
```

Example using `az rest`: I do a GET group limit for my quota group in centralus.

- For the resource standardddv4family my availableLimit = 50 cores which match the number of cores I requested and got approved at the group level
- The Limit = 40 because even though I submitted an increase for 50, I already had 10 cores at the group level from quota transfer example, and Azure only stamped an additional 40 cores
- The quotaAllocated = -10 because I transferred 10 cores from source sub to group from previous section

```
az rest --method get --url https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/resourceProviders/Microsoft.Compute/groupQuotaLimits/centralus?api-version=2025-03-01&$filter=resourceName eq standardddv4family
```

Az rest sample response:

```
az rest --method get --url "https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/resourceProviders/Microsoft.Compute/groupQuotaLimits/centralus?api-version=2025-03-01&$filter=resourceName eq 'standardddv4family'"
{
  "id": "/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/resourceProviders/Microsoft.Compute/groupQuotaLimits/eastus",
  "name": "eastus",
  "properties": {
    "nextLink": "",
    "provisioningState": "Succeeded",
    "value": [
      {
        "properties": {
          "allocatedToSubscriptions": {
            "value": [
              {
                "quotaAllocated": -10,
                "subscriptionId": "226818a0-4fa2-4c2d-be7f-03b9b92ab3a2"
              }
            ]
          },
          "availableLimit": 50,
          "limit": 40,
          "name": {
            "localizedValue": "standardddv4family",
            "value": "standardddv4family"
          },
          "resourceName": "standardddv4family",
          "unit": "Count"
        }
      }
    ]
  },
  "type": "Microsoft.Quota/groupQuotas/groupQuotaLimits"
}
```

## REST API

### GET groupQuotaLimit request status

Since groupQuotaLimit request is async operation, capture status of request using groupQuotaOperationsStatus ID from response header when submitting limit increase request

```
GET https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/groupQuotaRequests/{requestId}?api-version=2025-03-01
```

Example using `az rest` I used the groupQuotaOperationsStatus ID from my PATCH Quota Group Limit increase request of 50 cores for standardddv4family in centralus succeeded

```
az rest --method get --uri "https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/groupQuotaRequests/6c1cdfb8-d1ba-4ade-8a5f-2496f0845ce2?api-version=2025-03-01"
```

Sample response of approved Quota Group increase request:

```
{
  "id": "/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/groupQuotaRequests/6c1cdfb8-d1ba-4ade-8a5f-2496f0845ce2",
  "name": "6c1cdfb8-d1ba-4ade-8a5f-2496f0845ce2",
  "properties": {
    "provisioningState": "Succeeded",
    "requestProperties": {
      "requestSubmitTime": "2025-05-06T17:57:00.0001431+00:00"
    },
    "requestedResource": {
      "properties": {
        "limit": 20,
        "name": {
          "localizedValue": "STANDARDDDV4FAMILY",
          "value": "STANDARDDDV4FAMILY"
        },
        "provisioningState": "Succeeded",
        "region": "centralus"
      }
    }
  },
  "type": "Microsoft.Quota/groupQuotas/groupQuotaRequests"
}
```
