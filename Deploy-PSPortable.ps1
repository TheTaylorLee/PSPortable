Function Deploy-PSPortable {

    #Remove old package
    if (Test-Path $env:ProgramData\PS7x64) {
        Remove-Item $env:ProgramData\PS7x64 -Recurse -Force
    }

    #Download new package as zip file
    Function Invoke-DLPSPortable {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $url = "https://github.com/thetaylorlee/psportable/archive/master.zip"
        $output = "$env:ProgramData\PS7x64.zip"
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($url, $output)
    }; Invoke-DLPSPortable

    #Unzip to path download package
    function Invoke-Unzip {
        <#
    .DESCRIPTION
    Provides robust zip file extraction by attempting 3 possible methods.

    .Parameter zipfile
    Specify the zipfile location and name

    .Parameter outpath
    Specify the extract path for extracted files

    .EXAMPLE
    Extracts folder.zip to c:\folder

    Invoke-Unzip -zipfile c:\folder.zip -outpath c:\folder

    .Link
    https://github.com/TheTaylorLee/AdminToolbox
    #>

        [cmdletbinding()]
        param(
            [string]$zipfile,
            [string]$outpath
        )


        if (Get-Command expand-archive -ErrorAction 'SilentlyContinue') {
            Expand-Archive -Path $zipfile -DestinationPath $outpath
        }



        else {
            try {
                #Allows for unzipping folders in older versions of powershell if .net 4.5 or newer exists
                Add-Type -AssemblyName System.IO.Compression.FileSystem
                [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
            }

            catch {
                #If .net 4.5 or newer not present, com classes are used. This process is slower.
                [void] (New-Item -Path $outpath -ItemType Directory -Force)
                $Shell = New-Object -com Shell.Application
                $Shell.Namespace($outpath).copyhere($Shell.NameSpace($zipfile).Items(), 4)
            }
        }
    }

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
    }
    Show-Statement

}; Deploy-PSPortable