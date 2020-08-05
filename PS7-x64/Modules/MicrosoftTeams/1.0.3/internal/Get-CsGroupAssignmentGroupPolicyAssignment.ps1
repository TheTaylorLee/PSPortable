<#
.Synopsis
Get a specific group policy assignment
.Description
Get a specific group policy assignment
.Example
To view examples, please use the -Online parameter with Get-Help or navigate to: https://docs.microsoft.com/en-us/powershell/module/microsoft.teams.config/get-csgroupassignmentgrouppolicyassignment
.Inputs
Microsoft.Teams.Config.Cmdlets.Models.IIc3AdminConfigRpPolicyIdentity
.Outputs
Microsoft.Teams.Config.Cmdlets.Models.IErrorResponse
.Outputs
Microsoft.Teams.Config.Cmdlets.Models.IGroupAssignment
.Notes
COMPLEX PARAMETER PROPERTIES
To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.

INPUTOBJECT <IIc3AdminConfigRpPolicyIdentity>: Identity Parameter
  [GroupId <String>]: 
  [OperationId <String>]: OperationId received from submitting a batch
  [PolicyType <String>]: 
.Link
https://docs.microsoft.com/en-us/powershell/module/microsoft.teams.config/get-csgroupassignmentgrouppolicyassignment
#>
function Get-CsGroupAssignmentGroupPolicyAssignment {
[OutputType([Microsoft.Teams.Config.Cmdlets.Models.IGroupAssignment], [Microsoft.Teams.Config.Cmdlets.Models.IErrorResponse])]
[CmdletBinding(DefaultParameterSetName='Get2', PositionalBinding=$false)]
param(
    [Parameter(ParameterSetName='Get', Mandatory)]
    [Parameter(ParameterSetName='Get1', Mandatory)]
    [Microsoft.Teams.Config.Cmdlets.Category('Path')]
    [System.String]
    # HELP MESSAGE MISSING
    ${GroupId},

    [Parameter(ParameterSetName='Get', Mandatory)]
    [Microsoft.Teams.Config.Cmdlets.Category('Path')]
    [System.String]
    # HELP MESSAGE MISSING
    ${PolicyType},

    [Parameter(ParameterSetName='GetViaIdentity', Mandatory, ValueFromPipeline)]
    [Parameter(ParameterSetName='GetViaIdentity1', Mandatory, ValueFromPipeline)]
    [Microsoft.Teams.Config.Cmdlets.Category('Path')]
    [Microsoft.Teams.Config.Cmdlets.Models.IIc3AdminConfigRpPolicyIdentity]
    # Identity Parameter
    # To construct, see NOTES section for INPUTOBJECT properties and create a hash table.
    ${InputObject},

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
            Get = 'Microsoft.Teams.Config.private\Get-CsGroupAssignmentGroupPolicyAssignment_Get';
            Get1 = 'Microsoft.Teams.Config.private\Get-CsGroupAssignmentGroupPolicyAssignment_Get1';
            Get2 = 'Microsoft.Teams.Config.private\Get-CsGroupAssignmentGroupPolicyAssignment_Get2';
            GetViaIdentity = 'Microsoft.Teams.Config.private\Get-CsGroupAssignmentGroupPolicyAssignment_GetViaIdentity';
            GetViaIdentity1 = 'Microsoft.Teams.Config.private\Get-CsGroupAssignmentGroupPolicyAssignment_GetViaIdentity1';
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
