Function Deploy-PSPortable {

    <#
    .DESCRIPTION
    Downloads and Deploys a portable PowerShell 7 package, an included custom profile, and multiple useful modules. Used by the developer of the Admintoolbox modules as a repeatable Powershell environment with little effort.

    .EXAMPLE
    Downloads the PSPortable package, unzips it to programdata, and launces it.

    Deploy-PSPortable

    .LINK
    Deploy-PSPortableLight
    #>

    [CmdletBinding()]
    [Alias("PSPortable", "PSP")]
    param (
    )

    Try {
        #Remove old package
        if (Test-Path $env:ProgramData\PS7x64) {
            Remove-Item $env:ProgramData\PS7x64 -Recurse -Force
        }

        #Download new package as zip file
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $url = "https://github.com/thetaylorlee/psportable/archive/master.zip"
        $output = "$env:ProgramData\PS7x64.zip"
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($url, $output)


        #Unzip to path download package
        Invoke-Unzip -zipfile "$env:ProgramData\PS7x64.zip" -outpath "$env:ProgramData"
        Rename-Item "$env:ProgramData\PSPortable-master" "$env:ProgramData\PS7x64"
        Remove-Item "$env:ProgramData\PS7x64.zip" -Force

        #Pin shortcut to taskbar
        Invoke-Item "$env:ProgramData\PS7x64\PS7-x64\pwsh.exe.lnk"
        Function Show-Statement {
            Write-Host "
    ***************************************************
    *                                                 *
    *" -ForegroundColor Green -NoNewline
            Write-Host "  Pin the open PSPortable window to the Taskbar" -ForegroundColor Yellow -NoNewline
            Write-Host "  *
    *                                                 *
    ***************************************************
    " -ForegroundColor Green
        }; Show-Statement
    }
    catch {
        Write-Host $_.Exception.Message
    }
}