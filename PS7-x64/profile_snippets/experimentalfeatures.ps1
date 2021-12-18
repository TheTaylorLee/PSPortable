#Handling Bugged experimental features of psreadline
#When upgrading powershell 7 versions and psreadline check to see if these have been addressed.

#This is a work around to this issue. https://github.com/PowerShell/PowerShell/issues/14506

$Suggestions = Get-ExperimentalFeature -Name PSCommandNotFoundSuggestion | Where-Object { $_.enabled -like "true" }
$AnsiRendering = Get-ExperimentalFeature -Name PSAnsiRendering | Where-Object { $_.enabled -like "true" }

if ($Suggestions) {
    #Getting rid of annoying suggestion
    Disable-ExperimentalFeature  –Name PSCommandNotFoundSuggestion -WarningAction 'silent' | Out-Null
}
#PSAnsiRendering and beta versions of psreadline causing console color issues. Disabling this feature provides some relief
if ($AnsiRendering) {
    #Hopefully eliminates hardcoded console color changes when using write-verbose, write-warning, etc.
    Disable-ExperimentalFeature  –Name PSAnsiRendering -WarningAction 'silent' | Out-Null
    Disable-ExperimentalFeature  –Name PSAnsiprogress -WarningAction 'silent' | Out-Null
}