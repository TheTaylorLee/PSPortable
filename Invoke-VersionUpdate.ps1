#This Function is for use by the Packaged Microsoft Powershell Profile. It handles version upgrades when called.

Function Invoke-VersionUpdate {

    try {
        taskkill /im pwsh.exe /F
        taskkill /im windowsterminal.exe /F
        taskkill /im ConEMU.exe /F
        taskkill /im ConEMUC64.exe /F
    }
    catch {
    }

    Start-Sleep -Seconds 5

    #Remove old package
    #Remove this error action if having issues to potentionally find the problem
    Get-ChildItem $env:ProgramData\PS7x64 | Remove-Item -Recurse -Force -ErrorAction 'silentlycontinue'

    #Download new package as zip file
    Function Invoke-DLPSPortable {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $url = "https://github.com/thetaylorlee/psportable/archive/master.zip"
        $output = "$env:ProgramData\PS7x64.zip"
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($url, $output)
    }; Invoke-DLPSPortable

    #Unzip to path download package
    function Invoke-Unzip2 {
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

    Invoke-Unzip2 -zipfile "$env:ProgramData\PS7x64.zip" -outpath "$env:ProgramData"
    #Rename-Item "$env:ProgramData\PSPortable-master" "$env:ProgramData\PS7x64"
    Robocopy.exe $env:ProgramData\PSPortable-master $env:ProgramData\PS7x64 /mir /COPY:DATSO /r:1 /w:1
    Remove-Item "$env:ProgramData\PS7x64.zip" -Force
    Remove-Item "$env:ProgramData\PSPortable-master" -Force -Recurse

    #Pin shortcut to taskbar
    Invoke-Item "$env:ProgramData\PS7x64\PS7-x64\pwsh.exe.lnk"
    exit
}; Invoke-VersionUpdate