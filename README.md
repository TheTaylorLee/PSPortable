# PSPortable

Deploys a portable PowerShell package with often used modules. If you use this package, you will need to pay attention to the instructions under the fonts section.

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

* *__Fonts__* \
  This portable Powershell Package uses Oh-My-Posh. This means you will require a nerd font to not see question marks where symbols would be seen. Follow the below steps to install "Meslo LG M Regular Nerd Font Complete Mono". If you do not like that font you can get your own from https://www.nerdfonts.com/.

  * Open PSPortable or PSPortablelight
  * Run the function Install-Font
  * A window will pop-ip. Click install in that window.
  * Close the pop-up window
  * Right click the title bar of the open PWSH window and select properties
  * Click the font tab
  * Select "MesloLGM Nerd Font Mono" and hit ok
  * You are now done. If you are using windows terminal or another terminal, you will need to modify the default font there as well.