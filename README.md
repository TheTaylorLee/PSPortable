# PSPortable

Deploys a portable PowerShell package with often used modules.

* Open an admin powershell prompt
* Paste the contents of the Deploy-PSPortable.ps1 script into a powershell prompt

To get started run the following in an Administrative Powershell Prompt

```Powershell
(invoke-webrequest https://raw.githubusercontent.com/TheTaylorLee/PSPortable/master/Deploy-PSPortable.ps1).content | Invoke-Expression
```

**Changelog**

     - 1.0.0 Added Version Control
     - 1.1.0 Updated the readme with a getting started function
     - 1.2.0 Updated the readme with a changelog