---
layout: page
title: Permissions & APIs
parent: Implementation
nav_order: 1
---

# Permissions

Certain permissions are required to create Quota Groups and to add subscriptions. For more information, see [Assign Azure roles using Azure CLI](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-cli) or [Assign Azure roles using the Azure portal](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal).

- Assign the GroupQuota Request Operator role on the Management Group where the Quota Group is created
- Assign the Quota Request Operator role on all participating subscriptions to the relevant users or applications managing quota operations
- Assign the Reader role on all participating subscriptions to the relevant users or applications managing quota operations to view quota group resources in portal

---

# Quota group APIs

This section covers the supported Quota Group operations via API and portal.

> **Note**: Azure Quota Groups is a generally available (GA) feature. The current API version is 2025-03-01.

Use [Quota Group APIs](https://github.com/Azure/azure-rest-api-specs/blob/main/specification/quota/resource-manager/Microsoft.Quota/stable/2025-03-01/groupquota.json) to:

> **Note**: The GitHub repository linked above is the official location for Azure REST API specifications, including the Quota Group APIs. This is maintained by Microsoft and is the authoritative source for API documentation.

- Create or delete a Quota Group
- Add or remove subscriptions from a Quota Group
- Transfer or deallocate unused quota from subscriptions to a Quota Group
- Submit a Quota Group limit increase request
- Submit a support ticket via portal if Quota Group limit request is rejected
- View Group limit

---

# SDK sample links

Use the below links to download the latest supported SDKs for Quota Group operations:

- [Go](https://pkg.go.dev/github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/quota/armquota@v1.1.0)
- [Python](https://pypi.org/project/azure-mgmt-quota/2.0.0/)
- [Java](https://central.sonatype.com/artifact/com.azure.resourcemanager/azure-resourcemanager-quota/1.1.0)
- [.NET](https://www.nuget.org/packages/Azure.ResourceManager.Quota/1.1.0#readme-body-tab)
- [JS](https://www.npmjs.com/package/@azure/arm-quota/v/1.1.0)
