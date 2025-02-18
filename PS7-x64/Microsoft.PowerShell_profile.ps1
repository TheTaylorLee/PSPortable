#Variable script must be called first. Global variables used by other snippets will use these variables.

$ErrorActionPreference = 'SilentlyContinue'

. $PSScriptRoot\profile_snippets\variables.ps1
. $PSScriptRoot\profile_snippets\prompt.ps1
. $PSScriptRoot\profile_snippets\psreadline.ps1
. $PSScriptRoot\profile_snippets\versioncheck\versioncheck.ps1
. $PSScriptRoot\profile_snippets\exchangesnapin.ps1
. $PSScriptRoot\profile_snippets\installfont.ps1
. $PSScriptRoot\profile_snippets\importmodule.ps1

# Wanring: Don't refactor this section. This cannot be dot sourced and work, so it is run in the profile and not a seperate script.
if ($null -eq $env:WT_SESSION -and $env:TERM_PROGRAM -eq 'vscode') {
    . $PSScriptRoot\profile_snippets\windowsize.ps1
}

if ($env:TERM_PROGRAM -eq 'vscode') {
    Set-PSReadLineOption -PredictionViewStyle InlineView
}

$ErrorActionPreference = 'Continue'