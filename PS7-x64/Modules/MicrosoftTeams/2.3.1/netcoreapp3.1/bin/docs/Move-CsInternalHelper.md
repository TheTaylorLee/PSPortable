---
external help file:
Module Name: Microsoft.Teams.ConfigAPI.Cmdlets
online version: https://docs.microsoft.com/en-us/powershell/module/Teams/move-csinternalhelper
schema: 2.0.0
---

# Move-CsInternalHelper

## SYNOPSIS


## SYNTAX

### Rehome (Default)
```
Move-CsInternalHelper -ActionType <String> -UserSipUri <String> [-MoveToCloud] [-TeamDataCheckCpc]
 [-TeamDataCheckEnterpriseVoice] [-TeamDataMoveToTeam] [<CommonParameters>]
```

### BeginAndCompleteMove
```
Move-CsInternalHelper -ActionType <String> -MajorVersion <String> -UserSipUri <String> [<CommonParameters>]
```

### MoveResourcedata
```
Move-CsInternalHelper -ActionType <String> -MajorVersion <String> -ResourceData <String> -UserSipUri <String>
 [-TeamDataCheckCpc] [-TeamDataCheckEnterpriseVoice] [-TeamDataMoveToTeam] [<CommonParameters>]
```

### Validate
```
Move-CsInternalHelper -ActionType <String> -CmdletVersion <String> -LocalDeploymentInfoMajorVersion <String>
 -LocalDeploymentInfoPresenceFqdn <String> -LocalDeploymentInfoRegistrarFqdn <String> -UserSipUri <String>
 [-Force] [-LocalDeploymentInfoHostingProviderFqdn <String>] [-MoveToCloud] [-TeamDataCheckCpc]
 [-TeamDataCheckEnterpriseVoice] [-TeamDataMoveToTeam] [<CommonParameters>]
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

### -ActionType


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

### -CmdletVersion


```yaml
Type: System.String
Parameter Sets: Validate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force


```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: Validate
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LocalDeploymentInfoHostingProviderFqdn


```yaml
Type: System.String
Parameter Sets: Validate
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LocalDeploymentInfoMajorVersion


```yaml
Type: System.String
Parameter Sets: Validate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LocalDeploymentInfoPresenceFqdn


```yaml
Type: System.String
Parameter Sets: Validate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LocalDeploymentInfoRegistrarFqdn


```yaml
Type: System.String
Parameter Sets: Validate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MajorVersion


```yaml
Type: System.String
Parameter Sets: BeginAndCompleteMove, MoveResourcedata
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MoveToCloud


```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: Rehome, Validate
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceData


```yaml
Type: System.String
Parameter Sets: MoveResourcedata
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TeamDataCheckCpc


```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: MoveResourcedata, Rehome, Validate
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TeamDataCheckEnterpriseVoice


```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: MoveResourcedata, Rehome, Validate
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TeamDataMoveToTeam


```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: MoveResourcedata, Rehome, Validate
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserSipUri


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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject

## NOTES

ALIASES

## RELATED LINKS

