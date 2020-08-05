<#
.Synopsis
Assign a policy to a group
.Description
Assign a policy to a group
.Example
To view examples, please use the -Online parameter with Get-Help or navigate to: https://docs.microsoft.com/en-us/powershell/module/microsoft.teams.config/group-csgroupassignment
.Inputs
Microsoft.Teams.Config.Cmdlets.Models.IGroupAssignPayload
.Inputs
Microsoft.Teams.Config.Cmdlets.Models.IIc3AdminConfigRpPolicyIdentity
.Outputs
Microsoft.Teams.Config.Cmdlets.Models.IErrorResponse
.Outputs
Microsoft.Teams.Config.Cmdlets.Models.IVoid
.Notes
COMPLEX PARAMETER PROPERTIES
To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.

ASSIGNMENTDEFINITION <IGroupAssignPayload>: HELP MESSAGE MISSING
  [PolicyName <String>]: 
  [Priority <Int32?>]: 

INPUTOBJECT <IIc3AdminConfigRpPolicyIdentity>: Identity Parameter
  [GroupId <String>]: 
  [OperationId <String>]: OperationId received from submitting a batch
  [PolicyType <String>]: 
.Link
https://docs.microsoft.com/en-us/powershell/module/microsoft.teams.config/group-csgroupassignment
#>
function Group-CsGroupAssignment {
[OutputType([Microsoft.Teams.Config.Cmdlets.Models.IVoid], [Microsoft.Teams.Config.Cmdlets.Models.IErrorResponse])]
[CmdletBinding(DefaultParameterSetName='GroupExpanded', PositionalBinding=$false, SupportsShouldProcess, ConfirmImpact='Medium')]
param(
    [Parameter(ParameterSetName='Group', Mandatory)]
    [Parameter(ParameterSetName='GroupExpanded', Mandatory)]
    [Microsoft.Teams.Config.Cmdlets.Category('Path')]
    [System.String]
    # HELP MESSAGE MISSING
    ${GroupId},

    [Parameter(ParameterSetName='Group', Mandatory)]
    [Parameter(ParameterSetName='GroupExpanded', Mandatory)]
    [Microsoft.Teams.Config.Cmdlets.Category('Path')]
    [System.String]
    # HELP MESSAGE MISSING
    ${PolicyType},

    [Parameter(ParameterSetName='GroupViaIdentity', Mandatory, ValueFromPipeline)]
    [Parameter(ParameterSetName='GroupViaIdentityExpanded', Mandatory, ValueFromPipeline)]
    [Microsoft.Teams.Config.Cmdlets.Category('Path')]
    [Microsoft.Teams.Config.Cmdlets.Models.IIc3AdminConfigRpPolicyIdentity]
    # Identity Parameter
    # To construct, see NOTES section for INPUTOBJECT properties and create a hash table.
    ${InputObject},

    [Parameter(ParameterSetName='Group', Mandatory, ValueFromPipeline)]
    [Parameter(ParameterSetName='GroupViaIdentity', Mandatory, ValueFromPipeline)]
    [Microsoft.Teams.Config.Cmdlets.Category('Body')]
    [Microsoft.Teams.Config.Cmdlets.Models.IGroupAssignPayload]
    # HELP MESSAGE MISSING
    # To construct, see NOTES section for ASSIGNMENTDEFINITION properties and create a hash table.
    ${AssignmentDefinition},

    [Parameter(ParameterSetName='GroupExpanded')]
    [Parameter(ParameterSetName='GroupViaIdentityExpanded')]
    [Microsoft.Teams.Config.Cmdlets.Category('Body')]
    [System.String]
    # HELP MESSAGE MISSING
    ${PolicyName},

    [Parameter(ParameterSetName='GroupExpanded')]
    [Parameter(ParameterSetName='GroupViaIdentityExpanded')]
    [Microsoft.Teams.Config.Cmdlets.Category('Body')]
    [System.Int32]
    # HELP MESSAGE MISSING
    ${Priority},

    [Parameter(DontShow)]
    [Microsoft.Teams.Config.Cmdlets.Category('Runtime')]
    [System.Management.Automation.SwitchParameter]
    # Wait for .NET debugger to attach
    ${Break},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Teams.Config.Cmdlets.Category('Runtime')]
    [Microsoft.Teams.Config.Cmdlets.Runtime.SendAsyncStep[]]
    # SendAsync Pipeline Steps to be appended to the front of the pipeline
    ${HttpPipelineAppend},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Teams.Config.Cmdlets.Category('Runtime')]
    [Microsoft.Teams.Config.Cmdlets.Runtime.SendAsyncStep[]]
    # SendAsync Pipeline Steps to be prepended to the front of the pipeline
    ${HttpPipelinePrepend},

    [Parameter(DontShow)]
    [Microsoft.Teams.Config.Cmdlets.Category('Runtime')]
    [System.Uri]
    # The URI for the proxy server to use
    ${Proxy},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Teams.Config.Cmdlets.Category('Runtime')]
    [System.Management.Automation.PSCredential]
    # Credentials for a proxy server to use for the remote call
    ${ProxyCredential},

    [Parameter(DontShow)]
    [Microsoft.Teams.Config.Cmdlets.Category('Runtime')]
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
            Group = 'Microsoft.Teams.Config.private\Group-CsGroupAssignment_Group';
            GroupExpanded = 'Microsoft.Teams.Config.private\Group-CsGroupAssignment_GroupExpanded';
            GroupViaIdentity = 'Microsoft.Teams.Config.private\Group-CsGroupAssignment_GroupViaIdentity';
            GroupViaIdentityExpanded = 'Microsoft.Teams.Config.private\Group-CsGroupAssignment_GroupViaIdentityExpanded';
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
