---
layout: page
title: Manage Subscriptions
parent: Implementation
nav_order: 3
---

# Add or remove subscriptions from a quota group

This section covers how to add subscriptions after the Quota Group is created. When added to the group, subscriptions carry their existing quota and usage. The subscriptions' quota isn't manipulated when added to a group. Subscription quota remains separate from the group limit.

---

## Azure portal

### Add subscriptions to a quota group

1. Sign in to the Azure portal and enter "quotas" into the search box, then select **Quotas**
2. Under **Settings** in the left-hand side, select **Quota groups**
3. Select the **Management Group filter** and choose the management group containing your quota group
4. From the list of quota groups, select the quota group where you want to add subscriptions
5. In the quota group details view, select **Add subscriptions** from the top menu
6. In the **Add subscriptions** blade:
   - Use the subscription filter to find the subscriptions you want to add
   - Select the checkboxes next to the subscriptions you want to include
   - Select **Add** to add the selected subscriptions to the quota group

<figure>
<img src="img/1-new.jpeg" alt="Create quota group wizard showing basic configuration form" width="50%" class="clickable-image" />
<figcaption>Add subscriptions interface for selecting subscriptions to include in the quota group</figcaption>
</figure>

7. The subscriptions will be added with their existing quota and usage intact

---

### Remove subscriptions from a quota group

1. Navigate to your quota group following steps 1-4 above
2. In the quota group details view, you'll see a list of subscriptions currently in the group
3. Select the checkboxes next to the subscriptions you want to remove
4. Select **Remove subscriptions** from the top menu
5. Confirm the removal when prompted
6. The subscriptions will be removed while retaining their existing quota and usage

---

## REST API

To add subscriptions from the Quota Group using the REST API, make a `PUT` request to the following endpoint:

```
PUT https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/subscriptions/{subscriptionId}?api-version=2025-03-01
```

To remove subscriptions from the Quota Group using the REST API, make a `DELETE` request to the following endpoint:

```
DELETE https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}/subscriptions/{subscriptionId}?api-version=2025-03-01
```

At the moment of removal, subscriptions carry their existing quota and usage. The group limit isn't manipulated based on subscription removal.
