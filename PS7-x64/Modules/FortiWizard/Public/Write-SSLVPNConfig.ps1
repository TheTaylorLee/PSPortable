Function Write-SSLVPNConfig {

    <#
    .Link
    https://github.com/TheTaylorLee/FortiWizard/tree/main/docs
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]$ConfigFilePath,
        [Parameter(Mandatory = $true)]$CommaSeperatedDNSSuffixes,
        [Parameter(Mandatory = $true)]$DNofParentOU,
        [Parameter(Mandatory = $true)][ValidatePattern('^[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}$')]$DNSServerIP,
        [Parameter(Mandatory = $true)][ValidateScript( {
                if ($_ -match '^[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}$') {
                    $true
                }
                else {
                    throw "$_ is an invalid pattern. You must provide a subnet mask and not a prefix."
                }
            })]$InternalLanSubnetMask,
        [Parameter(Mandatory = $true)][ValidatePattern('^[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}$')]$InternalLanIP,
        [Parameter(Mandatory = $true)]$LanInterfaceName,
        [Parameter(Mandatory = $true)]$LDAPServerFriendlyName,
        [Parameter(Mandatory = $true)]$ServiceAccountPassword,
        [Parameter(Mandatory = $true)]$ServiceAccountsAMAccountName,
        [Parameter(Mandatory = $true)]$WanInterfaceName
    )


    Write-Output "
#initial setup for enabling the Forticlient VPN Config

config user ldap
    edit $LDAPSERVERFriendlyName
        Set-Variable server $DNSServerIP
        Set-Variable cnid sAMAccountName
        Set-Variable dn $DNofParentOU
        Set-Variable type regular
        Set-Variable username $ServiceAccountsAMAccountName
        Set-Variable password $ServiceAccountPassword
    next
end

config user group
    edit SSLVPNUsers
        Set-Variable member $LDAPSERVERFriendlyName
    next
end

config firewall address
    edit SSLVPN_TUNNEL_ADDR1
        Set-Variable type iprange
        Set-Variable associated-interface ssl.root
        Set-Variable start-ip 10.212.134.1
        Set-Variable end-ip 10.212.134.254
    next
end

config firewall address
    edit SSLVPN_InternalLan
        Set-Variable visibility disable
        Set-Variable subnet $InternalLanIP $InternalLanSubnetMask
    next
end

config vpn ssl web portal
    delete full-access
    delete web-access
    edit tunnel-access
        Set-Variable tunnel-mode enable
        Set-Variable ip-pools SSLVPN_TUNNEL_ADDR1
        Set-Variable ipv6-tunnel-mode disable
        config split-dns
        edit 1
            Set-Variable domains $CommaSeperatedDNSSuffixes
            Set-Variable dns-server1 $DNSServerIP
        next
        end
    next
    edit no-access
        Set-Variable forticlient-download disable
    next
end

config vpn ssl settings
    Set-Variable ssl-min-proto-ver tls1-0
    Set-Variable idle-timeout 43200
    Set-Variable auth-timeout 43200
    Set-Variable tunnel-ip-pools SSLVPN_TUNNEL_ADDR1
    Set-Variable dns-server1 $DNSServerIP
    Set-Variable source-interface $WanInterfaceName
    Set-Variable source-address all
    Set-Variable source-address6 all
    Set-Variable default-portal no-access
    Set-Variable port 10443
    config authentication-rule
        edit 1
            Set-Variable groups SSLVPNUsers
            Set-Variable portal tunnel-access
        next
    end
end

config firewall policy
    edit 0
        Set-Variable name SSLVPN
        Set-Variable srcintf ssl.root
        Set-Variable dstintf $LanInterfaceName
        Set-Variable srcaddr all
        Set-Variable dstaddr SSLVPN_InternalLan
        Set-Variable action accept
        Set-Variable schedule always
        Set-Variable service ALL
        Set-Variable utm-status enable
        Set-Variable ssl-ssh-profile 'Block Malicious'
        Set-Variable ips-sensor default
        Set-Variable nat enable
        Set-Variable groups SSLVPNUsers
    next
end"
}