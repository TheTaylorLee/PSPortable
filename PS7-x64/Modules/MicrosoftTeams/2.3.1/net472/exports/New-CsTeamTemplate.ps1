
# ----------------------------------------------------------------------------------
#
# Copyright Microsoft Corporation
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ----------------------------------------------------------------------------------

<#
.Synopsis

.Description

.Example
PS C:\>  (Get-CsTeamTemplate -OdataId '/api/teamtemplates/v1.0/com.microsoft.teams.template.AdoptOffice365/Public/en-US') > input.json
# open json in your favorite editor, make changes

PS C:\>  New-CsTeamTemplate -Locale en-US -Body (Get-Content '.\input.json' | Out-String)

{
  "id": "061fe692-7da7-4f65-a57b-0472cf0045af",
  "name": "New Template",
  "scope": "Tenant",
  "shortDescription": "New Description",
  "iconUri": "https://statics.teams.cdn.office.net/evergreen-assets/teamtemplates/icons/default_tenant.svg",
  "channelCount": 2,
  "appCount": 2,
  "modifiedOn": "2020-12-10T18:46:52.7231705Z",
  "modifiedBy": "6c4445f6-a23d-473c-951d-7474d289c6b3",
  "locale": "en-US",
  "@odata.id": "/api/teamtemplates/v1.0/061fe692-7da7-4f65-a57b-0472cf0045af/Tenant/en-US"
}
.Example
PS C:\>  New-CsTeamTemplate `
-Locale en-US `
-DisplayName 'New Template' `
-ShortDescription 'New Description' `
-App @{id='feda49f8-b9f2-4985-90f0-dd88a8f80ee1'}, @{id='1d71218a-92ad-4254-be15-c5ab7a3e4423'} `
-Channel @{ `
  displayName="General"; `
  id="General"; `
  isFavoriteByDefault=$true; `
}, `
@{ `
  displayName="test"; `
  id="b82b7d0a-6bc9-4fd8-bf09-d432e4ea0475"; `
  isFavoriteByDefault=$false; `
}


{
  "id": "061fe692-7da7-4f65-a57b-0472cf0045af",
  "name": "New Template",
  "scope": "Tenant",
  "shortDescription": "New Description",
  "iconUri": "https://statics.teams.cdn.office.net/evergreen-assets/teamtemplates/icons/default_tenant.svg",
  "channelCount": 2,
  "appCount": 2,
  "modifiedOn": "2020-12-10T18:46:52.7231705Z",
  "modifiedBy": "6c4445f6-a23d-473c-951d-7474d289c6b3",
  "locale": "en-US",
  "@odata.id": "/api/teamtemplates/v1.0/061fe692-7da7-4f65-a57b-0472cf0045af/Tenant/en-US"
}

.Inputs
Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IConfigApiBasedCmdletsIdentity
.Inputs
Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.ITeamTemplate
.Outputs
Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.ICreateTemplateResponse
.Outputs
Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.ITeamTemplateErrorResponse
.Notes
COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.

APP <ITeamsAppTemplate[]>: Gets or sets the set of applications that should be installed in teams created based on the template.The app catalog is the main directory for information about each app; this set is intended only as a reference.
  [Id <String>]: Gets or sets the app's ID in the global apps catalog.

BODY <ITeamTemplate>: The client input for a request to create a template.         Only admins from Config Api can perform this request.
  DisplayName <String>: Gets or sets the team's DisplayName.
  ShortDescription <String>: Gets or sets template short description.
  [App <ITeamsAppTemplate[]>]: Gets or sets the set of applications that should be installed in teams created based on the template.         The app catalog is the main directory for information about each app; this set is intended only as a reference.
    [Id <String>]: Gets or sets the app's ID in the global apps catalog.
  [Category <String[]>]: Gets or sets list of categories.
  [Channel <IChannelTemplate[]>]: Gets or sets the set of channel templates included in the team template.
    [Description <String>]: Gets or sets channel description as displayed to users.
    [DisplayName <String>]: Gets or sets channel name as displayed to users.
    [Id <String>]: Gets or sets identifier for the channel template.
    [IsFavoriteByDefault <Boolean?>]: Gets or sets a value indicating whether whether new members of the team should automatically favorite the channel,         pinning it for visibility in the UI and using resources to make switching to the channel faster.
    [Tab <IChannelTabTemplate[]>]: Gets or sets collection of tabs that should be added to the channel.
      [Configuration <ITeamsTabConfiguration>]: Represents the configuration of a tab.
        [ContentUrl <String>]: Gets or sets the Url used for rendering tab contents in Teams.
        [EntityId <String>]: Gets or sets the identifier for the entity hosted by the tab provider.
        [RemoveUrl <String>]: Gets or sets the Url that is invoked when the user tries to remove a tab from the FE client.
        [WebsiteUrl <String>]: Gets or sets the Url for showing tab contents outside of Teams.
      [Id <String>]: Gets or sets identifier for the channel tab template.
      [Key <String>]: Gets a unique identifier.
      [MessageId <String>]: Gets or sets id used to identify the chat message associated with the tab.
      [Name <String>]: Gets or sets the tab name displayed to users.
      [SortOrderIndex <String>]: Gets or sets index of the order used for sorting tabs.
      [TeamsAppId <String>]: Gets or sets the app's id in the global apps catalog.
      [WebUrl <String>]: Gets or sets the deep link url of the tab instance.
  [Classification <String>]: Gets or sets the team's classification.         Tenant admins configure AAD with the set of possible values.
  [Description <String>]: Gets or sets the team's Description.
  [DiscoverySetting <ITeamDiscoverySettings>]: Governs discoverability of a team.
    ShowInTeamsSearchAndSuggestion <Boolean>: Gets or sets value indicating if team is visible within search and suggestions in Teams clients.
  [FunSetting <ITeamFunSettings>]: Governs use of fun media like giphy and stickers in the team.
    AllowCustomMeme <Boolean>: Gets or sets a value indicating whether users are allowed to create and post custom meme images in team conversations.
    AllowGiphy <Boolean>: Gets or sets a value indicating whether users can post giphy content in team conversations.
    AllowStickersAndMeme <Boolean>: Gets or sets a value indicating whether users can post stickers and memes in team conversations.
    GiphyContentRating <String>: Gets or sets the rating filter on giphy content.
  [GuestSetting <ITeamGuestSettings>]: Guest role settings for the team.
    AllowCreateUpdateChannel <Boolean>: Gets or sets a value indicating whether guests can create or edit channels in the team.
    AllowDeleteChannel <Boolean>: Gets or sets a value indicating whether guests can delete team channels.
  [Icon <String>]: Gets or sets template icon.
  [IsMembershipLimitedToOwner <Boolean?>]: Gets or sets whether to limit the membership of the team to owners in the AAD group until an owner "activates" the team.
  [MemberSetting <ITeamMemberSettings>]: Member role settings for the team.
    AllowAddRemoveApp <Boolean>: Gets or sets a value indicating whether members can add or remove apps in the team.
    AllowCreatePrivateChannel <Boolean>: Gets or Sets a value indicating whether members can create Private channels.
    AllowCreateUpdateChannel <Boolean>: Gets or sets a value indicating whether members can create or edit channels in the team.
    AllowCreateUpdateRemoveConnector <Boolean>: Gets or sets a value indicating whether members can add, edit, or remove connectors in the team.
    AllowCreateUpdateRemoveTab <Boolean>: Gets or sets a value indicating whether members can add, edit or remove pinned tabs in the team.
    AllowDeleteChannel <Boolean>: Gets or sets a value indicating whether members can delete team channels.
    UploadCustomApp <Boolean>: Gets or sets a value indicating is allowed to upload custom apps.
  [MessagingSetting <ITeamMessagingSettings>]: Governs use of messaging features within the team         These are settings the team owner should be able to modify from UI after team creation.
    AllowChannelMention <Boolean>: Gets or sets a value indicating whether team members can at-mention entire channels in team conversations.
    AllowOwnerDeleteMessage <Boolean>: Gets or sets a value indicating whether team owners can delete anyone's messages in team conversations.
    AllowTeamMention <Boolean>: Gets or sets a value indicating whether team members can at-mention the entire team in team conversations.
    AllowUserDeleteMessage <Boolean>: Gets or sets a value indicating whether team members can delete their own messages in team conversations.
    AllowUserEditMessage <Boolean>: Gets or sets a value indicating whether team members can edit their own messages in team conversations.
  [OwnerUserObjectId <String>]: Gets or sets the AAD user object id of the user who should be set as the owner of the new team.         Only to be used when an application or administrative user is making the request on behalf of the specified user.
  [PublishedBy <String>]: Gets or sets published name.
  [Specialization <String>]: The specialization or use case describing the team.         Used for telemetry/BI, part of the team context exposed to app developers, and for legacy implementations of differentiated features for education.
  [TemplateId <String>]: Gets or sets the id of the base template for the team.         Either a Microsoft base template or a custom template.
  [Uri <String>]: Gets or sets uri to be used for GetTemplate api call.
  [Visibility <String>]: Used to control the scope of users who can view a group/team and its members, and ability to join.

CHANNEL <IChannelTemplate[]>: Gets or sets the set of channel templates included in the team template.
  [Description <String>]: Gets or sets channel description as displayed to users.
  [DisplayName <String>]: Gets or sets channel name as displayed to users.
  [Id <String>]: Gets or sets identifier for the channel template.
  [IsFavoriteByDefault <Boolean?>]: Gets or sets a value indicating whether whether new members of the team should automatically favorite the channel,         pinning it for visibility in the UI and using resources to make switching to the channel faster.
  [Tab <IChannelTabTemplate[]>]: Gets or sets collection of tabs that should be added to the channel.
    [Configuration <ITeamsTabConfiguration>]: Represents the configuration of a tab.
      [ContentUrl <String>]: Gets or sets the Url used for rendering tab contents in Teams.
      [EntityId <String>]: Gets or sets the identifier for the entity hosted by the tab provider.
      [RemoveUrl <String>]: Gets or sets the Url that is invoked when the user tries to remove a tab from the FE client.
      [WebsiteUrl <String>]: Gets or sets the Url for showing tab contents outside of Teams.
    [Id <String>]: Gets or sets identifier for the channel tab template.
    [Key <String>]: Gets a unique identifier.
    [MessageId <String>]: Gets or sets id used to identify the chat message associated with the tab.
    [Name <String>]: Gets or sets the tab name displayed to users.
    [SortOrderIndex <String>]: Gets or sets index of the order used for sorting tabs.
    [TeamsAppId <String>]: Gets or sets the app's id in the global apps catalog.
    [WebUrl <String>]: Gets or sets the deep link url of the tab instance.

DISCOVERYSETTING <ITeamDiscoverySettings>: Governs discoverability of a team.
  ShowInTeamsSearchAndSuggestion <Boolean>: Gets or sets value indicating if team is visible within search and suggestions in Teams clients.

FUNSETTING <ITeamFunSettings>: Governs use of fun media like giphy and stickers in the team.
  AllowCustomMeme <Boolean>: Gets or sets a value indicating whether users are allowed to create and post custom meme images in team conversations.
  AllowGiphy <Boolean>: Gets or sets a value indicating whether users can post giphy content in team conversations.
  AllowStickersAndMeme <Boolean>: Gets or sets a value indicating whether users can post stickers and memes in team conversations.
  GiphyContentRating <String>: Gets or sets the rating filter on giphy content.

GUESTSETTING <ITeamGuestSettings>: Guest role settings for the team.
  AllowCreateUpdateChannel <Boolean>: Gets or sets a value indicating whether guests can create or edit channels in the team.
  AllowDeleteChannel <Boolean>: Gets or sets a value indicating whether guests can delete team channels.

INPUTOBJECT <IConfigApiBasedCmdletsIdentity>: Identity Parameter
  [BridgeId <String>]: Identity of the bridge.
  [CivicAddressId <String>]: Civic address id.
  [Country <String>]: 
  [GroupId <String>]: The ID of a group whose policy assignments will be returned.
  [Identity <String>]: 
  [Locale <String>]: 
  [LocationId <String>]: Location id.
  [Name <String>]: Name of the bridge.
  [OdataId <String>]: A composite URI of a template.
  [OperationId <String>]: The ID of a batch policy assignment operation.
  [OrderId <String>]: 
  [PackageName <String>]: The name of a specific policy package
  [PolicyType <String>]: The policy type for which group policy assignments will be returned.
  [PortInOrderId <String>]: 
  [PublicTemplateLocale <String>]: Language and country code for localization of publicly available templates.
  [TenantId <String>]: 
  [UserId <String>]: UserId. Supports Guid. Eventually UPN and SIP.

MEMBERSETTING <ITeamMemberSettings>: Member role settings for the team.
  AllowAddRemoveApp <Boolean>: Gets or sets a value indicating whether members can add or remove apps in the team.
  AllowCreatePrivateChannel <Boolean>: Gets or Sets a value indicating whether members can create Private channels.
  AllowCreateUpdateChannel <Boolean>: Gets or sets a value indicating whether members can create or edit channels in the team.
  AllowCreateUpdateRemoveConnector <Boolean>: Gets or sets a value indicating whether members can add, edit, or remove connectors in the team.
  AllowCreateUpdateRemoveTab <Boolean>: Gets or sets a value indicating whether members can add, edit or remove pinned tabs in the team.
  AllowDeleteChannel <Boolean>: Gets or sets a value indicating whether members can delete team channels.
  UploadCustomApp <Boolean>: Gets or sets a value indicating is allowed to upload custom apps.

MESSAGINGSETTING <ITeamMessagingSettings>: Governs use of messaging features within the teamThese are settings the team owner should be able to modify from UI after team creation.
  AllowChannelMention <Boolean>: Gets or sets a value indicating whether team members can at-mention entire channels in team conversations.
  AllowOwnerDeleteMessage <Boolean>: Gets or sets a value indicating whether team owners can delete anyone's messages in team conversations.
  AllowTeamMention <Boolean>: Gets or sets a value indicating whether team members can at-mention the entire team in team conversations.
  AllowUserDeleteMessage <Boolean>: Gets or sets a value indicating whether team members can delete their own messages in team conversations.
  AllowUserEditMessage <Boolean>: Gets or sets a value indicating whether team members can edit their own messages in team conversations.
.Link
https://docs.microsoft.com/en-us/powershell/module/teams/new-csteamtemplate
#>
function New-CsTeamTemplate {
[OutputType([Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.ICreateTemplateResponse], [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.ITeamTemplateErrorResponse])]
[CmdletBinding(DefaultParameterSetName='NewExpanded', PositionalBinding=$false, SupportsShouldProcess, ConfirmImpact='Medium')]
param(
    [Parameter(ParameterSetName='New', Mandatory)]
    [Parameter(ParameterSetName='NewExpanded', Mandatory)]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Path')]
    [System.String]
    # .
    ${Locale},

    [Parameter(ParameterSetName='NewViaIdentity', Mandatory, ValueFromPipeline)]
    [Parameter(ParameterSetName='NewViaIdentityExpanded', Mandatory, ValueFromPipeline)]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Path')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IConfigApiBasedCmdletsIdentity]
    # Identity Parameter
    # To construct, see NOTES section for INPUTOBJECT properties and create a hash table.
    ${InputObject},

    [Parameter(ParameterSetName='New', Mandatory, ValueFromPipeline)]
    [Parameter(ParameterSetName='NewViaIdentity', Mandatory, ValueFromPipeline)]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Body')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.ITeamTemplate]
    # The client input for a request to create a template.
    # Only admins from Config Api can perform this request.
    # To construct, see NOTES section for BODY properties and create a hash table.
    ${Body},

    [Parameter(ParameterSetName='NewExpanded', Mandatory)]
    [Parameter(ParameterSetName='NewViaIdentityExpanded', Mandatory)]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Body')]
    [System.String]
    # Gets or sets the team's DisplayName.
    ${DisplayName},

    [Parameter(ParameterSetName='NewExpanded', Mandatory)]
    [Parameter(ParameterSetName='NewViaIdentityExpanded', Mandatory)]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Body')]
    [System.String]
    # Gets or sets template short description.
    ${ShortDescription},

    [Parameter(ParameterSetName='NewExpanded')]
    [Parameter(ParameterSetName='NewViaIdentityExpanded')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Body')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.ITeamsAppTemplate[]]
    # Gets or sets the set of applications that should be installed in teams created based on the template.The app catalog is the main directory for information about each app; this set is intended only as a reference.
    # To construct, see NOTES section for APP properties and create a hash table.
    ${App},

    [Parameter(ParameterSetName='NewExpanded')]
    [Parameter(ParameterSetName='NewViaIdentityExpanded')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Body')]
    [System.String[]]
    # Gets or sets list of categories.
    ${Category},

    [Parameter(ParameterSetName='NewExpanded')]
    [Parameter(ParameterSetName='NewViaIdentityExpanded')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Body')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IChannelTemplate[]]
    # Gets or sets the set of channel templates included in the team template.
    # To construct, see NOTES section for CHANNEL properties and create a hash table.
    ${Channel},

    [Parameter(ParameterSetName='NewExpanded')]
    [Parameter(ParameterSetName='NewViaIdentityExpanded')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Body')]
    [System.String]
    # Gets or sets the team's classification.Tenant admins configure AAD with the set of possible values.
    ${Classification},

    [Parameter(ParameterSetName='NewExpanded')]
    [Parameter(ParameterSetName='NewViaIdentityExpanded')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Body')]
    [System.String]
    # Gets or sets the team's Description.
    ${Description},

    [Parameter(ParameterSetName='NewExpanded')]
    [Parameter(ParameterSetName='NewViaIdentityExpanded')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Body')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.ITeamDiscoverySettings]
    # Governs discoverability of a team.
    # To construct, see NOTES section for DISCOVERYSETTING properties and create a hash table.
    ${DiscoverySetting},

    [Parameter(ParameterSetName='NewExpanded')]
    [Parameter(ParameterSetName='NewViaIdentityExpanded')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Body')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.ITeamFunSettings]
    # Governs use of fun media like giphy and stickers in the team.
    # To construct, see NOTES section for FUNSETTING properties and create a hash table.
    ${FunSetting},

    [Parameter(ParameterSetName='NewExpanded')]
    [Parameter(ParameterSetName='NewViaIdentityExpanded')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Body')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.ITeamGuestSettings]
    # Guest role settings for the team.
    # To construct, see NOTES section for GUESTSETTING properties and create a hash table.
    ${GuestSetting},

    [Parameter(ParameterSetName='NewExpanded')]
    [Parameter(ParameterSetName='NewViaIdentityExpanded')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Body')]
    [System.String]
    # Gets or sets template icon.
    ${Icon},

    [Parameter(ParameterSetName='NewExpanded')]
    [Parameter(ParameterSetName='NewViaIdentityExpanded')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Body')]
    [System.Management.Automation.SwitchParameter]
    # Gets or sets whether to limit the membership of the team to owners in the AAD group until an owner "activates" the team.
    ${IsMembershipLimitedToOwner},

    [Parameter(ParameterSetName='NewExpanded')]
    [Parameter(ParameterSetName='NewViaIdentityExpanded')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Body')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.ITeamMemberSettings]
    # Member role settings for the team.
    # To construct, see NOTES section for MEMBERSETTING properties and create a hash table.
    ${MemberSetting},

    [Parameter(ParameterSetName='NewExpanded')]
    [Parameter(ParameterSetName='NewViaIdentityExpanded')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Body')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.ITeamMessagingSettings]
    # Governs use of messaging features within the teamThese are settings the team owner should be able to modify from UI after team creation.
    # To construct, see NOTES section for MESSAGINGSETTING properties and create a hash table.
    ${MessagingSetting},

    [Parameter(ParameterSetName='NewExpanded')]
    [Parameter(ParameterSetName='NewViaIdentityExpanded')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Body')]
    [System.String]
    # Gets or sets the AAD user object id of the user who should be set as the owner of the new team.Only to be used when an application or administrative user is making the request on behalf of the specified user.
    ${OwnerUserObjectId},

    [Parameter(ParameterSetName='NewExpanded')]
    [Parameter(ParameterSetName='NewViaIdentityExpanded')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Body')]
    [System.String]
    # Gets or sets published name.
    ${PublishedBy},

    [Parameter(ParameterSetName='NewExpanded')]
    [Parameter(ParameterSetName='NewViaIdentityExpanded')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Body')]
    [System.String]
    # The specialization or use case describing the team.Used for telemetry/BI, part of the team context exposed to app developers, and for legacy implementations of differentiated features for education.
    ${Specialization},

    [Parameter(ParameterSetName='NewExpanded')]
    [Parameter(ParameterSetName='NewViaIdentityExpanded')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Body')]
    [System.String]
    # Gets or sets the id of the base template for the team.Either a Microsoft base template or a custom template.
    ${TemplateId},

    [Parameter(ParameterSetName='NewExpanded')]
    [Parameter(ParameterSetName='NewViaIdentityExpanded')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Body')]
    [System.String]
    # Gets or sets uri to be used for GetTemplate api call.
    ${Uri},

    [Parameter(ParameterSetName='NewExpanded')]
    [Parameter(ParameterSetName='NewViaIdentityExpanded')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Body')]
    [System.String]
    # Used to control the scope of users who can view a group/team and its members, and ability to join.
    ${Visibility},

    [Parameter(DontShow)]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Runtime')]
    [System.Management.Automation.SwitchParameter]
    # Wait for .NET debugger to attach
    ${Break},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Runtime')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Runtime.SendAsyncStep[]]
    # SendAsync Pipeline Steps to be appended to the front of the pipeline
    ${HttpPipelineAppend},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Runtime')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Runtime.SendAsyncStep[]]
    # SendAsync Pipeline Steps to be prepended to the front of the pipeline
    ${HttpPipelinePrepend},

    [Parameter(DontShow)]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Runtime')]
    [System.Uri]
    # The URI for the proxy server to use
    ${Proxy},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Runtime')]
    [System.Management.Automation.PSCredential]
    # Credentials for a proxy server to use for the remote call
    ${ProxyCredential},

    [Parameter(DontShow)]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Runtime')]
    [System.Management.Automation.SwitchParameter]
    # Use the default credentials for the proxy
    ${ProxyUseDefaultCredentials}
)

begin {
    try {
        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $parameterSet = $PSCmdlet.ParameterSetName
        $mapping = @{
            New = 'Microsoft.Teams.ConfigAPI.Cmdlets.private\New-CsTeamTemplate_New';
            NewExpanded = 'Microsoft.Teams.ConfigAPI.Cmdlets.private\New-CsTeamTemplate_NewExpanded';
            NewViaIdentity = 'Microsoft.Teams.ConfigAPI.Cmdlets.private\New-CsTeamTemplate_NewViaIdentity';
            NewViaIdentityExpanded = 'Microsoft.Teams.ConfigAPI.Cmdlets.private\New-CsTeamTemplate_NewViaIdentityExpanded';
        }
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand(($mapping[$parameterSet]), [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = {& $wrappedCmd @PSBoundParameters}
        $steppablePipeline = $scriptCmd.GetSteppablePipeline($MyInvocation.CommandOrigin)
        $steppablePipeline.Begin($PSCmdlet)
    } catch {
        throw
    }
}

process {
    try {
        $steppablePipeline.Process($_)
    } catch {
        throw
    }
}

end {
    try {
        $steppablePipeline.End()
    } catch {
        throw
    }
}
}

# SIG # Begin signature block
# MIIjhQYJKoZIhvcNAQcCoIIjdjCCI3ICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDlw7U8qHtA7zWS
# iOD11IhYWH2d/Koqifjyoz0mx72jj6CCDXMwggXxMIID2aADAgECAhMzAAABxC/f
# loSRukyuAAAAAAHEMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjAwOTI0MTkxMzE5WhcNMjEwOTIzMTkxMzE5WjByMQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMRwwGgYDVQQDExNTa3lw
# ZSBTb2Z0d2FyZSBTYXJsMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# mukxYIUP1RzxkmQLx6QILvQ0OryT3S4v7iazKVoNAAlLN59fvb/nxpcjbXKmB8s3
# 801nLYnNH9YOucqXe+1eow6Y860VqLf9WotFnVPXi8qyGF3HRz5WOnpJpp+EPR4I
# lq/oRc6MBpHGPiYqGbg/uRHs/Mo6j4iM5hhpiKYgvNDVIJ5Yq1JgUVrptKJyhg0A
# DlbCfJ3QjuJ9OhHhjsjOTDRamD8EFrEUkEhIWkQSwLlCCyxEOnTmYeCkz5LLM6sB
# 00mBXKSxyXnCeWGOHv3rweBf6r0Ba4Ugw66re4A+jEPA01evnBJMKFsPM3au5u+2
# OC2DMVn1jJ0ZSuPXAuDBJwIDAQABo4IBcjCCAW4wEwYDVR0lBAwwCgYIKwYBBQUH
# AwMwHQYDVR0OBBYEFDns7CCDCh3DFePbm/aHoX4oSgW0MFAGA1UdEQRJMEekRTBD
# MSkwJwYDVQQLEyBNaWNyb3NvZnQgT3BlcmF0aW9ucyBQdWVydG8gUmljbzEWMBQG
# A1UEBRMNMjMwMjU0KzQ2MTIyOTAfBgNVHSMEGDAWgBRIbmTlUAXTgqoXNzcitW2o
# ynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20v
# cGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3JsMGEGCCsG
# AQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3J0MAwG
# A1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIBAAWAmK5K7a9OXogJHeKetzTZ
# Dxo29fkF9YFuQpZsqiIYE4GplRWEeA32nRSR7GVaPtN2q6sSr+uJVegqHhbPrRnL
# dHw7Pbt4KXnTXEJmhhI8EoNZkL/LZa68pqwTEoUye6MkHj/UO6jq+bJ2c3Rh80zE
# 1msYbm2F5BdCLhDlC42R0Sf2coXQCmg8bg5DQZOO3J1w/hI2Zzd8SemVhwNhzgQX
# jc7VCr00VZamP8/Wmr+App+meaApN2CnRTdOvE1sxoV7u0VBC0rfYCMkKl9nQBKr
# 42dz/nOf9bqMNUMqoBkb0ts3WSbzrFG9+RFRI81tyyN5RtsdhSKxKz5tsp3Fus4m
# vnfnosNG7eT3va4ftNP2Kxv/ZrCHONCEmij89KLr/u6If7JYUUwY8L7gwX/Uwa/O
# quz9ITaYVu0h5h+/2eZ2fMU90VIB22/c4XiWQ6OkmcDmW1H2SPiUrnsYq/nmAwP2
# ZTwNBr2qL00ApUrlJxgzj9nrFTFBdfg3zb5DTLUNujRveXqRTMQSDkv6Zz6oMl+v
# Rs1TJwbVpP9D+XyyzO3uWuEFWFDbzxwC60ZlNAXfiAF8f8lNJmDylVzyB5kqcWtV
# zUx52QuL71s3UJakArS36QebQhfzBBh8KM2JkDQGPP2nNxomg7k7qGIrLOvFzIMs
# IwKg0F+Q2PdHuEaIAGM4MIIHejCCBWKgAwIBAgIKYQ6Q0gAAAAAAAzANBgkqhkiG
# 9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAO
# BgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEy
# MDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIw
# MTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEwOTA5WjB+MQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQgQ29k
# ZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKC
# AgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+laUKq4BjgaBEm6f8MMHt03a8YS
# 2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc6Whe0t+bU7IKLMOv2akrrnoJ
# r9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4Ddato88tt8zpcoRb0RrrgOGSs
# bmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+lD3v++MrWhAfTVYoonpy4BI6
# t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nkkDstrjNYxbc+/jLTswM9sbKv
# kjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6A4aN91/w0FK/jJSHvMAhdCVf
# GCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmdX4jiJV3TIUs+UsS1Vz8kA/DR
# elsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL5zmhD+kjSbwYuER8ReTBw3J6
# 4HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zdsGbiwZeBe+3W7UvnSSmnEyim
# p31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3T8HhhUSJxAlMxdSlQy90lfdu
# +HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS4NaIjAsCAwEAAaOCAe0wggHp
# MBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRIbmTlUAXTgqoXNzcitW2oynUC
# lTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0T
# AQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBDuRQFTuHqp8cx0SOJNDBaBgNV
# HR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9w
# cm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3JsMF4GCCsGAQUF
# BwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3Br
# aS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3J0MIGfBgNVHSAE
# gZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5t
# aWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1hcnljcHMuaHRtMEAGCCsGAQUF
# BwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkAYwB5AF8AcwB0AGEAdABlAG0A
# ZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn8oalmOBUeRou09h0ZyKbC5YR
# 4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7v0epo/Np22O/IjWll11lhJB9
# i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0bpdS1HXeUOeLpZMlEPXh6I/MT
# faaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/KmtYSWMfCWluWpiW5IP0wI/z
# Rive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvyCInWH8MyGOLwxS3OW560STkK
# xgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBpmLJZiWhub6e3dMNABQamASoo
# PoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJihsMdYzaXht/a8/jyFqGaJ+HN
# pZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYbBL7fQccOKO7eZS/sl/ahXJbY
# ANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbSoqKfenoi+kiVH6v7RyOA9Z74
# v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sLgOppO6/8MO0ETI7f33VtY5E9
# 0Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtXcVZOSEXAQsmbdlsKgEhr/Xmf
# wb1tbWrJUnMTDXpQzTGCFWgwghVkAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTECEzMAAAHEL9+WhJG6TK4AAAAAAcQwDQYJYIZIAWUDBAIBBQCg
# gaYwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwG
# CisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIF04LKAh1uDLuNSkryyRLzzTIbxo
# 7EGcD1fWbnidM31ZMDoGCisGAQQBgjcCAQwxLDAqoAyACgBTAGsAeQBwAGWhGoAY
# aHR0cDovL3d3dy5taWNyb3NvZnQuY29tMA0GCSqGSIb3DQEBAQUABIIBAGxgjitG
# 4fBiYYUoLTyH5/TLX7hw9Uv/VUGBVNdphvqcJRfiH7v/0UlY6gWbjf9wFd8iAYZH
# TTRhiYoeXcXTzqBqNx/1OjG+SSZ0qHgwEBQ8sPINXJJj8hpqp2y5oTS8wyanRKDc
# Y0iiDhUaVuRcKKZDjcxMia9LcBl/Hh3Cdd+hERB63kbjekWAgVBYzn4Xpf5dRZ4Z
# 3xTLC2AJNn/GceIQ8deZPu0+5b9As4ud+YIzkA/yifAASgJ5KpekrmorevdxKfMp
# fYg5H1JwlEmOKMaHcI0qE38KQMBcOOMWLMizJWXu9Wm7XhEsVfQX0tAk54l9VLfP
# vM79gyL/IdmrAmShghL6MIIS9gYKKwYBBAGCNwMDATGCEuYwghLiBgkqhkiG9w0B
# BwKgghLTMIISzwIBAzEPMA0GCWCGSAFlAwQCAQUAMIIBWAYLKoZIhvcNAQkQAQSg
# ggFHBIIBQzCCAT8CAQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEFAAQg2i+r
# dZXJOyPyq9cexcPtS1+FtI5tEAbqJLLnR44SNiUCBmB+YyaHfhgSMjAyMTA1MDcw
# MzM1NDEuMjVaMASAAgH0oIHYpIHVMIHSMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRp
# b25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNOOkQwODItNEJGRC1F
# RUJBMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloIIOSjCC
# BPkwggPhoAMCAQICEzMAAAFBr39Sl1zy3EUAAAAAAUEwDQYJKoZIhvcNAQELBQAw
# fDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
# ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMd
# TWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwHhcNMjAxMDE1MTcyODI3WhcN
# MjIwMTEyMTcyODI3WjCB0jELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
# b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
# dGlvbjEtMCsGA1UECxMkTWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1p
# dGVkMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjpEMDgyLTRCRkQtRUVCQTElMCMG
# A1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZTCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBAPIqy6i9vHWpfjyVJlCTsL2J/7DghM0M2co/eF2x
# T7UYQ4T42oL7yjr9RoDKDrl75KTN7jOROu78jgj8aoUwM6uwJN85BF1wb+yaDPF5
# tMeVHJwJKVIhKNHsnEZem52CAdypWVt7s+CXNr9hVdCghpC676nyj/Ff4toVcjfO
# eDno1qcfMBlGszOAmFFaMHIBA3O+jmPl2uFtuwwmSZtn/aJeAY0i/m9i/0/J/yxB
# pJ2lMcEkEzdS0ArfrgQwgEnelUEeQiyyVbejAS9FtTZWlsRACcJSHcgZ0tYoS70Y
# NY3PylGXtLERXQ934Sq4z2nN4aMtNOxb6+hqNFieKa9qyXUCAwEAAaOCARswggEX
# MB0GA1UdDgQWBBQtKD8sbi6Q/UVwa/XPDTtBBRLGxDAfBgNVHSMEGDAWgBTVYzpc
# ijGQ80N7fEYbxTNoWoVtVTBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1p
# Y3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNUaW1TdGFQQ0FfMjAxMC0w
# Ny0wMS5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1RpbVN0YVBDQV8yMDEwLTA3LTAx
# LmNydDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqGSIb3
# DQEBCwUAA4IBAQBSet8ifdgoagoKXsQ+PKJL4hrguIpDbL5sJQknrdbBabyRMyyQ
# fHExeM+KkE8/ALELXHsOpgFZkAmA7vX+XntdcV49S8B2LGRp0rPzn0bpdVSpmOdT
# kKaryuTvwreH7NCG5c6PHsjiycoE5Pe2l1QOFM6vBm5S+y0OV4sAGOOOjDgC5zVx
# aPyqvbb84qcGNWHEZ/55TEPm/djoiy5h1TItsAFDkYihb2gH2Fo4UHftqhyzLHaT
# ZbsAW1nuxReQAbA6NB0TjFsgoMXS0N76q9wzEh92ViooqxbL1iZnIX2TxkTm8KrM
# 70lzxZjwWfaPnq/uFKC1fudBlp50JMux1YC5MIIGcTCCBFmgAwIBAgIKYQmBKgAA
# AAAAAjANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUg
# QXV0aG9yaXR5IDIwMTAwHhcNMTAwNzAxMjEzNjU1WhcNMjUwNzAxMjE0NjU1WjB8
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
# aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDCCASIwDQYJKoZIhvcNAQEBBQAD
# ggEPADCCAQoCggEBAKkdDbx3EYo6IOz8E5f1+n9plGt0VBDVpQoAgoX77XxoSyxf
# xcPlYcJ2tz5mK1vwFVMnBDEfQRsalR3OCROOfGEwWbEwRA/xYIiEVEMM1024OAiz
# Qt2TrNZzMFcmgqNFDdDq9UeBzb8kYDJYYEbyWEeGMoQedGFnkV+BVLHPk0ySwcSm
# XdFhE24oxhr5hoC732H8RsEnHSRnEnIaIYqvS2SJUGKxXf13Hz3wV3WsvYpCTUBR
# 0Q+cBj5nf/VmwAOWRH7v0Ev9buWayrGo8noqCjHw2k4GkbaICDXoeByw6ZnNPOcv
# RLqn9NxkvaQBwSAJk3jN/LzAyURdXhacAQVPIk0CAwEAAaOCAeYwggHiMBAGCSsG
# AQQBgjcVAQQDAgEAMB0GA1UdDgQWBBTVYzpcijGQ80N7fEYbxTNoWoVtVTAZBgkr
# BgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUw
# AwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvXzpoYxDBWBgNVHR8ETzBN
# MEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0
# cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYIKwYBBQUHAQEETjBMMEoG
# CCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01p
# Y1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNydDCBoAYDVR0gAQH/BIGVMIGSMIGPBgkr
# BgEEAYI3LgMwgYEwPQYIKwYBBQUHAgEWMWh0dHA6Ly93d3cubWljcm9zb2Z0LmNv
# bS9QS0kvZG9jcy9DUFMvZGVmYXVsdC5odG0wQAYIKwYBBQUHAgIwNB4yIB0ATABl
# AGcAYQBsAF8AUABvAGwAaQBjAHkAXwBTAHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJ
# KoZIhvcNAQELBQADggIBAAfmiFEN4sbgmD+BcQM9naOhIW+z66bM9TG+zwXiqf76
# V20ZMLPCxWbJat/15/B4vceoniXj+bzta1RXCCtRgkQS+7lTjMz0YBKKdsxAQEGb
# 3FwX/1z5Xhc1mCRWS3TvQhDIr79/xn/yN31aPxzymXlKkVIArzgPF/UveYFl2am1
# a+THzvbKegBvSzBEJCI8z+0DpZaPWSm8tv0E4XCfMkon/VWvL/625Y4zu2JfmttX
# QOnxzplmkIz/amJ/3cVKC5Em4jnsGUpxY517IW3DnKOiPPp/fZZqkHimbdLhnPkd
# /DjYlPTGpQqWhqS9nhquBEKDuLWAmyI4ILUl5WTs9/S/fmNZJQ96LjlXdqJxqgaK
# D4kWumGnEcua2A5HmoDF0M2n0O99g/DhO3EJ3110mCIIYdqwUB5vvfHhAN/nMQek
# kzr3ZUd46PioSKv33nJ+YWtvd6mBy6cJrDm77MbL2IK0cs0d9LiFAR6A+xuJKlQ5
# slvayA1VmXqHczsI5pgt6o3gMy4SKfXAL1QnIffIrE7aKLixqduWsqdCosnPGUFN
# 4Ib5KpqjEWYw07t0MkvfY3v1mYovG8chr1m1rtxEPJdQcdeh0sVV42neV8HR3jDA
# /czmTfsNv11P6Z0eGTgvvM9YBS7vDaBQNdrvCScc1bN+NR4Iuto229Nfj950iEkS
# oYIC1DCCAj0CAQEwggEAoYHYpIHVMIHSMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRp
# b25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNOOkQwODItNEJGRC1F
# RUJBMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEw
# BwYFKw4DAhoDFQCq5b8ptQqriKEHK853C75A9VqVA6CBgzCBgKR+MHwxCzAJBgNV
# BAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4w
# HAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29m
# dCBUaW1lLVN0YW1wIFBDQSAyMDEwMA0GCSqGSIb3DQEBBQUAAgUA5D6hszAiGA8y
# MDIxMDUwNzAxMTExNVoYDzIwMjEwNTA4MDExMTE1WjB0MDoGCisGAQQBhFkKBAEx
# LDAqMAoCBQDkPqGzAgEAMAcCAQACAhQBMAcCAQACAhFGMAoCBQDkP/MzAgEAMDYG
# CisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEA
# AgMBhqAwDQYJKoZIhvcNAQEFBQADgYEAZ7JRQkFwSuF/GhhXGPj525yapfUILaUt
# K9xdYP0Vhm95gYlLV8dfvGTMcwrWqzafwgKPvtFQHq+GwlXrXupDOx7bSwjQnd/H
# 76yRAHPmYWwWXl/CtYEPeWnAZFNARviA8Z+iRVosr/oB5810c6js2q4rJBXU7WJ7
# eHhtRKhFpcwxggMNMIIDCQIBATCBkzB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0Eg
# MjAxMAITMwAAAUGvf1KXXPLcRQAAAAABQTANBglghkgBZQMEAgEFAKCCAUowGgYJ
# KoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCDZpjocYMPm
# Gk/rhbd6GK1t5VIMHfqiHsR5RKRbuv2ETDCB+gYLKoZIhvcNAQkQAi8xgeowgecw
# geQwgb0EIFE/ATyM6nN0nnB0TyygbVtLzjp0/u/IWlqPl3MVXq3eMIGYMIGApH4w
# fDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
# ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMd
# TWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAFBr39Sl1zy3EUAAAAA
# AUEwIgQglm7qVN8Cmoj7sXcxyewikqvWcglutB2qLbP1yt9xfUMwDQYJKoZIhvcN
# AQELBQAEggEAKhiquZQ2D0wl++xT3MXJhs4UvTKoeDSkk/mnbEW8q+PKbIBxsSNd
# 0ovNO9SXfq3p36Bz6g5WFS17gFpZV8/dk/qXbGlUAKkuCz3nF80JVT3pIZ+H1ksK
# fh4HyxoQLOCML1oob7YqSDr80GzCAOugFlPVyQXyLCDO95gXnjavK98nlIJybDae
# wR9HypuN+zEGZLiNTe4FLpFpu7Gd2r5HXRwTKpl/zX/9qHXIE6hHfd53AmVyCs9Y
# f6beoto8wiFwQ3UZlX3UXGOPNFAFRg8au8M+KrRLyE/PKmRim71WyB/Ekjz2nV6s
# /Q9h14DpvcQrw9Ze22YqyvG1M+OOV4nteQ==
# SIG # End signature block
