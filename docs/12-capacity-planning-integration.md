---
layout: page
title: Capacity planning integration
parent: Getting Started
nav_order: 4
---

# Integrate Quota Groups with capacity planning

## Overview

Establish a quarterly planning cadence for quota management to avoid being overwhelmed with support tickets. By planning for a quarter plus 30% buffer, you can ensure adequate capacity while minimizing administrative overhead.

---

## Key planning principles

### Processing time considerations
According to [Azure quota documentation](https://learn.microsoft.com/en-us/azure/quotas/quickstart-increase-quota-portal), quota increase requests:
- Don't have guaranteed processing times.
- Can take extended periods to process.
- Might be rejected if capacity is limited.
- Require manual review and approval.

### Capacity planning framework

Based on [Microsoft's Well-Architected Framework](https://learn.microsoft.com/en-us/azure/well-architected/performance-efficiency/capacity-planning):

> "Capacity planning refers to the process of determining the resources required to meet workload performance targets."

The framework emphasizes:
- Continuous monitoring of resource utilization.
- Data-driven forecasting of future needs.
- Maintaining adequate buffers for unexpected demand.

---

## Recommended planning process

### 1. Monitor current usage
Use [Azure Quotas monitoring and alerting](https://learn.microsoft.com/en-us/azure/quotas/how-to-guide-monitoring-alerting) to:
- Track quota utilization across all subscriptions in your group.
- Set up alerts for usage percentage thresholds.
- Configure action groups to automate responses.
- Query usage patterns with Azure Resource Graph.

Set up alerts at 70% utilization to ensure you have time to request increases before reaching limits.

### 2. Forecast future needs
Apply forecasting techniques as recommended by Microsoft:
- Analyze historical data to predict future workload trends.
- Align quota planning with business growth projections.
- Consider seasonal variations in demand.
- Plan for customer onboarding pipelines.

### 3. Submit requests 90 days in advance
Submit all requests at the start of each quarter for the following quarter:
- **Standard practice**: 90-day advance submission for all requests.
- **Batch submission**: Submit quota and access requests together.
- **No exceptions**: Even "simple" requests should follow this timeline.

### 4. Maintain buffers
[Quota Groups](https://learn.microsoft.com/en-us/azure/quotas/quota-groups) require manual quota management. Maintain adequate buffers:
- Keep a 30% buffer above projected quarterly usage.
- Pre-allocate quota at the group level for flexibility.
- Reserve capacity across multiple regions when possible.

---

## Quarterly planning cadence

Maintain a quarterly planning rhythm to avoid being overwhelmed with quota and access requests. This approach helps you manage tickets efficiently while ensuring adequate capacity.

### Recommended quarterly cycle
1. **Start of quarter**: Submit all requests for next quarter (90 days in advance).
2. **Week 1-2**: Analyze current utilization and growth patterns.
3. **Week 3-4**: Calculate needs for the quarter after next plus 30% buffer.
4. **Week 5-13**: Monitor request progress and track approvals.

### Quota buffer strategy
Plan for a quarter plus 30% additional capacity:
- **Base calculation**: Next quarter's projected usage.
- **Growth buffer**: Add 30% for unexpected demand.
- **Example**: If you expect to use 1,000 vCPUs next quarter, request 1,300 vCPUs.

This buffer accounts for:
- Unexpected customer growth.
- Seasonal demand variations.
- Processing delays for future requests.

### Quarterly planning example

**Current state (Q1)**: Using 800 Standard_D4s_v5 vCPUs across your Quota Group.

**Planning for Q2**:
1. **Growth projection**: 20% quarterly growth = 960 vCPUs.
2. **Add 30% buffer**: 960 × 1.3 = 1,248 vCPUs.
3. **Submit request**: For 1,250 vCPUs (rounded up).
4. **Timing**: Submit on January 1st for Q2 (April-June usage).

---

## Setting up quota alerts

Configure proactive monitoring using [Azure Quotas alerts](https://learn.microsoft.com/en-us/azure/quotas/how-to-guide-monitoring-alerting):

1. **Navigate to Quotas** in the Azure portal and select "My Quotas."
2. **Create alert rules** for each critical VM family:
   - Set threshold at 70% usage.
   - Choose appropriate severity level.
   - Configure evaluation frequency (recommended: every 6 hours).
3. **Configure action groups** to:
   - Send email notifications to your capacity team.
   - Trigger automated quota increase requests.
   - Log to your ITSM system.
4. **Use consistent settings**: Apply the same Resource Group and Managed Identity for all alert rules within a subscription.

---

## Risk mitigation strategies

### Handle request uncertainties
Because requests might be delayed or denied:
- Submit requests for multiple regions when possible.
- Have fallback options for different VM families.
- Maintain relationships with Azure support teams.
- Document all requests and their status.

### Capacity constraints
Per [Microsoft's guidance](https://learn.microsoft.com/en-us/azure/quotas/quotas-overview), when capacity is low:
- Requests might be rejected regardless of your subscription type.
- No escalation path guarantees approval.
- Consider alternative regions or VM types.

---

## Best practices for quarterly planning

1. **Maintain quarterly rhythm** - Submit all requests once per quarter to reduce ticket overhead.
2. **Apply 30% buffer** - Always request your projected quarterly usage plus 30%.
3. **Set up alerts** - Configure [quota usage alerts](https://learn.microsoft.com/en-us/azure/quotas/how-to-guide-monitoring-alerting) at 70% threshold.
4. **Batch requests** - Submit quota and access requests together to streamline processing.
5. **Track patterns** - Use Azure Resource Graph queries to analyze historical usage.

---

## Related resources

- [Azure Quotas overview](https://learn.microsoft.com/en-us/azure/quotas/quotas-overview)
- [Capacity planning - Well-Architected Framework](https://learn.microsoft.com/en-us/azure/well-architected/performance-efficiency/capacity-planning)
- [Azure Monitor documentation](https://learn.microsoft.com/en-us/azure/azure-monitor/)
- [Quota Groups documentation](https://learn.microsoft.com/en-us/azure/quotas/quota-groups)