Write-Host "
There are two options when installing PSPortable. A Light and A Full Version.

Choosing the full version will install a lot of complimentary modules and will take much longer.
While the light version will only install a minimum set of modules for common admin tasks.

It is recommended to install the full version on a primary workstation and the light version on servers.

" -ForegroundColor Green
$Prompt = Read-Host "Type one of the options to choose which version to install. (Full\Light)"
switch ($prompt) {
    full {
        Set-ExecutionPolicy Unrestricted -Confirm:$false -Force -Scope CurrentUser
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        (Invoke-WebRequest https://raw.githubusercontent.com/TheTaylorLee/PSPortable/main/Deploy-PSPortable.ps1 -UseBasicParsing).content | Invoke-Expression
    }
    light {
        Set-ExecutionPolicy Unrestricted -Confirm:$false -Force -Scope CurrentUser
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        (Invoke-WebRequest https://raw.githubusercontent.com/TheTaylorLee/PSPortable/main/Deploy-PSPortableLight.ps1 -UseBasicParsing).content | Invoke-Expression
    }
    default {
        Write-Warning "You didn't type Light or Full. Try again."
    }
}