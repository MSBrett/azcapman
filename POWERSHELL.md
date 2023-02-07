# Powershell Scripts for Managing Quota  

## Query existing quota:

```
$Location = 'West US 2'
$VMSize = 'Standard_D4d_v4'
$SKU = Get-AzComputeResourceSku -Location $Location | where ResourceType -eq "virtualMachines" | select Name,Family
$VMFamily = ($SKU | where Name -eq $VMSize | select -Property Family).Family
$Usage = Get-AzVMUsage -Location $Location | Where-Object { $_.Name.Value -eq $VMFamily }
