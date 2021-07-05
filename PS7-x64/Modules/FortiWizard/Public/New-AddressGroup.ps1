#Used By New-P2PTunnel


Function New-AddressGroup {
    <#
    .Link
    https://github.com/TheTaylorLee/FortiWizard/tree/main/docs
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]$GroupName,
        [Parameter(Mandatory = $true)]$AddressNames
    )

    Write-Output "
#Create Address Group

config firewall addrgrp
    edit $GroupName
        set member $AddressNames
        set allow-routing enable
    next
end
"
}