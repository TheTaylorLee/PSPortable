# PSPortable

Deploys a portable PowerShell package with often used modules. If you use this package, you will need to pay attention to the instructions under the fonts section.

<p align="Left">
<a href="https://open.vscode.dev/TheTaylorLee/PSPortable"><img src="https://open.vscode.dev/badges/open-in-vscode.svg"></a>
</p>

* *__To get started__*
  * Open an admin PowerShell prompt
  * Run the below script
  
  ```Powershell
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  (invoke-webrequest https://raw.githubusercontent.com/TheTaylorLee/PSPortable/master/Deploy-PSPortable.ps1 -usebasicparsing).content | Invoke-Expression
  ```

* *__To Upgrade__*
  * Open an admin PowerShell prompt
  * Run the below script
  
  ```Powershell
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  (invoke-webrequest https://raw.githubusercontent.com/TheTaylorLee/PSPortable/master/Invoke-VersionUpdate.ps1 -usebasicparsing).content | Invoke-Expression
  ```

* *__Using PSPortable or PSPortableLight in Terminal__* \

    These steps offer a guide to use PSPortable or PSPortableLight in Windows Terminal as intended. These steps will install a Nerdfont and Git, so the Oh-My-Posh theme is     properly presented.
    
  * Install Nerd Font, Git, and sign into Git account
  
  ```Powershell
  Install-Font
  Install-chocolatey
  choco install git
  git config --global user.name "account"
  git config --global user.email "email@site.com"
  ```
  
  * Terminal settings should be configured to your preference, [Example Settings](https://github.com/TheTaylorLee/PwshProfile/blob/main/WindowsTerminal/CustomSettings.json) 
    * Nerd Font must be specified in the PSPortable or PSPortableLight profile.

