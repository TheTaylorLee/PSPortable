# PSPortable

Deploys a portable PowerShell package with often used modules. When updates are released, launching PSPortable will present a changelog and prompt to use update-console to update if desired.

### Install Oh-MyPosh (Optional)
  * Skip if this is a server environment since oh-my-posh will not be used
  * Run from an admin pwsh prompt and not PowerShell

  ```powershell
  try{
  Remove-Item $env:POSH_PATH -Force -Recurse
  Uninstall-Module oh-my-posh -AllVersions
  } catch { }
  winget install JanDeDobbeleer.OhMyPosh -s winget
  ```

### Install PSPortable Full or Light
  * Open an admin PowerShell prompt
  * Run [this script](https://github.com/TheTaylorLee/PSPortable/blob/main/Deploy-Prompter.ps1) in PowerShell

### Using PSPortable or PSPortableLight in Terminal (Optional)
  - Install Nerd Font, Git, and sign into Git account

  ```Powershell
  Install-Font
  Install-chocolatey
  choco install git
  git config --global user.name "account"
  git config --global user.email "email@site.com"
  ```

  * Terminal settings should be configured to your preference, [Example Settings](https://github.com/TheTaylorLee/PwshProfile/blob/main/WindowsTerminal/CustomSettings.json)
    * Nerd Font must be specified in the PSPortable or PSPortableLight profile.

### Troubleshooting
  - If installing a module is blocked when running as administrator with the reason the command was not run as an administrator, first run this function to add a windows defender path exception.
  ```pwsh
  Add-MpPreference -ControlledFolderAccessAllowedApplications 'C:\ProgramData\PS7x64\PS7-x64\pwsh.exe'
  ```