Function New-IPPoolFixedRange {
    <#
    .Link
    https://github.com/TheTaylorLee/FortiWizard/tree/main/docs
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]$IPPoolName,
        [Parameter(Mandatory = $true)][ValidatePattern('^[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}$')]$StartIPRangeExternal,
        [Parameter(Mandatory = $true)][ValidatePattern('^[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}$')]$EndIPRangeExternal,
        [Parameter(Mandatory = $true)][ValidatePattern('^[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}$')]$StartIPRangeInternal,
        [Parameter(Mandatory = $true)][ValidatePattern('^[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}$')]$EndIPRangeInternal
    )

    Write-Output "
config firewall ippool
    edit $IPPoolName
        set type fixed-port-range
        set startip $StartIPRangeExternal
        set endip $EndIPRangeExternal
        set source-startip $StartIPRangeInternal
        set source-endip $EndIPRangeInternal
    next
end"
}