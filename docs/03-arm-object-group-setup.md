---
layout: page
title: Planning & Architecture
parent: Getting Started
nav_order: 3
---

# Quota group is an ARM object

Quota Group is a global ARM object created under a Management Group to logically group subscriptions for quota management. While it's tied to the Management Group for permissions, it doesn't auto-sync subscription membership. This means you have full flexibility to include subscriptions from different Management Groups. Quota Groups are:

- Quota Groups are created at the Management Group scope
- Quota Groups inherit permissions from their parent Management Group
- Quota Groups are designed as an orthogonal grouping mechanism. They're independent of subscription placement in the Management Group hierarchy
- Subscription lists aren't auto-synced from Management Groups, giving you flexibility to organize quotas separately from policy or role management

The following diagram shows an existing MG hierarchy set up with subscription 1 and subscription 2 being part of Management Group A, and subscription 3 being part of Management Group B. In this example, the customer chose to create all quota groups under the single Management Group A.

![Diagram of Management Group hierarchy with sample Quota Groups created under Management Group.](https://learn.microsoft.com/en-us/azure/quotas/media/quota-groups/sample-management-group-quota-group-hierarchy.png)

---

# Recommended group setup

A single Quota Group object manages quotas across multiple regions and VM families. Design your quota group structure with access control in mind. Access is inherited from the Management Group, so consider creating a tiered Management Group structure to ensure proper role assignments.

Example hierarchy:

- Management Group A owns Quota Groups 1 & 2
- Management Group B owns Quota Group 3
- Each quota group may be used to manage different applications, departments, and/or regions
- Quota Group operations such as quota transfers or increase requests, actions are scoped to specific regions and VM families

![Diagram of Management Group hierarchy with multiple Quota Groups created under Management Group.](https://learn.microsoft.com/en-us/azure/quotas/media/quota-groups/sample-recommended-quota-group-setup.png)
