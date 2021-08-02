---
Module Name: Microsoft.Teams.Config
Module Guid: 82b0bf19-c5cd-4c30-8db4-b458a4b84495
Download Help Link: https://docs.microsoft.com/en-us/powershell/module/microsoft.teams.config
Help Version: 1.0.0.0
Locale: en-US
---

# Microsoft.Teams.Config Module
## Description


## Microsoft.Teams.Config Cmdlets
### [Get-CsBatchPolicyAssignmentOperation](Get-CsBatchPolicyAssignmentOperation.md)
This cmdlet returns the status of all batch policy assignment operations for the last 30 days.
If an operation ID is specified, the detailed status for that operation is returned including the status for each user in the batch.

### [Get-CsGroupPolicyAssignment](Get-CsGroupPolicyAssignment.md)
This cmdlet returns group policy assignments.
Optional parameters allow the results to be restricted to policies assigned to a specific group or policies of a specific type.

### [Get-CsUserPolicyAssignment](Get-CsUserPolicyAssignment.md)
Get a list of effective policies for User.
Taking direct assignments and group assignments into consideration

### [New-CsBatchPolicyAssignmentOperation](New-CsBatchPolicyAssignmentOperation.md)
When a policy is assigned to a batch of users, the assignments are performed as an asynchronous operation.
The cmdlet returns the operation ID which can be used to track the progress and status of the assignments.
Users can be specified by their object ID (guid) or by their UPN/SIP/email (user@contoso.com).
A batch may contain up to 20,000 users.
Batch policy assignment is currently limited to the following policy types: CallingLineIdentity, OnlineVoiceRoutingPolicy, TeamsAppSetupPolicy, TeamsAppPermissionPolicy, TeamsCallingPolicy, TeamsCallParkPolicy, TeamsChannelsPolicy, TeamsEducationAssignmentsAppPolicy, TeamsEmergencyCallingPolicy, TeamsMeetingBroadcastPolicy, TeamsEmergencyCallRoutingPolicy, TeamsMeetingPolicy, TeamsMessagingPolicy, TeamsUpdateManagementPolicy, TeamsUpgradePolicy,  TeamsVerticalPackagePolicy, TeamsVideoInteropServicePolicy, TenantDialPlan

### [New-CsGroupPolicyAssignment](New-CsGroupPolicyAssignment.md)
This cmdlet will assign a policy to a group.
The policy assignment will then be propagated to the members of the group in accordance with the rules for group policy inheritance.
If a user is directly assigned a policy of a specific type, then they will not inherit a policy of the same type from a group.
If a user is a member of two or more groups that each have a policy of the same type assigned, then the user will inherit the policy based on the group policy assignment with the highest rank.
The group policy assignment rank is set at the time a policy is being assigned to a group and is relative to other group policy assignments of the same policy type.
For example, if there are two groups, each assigned a Teams Meeting policy, then one of the group assignments will be rank 1 while the other will be rank 2.
It is helpful to think of rank as determining the position of each policy assignment in an ordered list, from highest rank to lowest rank.
In fact, rank can be specified as any number, but these are converted into sequential values 1, 2, 3, etc.
with 1 being the highest rank.
When assigning a policy to a group, set the rank to be the position in the list where you want the new group policy assignment to be.
If a rank is not specified, the policy assignment will be given the lowest rank, corresponding to the end of the list.
Group policy assignment is currently limited to the following policy types: TeamsCallingPolicy, TeamsCallParkPolicy, TeamsChannelPolicy, TeamsEducationAssignmentsAppPolicy, TeamsMeetingBroadcastPolicy, TeamsMeetingPolicy, TeamsMessagingPolicy

### [Remove-CsGroupPolicyAssignment](Remove-CsGroupPolicyAssignment.md)
This cmdlet removes the policy of a specific type from a group.
A group can only be assigned one policy of a given type, so the name of the policy to be removed does not need to be specified.
When a policy assignment is removed from a group, any other group policy assignments of the same type that have lower rank will be updated.
For example, if the policy assignment with rank 2 is removed, then the rank 3 and 4 policy assignments will be updated to rank  2 and 3 respectively.

### [Set-CsGroupPolicyAssignment](Set-CsGroupPolicyAssignment.md)
This cmdlet will update the policy assignment for a group for a given policy type.
The policy instance and/or policy rank can be updated.
Refer to New-CsGroupPolicyAssignment for more details about rank.

