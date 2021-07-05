Function New-VIPHost {
    <#
    .Link
    https://github.com/TheTaylorLee/FortiWizard/tree/main/docs
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]$VIPName,
        [Parameter(Mandatory = $true)][ValidatePattern('^[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}$')]$ExternalIP,
        [Parameter(Mandatory = $true)]$Interface,
        [Parameter(Mandatory = $true)][ValidatePattern('^[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}$')]$InternalIP
    )

    Write-Output "
config firewall vip
    edit $VIPName
        set extip $ExternalIP
        set extintf $Interface
        set mappedip $InternalIP
    next
end
"
}