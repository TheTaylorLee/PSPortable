# PSPortable

Deploys a portable PowerShell package with often used modules. When updates are released, launching PSPortable will present a changelog and prompt to use update-console to update if desired.

* *__Install Oh-MyPosh__*
  * Skip if this is a server environment since oh-my-posh will not be used
  * Run from an admin pwsh prompt and not PowerShell

  ```powershell
  try{
  Remove-Item $env:POSH_PATH -Force -Recurse
  Uninstall-Module oh-my-posh -AllVersions
  } catch { }
  winget install JanDeDobbeleer.OhMyPosh -s winget
  ```

* *__Install PSPortable Full or Light__*
  * Open an admin PowerShell prompt
  * Run the below script to include all modules and update existing module that will be included
  * A full deploy is slow. It should be run rarely, such as on a primary workstation. The Light Version should be used more commonly.

  ```Powershell
  Set-ExecutionPolicy Unrestricted -confirm:$false -Force
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  (invoke-webrequest https://raw.githubusercontent.com/TheTaylorLee/PSPortable/master/Deploy-PSPortable.ps1 -usebasicparsing).content | Invoke-Expression
  ```

  * Or run the below script to include less modules (Light Version)
  <br><br/>
  > **Warning**
  > Do not run this script block if you ran the above script block.

   ```Powershell
   Set-ExecutionPolicy Unrestricted -confirm:$false -Force
   [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
   (invoke-webrequest https://raw.githubusercontent.com/TheTaylorLee/PSPortable/master/Deploy-PSPortableLight.ps1 -usebasicparsing).content | Invoke-Expression
   ```

* *__Using PSPortable or PSPortableLight in Terminal__*

    These steps offer a guide to use PSPortable or PSPortableLight in Windows Terminal as intended. These steps will install a Nerdfont and Git, so the Oh-My-Posh theme is properly presented.

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
