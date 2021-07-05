#Used By New-P2PTunnel

Function New-ServiceObject {
    <#
    .Link
    https://github.com/TheTaylorLee/FortiWizard/tree/main/docs
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, ParameterSetName = 'TCP')]
        [Parameter(Mandatory = $true, ParameterSetName = 'UDP')]$ServiceName,
        [Parameter(Mandatory = $true, ParameterSetName = 'TCP')]$TCPPortRange,
        [Parameter(Mandatory = $true, ParameterSetName = 'UDP')]$UDPPortRange
    )

    if ($TCPPortRange) {
        Write-Output "
config firewall service custom
    edit $ServiceName
        set tcp-portrange $TCPPortRange
    next
end"
    }

    if ($UDPPortRange) {
        Write-Output "
config firewall service custom
    edit $ServiceName
        set udp-portrange $UDPPortRange
    next
end"
    }
}