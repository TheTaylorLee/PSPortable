$ErrorActionPreference = 'SilentlyContinue'

#Powershell Customization
#Need newer version of PSReadlin that fixes tab complete bug
function prompt {
    $location = Get-Location
    Write-Host -NoNewline "$(HOSTNAME.EXE) "                  -ForegroundColor Green
    Write-Host -NoNewline '~'                                 -ForegroundColor Yellow
    Write-Host -NoNewline $(Get-Location).Path.Split('\')[-1] -ForegroundColor Cyan
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
#Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete

#Configure PSReadline Intellisense

$query = Get-Module PSReadLine
if ($query.Version -gt "2.1") {
    Set-PSReadLineOption -Colors @{
        InlinePrediction = '#85C1E9'
        ListPrediction   = '#27FF00'
    }
    Set-PSReadLineOption -PredictionViewStyle ListView
    try {
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    }
    catch {
        Set-PSReadLineOption -PredictionSource History
    }
}

Function Set-WindowSize {
    #Specify Window Size, Buffer, and Histor Parameters
    [int]$Height = 30
    [int]$Width = 140
    [int]$Buffer = 8000

    $console = $host.ui.rawui
    $ConBuffer = $console.BufferSize
    $ConSize = $console.WindowSize

    $currWidth = $ConSize.Width
    $currHeight = $ConSize.Height

    # if height is too large, set to max allowed size
    if ($Height -gt $host.UI.RawUI.MaxPhysicalWindowSize.Height) {
        $Height = $host.UI.RawUI.MaxPhysicalWindowSize.Height
    }

    # if width is too large, set to max allowed size
    if ($Width -gt $host.UI.RawUI.MaxPhysicalWindowSize.Width) {
        $Width = $host.UI.RawUI.MaxPhysicalWindowSize.Width
    }

    # If the Buffer is wider than the new console setting, first reduce the width
    If ($ConBuffer.Width -gt $Width ) {
        $currWidth = $Width
    }

    # If the Buffer is higher than the new console setting, first reduce the height
    If ($ConBuffer.Height -gt $Height ) {
        $currHeight = $Height
    }

    # initial resizing if needed
    $host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.size($currWidth, $currHeight)

    # Set the Buffer
    $host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.size($Width, $Buffer)

    # Now set the WindowSize
    $host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.size($Width, $Height)
}
Set-WindowSize
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