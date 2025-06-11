---
layout: page
title: Region Access Requests
parent: Operations & Support
nav_order: 4
---

# Azure region access request process

Certain Azure regions require customers to go through a request process in order to gain access. To request access to these regions, you may [open a support request](https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade/newsupportrequest) and work with our Support team to discuss or enable access.

{: .important }
> **Important for Quota Groups**: This process is essential for Quota Groups functionality. Quota Groups addresses quota management but does not address regional or zonal access. Quota transfers between subscriptions and deployments will fail unless regional and zonal access is provided on the subscription.

---

## Step 1: Create a new support request

The process to request access is relatively straight forward. You can initiate the process directly within the Azure portal, follow these steps:

1. Log into the [Azure Portal](https://portal.azure.com/) and navigate to **Help + support**, then select **Create a new support request**.

2. In the **New support request** page, complete the following:
   - **Issue Type**: Select **Service and subscription Limit (quotas)**
   - **Subscription**: Select the relevant subscription for which you would like to request access
   - **Quota type**: Select **Compute-VM (core-vCPUs) subscription limit increases**
   - Select **Next**

<figure>
<img src="img/region-request-basics.png" alt="New Support Request information under Basics tab" width="70%" class="clickable-image" />
<figcaption>New support request form showing the basic configuration for region access</figcaption>
</figure>

## Step 2: Provide problem details

1. In the **Problem details** section, select **Enter details**.

<figure>
<img src="img/region-request-enter-details.png" alt="Enter details button" width="50%" class="clickable-image" />
<figcaption>Problem details section with Enter details button highlighted</figcaption>
</figure>

2. Select the deployment mode.
3. Select one or more regions that you want to request access. If the regions are not listed, go to the **Reserved access regions** section.
4. Select the VM series, and then specify new vCPU limit.

<figure>
<img src="img/region-request-quota-details.png" alt="Quota details page" width="70%" class="clickable-image" />
<figcaption>Quota details configuration showing region selection and VM series options</figcaption>
</figure>

5. Select **Save and continue**.

---

## Step 3: Enter your support method

1. Select the severity based on your urgency of request.
2. Fill in the details for the best way to contact you. We use this information to follow up with you if we need extra information, or need to learn more about your intended use of the Azure Region to which you are requesting access.
3. Select **Create** to complete the process.

---

## Request processing

Once you create the support request, the ticket follows our standard process, including a stop with the Azure Engineering team, where we validate the claims made in the request. This may include reaching out to the requestor for further details, so ensure that you add up-to-date contact details.

The support request will be routed back to you once complete, letting you know of the result. If successful, you will then see the Azure Region you have requested access to in your portal and can begin to consume resources just like any other Azure region.

---

## Reserved access regions

To view which regions are access restricted, see [Azure paired regions](https://learn.microsoft.com/en-us/azure/reliability/cross-region-replication-azure#azure-paired-regions).

To request access for the reserved access regions, follow these steps:

1. In the **New support request** page, complete the following:
   - **Issue Type**: Select **Service and subscription Limit (quotas)**
   - **Subscription**: Select the relevant subscription for which you would like to request access
     
     > **Note**: If you want to enable the region access for multiple subscriptions, you can include the additional subscription IDs in the Description section in the next page, thereby avoiding the need to fill out multiple support requests.
     
   - **Quota type**: Select **Other Requests**
   - Select **Next**

2. In the description section, input "Request access for the Azure `<the region name>` Regions for `<your organization name>`". Then specify your initial deployment model, your compute, storage, and SQL resource quota.

---

### Recommended quota template

If you're unsure about what you'll need, we recommend that you add the following basic quota to the description section of the request, and include all the VM Types you are likely to need over time. This won't lock you into a specific quota. The quota can be adjusted as necessary over time.

| Field | Value |
|-------|-------|
| Region to Enable | `<insert the region you are requesting access to>` |
| Deployment Model | ARM |
| Planned VM types | For example, Dv3 Series |
| Planned Compute usage in Cores | 25 |
| Planned Storage usage in TB | 10 |
| Planned SQL Database SKU | For example, S0 |
| Planned No. of Databases per DB SKU (20 DB limit per SKU) | `<specify number>` |

---

### Additional resource considerations

You can also include the following additional resource needs in your support request, or submit via a separate support request at another time:

---

#### Azure VM Reserved Instances

List the specific VM Types for which you plan to apply Reserved Instances, and your estimated usage in Cores.

| Field | Value |
|-------|-------|
| Issue Type | Reserved Instance Region enablement |
| Subscription ID that needs to be enabled | `<subscription ID>` |
| Region: Name of the region | `<insert the Azure region you are requesting access to>` |
| VM Series: (Example Dv2) | `<specify series>` |
| Planned usage in Cores | `<specify cores>` |

> **Note**: Once access is confirmed for Reserved Instances, you can make the Reserved Instance purchase.

---

#### SQL Data Warehouse

In the details section of the request, add the SQL Data warehouse requirements with the following:

| Field | Value |
|-------|-------|
| Subscription GUID | Only needed if submitting as a standalone request |
| Region | `<insert the Azure region you are requesting access to>` |

---

### Best practices for requests

- In your submission form, list all Virtual Machine SKUs, which you would like to request access for, along with your requested quota, thereby avoiding the need to fill out multiple support requests.
- If you want to request access for Storage, SQL, SQL-Managed Instance, HDI, and/or Batch, we recommend including these in your submission as well, along with your requested quota for these.
- If you have multiple Subscription IDs, include any additional Subscription IDs in the description section.
- If you prefer to submit multiple requests, Microsoft Support will combine these requests on your behalf, for more streamlined communications.

3. Enter your contact details and create the support ticket.

---

## Related resources

- [Azure paired regions](https://learn.microsoft.com/en-us/azure/reliability/cross-region-replication-azure#azure-paired-regions)
- [Create a support request](https://ms.portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade/overview?DMC=troubleshoot)
- [Azure community support](https://learn.microsoft.com/en-us/answers/products/azure?product=all)
- [Azure feedback community](https://feedback.azure.com/d365community)

---

## Connection to quota groups

Once regional and zonal access is approved for your subscriptions, you can then use Quota Groups to manage quota across those subscriptions. See:
- [Overview & benefits](01-intro-benefits-scenarios.md) - Learn about Quota Groups capabilities
- [Prerequisites](02-prerequisites.md) - Review requirements before setting up Quota Groups
- [Creating quota groups](03-creating-quota-groups.md) - Step-by-step setup guide

---

*This documentation is based on Microsoft Learn article: [Azure region access request process](https://learn.microsoft.com/en-us/troubleshoot/azure/general/region-access-request-process)*
