---
layout: default
title: Quota Group Management
parent: Tools & Scripts
nav_order: 2
---

# Quota Group Management Scripts

This document provides a comprehensive reference for all Azure Quota Group REST API commands and their corresponding `az rest` invocations. These commands enable programmatic management of quota groups, subscription membership, quota transfers, and quota increase requests.

---

## API Version

All REST API calls use API version `2025-03-01`.

---

## REST API Commands Reference

### Create a quota group

Creates a new quota group within a management group.

**REST API:**
```http
PUT https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}?api-version=2025-03-01
```

**Request Body:**

```json
{
  "properties": {
    "displayName": "allocationGroupTest"
  }
}
```

**Az Rest Command:**

```bash
az rest --method put \
  --url "https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}?api-version=2025-03-01" \
  --body '{
    "properties": {
      "displayName": "allocationGroupTest"
    }
  }'
```

**Sample Response:**

```json
{
  "id": "/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}",
  "name": "{groupquota}",
  "properties": {
    "provisioningState": "ACCEPTED"
  },
  "type": "Microsoft.Quota/groupQuotas"
}
```

---

### Delete a quota group

Deletes an existing quota group. All subscriptions must be removed from the group before deletion.

**REST API:**
```http
DELETE https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupQuotaName}?api-version=2025-03-01
```

**Az Rest Command:**
```bash
az rest --method delete \
  --url "https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupQuotaName}?api-version=2025-03-01"
```

---

### Add subscription to quota group

Adds a subscription to an existing quota group.

**REST API:**
```http
PUT https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/subscriptions/{subscriptionId}?api-version=2025-03-01
```

**Az Rest Command:**
```bash
az rest --method put \
  --url "https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/subscriptions/{subscriptionId}?api-version=2025-03-01"
```

---

### Remove subscription from quota group

Removes a subscription from a quota group. The subscription retains its existing quota and usage.

**REST API:**
```http
DELETE https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/subscriptions/{subscriptionId}?api-version=2025-03-01
```

**Az Rest Command:**
```bash
az rest --method delete \
  --url "https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/subscriptions/{subscriptionId}?api-version=2025-03-01"
```

---

### View quota allocation for subscription

Retrieves the current quota allocation for a specific subscription within a quota group.

**REST API:**
```http
GET https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/subscriptions/{subscriptionId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/resourceProviders/Microsoft.Compute/quotaAllocations/{location}?api-version=2025-03-01
```

**Az Rest Command:**

```bash
az rest --method get \
  --url "https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/subscriptions/{subscriptionId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/resourceProviders/Microsoft.Compute/quotaAllocations/{location}?api-version=2025-03-01&\$filter=resourceName eq 'standardddv4family'"
```

**Sample Response:**

```json
{
  "id": "/providers/Microsoft.Management/managementGroups/{managementGroupId}/subscriptions/{subscriptionId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/resourceProviders/Microsoft.Compute/quotaAllocations/{location}",
  "name": "{location}",
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

### Transfer quota between subscription and group

Transfers quota from a subscription to the group or from the group to a subscription.

**REST API:**
```http
PATCH https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/subscriptions/{subscriptionId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/resourceProviders/Microsoft.Compute/quotaAllocations/{location}?api-version=2025-03-01
```

**Request Body:**

```json
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

**Az Rest Command:**

```bash
az rest --method patch \
  --url "https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/subscriptions/{subscriptionId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/resourceProviders/Microsoft.Compute/quotaAllocations/{location}?api-version=2025-03-01" \
  --body '{
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
  }'
```

---

### Submit quota group increase request

Submits a request to increase the quota limit for a quota group.

**REST API:**
```http
PATCH https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/resourceProviders/Microsoft.Compute/groupQuotaLimits/{location}?api-version=2025-03-01
```

**Request Body:**

```json
{
  "properties": {
    "value": [
      {
        "properties": {
          "resourceName": "standardddv4family",
          "limit": 50,
          "comment": "Request for additional compute capacity"
        }
      }
    ]
  }
}
```

**Az Rest Command:**

```bash
az rest --method patch \
  --url "https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/resourceProviders/Microsoft.Compute/groupQuotaLimits/{location}?api-version=2025-03-01" \
  --body '{
    "properties": {
      "value": [
        {
          "properties": {
            "resourceName": "standardddv4family",
            "limit": 50,
            "comment": "Request for additional compute capacity"
          }
        }
      ]
    }
  }'
```

**Sample Response:**

```http
Status code: 202
Location: https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/groupQuotaOperationsStatus/{requestId}?api-version=2025-03-01
Retry-After: 30
```

---

### Get group quota limits

Retrieves the current quota limits and allocations for a quota group.

**REST API:**
```http
GET https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/resourceProviders/Microsoft.Compute/groupQuotaLimits/{location}?api-version=2025-03-01&$filter=resourceName eq '{resourceName}'
```

**Az Rest Command:**
```bash
az rest --method get \
  --url "https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/resourceProviders/Microsoft.Compute/groupQuotaLimits/{location}?api-version=2025-03-01&\$filter=resourceName eq 'standardddv4family'"
```

**Sample Response:**
```json
{
  "id": "/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/resourceProviders/Microsoft.Compute/groupQuotaLimits/{location}",
  "name": "{location}",
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

---

### Get quota increase request status

Checks the status of a quota increase request using the operation ID returned from the increase request.

**REST API:**
```http
GET https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/groupQuotaRequests/{requestId}?api-version=2025-03-01
```

**Az Rest Command:**
```bash
az rest --method get \
  --url "https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/groupQuotaRequests/{requestId}?api-version=2025-03-01"
```

**Sample Response:**
```json
{
  "id": "/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/groupQuotaRequests/{requestId}",
  "name": "{requestId}",
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

---

## Response Fields Explanation

### Quota Allocation Response Fields

- **limit**: Current subscription limit for the specified resource
- **shareableQuota**: Amount transferred from subscription to group (negative values indicate quota given to group)

### Group Quota Limits Response Fields

- **availableLimit**: Total cores available at the group level for distribution
- **limit**: Cores explicitly requested and approved/stamped on the group via quota increase requests
- **quotaAllocated**: Cores allocated to subscriptions (negative values indicate cores deallocated from subscription to group)
- **allocatedToSubscriptions**: Array showing quota allocation per subscription within the group

---

## Common Parameters

- `{managementGroupId}`: The ID of the management group containing the quota group
- `{groupquota}`: The name of the quota group
- `{subscriptionId}`: The Azure subscription ID
- `{location}`: Azure region (e.g., "eastus", "westus2", "centralus")
- `{resourceName}`: VM family name (e.g., "standardddv4family", "standarddv4family")
- `{requestId}`: The operation ID returned from quota increase requests

---

## Prerequisites

Before using these commands, ensure you have:

1. **Permissions**: GroupQuota Request Operator role on the Management Group
2. **Subscriptions**: Proper subscription-level permissions (Quota Request Operator and Reader roles)
3. **Resource Providers**: Microsoft.Quota and Microsoft.Compute registered on all subscriptions
4. **Authentication**: Valid Azure CLI authentication (`az login`)

---

## Related Documentation

For detailed step-by-step guides and Azure portal instructions, refer to:
- [Creating & Deleting Groups](../docs/05-create-delete-group.md)
- [Managing Subscriptions](../docs/06-add-remove-subscriptions.md)
- [Transfer Operations](../docs/07-transfer-quota.md)
- [Quota Increase Requests](../docs/08-increase-request.md)
- [Status Monitoring](../docs/09-get-status.md)

