Function Enable-PushNotifications {
    <#
    .Link
    https://github.com/TheTaylorLee/FortiWizard/tree/main/docs
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)]$UnusedPort,
        [Parameter(Mandatory = $True)]$WanInterfaceName,
        [Parameter(Mandatory = $True)][ValidatePattern('^[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}$')]$WanIP
    )

    $pass = Read-Host "Provide a password for an unprivileged admin. This is required for Push Notifications to be enable. One admin account must not have 2fa enabled. (Password)"

    Write-Output "
#Enable SSL Client VPN Push Notifications
config system accprofile
    edit no_access
        set system-diagnostics disable
    next
end

edit FTMAdmin
        set accprofile 'no_access'
        set comments 'For Fortitokens Do Not Disable!!!!!! The FortiGate checks trusted host settings before allowing incoming traffic. This also applies to push notification responses. If no administrator without trusted hosts exists, the push response is denied and fails.'
        set password $pass
    next
end

config system ftm-push
    set server-ip $WanIP
    set server-port $UnusedPort
    set status enable
end

config system interface
    edit $WanInterfaceName
        set allowaccess ftm
    next
end
"
}