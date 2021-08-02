---
external help file:
Module Name: Microsoft.Teams.ConfigAPI.Cmdlets
online version: https://docs.microsoft.com/en-us/powershell/module/Teams/get-csteamtemplate
schema: 2.0.0
---

# Get-CsTeamTemplate

## SYNOPSIS
Get details of a team template given the uri.

## SYNTAX

### Get (Default)
```
Get-CsTeamTemplate -OdataId <String> [<CommonParameters>]
```

### GetViaIdentity
```
Get-CsTeamTemplate -InputObject <IConfigApiBasedCmdletsIdentity> [<CommonParameters>]
```

## DESCRIPTION
Get details of a team template given the uri.

## EXAMPLES

### Example 1: Get details for every template that passes a condition
```powershell
PS C:\> (Get-CsTeamTemplateList -PublicTemplateLocale en-US) | where Name -like 'test' | ForEach-Object {Get-CsTeamTemplate -OdataId $_.OdataId}


{
  "templateId": "cefcf333-91a9-43d0-919f-bbca5b7d2b24",
  "displayName": "test",
  "description": "test",
  "schemaVersion": "v1.0",
  "scope": "Tenant",
  "locale": "en-US",
  "icon": "https://statics.teams.cdn.office.net/evergreen-assets/teamtemplates/icons/default_tenant.svg",
  "discoverySettings": {
    "showInTeamsSearchAndSuggestions": false
  },
  "visibility": "Private",
  "channels": [
    {
      "id": "General",
      "displayName": "General",
      "isFavoriteByDefault": true,
      "tabs": [ ]
    },
    {
      "id": "744414e7-01d7-4108-bf95-b3d0441150c7",
      "displayName": "test",
      "description": "",
      "isFavoriteByDefault": true,
      "tabs": [ ]
    },
    {
      "id": "ca606482-13f6-4611-9061-e7f47e556d8e",
      "displayName": "test123",
      "description": "",
      "isFavoriteByDefault": false,
      "tabs": [ ]
    },
    {
      "id": "a94d85ec-b7d7-44e9-83f6-86a4f4dc8da9",
      "displayName": "1234",
      "description": "",
      "isFavoriteByDefault": false,
      "tabs": [ ]
    }
  ],
  "memberSettings": {
    "allowCreateUpdateChannels": false,
    "allowDeleteChannels": false,
    "allowAddRemoveApps": false,
    "uploadCustomApp": false,
    "allowCreateUpdateRemoveTabs": false,
    "allowCreateUpdateRemoveConnectors": false,
    "allowCreatePrivateChannels": false
  },
  "guestSettings": {
    "allowCreateUpdateChannels": false,
    "allowDeleteChannels": false
  },
  "messagingSettings": {
    "allowUserEditMessages": false,
    "allowUserDeleteMessages": false,
    "allowOwnerDeleteMessages": false,
    "allowTeamMentions": false,
    "allowChannelMentions": false
  },
  "funSettings": {
    "allowGiphy": false,
    "allowStickersAndMemes": false,
    "allowCustomMemes": false
  },
  "isMembershipLimitedToOwners": false,
  "apps": [
    {
      "id": "26bc2873-6023-480c-a11b-76b66605ce8c"
    },
    {
      "id": "com.microsoft.teamspace.tab.planner"
    },
    {
      "id": "com.microsoft.teamspace.tab.vsts"
    }
  ],
  "isDynamicMembership": false,
  "modifiedBy": "6c4445f6-a23d-473c-951d-7474d289c6b3",
  "modifiedOn": "2020-08-21T13:02:48.2021992Z",
  "shortDescription": "test"
}
```

Perform full details pull for every template that falls under a rule.
If you have a lot of templates to look for, consider using Get-CsTeamTemplateList

### Example 2: Save template configuration as a JSON
```powershell
PS C:\> Get-CsTeamTemplate -OdataId '/api/teamtemplates/v1.0/cefcf333-91a9-43d0-919f-bbca5b7d2b24/Tenant/en-US' > 'config.json'
```

Useful for reusing and reconfiguring existing templates configurations for updating, localizing and creating new templates.

## PARAMETERS

### -InputObject
Identity Parameter
To construct, see NOTES section for INPUTOBJECT properties and create a hash table.

```yaml
Type: Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IConfigApiBasedCmdletsIdentity
Parameter Sets: GetViaIdentity
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -OdataId
A composite URI of a template.

```yaml
Type: System.String
Parameter Sets: Get
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

### Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IConfigApiBasedCmdletsIdentity

## OUTPUTS

### Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.ITeamTemplate

### Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.ITeamTemplateErrorResponse

## NOTES

ALIASES

COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.


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

