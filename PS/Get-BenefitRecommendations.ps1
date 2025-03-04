
[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $BillingScope="providers/Microsoft.Billing/billingAccounts/1234567",

    [Parameter()]
    [string]
    [ValidateSet('Last7Days', 'Last30Days', 'Last60Days')]
    $LookBackPeriod='Last7Days',

    [Parameter()]
    [string]
    [ValidateSet('P1Y', 'P3Y')]
    $term='P3Y'
)

$url="https://management.azure.com/{0}/providers/Microsoft.CostManagement/benefitRecommendations?`$filter=properties/lookBackPeriod eq '{1}' AND properties/term eq '{2}'&`$expand=properties/usage,properties/allRecommendationDetails&api-version=2024-08-01" -f $BillingScope, $lookBackPeriod, $term
$uri=[uri]::new($url)
$result = Invoke-AzRestMethod -Uri $uri.AbsoluteUri -Method GET
$jsonResult = $result.Content | ConvertFrom-Json

Write-Output ""
Write-Output "Raw output"
$result.Content
Write-Output ""
Write-Output "Recommended savings plan"
$jsonResult.value.properties.recommendationDetails | Format-Table
Write-Output ""
Write-Output "All savings plan recommendations"
$jsonResult.value.properties.allRecommendationDetails.value | Format-Table