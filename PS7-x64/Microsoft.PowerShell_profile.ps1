$ErrorActionPreference = 'SilentlyContinue'

<#old prompt
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
#>

function prompt {
    $location = Get-Location
    Write-Host -NoNewline "$(HOSTNAME.EXE) "                  -ForegroundColor Green
    Write-Host -NoNewline '~'                                 -ForegroundColor Yellow
    Write-Host -NoNewline $(Get-Location).Path.Split('\')[-1] -ForegroundColor Cyan
    Write-Host -NoNewline ">" -ForegroundColor Green

    $Adminp = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
    $ver = [string]$host.Version.major + '.' + [string]$host.version.minor
    $host.UI.RawUI.WindowTitle = "$ver" + ' - Admin is ' + "$Adminp" + " - $location"

    Return " "
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------

<#Default
Set-PSReadLineOption -BellStyle Audible
Set-PSReadLineKeyHandler -Chord Tab -Function TabCompleteNext
Set-PSReadLineKeyHandler -Chord Ctrl+Space -Function MenuComplete
Set-PSReadLineOption -editmode Windows
#>
#Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Set-PSReadLineOption -BellStyle None -EditMode Windows
Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete

#Configure PSReadline Intellisense
$query = Get-Module PSReadLine
if ($query.Version -le "2.2") {
    Install-Module psreadline -AllowPrerelease -AllowClobber -Force
}

Function Set-PSReadlineIntellisenseOptions {
    #Set colors for intellisense prediction
    Set-PSReadLineOption -Colors @{
        InlinePrediction = '#85C1E9'
        ListPrediction   = '#27FF00'
    }
    #Set viewStyle based on powershell version requirements
    if ($psversiontable.psversion.major -ge 7 ) {
        Set-PSReadLineOption -PredictionViewStyle ListView
    }
    else {
        Set-PSReadLineOption -PredictionViewStyle InlineView
    }
    #Set prediction source for intellisense
    try {
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    }
    catch {
        Set-PSReadLineOption -PredictionSource History
    }
}
Set-PSReadlineIntellisenseOptions

Set-PSReadLineKeyHandler -Key F12 `
    -BriefDescription History `
    -LongDescription 'Show command history' `
    -ScriptBlock {
    $pattern = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$pattern, [ref]$null)
    if ($pattern) {
        $pattern = [regex]::Escape($pattern)
    }

    $history = [System.Collections.ArrayList]@(
        $last = ''
        $lines = ''
        foreach ($line in [System.IO.File]::ReadLines((Get-PSReadLineOption).HistorySavePath)) {
            if ($line.EndsWith('`')) {
                $line = $line.Substring(0, $line.Length - 1)
                $lines = if ($lines) {
                    "$lines`n$line"
                }
                else {
                    $line
                }
                continue
            }

            if ($lines) {
                $line = "$lines`n$line"
                $lines = ''
            }

            if (($line -cne $last) -and (!$pattern -or ($line -match $pattern))) {
                $last = $line
                $line
            }
        }
    )
    $history.Reverse()

    $command = $history | Out-GridView -Title 'Select a command to repeat' -PassThru
    if ($command) {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert(($command -join "`n"))
    }
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------

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

#Imports the Exchange Online Module if exists
$CreateEXOPSSession = (Get-ChildItem -Path $Env:LOCALAPPDATA\Apps\2.0* -Filter CreateExoPSSession.ps1 -Recurse -ErrorAction SilentlyContinue -Force | Select-Object -Last 1).DirectoryName
Import-Module  "$CreateEXOPSSession\CreateExoPSSession.ps1" -Force

#Clear EXO and exchange messages
Clear-Host

#-------------------------------------------------------------------------------------------------------------------------------------------------------

#Imports the Exchange Snapins if they exists by initiating a PSSession
$t1 = Test-Path "C:\Program Files\Microsoft\Exchange Server"
$t2 = Test-Path "C:\Program Files (x86)\Microsoft\Exchange Server"

if ($t1 -or $t2 -eq $true) {

    Write-Host "Importing Exchange Module into the ps7 session" -ForegroundColor Green
    $fqdn = [System.Net.Dns]::GetHostByName(($env:computerName)).hostname
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$fqdn/PowerShell/
    Import-PSSession $Session -DisableNameChecking
}

#-------------------------------------------------------------------------------------------------------------------------------------------------------


Import-Module AdminToolbox
Import-Module BetterCredentials
Import-Module MyFunctions

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

#Downloads folder variable
$Down = "$env:USERPROFILE\downloads"

#Set starting directory to downloads
Set-Location $Down

$ErrorActionPreference = 'Continue'