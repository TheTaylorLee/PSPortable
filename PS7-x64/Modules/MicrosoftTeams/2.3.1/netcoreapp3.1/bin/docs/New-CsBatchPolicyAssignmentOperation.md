---
external help file:
Module Name: Microsoft.Teams.ConfigAPI.Cmdlets
online version: https://docs.microsoft.com/en-us/powershell/module/Teams/new-csbatchpolicyassignmentoperation
schema: 2.0.0
---

# New-CsBatchPolicyAssignmentOperation

## SYNOPSIS
When a policy is assigned to a batch of users, the assignments are performed as an asynchronous operation.
The cmdlet returns the operation ID which can be used to track the progress and status of the assignments.
Users can be specified by their object ID (guid) or by their UPN/SIP/email (user@contoso.com).
A batch may contain up to 20,000 users.
Batch policy assignment is currently limited to the following policy types: CallingLineIdentity, OnlineVoiceRoutingPolicy, TeamsAppSetupPolicy, TeamsAppPermissionPolicy, TeamsCallingPolicy, TeamsCallParkPolicy, TeamsChannelsPolicy, TeamsEducationAssignmentsAppPolicy, TeamsEmergencyCallingPolicy, TeamsMeetingBroadcastPolicy, TeamsEmergencyCallRoutingPolicy, TeamsMeetingPolicy, TeamsMessagingPolicy, TeamsUpdateManagementPolicy, TeamsUpgradePolicy,  TeamsVerticalPackagePolicy, TeamsVideoInteropServicePolicy, TenantDialPlan

## SYNTAX

```
New-CsBatchPolicyAssignmentOperation -Identity <String[]> [-OperationName <String>]
 [-AdditionalParameters <Hashtable>] [-PolicyName <String>] [-PolicyType <String>] [-Confirm] [-WhatIf]
 [<CommonParameters>]
```

## DESCRIPTION
When a policy is assigned to a batch of users, the assignments are performed as an asynchronous operation.
The cmdlet returns the operation ID which can be used to track the progress and status of the assignments.
Users can be specified by their object ID (guid) or by their UPN/SIP/email (user@contoso.com).
A batch may contain up to 20,000 users.
Batch policy assignment is currently limited to the following policy types: CallingLineIdentity, OnlineVoiceRoutingPolicy, TeamsAppSetupPolicy, TeamsAppPermissionPolicy, TeamsCallingPolicy, TeamsCallParkPolicy, TeamsChannelsPolicy, TeamsEducationAssignmentsAppPolicy, TeamsEmergencyCallingPolicy, TeamsMeetingBroadcastPolicy, TeamsEmergencyCallRoutingPolicy, TeamsMeetingPolicy, TeamsMessagingPolicy, TeamsUpdateManagementPolicy, TeamsUpgradePolicy,  TeamsVerticalPackagePolicy, TeamsVideoInteropServicePolicy, TenantDialPlan

## EXAMPLES

### Example 1: {{ Add title here }}
```powershell
PS C:\> {{ Add code here }}

{{ Add output here }}
```

{{ Add description here }}

### Example 2: {{ Add title here }}
```powershell
PS C:\> {{ Add code here }}

{{ Add output here }}
```

{{ Add description here }}

## PARAMETERS

### -AdditionalParameters
Dictionary of \<any\>

```yaml
Type: System.Collections.Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Identity
.

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases: User

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OperationName
An optional name for the batch assignment operation.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PolicyName
.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PolicyType
.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String

## NOTES

ALIASES

## RELATED LINKS

