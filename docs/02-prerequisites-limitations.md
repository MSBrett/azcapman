---
layout: page
title: Prerequisites & Limitations
parent: Getting Started
nav_order: 2
---

# Prerequisites

Before you can use the Quota Group feature, you must:

- Register the `Microsoft.Quota` and `Microsoft.Compute` resource provider on all relevant subscriptions before adding to a Quota Group. For more information, see [Registering the Microsoft Quota resource provider](https://learn.microsoft.com/en-us/rest/api/quota/#registering-the-microsoft-quota-resource-provider)
- A Management Group (MG) is needed to create a Quota Group. Your group inherits quota write and/or read permissions from the Management Group. Subscriptions belonging to another MG can be added to the Quota Group
- Certain permissions are required to create Quota Groups and to add subscriptions

---

# Limitations

- Available only for Enterprise Agreement (EA), Microsoft Customer Agreement (MCA), and Internal subscriptions
- Supports IaaS compute resources only
- Available in public cloud regions only
- **⚠️ CRITICAL WARNING - MANAGEMENT GROUP DELETION**: 
  
  **DO NOT DELETE THE MANAGEMENT GROUP** containing your Quota Group without following these steps:
  
  1. **FIRST** - Allocate all quota from the group back to subscriptions
  2. **SECOND** - Remove all subscriptions from the Quota Group
  3. **THIRD** - Delete the Quota Group object
  4. **ONLY THEN** - Delete the Management Group
  
  **CONSEQUENCES OF IMPROPER DELETION**:
  - **Permanent loss** of access to the Quota Group limit
  - **Stranded quota** that cannot be recovered without support
  - **Service disruption** if quota is needed for deployments
  
  **Recovery Process**: If accidentally deleted, you must recreate the Management Group with the **EXACT SAME ID**. This is complex, may require Microsoft support, and is not guaranteed to restore access
- A subscription can belong to a single Quota Group at a time
- Quota Groups addresses the quota management pain point, it doesn't address the regional and/or zonal access pain point. To get region and/or zonal access on subscriptions, [see region access request process](https://learn.microsoft.com/en-us/troubleshoot/azure/general/region-access-request-process). Quota transfers between subscriptions and deployments will fail unless regional and/or zonal access is provided on the subscription

## Operational limits

The following operational limits may apply (check with Azure support for current values):
- Maximum number of subscriptions per quota group
- Maximum number of quota groups per management group
- API rate limits for quota operations
- Maximum concurrent transfer operations
