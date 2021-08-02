---
external help file:
Module Name: Microsoft.Teams.ConfigAPI.Cmdlets
online version: https://docs.microsoft.com/en-us/powershell/module/Teams/new-cssmv2orderasync
schema: 2.0.0
---

# New-CsSmV2OrderAsync

## SYNOPSIS


## SYNTAX

### CreateExpanded (Default)
```
New-CsSmV2OrderAsync -TenantId <String> [-TelephoneNumberDisable <String[]>]
 [-TelephoneNumberEnable <String[]>] [-Confirm] [-WhatIf] [<CommonParameters>]
```

### Create
```
New-CsSmV2OrderAsync -TenantId <String>
 -Body <IMicrosoftSkypeSyncPstnTnmCapabilityUpdateApiModelsCreateOrderSmsEnableOrDisableRequest> [-Confirm]
 [-WhatIf] [<CommonParameters>]
```

### CreateViaIdentity
```
New-CsSmV2OrderAsync -InputObject <IConfigApiBasedCmdletsIdentity>
 -Body <IMicrosoftSkypeSyncPstnTnmCapabilityUpdateApiModelsCreateOrderSmsEnableOrDisableRequest> [-Confirm]
 [-WhatIf] [<CommonParameters>]
```

### CreateViaIdentityExpanded
```
New-CsSmV2OrderAsync -InputObject <IConfigApiBasedCmdletsIdentity> [-TelephoneNumberDisable <String[]>]
 [-TelephoneNumberEnable <String[]>] [-Confirm] [-WhatIf] [<CommonParameters>]
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

### -Body
SmsEnableOrDisableRequest
To construct, see NOTES section for BODY properties and create a hash table.

```yaml
Type: Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IMicrosoftSkypeSyncPstnTnmCapabilityUpdateApiModelsCreateOrderSmsEnableOrDisableRequest
Parameter Sets: Create, CreateViaIdentity
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -InputObject
Identity Parameter
To construct, see NOTES section for INPUTOBJECT properties and create a hash table.

```yaml
Type: Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IConfigApiBasedCmdletsIdentity
Parameter Sets: CreateViaIdentity, CreateViaIdentityExpanded
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -TelephoneNumberDisable
.

```yaml
Type: System.String[]
Parameter Sets: CreateExpanded, CreateViaIdentityExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TelephoneNumberEnable
.

```yaml
Type: System.String[]
Parameter Sets: CreateExpanded, CreateViaIdentityExpanded
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TenantId
.

```yaml
Type: System.String
Parameter Sets: Create, CreateExpanded
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

### Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IConfigApiBasedCmdletsIdentity

### Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IMicrosoftSkypeSyncPstnTnmCapabilityUpdateApiModelsCreateOrderSmsEnableOrDisableRequest

## OUTPUTS

### Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IAny

### Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IMicrosoftSkypeSyncPstnTnmCapabilityUpdateApiModelsCapabilityUpdateOrder

### Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IMicrosoftSkypeSyncPstnTnmServiceModelsErrorBody

## NOTES

ALIASES

COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.


BODY <IMicrosoftSkypeSyncPstnTnmCapabilityUpdateApiModelsCreateOrderSmsEnableOrDisableRequest>: SmsEnableOrDisableRequest
  - `[TelephoneNumberDisable <String[]>]`: 
  - `[TelephoneNumberEnable <String[]>]`: 

INPUTOBJECT <IConfigApiBasedCmdletsIdentity>: Identity Parameter
  - `[BridgeId <String>]`: Identity of the bridge.
  - `[CivicAddressId <String>]`: Civic address id.
  - `[Country <String>]`: 
  - `[GroupId <String>]`: The ID of a group whose policy assignments will be returned.
  - `[Identity <String>]`: 
  - `[Locale <String>]`: 
  - `[LocationId <String>]`: Location id.
  - `[Name <String>]`: Name of the bridge.
  - `[OdataId <String>]`: A composite URI of a template.
  - `[OperationId <String>]`: The ID of a batch policy assignment operation.
  - `[OrderId <String>]`: 
  - `[PackageName <String>]`: The name of a specific policy package
  - `[PolicyType <String>]`: The policy type for which group policy assignments will be returned.
  - `[PortInOrderId <String>]`: 
  - `[PublicTemplateLocale <String>]`: Language and country code for localization of publicly available templates.
  - `[TenantId <String>]`: 
  - `[UserId <String>]`: UserId. Supports Guid. Eventually UPN and SIP.

## RELATED LINKS

