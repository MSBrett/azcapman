# GO Examples for Managing Quota 

## Request AZ Enablement via a Service Request:


**1 ticket per subscription listing all regions, zones and SKUs.**

Invoke the “List Support Services” and get the name (which is a GUID) for the support service with display name: “Service and subscription limits (quotas)”. In my environment, this GUID is: 06bfd9d3-516b-d5c6-5802-169c800dec89

Use the support service name (GUID) from call above to get invoke “List Problem Classification” and get the name (which is a GUID) for the problem classification with display name: “Other Requests”. In my environment, this GUID is: 599a339a-a959-d783-24fc-81a42d3fd5fb

Use both the support service name (GUID) and the problem classification name (GUID) from the two calls above to create a support ticket. The Go SDK call will look something like what’s shown below. Please note everything in {{}} needs to be replaced with your values and the contact information should be updated appropriately. The documentation doesn’t call out specific limits in length or format of the ticket name, (and I’m not able to test in my environment), so I don’t know 100% if there are length/format restrictions that would prevent you from using the format: "{{subId}}-{{region}}-{{vmSeries}}". Additionally, I’m assuming the \n is valid for line breaks in the description, but again this will require testing.



```
    func ExampleTicketsClient_BeginCreate() {
    cred, err := azidentity.NewDefaultAzureCredential(nil)
    if err != nil {
        log.Fatalf("failed to obtain a credential: %v", err)
    }
    ctx := context.Background()
    client, err := armsupport.NewTicketsClient("subid", cred, nil)
    if err != nil {
        log.Fatalf("failed to create client: %v", err)
    }
    poller, err := client.BeginCreate(ctx,
        "{{subId}}-{{region}}-{{vmSeries}}",
        armsupport.TicketDetails{
            Properties: &armsupport.TicketDetailsProperties{
                Description: to.Ptr("Issue Type: Zone 1,2,3 access\nRegion: {{region}}\nVM Series: {{vmSeries}}\nPlanned Compute usage in Cores: {{coreQty}}\nPlanned UltraDisk usage in GB: {{ultraDiskQty}}\nPlanned Premium SSD v1 usage in GB: {{premiumDiskQty}}"),
                ContactDetails: &armsupport.ContactProfile{
                    Country:                  to.Ptr("usa"),
                    FirstName:                to.Ptr("abc"),
                    LastName:                 to.Ptr("xyz"),
                    PreferredContactMethod:   to.Ptr(armsupport.PreferredContactMethodEmail),
                    PreferredSupportLanguage: to.Ptr("en-US"),
                    PreferredTimeZone:        to.Ptr("Pacific Standard Time"),
                    PrimaryEmailAddress:      to.Ptr(abc@contoso.com),
                },
                ProblemClassificationID: to.Ptr("/providers/Microsoft.Support/services/{{serviceNameGuid}}/problemClassifications/{{problemClassificationNameGuid}}"),
                ServiceID:               to.Ptr("/providers/Microsoft.Support/services/{{serviceNameGuid}}"),
                Severity:                to.Ptr(armsupport.SeverityLevelModerate),
                Title:                   to.Ptr("Enable Zone 1, 2, 3 access for {{vmSeries}} in region {{region}}"),
            },
        },
        nil)
    if err != nil {
        log.Fatalf("failed to finish the request: %v", err)
    }
    res, err := poller.PollUntilDone(ctx, nil)
    if err != nil {
        log.Fatalf("failed to pull the result: %v", err)
    }
    // TODO: use response item
    _ = res
}