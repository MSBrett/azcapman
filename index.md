---
layout: default
title: Quota Group Onboarding Guide for ISVs
description: Comprehensive guide for Independent Software Vendors to implement and manage Azure Quota Groups.
nav_order: 0
---

# Quota group onboarding guide for ISVs

This guide helps Independent Software Vendors implement Azure quota groups to manage capacity across customer subscriptions.

## About this guide

Use this guide if you're an ISV who needs to:
- Share compute quota across multiple Azure subscriptions
- Reallocate unused quota without filing support tickets
- Request quota increases at the group level instead of per subscription
- Reduce quota management overhead for IaaS compute resources

## Quick start

New to Azure quota groups? Follow this learning path:

1. **[Getting Started](getting-started.html)** - Learn about quota groups and assess benefits for your ISV
2. **[Implementation](implementation.html)** - Set up quota groups for your ISV solution
3. **[Operations & Support](operations-support.html)** - Manage quota groups in production
4. **[Tools & Scripts](tools-scripts.html)** - Automate quota management workflows

## Why quota groups for ISVs

- **Share quota efficiently** - Pool compute quota across customer subscriptions in your group
- **Self-service management** - Redistribute unused quota without Microsoft support tickets
- **Streamlined requests** - Submit quota increases at the group level, then allocate to subscriptions
- **Reduced overhead** - Fewer quota-related support requests and administrative tasks

{: .important }
> **Note**: Quota Groups only support IaaS compute resources and require Enterprise Agreement, Microsoft Customer Agreement, or Internal subscriptions.

## Quarterly capacity planning with Quota Groups

Maintain a quarterly planning cadence to streamline quota management:
- **Submit 90 days in advance** - Submit all requests at the start of each quarter for the next quarter.
- **Buffer adequately** - Request your projected quarterly usage plus 30%.
- **Batch requests** - Submit quota and zonal access requests together.
- **Track utilization** - Monitor trends to refine future projections.

[Quota Groups](https://learn.microsoft.com/en-us/azure/quotas/quota-groups) enable self-service quota management across subscriptions, reducing the number of support transactions needed.

{: .warning }
> **Important**: Quota requests don't have guaranteed processing times. Always submit requests 90 days in advance. See our [capacity planning integration guide](docs/12-capacity-planning-integration.html) for detailed planning strategies.

## Documentation sections

### 📚 [Getting Started](getting-started.html)
Learn about quota groups and plan your implementation.

### ⚙️ [Implementation](implementation.html)
Step-by-step guides for setting up quota groups.

### 🔄 [Operations & Support](operations-support.html)
Manage and troubleshoot quota groups in production.

### 🛠️ [Tools & Scripts](tools-scripts.html)
PowerShell scripts and automation tools for quota management.

---

Use the navigation menu on the left to browse through all sections.
