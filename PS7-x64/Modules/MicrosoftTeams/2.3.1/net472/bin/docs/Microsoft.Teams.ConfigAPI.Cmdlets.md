---
Module Name: Microsoft.Teams.ConfigAPI.Cmdlets
Module Guid: 82b0bf19-c5cd-4c30-8db4-b458a4b84495
Download Help Link: https://docs.microsoft.com/en-us/powershell/module/microsoft.teams.configapi.cmdlets
Help Version: 1.0.0.0
Locale: en-US
---

# Microsoft.Teams.ConfigAPI.Cmdlets Module
## Description


## Microsoft.Teams.ConfigAPI.Cmdlets Cmdlets
### [Connect-CsConfigApi](Connect-CsConfigApi.md)


### [Disconnect-CsConfigApi](Disconnect-CsConfigApi.md)


### [Get-CsAcquiredNumberV2Async](Get-CsAcquiredNumberV2Async.md)


### [Get-CsAreaCodeV2AreaCodeAsync](Get-CsAreaCodeV2AreaCodeAsync.md)


### [Get-CsBatchPolicyAssignmentOperation](Get-CsBatchPolicyAssignmentOperation.md)
This cmdlet returns the status of all batch policy assignment operations for the last 30 days.
If an operation ID is specified, the detailed status for that operation is returned including the status for each user in the batch.

### [Get-CsCapabilityV2Capability](Get-CsCapabilityV2Capability.md)


### [Get-CsCapabilityV2OrderAsync](Get-CsCapabilityV2OrderAsync.md)


### [Get-CsGroupPolicyAssignment](Get-CsGroupPolicyAssignment.md)
This cmdlet returns group policy assignments.
Optional parameters allow the results to be restricted to policies assigned to a specific group or policies of a specific type.

### [Get-CsInternalConfigApiModuleVersion](Get-CsInternalConfigApiModuleVersion.md)


### [Get-CsOdcBridge](Get-CsOdcBridge.md)
Get a specific bridge by identity.

### [Get-CsOdcServiceNumber](Get-CsOdcServiceNumber.md)
Get service number by unique id.

### [Get-CsOnlinePowerShellEndpoint](Get-CsOnlinePowerShellEndpoint.md)


### [Get-CsOnlineSession](Get-CsOnlineSession.md)


### [Get-CsOrderV2Async](Get-CsOrderV2Async.md)


### [Get-CsPolicyPackage](Get-CsPolicyPackage.md)
Get all the policy packages available on a tenant

### [Get-CsPortInOrderV2FormAsync](Get-CsPortInOrderV2FormAsync.md)


### [Get-CsPortInOrderV2OrderAsync](Get-CsPortInOrderV2OrderAsync.md)


### [Get-CsReleaseOrderV2](Get-CsReleaseOrderV2.md)


### [Get-CsSearchOrderV2OrderAsync](Get-CsSearchOrderV2OrderAsync.md)


### [Get-CsSmV2OrderAsync](Get-CsSmV2OrderAsync.md)


### [Get-CsTeamTemplate](Get-CsTeamTemplate.md)
Get details of a team template given the uri.

### [Get-CsTeamTemplateList](Get-CsTeamTemplateList.md)


### [Get-CsTenantApp](Get-CsTenantApp.md)
Get Tenant.

### [Get-CsTenantLocationPhoneNumberAsync](Get-CsTenantLocationPhoneNumberAsync.md)
Get phone numbers by location.

### [Get-CsTenantLocationUserAsync](Get-CsTenantLocationUserAsync.md)
Get users by location.

### [Get-CsTenantObou](Get-CsTenantObou.md)
Get Tenant.

### [Get-CsTenantPhoneAssignment](Get-CsTenantPhoneAssignment.md)
Get phone number assignment count at given civic address.

### [Get-CsTenantUserAssignment](Get-CsTenantUserAssignment.md)
Get User assignment count at given civic address.

### [Get-CsUser](Get-CsUser.md)
Get User.

### [Get-CsUserApp](Get-CsUserApp.md)
Get User.

### [Get-CsUserPolicyAssignment](Get-CsUserPolicyAssignment.md)
Get a list of effective policies for User.
Taking direct assignments and group assignments into consideration

### [Get-CsUserPolicyPackage](Get-CsUserPolicyPackage.md)
Get the policy package assigned to a user

### [Get-CsUserPolicyPackageRecommendation](Get-CsUserPolicyPackageRecommendation.md)
Get recommendations on which policy packages are best suited for a given user

### [Grant-CsBatchPolicy](Grant-CsBatchPolicy.md)
Assign multiple policies to a list of users.

### [Grant-CsGroupPolicyPackageAssignment](Grant-CsGroupPolicyPackageAssignment.md)


### [Grant-CsUserPolicyPackage](Grant-CsUserPolicyPackage.md)
Assign a policy package to a list of users in a tenant (maximum of 20 users at a time)

### [Invoke-CsComprehensiveHealthV2HealthAsync](Invoke-CsComprehensiveHealthV2HealthAsync.md)


### [Invoke-CsDownloadPortInOrderV2LoaTemplateAsync](Invoke-CsDownloadPortInOrderV2LoaTemplateAsync.md)


### [Invoke-CsExecutePortInOrderV2ActionAsync](Invoke-CsExecutePortInOrderV2ActionAsync.md)


### [Invoke-CsHealthV2](Invoke-CsHealthV2.md)


### [Invoke-CsInternalBeginmove](Invoke-CsInternalBeginmove.md)
Begin Move

### [Invoke-CsInternalCompletemove](Invoke-CsInternalCompletemove.md)
Complete Move

### [Invoke-CsInternalGetpolicy](Invoke-CsInternalGetpolicy.md)
Get policies

### [Invoke-CsInternalPsTelemetry](Invoke-CsInternalPsTelemetry.md)


### [Invoke-CsInternalRehomeuser](Invoke-CsInternalRehomeuser.md)
RehomeUser

### [Invoke-CsInternalRollback](Invoke-CsInternalRollback.md)
Rollback

### [Invoke-CsInternalSelfhostLogger](Invoke-CsInternalSelfhostLogger.md)


### [Invoke-CsInternalSetmovedresourcedata](Invoke-CsInternalSetmovedresourcedata.md)
Set MovedResource Data

### [Invoke-CsInternalTelemetryRelay](Invoke-CsInternalTelemetryRelay.md)
Receives the telemetry data from the Connect-MicrosoftTeams cmdlet, and writes this data to MDM and MDS.

### [Invoke-CsInternalValidateuser](Invoke-CsInternalValidateuser.md)
Validate user

### [Invoke-CsProbeHealthV2RoleInstance](Invoke-CsProbeHealthV2RoleInstance.md)


### [Invoke-CsStatusHealthV2](Invoke-CsStatusHealthV2.md)


### [Invoke-CsTimeHealthV2](Invoke-CsTimeHealthV2.md)


### [Invoke-CsUploadPortInOrderV2LoaAsync](Invoke-CsUploadPortInOrderV2LoaAsync.md)


### [Move-CsInternalHelper](Move-CsInternalHelper.md)


### [New-CsBatchPolicyAssignmentOperation](New-CsBatchPolicyAssignmentOperation.md)
When a policy is assigned to a batch of users, the assignments are performed as an asynchronous operation.
The cmdlet returns the operation ID which can be used to track the progress and status of the assignments.
Users can be specified by their object ID (guid) or by their UPN/SIP/email (user@contoso.com).
A batch may contain up to 20,000 users.
Batch policy assignment is currently limited to the following policy types: CallingLineIdentity, OnlineVoiceRoutingPolicy, TeamsAppSetupPolicy, TeamsAppPermissionPolicy, TeamsCallingPolicy, TeamsCallParkPolicy, TeamsChannelsPolicy, TeamsEducationAssignmentsAppPolicy, TeamsEmergencyCallingPolicy, TeamsMeetingBroadcastPolicy, TeamsEmergencyCallRoutingPolicy, TeamsMeetingPolicy, TeamsMessagingPolicy, TeamsUpdateManagementPolicy, TeamsUpgradePolicy,  TeamsVerticalPackagePolicy, TeamsVideoInteropServicePolicy, TenantDialPlan

### [New-CsBatchPolicyPackageAssignmentOperation](New-CsBatchPolicyPackageAssignmentOperation.md)
Assign a policy package to a list of users in a tenant (maximum of 5000 users at a time).
Returns an operation id which can be checked at a later time.

### [New-CsCustomPolicyPackage](New-CsCustomPolicyPackage.md)


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

### [New-CsOnlineSession](New-CsOnlineSession.md)


### [New-CsPortInOrderV2Async](New-CsPortInOrderV2Async.md)


### [New-CsReleaseOrderV2Async](New-CsReleaseOrderV2Async.md)


### [New-CsSearchOrderV2OrderAsync](New-CsSearchOrderV2OrderAsync.md)


### [New-CsSmV2OrderAsync](New-CsSmV2OrderAsync.md)


### [New-CsTeamTemplate](New-CsTeamTemplate.md)


### [Remove-CsCustomPolicyPackage](Remove-CsCustomPolicyPackage.md)
Delete a policy package

### [Remove-CsGroupPolicyAssignment](Remove-CsGroupPolicyAssignment.md)
This cmdlet removes the policy of a specific type from a group.
A group can only be assigned one policy of a given type, so the name of the policy to be removed does not need to be specified.
When a policy assignment is removed from a group, any other group policy assignments of the same type that have lower rank will be updated.
For example, if the policy assignment with rank 2 is removed, then the rank 3 and 4 policy assignments will be updated to rank  2 and 3 respectively.

### [Remove-CsTeamTemplate](Remove-CsTeamTemplate.md)


### [Search-CsCountryV2CountryAsync](Search-CsCountryV2CountryAsync.md)


### [Search-CsPlanV2PlanAsync](Search-CsPlanV2PlanAsync.md)


### [Search-CsUser](Search-CsUser.md)
Searches a tenant for users.

### [Set-CsGroupPolicyAssignment](Set-CsGroupPolicyAssignment.md)
This cmdlet will update the policy assignment for a group for a given policy type.
The policy instance and/or policy rank can be updated.
Refer to New-CsGroupPolicyAssignment for more details about rank.

### [Set-CsInternalOnlinePowerShellEndpoint](Set-CsInternalOnlinePowerShellEndpoint.md)


### [Set-CsOdcBridge](Set-CsOdcBridge.md)
Sets a bridge using unique id.

### [Update-CsCapabilityV2CapabilityAsync](Update-CsCapabilityV2CapabilityAsync.md)


### [Update-CsCustomPolicyPackage](Update-CsCustomPolicyPackage.md)


### [Update-CsPortInOrderV2FormAsync](Update-CsPortInOrderV2FormAsync.md)


### [Update-CsSearchOrderV2OrderStatusAsync](Update-CsSearchOrderV2OrderStatusAsync.md)


### [Update-CsTeamTemplate](Update-CsTeamTemplate.md)


