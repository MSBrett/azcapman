az rest --method put --url https://management.azure.com/providers/Microsoft.Management/managementGroups/alz-platform/providers/Microsoft.Quota/groupQuotas/platform-quota-group?api-version=2025-03-01 --body '{
  "properties": {
    "displayName": "Platform-Quota-Group"
  }
}'

az rest --method patch --url  https://management.azure.com/providers/Microsoft.Management/managementGroups/alz-platform/providers/Microsoft.Quota/groupQuotas/platform-quota-group?api-version=2025-03-01 --body '{
  "properties": {
    "value": [
      {
        "properties": {
          "resourceName": "standardddv4family",
          "limit": 50,
          "comment": "comments"
        }
      }
    ]
  }
}'