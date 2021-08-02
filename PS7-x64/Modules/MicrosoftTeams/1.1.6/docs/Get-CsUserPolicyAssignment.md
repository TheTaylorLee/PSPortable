---
external help file:
Module Name: Microsoft.Teams.Config
online version: https://docs.microsoft.com/en-us/powershell/module/Teams/get-csuserpolicyassignment
schema: 2.0.0
---

# Get-CsUserPolicyAssignment

## SYNOPSIS
Get a list of effective policies for User.
Taking direct assignments and group assignments into consideration

## SYNTAX

### Get (Default)
```
Get-CsUserPolicyAssignment -Identity <String> [-PolicyType <String>] [<CommonParameters>]
```

### GetViaIdentity
```
Get-CsUserPolicyAssignment -InputObject <IIc3AdminConfigRpPolicyIdentity> [-PolicyType <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Get a list of effective policies for User.
Taking direct assignments and group assignments into consideration

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

### -Identity
.

```yaml
Type: System.String
Parameter Sets: Get
Aliases: User

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
Identity Parameter
To construct, see NOTES section for INPUTOBJECT properties and create a hash table.

```yaml
Type: Microsoft.Teams.Config.Cmdlets.Models.IIc3AdminConfigRpPolicyIdentity
Parameter Sets: GetViaIdentity
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -PolicyType
The policy type for which group policy assignments will be returned.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Microsoft.Teams.Config.Cmdlets.Models.IIc3AdminConfigRpPolicyIdentity

## OUTPUTS

### Microsoft.Teams.Config.Cmdlets.Models.IEffectivePolicy

## NOTES

ALIASES

COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.


INPUTOBJECT <IIc3AdminConfigRpPolicyIdentity>: Identity Parameter
  - `[GroupId <String>]`: The ID of a group whose policy assignments will be returned.
  - `[Identity <String>]`: 
  - `[OperationId <String>]`: The ID of a batch policy assignment operation.
  - `[PolicyType <String>]`: The policy type for which group policy assignments will be returned.

## RELATED LINKS

