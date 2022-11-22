$hostpath = (Get-Process -PID $pid).path

if ($hostpath -eq "$env:ProgramData\PS7x64\PS7-x64\pwsh.exe") {
    . $PSScriptRoot\psportable.ps1
}

if ($hostpath -eq "$env:ProgramData\PS7x64Light\PS7-x64\pwsh.exe") {
    . $PSScriptRoot\psportablelight.ps1
}