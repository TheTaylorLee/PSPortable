---
external help file:
Module Name: Microsoft.Teams.ConfigAPI.Cmdlets
online version: https://docs.microsoft.com/en-us/powershell/module/Teams/remove-csgrouppolicyassignment
schema: 2.0.0
---

# Remove-CsGroupPolicyAssignment

## SYNOPSIS
This cmdlet removes the policy of a specific type from a group.
A group can only be assigned one policy of a given type, so the name of the policy to be removed does not need to be specified.
When a policy assignment is removed from a group, any other group policy assignments of the same type that have lower rank will be updated.
For example, if the policy assignment with rank 2 is removed, then the rank 3 and 4 policy assignments will be updated to rank  2 and 3 respectively.

## SYNTAX

```
Remove-CsGroupPolicyAssignment -GroupId <String> -PolicyType <String> [-PassThru] [-Confirm] [-WhatIf]
 [<CommonParameters>]
```

## DESCRIPTION
This cmdlet removes the policy of a specific type from a group.
A group can only be assigned one policy of a given type, so the name of the policy to be removed does not need to be specified.
When a policy assignment is removed from a group, any other group policy assignments of the same type that have lower rank will be updated.
For example, if the policy assignment with rank 2 is removed, then the rank 3 and 4 policy assignments will be updated to rank  2 and 3 respectively.

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
The ID of the group from which the assignment will be removed.

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

