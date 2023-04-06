# Powershell Scripts for Managing Quota  

## Query existing quota:

```
$Location = 'West US 2'
$VMSize = 'Standard_D4d_v4'
$SKU = Get-AzComputeResourceSku -Location $Location | where ResourceType -eq "virtualMachines" | select Name,Family
$VMFamily = ($SKU | where Name -eq $VMSize | select -Property Family).Family
$Usage = Get-AzVMUsage -Location $Location | Where-Object { $_.Name.Value -eq $VMFamily }
```
## Programmatically creating regional quota requests (PowerShell)
```
$QuotaPercentageThreshold = "80"
$NewLimitIncrement = "25"
$Location = 'EastUS'
$VMSize = 'Standard_B2ms'

$SKU = Get-AzComputeResourceSku -Location $Location | Where-Object ResourceType -eq "virtualMachines" | Select-Object Name,Family
$VMFamily = ($SKU | Where-Object Name -eq $VMSize | Select-Object -Property Family).Family
$Usage = Get-AzVMUsage -Location $Location | Where-Object { $_.Name.Value -eq $VMFamily } | Select-Object @{label="Name";expression={$_.name.LocalizedValue}},currentvalue,limit, @{label="PercentageUsed";expression={[math]::Round(($_.currentvalue/$_.limit)*100,1)}}
$NewLimit = $Usage.Limit + $NewLimitIncrement

#Ticket Details
$TicketName =  "Quota Request"
$TicketTitle = "Quota Request"
$TicketDescription = "Quota request for $VMSize"
$Severity = "Critical" #Minimal, Moderate, Critical, HighestCriticalImpact
$ContactFirstName = "Mike"
$ContactLastName = "Tyson"
$TimeZone = "pacific standard time"
$Language = "en-us"
$Country = "USA"
$PrimaryEmail = "mtyson@boxing.com"
$AdditionalEmail = "mjordan@nba.com"
$ServiceNameGUID = "06bfd9d3-516b-d5c6-5802-169c800dec89" 
$ProblemClassificationGUID = "599a339a-a959-d783-24fc-81a42d3fd5fb"

Write-Output "$($Usage.Name.LocalizedValue): You have consumed Percentage: $($USage.PercentageUsed)% | $($Usage.CurrentValue) /$($Usage.Limit) of available quota"

if ($($USage.PercentageUsed) -gt $QuotaPercentageThreshold) {
    Write-Output "Creating support case"
    New-AzSupportTicket `
        -Name "$TicketName" `
        -Title "$TicketTitle" `
        -Description "$TicketDescription" `
        -Severity "$Severity" `
        -ProblemClassificationId "/providers/Microsoft.Support/services/$ServiceNameGUID/problemClassifications/$ProblemClassificationGUID" `
        -QuotaTicketDetail @{QuotaChangeRequestVersion = "1.0" ; QuotaChangeRequests = (@{Region = "$Location"; Payload = "{`"VMFamily`":`"$VMSize`",`"NewLimit`":$NewLimit}"})} -CustomerContactDetail @{FirstName = "$ContactFirstName" ; LastName = "$ContactLastName" ; PreferredTimeZone = "$TimeZone" ; PreferredSupportLanguage = "$Language" ; Country = "$Country" ; PreferredContactMethod = "Email" ; PrimaryEmailAddress = "$PrimaryEmail" ; AdditionalEmailAddress = "$AdditionalEmail"}
}
else {
    Write-Output "Nothing to do here, exiting"
    Exit
}
```
