Import-Module AdminToolbox
Import-Module BetterCredentials
Import-Module MyFunctions
Import-Module posh-git
Import-Module oh-my-posh

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}