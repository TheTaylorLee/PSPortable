function Connect-ExchangeServer {
    <#
    .DESCRIPTION
    Import a Powershell session from a remote exchange server with the exchange commands available

    .PARAMETER FQDN
    Fully Qualified Domain name of the exchange Server being connected to

    .EXAMPLE
    Connect-ExchangeServer -FQDN server.domain.com

    .NOTES
    Powershell Remoting must be enabled on the Exchange server.

    .Link
    Disconnect-ExchangeServer
    #>

    [CmdletBinding()]
    [Alias('Connect-Exchange')]
    param (
        [Parameter(Mandatory = $true)]$FQDN
    )

    $Credential = Get-Credential

    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$fqdn/PowerShell/ -Authentication Kerberos -Credential $Credential
    Import-PSSession $Session -DisableNameChecking
}
