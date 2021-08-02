---
external help file:
Module Name: Microsoft.Teams.ConfigAPI.Cmdlets
online version: https://docs.microsoft.com/en-us/powershell/module/Teams/get-csbatchpolicyassignmentoperation
schema: 2.0.0
---

# Get-CsBatchPolicyAssignmentOperation

## SYNOPSIS
This cmdlet returns the status of all batch policy assignment operations for the last 30 days.
If an operation ID is specified, the detailed status for that operation is returned including the status for each user in the batch.

## SYNTAX

### Get (Default)
```
Get-CsBatchPolicyAssignmentOperation [-Status <String>] [<CommonParameters>]
```

### Get1
```
Get-CsBatchPolicyAssignmentOperation -Identity <String> [<CommonParameters>]
```

## DESCRIPTION
This cmdlet returns the status of all batch policy assignment operations for the last 30 days.
If an operation ID is specified, the detailed status for that operation is returned including the status for each user in the batch.

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
The ID of a batch policy assignment operation.

```yaml
Type: System.String
Parameter Sets: Get1
Aliases: OperationId

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
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
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IBatchJobStatus

### Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.ISimpleBatchJobStatus

## NOTES

ALIASES

## RELATED LINKS

