---
layout: default
title: Creating & Deleting Groups
parent: Implementation
nav_order: 2
---

# Creating and deleting quota groups

This guide walks through creating and deleting quota groups using both the Azure portal and REST API.

## Prerequisites

Before creating a quota group, ensure you have:
- Completed the [prerequisites](02-prerequisites-limitations.md)
- The **GroupQuota Request Operator** role on the Management Group
- Subscriptions ready to be added to the group

---

## Creating a quota group

### Azure portal

To create a Quota Group using the Azure portal:

1. Sign in to the [Azure portal](https://portal.azure.com) and enter "quotas" into the search box, then select **Quotas**
2. Under **Settings** in the left-hand side, select **Quota groups**
3. Select **Create quota group** at the top of the page

<figure>
<img src="img/0-start.jpeg" alt="Azure Quotas landing page showing empty quota groups section" width="50%" />
<figcaption>Azure Quotas landing page with empty quota groups section</figcaption>
</figure>

4. In the **Create quota group** blade:
   - **Management Group**: Select the management group where you want to create the quota group
   - **Quota group name**: Enter a unique name for your quota group (must be unique within the management group)
   - **Display name**: Enter a descriptive display name

<figure>
<img src="img/1-new.jpeg" alt="Create quota group wizard showing basic configuration form" width="50%" />
<figcaption>Create quota group wizard with management group and naming fields</figcaption>
</figure>

<figure>
<img src="img/3-name.jpeg" alt="Management group selection" width="50%" />
<figcaption>Select the management group to create the quota group in</figcaption>
</figure>

5. Optionally, add subscriptions to the quota group:
   - Select **Add subscriptions**
   - Choose the subscriptions you want to include
   - Note: Subscriptions can only belong to one quota group at a time

<figure>
<img src="img/4-subs.jpeg" alt="Subscription selection with subscriptions selected" width="50%" />
<figcaption>Selected subscriptions ready to be added to the quota group</figcaption>
</figure>

6. Review your configuration and select **Create**

<figure>
<img src="img/5-create.jpeg" alt="Review and create summary for quota group" width="50%" />
<figcaption>Review and create summary showing quota group configuration</figcaption>
</figure>

7. The quota group will be created with:
   - Provisioning state: "Accepted"
   - Initial group limit: 0 (you'll need to request quota increases separately)

<figure>
<img src="img/6-error.jpeg" alt="Errors if you haven't read the prerequisites" width="50%" />
<figcaption>If prerequisites are not met, the wizard will display an error</figcaption>
</figure>

<figure>
<img src="img/7-done.jpeg" alt="Quota groups list showing created groups" width="50%" />
<figcaption>Quota groups list displaying the newly created quota group</figcaption>
</figure>

### REST API

To create a Quota Group using the REST API, make a `PUT` request:

```
PUT https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupQuotaName}?api-version=2025-03-01
```

Request body:
```json
{
  "properties": {
    "displayName": "My Quota Group Display Name"
  }
}
```

Example using Azure CLI:
```bash
az rest --method put \
  --url "https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupQuotaName}?api-version=2025-03-01" \
  --body '{
    "properties": {
      "displayName": "My Quota Group Display Name"
    }
  }'
```

Sample response:
```json
{
  "id": "/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupQuotaName}",
  "name": "{groupQuotaName}",
  "properties": {
    "provisioningState": "Accepted",
    "displayName": "My Quota Group Display Name"
  },
  "type": "Microsoft.Quota/groupQuotas"
}
```

---

## Deleting a quota group

### Important considerations

- **All subscriptions must be removed** from the quota group before deletion
- Requires the **GroupQuota Request Operator** role on the Management Group
- Deletion is permanent and cannot be undone

### Azure portal

To delete a Quota Group using the Azure portal:

1. Sign in to the Azure portal and navigate to **Quotas**
2. Under **Settings**, select **Quota groups**
3. Select the **Management Group filter** and choose the management group containing your quota group
4. From the list, select the quota group you want to delete
5. **Important**: Ensure all subscriptions have been removed from the quota group
6. Select **Delete quota group** from the top menu
7. Confirm the deletion when prompted

### REST API

To delete a Quota Group using the REST API:

```
DELETE https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupQuotaName}?api-version=2025-03-01
```

Example using Azure CLI:
```bash
az rest --method delete \
  --url "https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupQuotaName}?api-version=2025-03-01"
```

The deletion operation will return:
- **200 OK** if the deletion was successful
- **404 Not Found** if the quota group doesn't exist
- **409 Conflict** if the quota group still contains subscriptions

## Next steps

After creating a quota group:
1. [Add subscriptions to the group](06-add-remove-subscriptions.md)
2. [Request quota increases for the group](08-increase-request.md)
3. [Transfer quota between subscriptions](07-transfer-quota.md)