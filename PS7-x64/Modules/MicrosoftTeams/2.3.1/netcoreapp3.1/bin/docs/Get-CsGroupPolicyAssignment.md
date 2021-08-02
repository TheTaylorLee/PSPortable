---
external help file:
Module Name: Microsoft.Teams.ConfigAPI.Cmdlets
online version: https://docs.microsoft.com/en-us/powershell/module/Teams/get-csgrouppolicyassignment
schema: 2.0.0
---

# Get-CsGroupPolicyAssignment

## SYNOPSIS
This cmdlet returns group policy assignments.
Optional parameters allow the results to be restricted to policies assigned to a specific group or policies of a specific type.

## SYNTAX

### Get2 (Default)
```
Get-CsGroupPolicyAssignment [-PolicyType <String>] [<CommonParameters>]
```

### Get
```
Get-CsGroupPolicyAssignment -GroupId <String> -PolicyType <String> [<CommonParameters>]
```

### Get1
```
Get-CsGroupPolicyAssignment -GroupId <String> [<CommonParameters>]
```

## DESCRIPTION
This cmdlet returns group policy assignments.
Optional parameters allow the results to be restricted to policies assigned to a specific group or policies of a specific type.

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
The ID of a group whose policy assignments will be returned.

```yaml
Type: System.String
Parameter Sets: Get, Get1
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
Parameter Sets: Get, Get2
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IGroupAssignment

## NOTES

ALIASES

## RELATED LINKS

