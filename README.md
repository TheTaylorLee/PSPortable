# PSPortable

Deploys a portable PowerShell package with often used modules.

* *__To get started__*
  * Open an admin PowerShell prompt
  * Run the below function

```Powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
(invoke-webrequest https://raw.githubusercontent.com/TheTaylorLee/PSPortable/master/Deploy-PSPortable.ps1).content | Invoke-Expression
```

**Changelog**

     - 1.0.0 Added Version Control
     - 1.1.0 Updated the readme with a getting started function
     - 1.2.0 Updated the readme with a changelog