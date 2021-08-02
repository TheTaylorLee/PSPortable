---
external help file:
Module Name: Microsoft.Teams.ConfigAPI.Cmdlets
online version: https://docs.microsoft.com/en-us/powershell/module/Teams/invoke-csinternalvalidateuser
schema: 2.0.0
---

# Invoke-CsInternalValidateuser

## SYNOPSIS
Validate user

## SYNTAX

### InternalExpanded (Default)
```
Invoke-CsInternalValidateuser -CmdletVersion <String> -Force -LocalDeploymentInfoMajorVersion <Int32>
 -LocalDeploymentInfoPresenceFqdn <String> -LocalDeploymentInfoRegistrarFqdn <String> -MoveToCloud
 -TeamDataCheckCpc -TeamDataCheckEnterpriseVoice -TeamDataMoveToTeam -UserSipUri <String>
 [-LocalDeploymentInfoHostingProviderFqdn <String>] [-Confirm] [-WhatIf] [<CommonParameters>]
```

### Internal
```
Invoke-CsInternalValidateuser -Body <IValidateUserRequestBody> [-Confirm] [-WhatIf] [<CommonParameters>]
```

## DESCRIPTION
Validate user

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

### -Body
.
To construct, see NOTES section for BODY properties and create a hash table.

```yaml
Type: Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IValidateUserRequestBody
Parameter Sets: Internal
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -CmdletVersion
.

```yaml
Type: System.String
Parameter Sets: InternalExpanded
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: InternalExpanded
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LocalDeploymentInfoHostingProviderFqdn
.

```yaml
Type: System.String
Parameter Sets: InternalExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LocalDeploymentInfoMajorVersion
.

```yaml
Type: System.Int32
Parameter Sets: InternalExpanded
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LocalDeploymentInfoPresenceFqdn
.

```yaml
Type: System.String
Parameter Sets: InternalExpanded
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LocalDeploymentInfoRegistrarFqdn
.

```yaml
Type: System.String
Parameter Sets: InternalExpanded
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MoveToCloud
.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: InternalExpanded
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TeamDataCheckCpc
.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: InternalExpanded
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TeamDataCheckEnterpriseVoice
.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: InternalExpanded
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TeamDataMoveToTeam
.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: InternalExpanded
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserSipUri
.

```yaml
Type: System.String
Parameter Sets: InternalExpanded
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

### Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IValidateUserRequestBody

## OUTPUTS

### Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IDeploymentInfo

## NOTES

ALIASES

COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.


BODY <IValidateUserRequestBody>: .
  - `CmdletVersion <String>`: 
  - `Force <Boolean>`: 
  - `LocalDeploymentInfoMajorVersion <Int32>`: 
  - `LocalDeploymentInfoPresenceFqdn <String>`: 
  - `LocalDeploymentInfoRegistrarFqdn <String>`: 
  - `MoveToCloud <Boolean>`: 
  - `TeamDataCheckCpc <Boolean>`: 
  - `TeamDataCheckEnterpriseVoice <Boolean>`: 
  - `TeamDataMoveToTeam <Boolean>`: 
  - `UserSipUri <String>`: 
  - `[LocalDeploymentInfoHostingProviderFqdn <String>]`: 

## RELATED LINKS

