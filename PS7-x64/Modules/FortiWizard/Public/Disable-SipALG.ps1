Function Disable-SipALG {

    <#
    .Link
    https://github.com/TheTaylorLee/FortiWizard/tree/main/docs
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false)][switch]$LessThanMajor6Minor2
    )

    if ($LessThanMajor6Minor2) {
        Write-Output "
#Disable Sip Settings

config system settings
    set sip-helper disable
    set sip-nat-trace disable
    set default-voip-alg-mode kernel-helper-based
end

config voip profile
    edit default
        config sip
            set status disable
            set rtp disable
        end
end

config system session-helper
    delete 13
end"
    }

    else {
        Write-Output "
#Disable Sip Settings

config system settings
    set default-voip-alg-mode kernel-helper-based
    set sip-expectation disable
    set sip-nat-trace disable
end

config voip profile
    edit default
        config sip
            set rtp disable
        end
end

config system session-helper
    delete 13
end"
    }
}