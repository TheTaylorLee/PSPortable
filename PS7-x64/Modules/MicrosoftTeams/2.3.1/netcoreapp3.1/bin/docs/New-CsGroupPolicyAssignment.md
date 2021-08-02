---
external help file:
Module Name: Microsoft.Teams.ConfigAPI.Cmdlets
online version: https://docs.microsoft.com/en-us/powershell/module/Teams/new-csgrouppolicyassignment
schema: 2.0.0
---

# New-CsGroupPolicyAssignment

## SYNOPSIS
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

## SYNTAX

```
New-CsGroupPolicyAssignment -GroupId <String> -PolicyType <String> -PolicyName <String> [-Rank <Int32>]
 [-PassThru] [-Confirm] [-WhatIf] [<CommonParameters>]
```

## DESCRIPTION
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

### -GroupId
The ID of a batch policy assignment operation.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Returns true when the command succeeds

```yaml
Type: System.Management.Automation.SwitchParameter
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

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PolicyType
The policy type for which group policy assignments will be returned.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Rank
.

```yaml
Type: System.Int32
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

