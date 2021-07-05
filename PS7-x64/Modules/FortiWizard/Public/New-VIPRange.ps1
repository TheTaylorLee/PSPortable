Function New-VIPRange {
    <#
    .Link
    https://github.com/TheTaylorLee/FortiWizard/tree/main/docs
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]$VIPName,
        [Parameter(Mandatory = $true)]
        [ValidateScript( {
                if ($_ -match '^[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}[-][0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}$') {
                    $true
                }
                else {
                    throw "$_ is an invalid entry. You must provide a range in this pattern 192.168.1.1-192.168.1.254"
                }
            })]$ExternalIPRange,
        [Parameter(Mandatory = $true)]$Interface,
        [Parameter(Mandatory = $true)]
        [ValidateScript( {
                if ($_ -match '^[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}[-][0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}$') {
                    $true
                }
                else {
                    throw "$_ is an invalid entry. You must provide a range in this pattern 192.168.1.1-192.168.1.254"
                }
            })]$InternalIPRange
    )

    Write-Output "
config firewall vip
    edit $VIPName
        set extip $ExternalIPRange
        set extintf $Interface
        set mappedip $InternalIPRange
    next
end"
}