---
external help file:
Module Name: Microsoft.Teams.ConfigAPI.Cmdlets
online version: https://docs.microsoft.com/en-us/powershell/module/Teams/get-csteamtemplatelist
schema: 2.0.0
---

# Get-CsTeamTemplateList

## SYNOPSIS


## SYNTAX

```
Get-CsTeamTemplateList [[-PublicTemplateLocale] <String>] [<CommonParameters>]
```

## DESCRIPTION


## EXAMPLES

### Example 1: Get all available templates
```powershell
PS C:\> Get-CsTeamTemplateList

OdataId                                                         Name                           ShortDescription                 Chann AppCo
                                                                                                                                elCou unt
                                                                                                                                nt
-------                                                         ----                           ----------------                 ----- -----
/api/teamtemplates/v1.0/healthcareWard/Public/en-US             Collaborate on Patient Care    Collaborate on patient care i... 6     1
/api/teamtemplates/v1.0/healthcareHospital/Public/en-US         Hospital                       Facilitate collaboration with... 6     1
/api/teamtemplates/v1.0/retailStore/Public/en-US                Organize a Store               Collaborate with your retail ... 3     1
/api/teamtemplates/v1.0/retailManagerCollaboration/Public/en-US Retail - Manager Collaboration Collaborate with managers acr... 3     1

```

Basic all-templates lookup case

### Example 2: Filter templates by attribute
```powershell
PS C:\> (Get-CsTeamTemplateList -PublicTemplateLocale en-US) | where ChannelCount -GT 3

OdataId                                                 Name                           ShortDescription                 Chann AppCo
                                                                                                                        elCou unt
                                                                                                                        nt
-------                                                 ----                           ----------------                 ----- -----
/api/teamtemplates/v1.0/healthcareWard/Public/en-US     Collaborate on Patient Care    Collaborate on patient care i... 6     1
/api/teamtemplates/v1.0/healthcareHospital/Public/en-US Hospital                       Facilitate collaboration with... 6     1
```

Get a filtered subset of templates

## PARAMETERS

### -PublicTemplateLocale


```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IErrorObject

### Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.ITeamTemplateSummary

## NOTES

ALIASES

## RELATED LINKS

