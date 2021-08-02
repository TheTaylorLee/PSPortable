---
external help file:
Module Name: Microsoft.Teams.ConfigAPI.Cmdlets
online version: https://docs.microsoft.com/en-us/powershell/module/Teams/get-csonlinepowershellendpoint
schema: 2.0.0
---

# Get-CsOnlinePowerShellEndpoint

## SYNOPSIS


## SYNTAX

### OverrideDiscoveryUri (Default)
```
Get-CsOnlinePowerShellEndpoint -TargetDomain <Fqdn> [-OverrideDesiredLink <String>]
 [-OverrideDiscoveryUri <Uri>] [-Confirm] [-WhatIf] [<CommonParameters>]
```

### TeamsEnvironmentName
```
Get-CsOnlinePowerShellEndpoint -TargetDomain <Fqdn> [-OverrideDesiredLink <String>]
 [-TeamsEnvironmentName <TeamsEnvironment>] [-Confirm] [-WhatIf] [<CommonParameters>]
```

## DESCRIPTION


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

### -OverrideDesiredLink


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

### -OverrideDiscoveryUri


```yaml
Type: System.Uri
Parameter Sets: OverrideDiscoveryUri
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TargetDomain


```yaml
Type: Microsoft.Teams.ConfigApi.Cmdlets.Fqdn
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TeamsEnvironmentName


```yaml
Type: Microsoft.Teams.ConfigApi.Cmdlets.DeploymentConfiguration+TeamsEnvironment
Parameter Sets: TeamsEnvironmentName
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

### System.Object

## NOTES

ALIASES

## RELATED LINKS

