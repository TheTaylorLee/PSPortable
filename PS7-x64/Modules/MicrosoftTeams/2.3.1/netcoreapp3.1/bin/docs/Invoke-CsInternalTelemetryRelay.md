---
external help file:
Module Name: Microsoft.Teams.ConfigAPI.Cmdlets
online version: https://docs.microsoft.com/en-us/powershell/module/Teams/invoke-csinternaltelemetryrelay
schema: 2.0.0
---

# Invoke-CsInternalTelemetryRelay

## SYNOPSIS
Receives the telemetry data from the Connect-MicrosoftTeams cmdlet, and writes this data to MDM and MDS.

## SYNTAX

### InternalExpanded (Default)
```
Invoke-CsInternalTelemetryRelay [-ConfigApiPowershellModuleVersion <String>]
 [-MicrosoftTeamsPsVersion <String>] [-SfBOnlineConnectorPsversion <String>] [-Confirm] [-WhatIf]
 [<CommonParameters>]
```

### Internal
```
Invoke-CsInternalTelemetryRelay -Body <IConnectPowershellTelemetry> [-Confirm] [-WhatIf] [<CommonParameters>]
```

## DESCRIPTION
Receives the telemetry data from the Connect-MicrosoftTeams cmdlet, and writes this data to MDM and MDS.

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
The version numbers for the relevant powershell modules, possibly installed on the machine.
NOTE: This definition must be manually kept same as defined in 
src\Microsoft.TeamsCmdlets.PowerShell.Connect\ConnectMicrosoftTeams.cs of the repository
https://domoreexp.visualstudio.com/DefaultCollection/Teamspace/_git/teams-powershellcmdlet.
To construct, see NOTES section for BODY properties and create a hash table.

```yaml
Type: Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IConnectPowershellTelemetry
Parameter Sets: Internal
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ConfigApiPowershellModuleVersion
Gets or Sets the Version of the ConfigApiPowershell module.

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

### -MicrosoftTeamsPsVersion
Gets or Sets the Version of the MicrosoftTeams powershell module.

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

### -SfBOnlineConnectorPsversion
Gets or Sets the Version of the Skype For Business Online Connector.

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

### Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IConnectPowershellTelemetry

## OUTPUTS

### System.String

## NOTES

ALIASES

COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.


BODY <IConnectPowershellTelemetry>: The version numbers for the relevant powershell modules, possibly installed on the machine.         NOTE: This definition must be manually kept same as defined in         src\Microsoft.TeamsCmdlets.PowerShell.Connect\ConnectMicrosoftTeams.cs of the repository         https://domoreexp.visualstudio.com/DefaultCollection/Teamspace/_git/teams-powershellcmdlet.
  - `[ConfigApiPowershellModuleVersion <String>]`: Gets or Sets the Version of the ConfigApiPowershell module.
  - `[MicrosoftTeamsPsVersion <String>]`: Gets or Sets the Version of the MicrosoftTeams powershell module.
  - `[SfBOnlineConnectorPsversion <String>]`: Gets or Sets the Version of the Skype For Business Online Connector.

## RELATED LINKS

