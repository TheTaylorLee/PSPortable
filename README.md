# PSPortable

Deploys a portable PowerShell package with often used modules.

* *__To get started__*
  * Open an admin PowerShell prompt
  * Run the below function

```Powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
(invoke-webrequest https://raw.githubusercontent.com/TheTaylorLee/PSPortable/master/Deploy-PSPortable.ps1).content | Invoke-Expression
```

* *__To Upgrade__*
  * Open an admin PowerShell prompt
  * Run the below function

```Powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
(invoke-webrequest https://raw.githubusercontent.com/TheTaylorLee/PSPortable/master/Invoke-VersionUpdate.ps1).content | Invoke-Expression
```