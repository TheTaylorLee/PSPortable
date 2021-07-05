Function Enable-Management {

    <#
    .Link
    https://github.com/TheTaylorLee/FortiWizard/tree/main/docs
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)][string]$AdminUsername = "admin",
        [Parameter(Mandatory = $true)]$WANInterfaceName
    )


    Write-Output "
#Enable Management from Interface ($WANInterfaceName) and configure trusted hosts for the admin account ($AdminUsername)

config system admin
    edit $AdminUsername
        set trusthost1 104.188.119.0 255.255.255.255
        set trusthost2 50.203.117.192 255.255.255.248
        set trusthost3 69.94.230.192 255.255.255.192
        set trusthost4 10.0.0.0 255.0.0.0
        set trusthost5 192.168.0.0 255.255.0.0
        set trusthost6 172.16.0.0 255.240.0.0
    next
end

config system interface
    edit $WANInterfaceName
        set allowaccess ping https ssh ftm
    next
end"
}