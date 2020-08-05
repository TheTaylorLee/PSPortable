---
external help file:
Module Name: Microsoft.Teams.Config
online version: https://docs.microsoft.com/en-us/powershell/module/microsoft.teams.config/get-csbatchpolicyassignmentoperation
schema: 2.0.0
---

# Get-CsBatchPolicyAssignmentOperation

## SYNOPSIS
Get all batch operations for OAuth tenant

## SYNTAX

### Get (Default)
```
Get-CsBatchPolicyAssignmentOperation [-Status <String>] [<CommonParameters>]
```

### Get1
```
Get-CsBatchPolicyAssignmentOperation -OperationId <String> [<CommonParameters>]
```

### GetViaIdentity
```
Get-CsBatchPolicyAssignmentOperation -InputObject <IIc3AdminConfigRpPolicyIdentity> [<CommonParameters>]
```

## DESCRIPTION
Get all batch operations for OAuth tenant

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
Dynamic: False
```

### -OperationId
OperationId received from submitting a batch

```yaml
Type: System.String
Parameter Sets: Get1
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
Dynamic: False
```

### -Status
Option filter

```yaml
Type: System.String
Parameter Sets: Get
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
Dynamic: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Microsoft.Teams.Config.Cmdlets.Models.IIc3AdminConfigRpPolicyIdentity

## OUTPUTS

### Microsoft.Teams.Config.Cmdlets.Models.IBatchJobStatus

### Microsoft.Teams.Config.Cmdlets.Models.IErrorResponse

### Microsoft.Teams.Config.Cmdlets.Models.ISimpleBatchJobStatus

## ALIASES

## NOTES

### COMPLEX PARAMETER PROPERTIES
To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.

#### INPUTOBJECT <IIc3AdminConfigRpPolicyIdentity>: Identity Parameter
  - `[GroupId <String>]`: 
  - `[OperationId <String>]`: OperationId received from submitting a batch
  - `[PolicyType <String>]`: 

## RELATED LINKS

