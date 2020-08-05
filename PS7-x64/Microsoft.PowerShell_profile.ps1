$ErrorActionPreference = 'SilentlyContinue'

#Powershell Customization
function prompt {
    $location = Get-Location
    Write-Host -NoNewLine "$(HOSTNAME.EXE) "                  -ForegroundColor Green
    Write-Host -NoNewLine '~'                                 -ForegroundColor Yellow
    Write-Host -NoNewLine $(Get-Location).Path.Split('\')[-1] -ForegroundColor Cyan
    Write-Host -NoNewline ">" -ForegroundColor Green

    $Adminp = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
    $host.UI.RawUI.WindowTitle = 'Admin is ' + "$Adminp" + ' - PSVersion ' + $host.version + " - $location"

    Return " "
}

<#Default
Set-PSReadLineOption -BellStyle Audible
Set-PSReadLineKeyHandler -Chord Tab -Function TabCompleteNext
Set-PSReadLineKeyHandler -Chord Ctrl+Space -Function MenuComplete
#>
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete
#Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
#-------------------------------------------------------------------------------------------------------------------------------------------------------

#Downloads folder variable
$Down = "$env:USERPROFILE\downloads"


# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

$ErrorActionPreference = 'Continue'
Import-Module AdminToolbox
