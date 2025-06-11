---
layout: page
title: Support Process
parent: Operations & Support
nav_order: 3
---

# Support ticket process for quota group requests

## When to file a support ticket

File a support ticket when:
- Your quota group limit increase request is rejected
- You encounter issues with quota transfers or allocations
- You need assistance with complex quota scenarios

## Requirements

- **Minimum role**: Support Request Contributor on a subscription within the group
- Support tickets are created using a subscription ID from the group, but approved quota is applied at the group level

## Filing a support ticket via portal

### Step 1: Navigate to quota groups
1. Sign in to the Azure portal and search for "quotas"
2. Select **Quota groups** under Settings
3. Use the Management Group filter to find your quota group
4. Select your quota group from the list

### Step 2: Request quota increase
1. Filter by Region and/or VM Family
2. Select the checkbox for your desired resource
3. Click **Increase group quota**
4. Enter the absolute value for your new group limit
5. Click **Submit**

### Step 3: Create support ticket (if request fails)
If you receive a "We were unable to adjust your quota" notification:

1. Click **Generate a support ticket**
2. Fill in the Request details:
   - Deployment model: Resource Manager (pre-filled)
   - Review the auto-populated quota group details
3. Complete Additional details:
   - Enable advance diagnostic information
   - Select preferred contact method
4. Review and create the ticket

### Step 4: Track your request
- View in Quotas > Request tab
- Or check Help + Support > Recent support requests

## Important notes

- Regional access must be granted separately - see [region access request process](https://learn.microsoft.com/en-us/troubleshoot/azure/general/region-access-request-process)
- Quota transfers will fail without proper regional/zonal access
