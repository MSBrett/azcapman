# Prerequisites

Before you can use the Quota Group feature, you must:

- Register the `Microsoft.Quota` and `Microsoft.Compute` resource provider on all relevant subscriptions before adding to a Quota Group. For more information, see [Registering the Microsoft Quota resource provider](https://learn.microsoft.com/en-us/rest/api/quota/#registering-the-microsoft-quota-resource-provider)
- A Management Group (MG) is needed to create a Quota Group. Your group inherits quota write and/or read permissions from the Management Group. Subscriptions belonging to another MG can be added to the Quota Group
- Certain permissions are required to create Quota Groups and to add subscriptions

# Limitations

- Available only for Enterprise Agreement or Microsoft Customer Agreement and Internal subscriptions
- Supports IaaS compute resources only
- Available in public cloud regions only
- Management Group deletion results in the loss of access to the Quota Group limit. To clear out the group limit, allocate cores to subscriptions, delete subscriptions, then the Quota Group object before deletion of Management Group. In the event that the MG's deleted, access your Quota Group limit by recreating the MG with the same ID as before
- A subscription can belong to a single Quota Group at a time
- Quota Groups addresses the quota management pain point, it doesn't address the regional and/or zonal access pain point. To get region and/or zonal access on subscriptions, [see region access request process](https://learn.microsoft.com/en-us/troubleshoot/azure/general/region-access-request-process). Quota transfers between subscriptions and deployments will fail unless regional and/or zonal access is provided on the subscription
