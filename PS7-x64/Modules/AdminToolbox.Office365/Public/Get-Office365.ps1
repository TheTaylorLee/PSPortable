function Get-Office365 {

    Get-Intro365

    Write-Host "Office 365 Functions"                                                                        -ForegroundColor green
    Write-Host "Connect-Office365          ..Connects to Office 365 Module"                                  -ForegroundColor cyan
    Write-Host "Get-CRTReport              ..Gets a security report for Threat hunting. Credit: Crowdstrike" -ForegroundColor cyan
    Write-Host " "

    Write-Host "ADSync Module Functions"                                                                     -ForegroundColor green
    Write-Host "Invoke-Sync365             ..Invokes an Azure sync using a Non-Verbose alias remotely"       -ForegroundColor cyan
    Write-Host "Start-AzureSync            ..Starts an Azure AD and Local AD Sync"                           -ForegroundColor cyan
    Write-Host " "

    Write-Host "AzureAD Module Functions"                                                                    -ForegroundColor green
    Write-Host "Get-GuestUsers             ..Gets a security report of guest users from Azure AD"            -ForegroundColor cyan
    Write-Host " "

    Write-Host "ExchangeOnline Module Functions"                                                             -ForegroundColor green
    Write-Host "Convert-MailboxToShared    ..Convert Disabled mailbox to a Shared Mailbox"                   -ForegroundColor cyan
    Write-Host "Get-AuthPolicy             ..Gets Exchange Online Auth Policy"                               -ForegroundColor cyan
    Write-Host "Get-Messagetrace           ..Gets an log of email messages"                                  -ForegroundColor cyan
    Write-Host "Get-MFAStatus              ..Gets Multifactor Settings for Msol Users"                       -ForegroundColor cyan
    Write-Host "New-AuthPolicy             ..New Exchange Online Auth Policies Created"                      -ForegroundColor cyan
    Write-Host "Set-AuthPolicy             ..Sets Exchange Online Auth Policy"                               -ForegroundColor cyan
    Write-Host " "

    Write-Host "MSOnline Module Functions"                                                                   -ForegroundColor green
    Write-Host "Get-RoleMembers            ..Gets Office 365 roles and their members"                        -ForegroundColor cyan
    Write-Host " "
}