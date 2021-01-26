function Start-Cmder {
    <#
    .DESCRIPTION
    Launch a drop-down command console.

    .EXAMPLE
    Launch Cmder

    Cmder

    .Example
    Add Cmder to startup login startup

    Cmder -Startup
    #>

    [cmdletbinding()]
    [Alias ('cmder')]
    param (
        [Parameter (Mandatory = $false)][Switch]$Startup
    )

    if ($Startup) {
        "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
    }

    else {
        $module = (Get-Module admintoolbox).ModuleBase
        $cmder = "$module\support\cmder_mini\Cmder.exe"
        $cmder
        Start-Process $cmder
    }
}