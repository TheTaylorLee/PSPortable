#Imports the Exchange Online Module if exists
$CreateEXOPSSession = (Get-ChildItem -Path $Env:LOCALAPPDATA\Apps\2.0* -Filter CreateExoPSSession.ps1 -Recurse -ErrorAction SilentlyContinue -Force | Select-Object -Last 1).DirectoryName
if (Test-Path $CreateEXOPSSession) {
    Import-Module  "$CreateEXOPSSession\CreateExoPSSession.ps1" -Force

    #Clear EXO and exchange messages
    Clear-Host
}