# Azure Quota and Capacity Management Documentation

This repository contains comprehensive documentation for Azure quota and capacity management, built with Jekyll and the Just the Docs theme for GitHub Pages.

## 🚀 Quick Start

### Local Development

1. Install Ruby (>= 3.2) and Bundler
2. Run:
   ```sh
   bundle install
   bundle exec jekyll serve --livereload
   ```
3. Visit [http://localhost:4000/azcapman/](http://localhost:4000/azcapman/) to preview the site

### GitHub Pages Deployment

This site is configured for automatic deployment to GitHub Pages using the remote theme feature. Push changes to the main branch to trigger deployment.

## Deployment

- The site is automatically built and deployed to GitHub Pages on every push to `main` via GitHub Actions.
- To update the site, edit Markdown files and push changes to `main`.

## Structure

- `index.md` — Home page
- `docs/` — Documentation content
- `_config.yml` — Jekyll/Just the Docs configuration
- `Gemfile` — Ruby dependencies
- `.github/workflows/gh-pages.yml` — GitHub Actions workflow for deployment

For more, see [Just the Docs documentation](https://just-the-docs.github.io/just-the-docs/docs/).

# Quota and Capacity Management
This repo contains best practices and helper code for managing quota in Azure.

## Request new quota
Quota is granted regionally.  Access to availability zones is requested separately.
- Query             : [Resource Skus – List (customer will just see the Region/Zone not available for the sub)](https://learn.microsoft.com/en-us/rest/api/compute/resource-skus/list?tabs=Go)
- Quota API         : [Azure Quota REST API Reference | Microsoft Learn](https://learn.microsoft.com/en-us/rest/api/reserved-vm-instances/quotaapi)
- Service Request   : [Request quota increase via Support API | Microsoft Learn](https://learn.microsoft.com/en-us/rest/api/support/quota-payload)  
- Zonal Access      : [Azure region access request process - Azure | Microsoft Learn](https://learn.microsoft.com/en-us/troubleshoot/azure/general/region-access-request-process#reserved-access-regions)


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

