
Function Invoke-Download {
    Param(
        [string]$Owner,
        [string]$Repository,
        [string]$Path,
        [string]$DestinationPath
    )

    $baseUri = "https://api.github.com/"
    $args = "repos/$Owner/$Repository/contents/$Path"
    $wr = Invoke-WebRequest -Uri $($baseuri + $args)
    $objects = $wr.Content | ConvertFrom-Json
    $files = $objects | where { $_.type -eq "file" } | select -exp download_url
    $directories = $objects | where { $_.type -eq "dir" }

    $directories | ForEach-Object {
        DownloadFilesFromRepo -Owner $Owner -Repository $Repository -Path $_.path -DestinationPath $($DestinationPath + $_.name)
    }


    if (-not (Test-Path $DestinationPath)) {
        # Destination path does not exist, let's create it
        try {
            New-Item -Path $DestinationPath -ItemType Directory -ErrorAction Stop
        }
        catch {
            throw "Could not create path '$DestinationPath'!"
        }
    }

    foreach ($file in $files) {
        $fileDestination = Join-Path $DestinationPath (Split-Path $file -Leaf)
        try {
            Invoke-WebRequest -Uri $file -OutFile $fileDestination -ErrorAction Stop -Verbose
            "Grabbed '$($file)' to '$fileDestination'"
        }
        catch {
            throw "Unable to download '$($file.path)'"
        }
    }

}

Remove-Item $env:ProgramData\PS7x64 -Recurse -Force

Invoke-Download -DestinationPath $env:ProgramData\PS7x64 -Owner TheTaylorLee -Repository PSPortable

Write-Host "Pin pwsh.exe.lnk to the Taskbar if desired from the opened explorer window" -ForegroundColor Green
Invoke-Item "$env:ProgramData\PS7x64\PS7-x64"