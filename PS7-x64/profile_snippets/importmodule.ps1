Import-Module AdminToolbox
Import-Module BetterCredentials
Import-Module completionpredictor
Import-Module MyFunctions
Import-Module posh-git # needed for ohmyposh

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

#Set starting directory to downloads
Set-Location $Down