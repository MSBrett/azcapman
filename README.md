# Quota and Capacity Management
This repo contains best practices and helper code for managing quota in Azure.

## Request new quota
Quota is granted regionally.  Access to availability zones is requested separately.
- Regional Quota : [Request quota increase via Support API | Microsoft Learn](https://learn.microsoft.com/en-us/rest/api/support/quota-payload)  
- Zonal Access : [Azure region access request process - Azure | Microsoft Learn](https://learn.microsoft.com/en-us/troubleshoot/azure/general/region-access-request-process#reserved-access-regions)


## APIs for requesting Quota via a Service Request.
This is the fall-back path for scenarios where quota cannot granted via the Quota API or where AZ enablement is required.  There are 3 API calls involved in creating the support request – 2 of which can be cached per subscription:

[List Support Services](https://learn.microsoft.com/en-us/rest/api/support/services/list?tabs=G)

[List Problem Classifications](https://learn.microsoft.com/en-us/rest/api/support/problem-classifications/list?tabs=Go)

[Create Support Ticket](https://learn.microsoft.com/en-us/rest/api/support/support-tickets/create?tabs=Go) 

## Zonal requests

Zonal capacity requests are classified differently to typical quota requests.
- Issue Type: Service and subscription Limit (quotas).
- Quota type: select Other Requests.
- In Subscription, select the relevant subscription for which you would like to request access. 
- If you want to enable the region access for multiple subscriptions, you can include the additional subscription IDs in the Description section in the next page, thereby avoiding the need to fill out multiple support requests.

| Field            | Value         
|------------------|---------------|
| Region to Enable                                          | insert the region you are requesting access to |
| Deployment Model                                          | ARM                                            |
| Planned VM types                                          | For example, Dv3 Series |
| Planned Compute usage in Cores                            | 25 |
| Planned Storage usage in TB                               | 10 |
| Planned SQL Database SKU                                  | For example, S0 |
| Planned No. of Databases per DB SKU (20 DB limit per SKU) | 20 |
    
