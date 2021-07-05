#Used By New-P2PTunnel

Function New-ServiceGroup {
    <#
    .Link
    https://github.com/TheTaylorLee/FortiWizard/tree/main/docs
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]$ServiceGroupName,
        [Parameter(Mandatory = $true)]$Members
    )

    Write-Output "
config firewall service group
    edit $ServiceGroupName
        set member $Members
    next
end
"
}