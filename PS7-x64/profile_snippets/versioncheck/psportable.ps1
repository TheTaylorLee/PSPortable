Function Invoke-VersionCheck {

    $CurrentVersion = Get-Content "C:\ProgramData\PS7x64\version.txt"

    $VersionCheck = (Invoke-WebRequest https://raw.githubusercontent.com/TheTaylorLee/PSPortable/master/version.txt -Headers @{"Cache-Control" = "no-cache" } -UseBasicParsing).content | Select-String $CurrentVersion

    if ($VersionCheck) {
    }
    else {
        (Invoke-WebRequest https://raw.githubusercontent.com/TheTaylorLee/PSPortable/master/Changelog.md -Headers @{"Cache-Control" = "no-cache" } -UseBasicParsing).content
        Write-Host " "

        Write-Host "Current $CurrentVersion" -ForegroundColor Green

        Write-Host " "
        Write-Host "A new version of PSPortable has been detected" -ForegroundColor Green
        Write-Host "If you wish to update your console now, run the function Update-Console" -ForegroundColor Cyan
        Write-Warning "This will close all open sessions of ConEmu and pwsh.exe if run"
    }
}; Invoke-VersionCheck

Function Update-Console {

    Start-Process -FilePath powershell.exe -ArgumentList "-executionpolicy bypass", -noprofile, -NoLogo, "-File $env:ProgramData\PS7x64\Invoke-VersionUpdate.ps1"

}