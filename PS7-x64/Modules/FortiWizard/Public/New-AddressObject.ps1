#Used By New-P2PTunnel

Function New-AddressObject {
    <#
    .Link
    https://github.com/TheTaylorLee/FortiWizard/tree/main/docs
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]$AddressName,
        [Parameter(Mandatory = $true)][ValidatePattern('^[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}$')]$IPAddress,
        [Parameter(Mandatory = $true)][ValidateScript( {
                if ($_ -match '^[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}$') {
                    $true
                }
                else {
                    throw "$_ is an invalid pattern. You must provide a subnet mask and not a prefix."
                }
            })]$SubnetMask
    )

    Write-Output "
#Create Addresses

config firewall address
    edit $AddressName
        set subnet $IPAddress $SubnetMask
        set allow-routing enable
    next
end
"
}