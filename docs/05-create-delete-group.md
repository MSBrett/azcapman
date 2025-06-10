# Create a quota group

- Create a Quota Group object to be able to do quota transfers between subscriptions and submit Quota Group increase requests
- Requires the GroupQuota Request Operator role on the Management Group used to create Quota Group

## Azure portal

To create a Quota Group using the Azure portal:

1. Sign in to the Azure portal and enter "quotas" into the search box, then select **Quotas**
2. Under **Settings** in the left-hand side, select **Quota groups**
3. Select **Create quota group** at the top of the page

<img src="img/0-start.jpeg" alt="Azure Quotas landing page showing empty quota groups section" width="50%" />

4. In the **Create quota group** blade:
   - **Management Group**: Select the management group where you want to create the quota group
   - **Quota group name**: Enter a unique name for your quota group
   - **Display name**: Enter a descriptive display name


<img src="img/1-new.jpeg" alt="Create quota group wizard showing basic configuration form" width="50%" />

<img src="img/3-name.jpeg" alt="Subscription selection showing available subscriptions to add" width="50%" />

<img src="img/4-subs.jpeg" alt="Subscription selection with subscriptions selected" width="50%" />

5. Select **Create** to create the quota group

<img src="img/5-create.jpeg" alt="Review and create summary for quota group" width="50%" />

6. The quota group will be created with a provisioning state of "Accepted" and an initial group limit of 0

<img src="img/6-error.jpeg" alt="Review and create summary for quota group" width="50%" />

<img src="img/7-done.jpeg" alt="Quota groups list showing created groups" width="50%" />

## REST API
To create a Quota Group using the REST API, make a `PUT` request to the following endpoint:

```
PUT https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}?api-version=2025-03-01
```

Request body:

```
{
  "properties": {
    "displayName": "allocationGroupTest"
  }
}
```

Example using `az rest`:

```
az rest --method put --url https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}?api-version=2025-03-01 --body '{
  "properties": {
    "displayName": "allocationGroupTest"
  }
}'
```

Sample response:

```
{
  "id": "/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupquota}",
  "name": "{groupquota}",
  "properties": {
    "provisioningState": "ACCEPTED"
  },
  "type": "Microsoft.Quota/groupQuotas"
}
```

# Delete a quota group

- Requires the GroupQuota Request Operator role on the Management Group used to DELETE a Quota Group
- All subscriptions must be removed from Quota Group before deletion

## Azure portal

To delete a Quota Group using the Azure portal:

1. Sign in to the Azure portal and enter "quotas" into the search box, then select **Quotas**
2. Under **Settings** in the left-hand side, select **Quota groups**
3. Select the **Management Group filter** and choose the management group containing your quota group
4. From the list of quota groups, select the quota group you want to delete
5. Ensure all subscriptions have been removed from the quota group first
6. Select **Delete quota group** from the top menu
7. Confirm the deletion when prompted

## REST API
To delete a Quota Group:

```
DELETE https://management.azure.com/providers/Microsoft.Management/managementGroups/{managementGroupId}/providers/Microsoft.Quota/groupQuotas/{groupQuotaName}?api-version=2025-03-01
```
