---
layout: page
title: Overview & Benefits
parent: Getting Started
nav_order: 1
---

# Azure quota groups

Azure Quota Groups allow you to share quota among a group of subscriptions, reducing the number of quota transactions. This feature elevates the quota construct from a subscription level to a Quota Group Azure Resource Management (ARM) object, enabling customers to self-manage their procured quota within a group without needing approvals.

---

## Key benefits

- Quota sharing across subscriptions: Share procured quotas within a group of subscriptions
- Self-service management: Manually distribute or reallocate unused quota without Microsoft intervention
- Fewer support requests: Avoid filing support tickets when reallocating quota or managing new subscriptions
- Group quota requests: Request quota at the group level and allocate it across subscriptions as needed

**Note**: All quota transfers and allocations are manual operations. Azure Quota Groups do not provide automatic load balancing or quota redistribution.

---

## Important limitations

**Availability zones and regional access**: Quota Groups addresses the quota management pain point, but does not address the regional or zonal access pain point. To get region or zonal access on subscriptions, see the [region access request process](11-region-access-requests.md). Quota transfers between subscriptions and deployments will fail unless regional and zonal access is provided on the subscription.

Additional limitations include:
- Available only for Enterprise Agreement (EA), Microsoft Customer Agreement (MCA), and Internal subscriptions
- Supports IaaS compute resources only
- Available in public cloud regions only
- A subscription can belong to a single Quota Group at a time

## What Azure Quota Groups do NOT provide

- **No automatic quota balancing**: Quota must be manually transferred between subscriptions
- **No built-in monitoring or alerting**: No native alerts for quota utilization thresholds
- **No cross-region transfers**: Quota transfers are limited to the same region
- **No automatic failover**: If a subscription exhausts quota, it won't automatically borrow from the group
- **No quota policies**: Cannot set automatic rules for quota distribution
- **No historical tracking**: No built-in analytics for quota usage patterns over time

---

## Supported scenarios

The transfer of unused quota between subscriptions is done via Quota Group object created. At the moment of creating a Quota Group object, the group limit is set to 0. Customers must update the group limit themselves, either by transferring quota from a subscription in the group or by submitting a Quota Group limit increase request and getting approved. When deploying resources, the quota check at runtime is done against the subscription quota.

- Deallocation: Transfer unused quota from your subscriptions to Group Quota
- Allocation: Transfer quota from group to target subscriptions
- Submit Quota Group increase request for a given region and Virtual Machine (VM) family. Once your request's approved, transfer quota from group to target subscriptions
- Quota Group increase requests are subject to the same checks as subscription quota increase requests. If capacity's low, then the request is rejected
- According to [Microsoft's quota documentation](https://learn.microsoft.com/en-us/azure/quotas/quickstart-increase-quota-portal), quota requests have no guaranteed SLA and processing can take extended periods

---

## Proactive capacity planning best practices

Azure Quota Groups work best when integrated into your regular capacity planning processes:

### Quarterly planning approach
Adopt a quarterly planning cadence to manage quota efficiently:
- Submit all quota requests once per quarter to reduce ticket volume.
- Calculate your quarterly needs plus a 30% buffer.
- Batch quota and regional/zonal access requests together.
- Track actual usage to improve future forecasts.

### Monitoring and forecasting
Following [Microsoft's Well-Architected Framework](https://learn.microsoft.com/en-us/azure/well-architected/performance-efficiency/capacity-planning) recommendations:
- Use Azure Monitor to track quota utilization trends.
- Analyze historical patterns to predict future demands.
- Document capacity requirements as part of your architectural decisions.

As stated in the framework: "Azure Monitor enables you to collect and analyze telemetry data from your applications and infrastructure."

### Key considerations
- **No automatic quota balancing**: You must manually transfer quota between subscriptions.
- **No guaranteed processing times**: Plan capacity requests early.
- **Regional and zonal restrictions**: [Quota Groups don't solve for zonal restrictions](https://learn.microsoft.com/en-us/azure/quotas/quota-groups) - these require separate access requests.
