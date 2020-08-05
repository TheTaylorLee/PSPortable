@{
  GUID = '82b0bf19-c5cd-4c30-8db4-b458a4b84495'
  RootModule = './Microsoft.Teams.Config.psm1'
  ModuleVersion = '0.1.0'
  CompatiblePSEditions = 'Core', 'Desktop'
  Author="Microsoft Corporation"
  CompanyName="Microsoft Corporation"
  Copyright="Copyright (c) Microsoft Corporation.  All rights reserved."
  Description="Microsoft Teams Configuration PowerShell module"
  PowerShellVersion = '5.1'
  DotNetFrameworkVersion = '4.7.2'
  RequiredAssemblies = './bin/Microsoft.Teams.Config.private.dll'
  FormatsToProcess = './Microsoft.Teams.Config.format.ps1xml'
  CmdletsToExport = 'Get-CsBatchPolicyAssignmentOperation', 'Invoke-CsBatchPolicyAssignment', '*'
  AliasesToExport = '*'
  PrivateData = @{
    PSData = @{
      Tags = ''
      LicenseUri = ''
      ProjectUri = ''
      ReleaseNotes = ''
    }
  }
}
