function prompt {
    $(
        if ((Test-Path $env:userprofile\appdata\local\Programs\oh-my-posh\bin\oh-my-posh.exe) -and (Get-Module posh-git) -and $Global:sow -eq '1') {
            try {
                oh-my-posh.exe init pwsh --config $env:POSH_THEMES_PATH\sonicboom_light.omp.json | Invoke-Expression
            }
            catch {
                $location = Get-Location
                Write-Host -NoNewline "$(HOSTNAME.EXE) "                  -ForegroundColor Green
                Write-Host -NoNewline '~'                                 -ForegroundColor Yellow
                Write-Host -NoNewline $(Get-Location).Path.Split('\')[-1] -ForegroundColor Cyan
                Write-Host -NoNewline ">" -ForegroundColor Green
                $Adminp = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
                $ver = [string]$host.Version.major + '.' + [string]$host.version.minor + '.' + [string]$host.version.build + "-" + [string]$host.version.PSSemVerPreReleaseLabel
                $host.UI.RawUI.WindowTitle = "$ver" + ' - Admin is ' + "$Adminp" + " - $location"
                Return " "
            }
        }
        else {
            $location = Get-Location
            Write-Host -NoNewline "$(HOSTNAME.EXE) "                  -ForegroundColor Green
            Write-Host -NoNewline '~'                                 -ForegroundColor Yellow
            Write-Host -NoNewline $(Get-Location).Path.Split('\')[-1] -ForegroundColor Cyan
            Write-Host -NoNewline ">" -ForegroundColor Green
            $Adminp = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
            $ver = [string]$host.Version.major + '.' + [string]$host.version.minor + '.' + [string]$host.version.build + "-" + [string]$host.version.PSSemVerPreReleaseLabel
            $host.UI.RawUI.WindowTitle = "$ver" + ' - Admin is ' + "$Adminp" + " - $location"
            Return " "
        }
    )
}