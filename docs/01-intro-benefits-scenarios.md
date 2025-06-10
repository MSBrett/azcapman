# Azure Quota Groups

Azure Quota Groups allow you to share quota among a group of subscriptions, reducing the number of quota transactions. This feature elevates the quota construct from a subscription level to a Quota Group Azure Resource Management (ARM) object, enabling customers to self-manage their procured quota within a group without needing approvals.

## Key benefits

- Quota sharing across subscriptions: Share procured quotas within a group of subscriptions
- Self-service management: Distribute or reallocate unused quota without Microsoft intervention
- Fewer support requests: Avoid filing support tickets when reallocating quota or managing new subscriptions
- Group quota requests: Request quota at the group level and allocate it across subscriptions as needed

## Supported scenarios

The transfer of unused quota between subscriptions is done via Quota Group object created. At the moment of creating a Quota Group object, the group limit is set to 0. Customers must update the group limit themselves, either by transferring quota from a subscription in the group or by submitting a Quota Group limit increase request and getting approved. When deploying resources, the quota check at runtime is done against the subscription quota.

- Deallocation: Transfer unused quota from your subscriptions to Group Quota
- Allocation: Transfer quota from group to target subscriptions
- Submit Quota Group increase request for a given region and Virtual Machine (VM) family. Once your request's approved, transfer quota from group to target subscriptions
- Quota Group increase requests are subject to the same checks as subscription quota increase requests. If capacity's low, then the request is rejected
