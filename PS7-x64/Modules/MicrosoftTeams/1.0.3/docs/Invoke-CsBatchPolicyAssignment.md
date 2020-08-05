---
external help file:
Module Name: Microsoft.Teams.Config
online version: https://docs.microsoft.com/en-us/powershell/module/microsoft.teams.config/invoke-csbatchpolicyassignment
schema: 2.0.0
---

# Invoke-CsBatchPolicyAssignment

## SYNOPSIS
Submit a new batch for policy assignments

## SYNTAX

### BatchExpanded (Default)
```
Invoke-CsBatchPolicyAssignment -Identity <String[]> -PolicyName <String> -PolicyType <String>
 [-OperationName <String>] [-Confirm] [-WhatIf] [<CommonParameters>]
```

### Batch
```
Invoke-CsBatchPolicyAssignment -Payload <IBatchAssignBody> [-OperationName <String>] [-Confirm] [-WhatIf]
 [<CommonParameters>]
```

## DESCRIPTION
Submit a new batch for policy assignments

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
HELP MESSAGE MISSING

```yaml
Type: System.String[]
Parameter Sets: BatchExpanded
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
Dynamic: False
```

### -OperationName
string

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
Dynamic: False
```

### -Payload
HELP MESSAGE MISSING
To construct, see NOTES section for PAYLOAD properties and create a hash table.

```yaml
Type: Microsoft.Teams.Config.Cmdlets.Models.IBatchAssignBody
Parameter Sets: Batch
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
Dynamic: False
```

### -PolicyName
HELP MESSAGE MISSING

```yaml
Type: System.String
Parameter Sets: BatchExpanded
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
Dynamic: False
```

### -PolicyType
HELP MESSAGE MISSING

```yaml
Type: System.String
Parameter Sets: BatchExpanded
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
Dynamic: False
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
Dynamic: False
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
Dynamic: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Microsoft.Teams.Config.Cmdlets.Models.IBatchAssignBody

## OUTPUTS

### Microsoft.Teams.Config.Cmdlets.Models.IErrorResponse

### System.String

## ALIASES

## NOTES

### COMPLEX PARAMETER PROPERTIES
To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.

#### PAYLOAD <IBatchAssignBody>: HELP MESSAGE MISSING
  - `Identity <String[]>`: 
  - `PolicyName <String>`: 
  - `PolicyType <String>`: 

## RELATED LINKS

