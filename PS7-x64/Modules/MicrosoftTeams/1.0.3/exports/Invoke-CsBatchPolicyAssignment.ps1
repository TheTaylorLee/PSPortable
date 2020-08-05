<#
.Synopsis
Submit a new batch for policy assignments
.Description
Submit a new batch for policy assignments
.Example
To view examples, please use the -Online parameter with Get-Help or navigate to: https://docs.microsoft.com/en-us/powershell/module/microsoft.teams.config/invoke-csbatchpolicyassignment
.Inputs
Microsoft.Teams.Config.Cmdlets.Models.IBatchAssignBody
.Outputs
Microsoft.Teams.Config.Cmdlets.Models.IErrorResponse
.Outputs
System.String
.Notes
COMPLEX PARAMETER PROPERTIES
To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.

PAYLOAD <IBatchAssignBody>: HELP MESSAGE MISSING
  Identity <String[]>: 
  PolicyName <String>: 
  PolicyType <String>: 
.Link
https://docs.microsoft.com/en-us/powershell/module/microsoft.teams.config/invoke-csbatchpolicyassignment
#>
function Invoke-CsBatchPolicyAssignment {
[OutputType([System.String], [Microsoft.Teams.Config.Cmdlets.Models.IErrorResponse])]
[CmdletBinding(DefaultParameterSetName='BatchExpanded', PositionalBinding=$false, SupportsShouldProcess, ConfirmImpact='Medium')]
param(
    [Parameter()]
    [Microsoft.Teams.Config.Cmdlets.Category('Query')]
    [System.String]
    # string
    ${OperationName},

    [Parameter(ParameterSetName='Batch', Mandatory, ValueFromPipeline)]
    [Microsoft.Teams.Config.Cmdlets.Category('Body')]
    [Microsoft.Teams.Config.Cmdlets.Models.IBatchAssignBody]
    # HELP MESSAGE MISSING
    # To construct, see NOTES section for PAYLOAD properties and create a hash table.
    ${Payload},

    [Parameter(ParameterSetName='BatchExpanded', Mandatory)]
    [Microsoft.Teams.Config.Cmdlets.Category('Body')]
    [System.String[]]
    # HELP MESSAGE MISSING
    ${Identity},

    [Parameter(ParameterSetName='BatchExpanded', Mandatory)]
    [Microsoft.Teams.Config.Cmdlets.Category('Body')]
    [System.String]
    # HELP MESSAGE MISSING
    ${PolicyName},

    [Parameter(ParameterSetName='BatchExpanded', Mandatory)]
    [Microsoft.Teams.Config.Cmdlets.Category('Body')]
    [System.String]
    # HELP MESSAGE MISSING
    ${PolicyType},

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
            Batch = 'Microsoft.Teams.Config.private\Invoke-CsBatchPolicyAssignment_Batch';
            BatchExpanded = 'Microsoft.Teams.Config.private\Invoke-CsBatchPolicyAssignment_BatchExpanded';
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
