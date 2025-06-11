---
layout: page
title: Support Process
parent: Operations & Support
nav_order: 3
---

# Submit quota group limit increase and file support ticket if request fails

- If Quota Group limit request is rejected via API or portal, then customer must submit support ticket via the self-serve Quota Group request portal blade
- Support tickets for Quota Groups will be created based on a preselected subscription ID within the group, the customer has the ability to edit the sub ID when updating request details. Even though ticket's created using sub ID, if approved the quota will be stamped at the group level
- User requires at a minimum the Support request contributor role to create support ticket on subscription in the group
- Quota Groups addresses the quota management pain point, it doesn't address the regional and/or zonal access pain point. To get region and/or zonal access on subscriptions, [see region access request process](https://learn.microsoft.com/en-us/troubleshoot/azure/general/region-access-request-process). Quota transfers between subscriptions and deployments will fail unless regional and/or zonal access is provided on the subscription

---

## Portal

1. To view the Quotas page, sign in to the Azure portal and enter "quotas" into the search box, then select Quotas
2. Under settings in left hand side, select Quota groups
3. To view existing Quota Group, select Management Group filter and select management group used to create Quota Group
4. Select Quota Group from list of Quota Group(s)
5. In the Quota Group resources view there will be the list of Quota Group resources by region by Group quota (limit)
6. Use the filters to select Region and/or VM Family, you can also search for region and/or VM family in the search bar
7. Select the checkbox to the desired Quota Group resource, then select the Increase group quota button at the top of page
8. On right side view the New quota request blade with selected region(s) at the top with details on the selected Quota Group resource, the Current group quota value, and under New group quota column enter the absolute value of desired net new group limit. I.e., I want 20 cores assigned at group for DSv3 in Australia Central, I will enter 20 under New group quota
9. Select Submit button, notification We are reviewing your request to adjust the quota this may take up to ~3 minutes to complete
10. If successful the New quota request view will show the selected Quota Group resource by location status of request, the Increase value and New limit
11. Refresh the Quota Group resources view to view latest Group quota / group limit
12. If Quota Group limit increase was rejected notification We were unable to adjust your quota will surface
13. Select the Generate a support ticket button to start process of creating support ticket
14. In the Request details view Deployment model as Resource Manager, request details view will surface the Quota Group name, Management Group ID, Quota Group resource, Location selected, and the Desired increase value, select Save and Continue button
15. In Additional details view select required options Advance diagnostic information and Preferred contact method and select Next
16. Review details in Review + Create view and select Create button, notification New Support Request in top right corner will ticket ID and link
17. To view request details return to Quotas blade and select the Request tab under the Overview page, see the list of quota requests, you may also search and go to Help + Support blade and view request under Recent support requests table
