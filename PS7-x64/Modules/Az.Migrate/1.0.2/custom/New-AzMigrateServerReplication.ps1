
# ----------------------------------------------------------------------------------
#
# Copyright Microsoft Corporation
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ----------------------------------------------------------------------------------

<#
.Synopsis
Starts replication for the specified server.
.Description
The New-AzMigrateServerReplication cmdlet starts the replication for a particular discovered server in the Azure Migrate project.
.Link
https://docs.microsoft.com/powershell/module/az.migrate/new-azmigrateserverreplication
#>
function New-AzMigrateServerReplication {
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20180110.IJob])]
    [CmdletBinding(DefaultParameterSetName = 'ByIdDefaultUser', PositionalBinding = $false)]
    param(
        [Parameter(ParameterSetName = 'ByIdDefaultUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByIdPowerUser', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the machine ID of the discovered server to be migrated.
        ${MachineId},

        [Parameter(ParameterSetName = 'ByInputObjectDefaultUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByInputObjectPowerUser', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api202001.IVMwareMachine]
        # Specifies the discovered server to be migrated. The server object can be retrieved using the Get-AzMigrateServer cmdlet.
        ${InputObject},

        [Parameter(ParameterSetName = 'ByIdPowerUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByInputObjectPowerUser', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20180110.IVMwareCbtDiskInput[]]
        # Specifies the disks on the source server to be included for replication.
        ${DiskToInclude},

        [Parameter(Mandatory)]
        [ValidateSet("NoLicenseType" , "WindowsServer")]
        [ArgumentCompleter( { "NoLicenseType" , "WindowsServer" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies if Azure Hybrid benefit is applicable for the source server to be migrated.
        ${LicenseType},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Resource Group id within the destination Azure subscription to which the server needs to be migrated.
        ${TargetResourceGroupId},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Virtual Network id within the destination Azure subscription to which the server needs to be migrated.
        ${TargetNetworkId},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Subnet name within the destination Virtual Netowk to which the server needs to be migrated.
        ${TargetSubnetName},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Mapping.
        ${ReplicationContainerMapping},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Account id.
        ${VMWarerunasaccountID},

        [Parameter(Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the name of the Azure VM to be created.
        ${TargetVMName},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the SKU of the Azure VM to be created.
        ${TargetVMSize},

        [Parameter(ParameterSetName = 'ByIdDefaultUser')]
        [Parameter(ParameterSetName = 'ByInputObjectDefaultUser')]
        [Parameter(ParameterSetName = 'ByIdPowerUser')]
        [Parameter(ParameterSetName = 'ByInputObjectPowerUser')]
        [ValidateSet("true" , "false")]
        [ArgumentCompleter( { "true" , "false" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies if replication be auto-repaired in case change tracking is lost for the source server under replication.
        ${PerformAutoResync},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Availability Set to be used for VM creationSpecifies the Availability Set to be used for VM creation.
        ${TargetAvailabilitySet},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Availability Zone to be used for VM creation.
        ${TargetAvailabilityZone},

        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the storage account to be used for boot diagnostics.
        ${TargetBootDiagnosticsStorageAccount},

        [Parameter(ParameterSetName = 'ByIdDefaultUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByInputObjectDefaultUser', Mandatory)]
        [ValidateSet("Standard_LRS" , "Premium_LRS", "StandardSSD_LRS")]
        [ArgumentCompleter( { "Standard_LRS" , "Premium_LRS", "StandardSSD_LRS" })]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the type of disks to be used for the Azure VM.
        ${DiskType},
        
        [Parameter(ParameterSetName = 'ByIdDefaultUser', Mandatory)]
        [Parameter(ParameterSetName = 'ByInputObjectDefaultUser', Mandatory)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Operating System disk for the source server to be migrated.
        ${OSDiskID},

        [Parameter(ParameterSetName = 'ByIdDefaultUser')]
        [Parameter(ParameterSetName = 'ByInputObjectDefaultUser')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the disk encyption set to be used.
        ${DiskEncryptionSetID},
    
        [Parameter()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.DefaultInfo(Script = '(Get-AzContext).Subscription.Id')]
        [System.String]
        # Azure Subscription ID.
        ${SubscriptionId},

        [Parameter()]
        [Alias('AzureRMContext', 'AzureCredential')]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Azure')]
        [System.Management.Automation.PSObject]
        # The credentials, account, tenant, and subscription used for communication with Azure.
        ${DefaultProfile},
    
        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Wait for .NET debugger to attach
        ${Break},
    
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be appended to the front of the pipeline
        ${HttpPipelineAppend},
    
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be prepended to the front of the pipeline
        ${HttpPipelinePrepend},
    
        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [System.Uri]
        # The URI for the proxy server to use
        ${Proxy},
    
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [System.Management.Automation.PSCredential]
        # Credentials for a proxy server to use for the remote call
        ${ProxyCredential},
    
        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Use the default credentials for the proxy
        ${ProxyUseDefaultCredentials}
    )
    
    process {
        
        $parameterSet = $PSCmdlet.ParameterSetName
        $HasRunAsAccountId = $PSBoundParameters.ContainsKey('VMWarerunasaccountID')
        $HasTargetAVSet = $PSBoundParameters.ContainsKey('TargetAvailabilitySet')
        $HasTargetAVZone = $PSBoundParameters.ContainsKey('TargetAvailabilityZone')
        $HasTargetBDStorage = $PSBoundParameters.ContainsKey('TargetBootDiagnosticsStorageAccount')
        $HasResync = $PSBoundParameters.ContainsKey('PerformAutoResync')
        $HasDiskEncryptionSetID = $PSBoundParameters.ContainsKey('DiskEncryptionSetID')
        $HasTargetVMSize = $PSBoundParameters.ContainsKey('TargetVMSize')

        $null = $PSBoundParameters.Remove('ReplicationContainerMapping')
        $null = $PSBoundParameters.Remove('VMWarerunasaccountID')
        $null = $PSBoundParameters.Remove('TargetAvailabilitySet')
        $null = $PSBoundParameters.Remove('TargetAvailabilityZone')
        $null = $PSBoundParameters.Remove('TargetBootDiagnosticsStorageAccount')
        $null = $PSBoundParameters.Remove('MachineId')
        $null = $PSBoundParameters.Remove('DiskToInclude')
        $null = $PSBoundParameters.Remove('TargetResourceGroupId')
        $null = $PSBoundParameters.Remove('TargetNetworkId')
        $null = $PSBoundParameters.Remove('TargetSubnetName')
        $null = $PSBoundParameters.Remove('TargetVMName')
        $null = $PSBoundParameters.Remove('TargetVMSize')
        $null = $PSBoundParameters.Remove('PerformAutoResync')
        $null = $PSBoundParameters.Remove('DiskType')
        $null = $PSBoundParameters.Remove('OSDiskID')
        $null = $PSBoundParameters.Remove('LicenseType')
        $null = $PSBoundParameters.Remove('DiskEncryptionSetID')

        $null = $PSBoundParameters.Remove('MachineId')
        $null = $PSBoundParameters.Remove('InputObject')

        $validLicenseSpellings = @{ 
            NoLicenseType = "NoLicenseType";
            WindowsServer = "WindowsServer"
        }
        $LicenseType = $validLicenseSpellings[$LicenseType]

        if ($parameterSet -match "DefaultUser") {
            $validDiskTypeSpellings = @{ 
                Standard_LRS    = "Standard_LRS";
                Premium_LRS     = "Premium_LRS";
                StandardSSD_LRS = "StandardSSD_LRS"
            }
            $DiskType = $validDiskTypeSpellings[$DiskType]
            
            if ($parameterSet -eq "ByInputObjectDefaultUser") {
                foreach ($onPremDisk in $InputObject.Disk) {
                    if ($onPremDisk.Uuid -eq $OSDiskID) {
                        $OSDiskID = $onPremDisk.Uuid
                        break
                    }
                }
            }
        }
           
        if (($parameterSet -match 'Id') -or ($parameterSet -match 'InputObject')) {
            if (($parameterSet -match 'InputObject')) {
                $MachineId = $InputObject.Id
            }
            $MachineIdArray = $MachineId.Split("/")
            $SiteType = $MachineIdArray[7]
            $SiteName = $MachineIdArray[8]
            $ResourceGroupName = $MachineIdArray[4]
            $MachineName = $MachineIdArray[10]

            $null = $PSBoundParameters.Add('ResourceGroupName', $ResourceGroupName)
            $null = $PSBoundParameters.Add('SiteName', $SiteName)
            $siteObject = Az.Migrate\Get-AzMigrateSite @PSBoundParameters
            if ($siteObject -and ($siteObject.Count -ge 1)) {
                $ProjectName = $siteObject.DiscoverySolutionId.Split("/")[8]
            }
            else {
                throw "Site not found"
            }
                
            $null = $PSBoundParameters.Remove('ResourceGroupName')
            $null = $PSBoundParameters.Remove('SiteName')

            $null = $PSBoundParameters.Add("ResourceGroupName", $ResourceGroupName)
            $null = $PSBoundParameters.Add("Name", "Servers-Migration-ServerMigration")
            $null = $PSBoundParameters.Add("MigrateProjectName", $ProjectName)
                
            $solution = Az.Migrate\Get-AzMigrateSolution @PSBoundParameters
            $VaultName = $solution.DetailExtendedDetail.AdditionalProperties.vaultId.Split("/")[8]
                
            $null = $PSBoundParameters.Remove('ResourceGroupName')
            $null = $PSBoundParameters.Remove("Name")
            $null = $PSBoundParameters.Remove("MigrateProjectName")
        }
        if ($SiteType -ne "VMwareSites") {
            throw "Provider not supported"
        }
           
        # in case if the credential type is null which is in case of older appliances or
        # in case if the credential type is vmwarefabric type which is for newer appliances
        # send that run as account id only.
        # for vCenter there will be always one credential so returning the first one which matches it.
        # when multiple vCenter support comes then this might not work and need to redesign this.
        if (!$HasRunAsAccountId) {
            $null = $PSBoundParameters.Add('ResourceGroupName', $ResourceGroupName)
            $null = $PSBoundParameters.Add('SiteName', $SiteName)
            $runAsAccounts = Az.Migrate\Get-AzMigrateRunAsAccount @PSBoundParameters
            $VMWarerunasaccountID = ""
            foreach ($account in $runAsAccounts) {
                if (($null -eq $account.CredentialType) -or ($account.CredentialType -eq "VMwareFabric")) {
                    $VMWarerunasaccountID = $account.Id
                    break
                }
            }
            if ($VMWarerunasaccountID -eq "") {
                throw "Run As Account missing"
            }

            $null = $PSBoundParameters.Remove('ResourceGroupName')
            $null = $PSBoundParameters.Remove('SiteName')
        }

        $policyName = "migrate" + $SiteName + "policy"
        $null = $PSBoundParameters.Add('ResourceGroupName', $ResourceGroupName)
        $null = $PSBoundParameters.Add('ResourceName', $VaultName)
        $null = $PSBoundParameters.Add('PolicyName', $policyName)
        $policyObj = Az.Migrate\Get-AzMigrateReplicationPolicy @PSBoundParameters -ErrorVariable notPresent -ErrorAction SilentlyContinue
        if ($policyObj -and ($policyObj.Count -ge 1)) {
            $PolicyId = $policyObj.Id
        }
        else {
            throw "The replication infrastructure is not initialized. Run the initialize-azmigratereplicationinfrastructure script again."
        }
        $null = $PSBoundParameters.Remove('ResourceGroupName')
        $null = $PSBoundParameters.Remove('ResourceName')
        $null = $PSBoundParameters.Remove('PolicyName')

        $null = $PSBoundParameters.Add('ResourceGroupName', $ResourceGroupName)
        $null = $PSBoundParameters.Add('ResourceName', $VaultName)
        $allFabrics = Az.Migrate\Get-AzMigrateReplicationFabric @PSBoundParameters
        $FabricName = ""
        if ($allFabrics -and ($allFabrics.length -gt 0)) {
            foreach ($fabric in $allFabrics) {
                if (($fabric.Property.CustomDetail.InstanceType -ceq "VMwareV2") -and ($fabric.Property.CustomDetail.VmwareSiteId.Split("/")[8] -ceq $SiteName)) {
                    $FabricName = $fabric.Name
                    break
                }
            }
        }
        if ($FabricName -eq "") {
            throw "Fabric not found for given resource group."
        }
                
        $null = $PSBoundParameters.Add('FabricName', $FabricName)
        $peContainers = Az.Migrate\Get-AzMigrateReplicationProtectionContainer @PSBoundParameters
        $ProtectionContainerName = ""
        if ($peContainers -and ($peContainers.length -gt 0)) {
            $ProtectionContainerName = $peContainers[0].Name
        }

        if ($ProtectionContainerName -eq "") {
            throw "Container not found for given resource group."
        }

        $mappingName = "containermapping"
        $null = $PSBoundParameters.Add('MappingName', $mappingName)
        $null = $PSBoundParameters.Add("ProtectionContainerName", $ProtectionContainerName)

        $mappingObject = Az.Migrate\Get-AzMigrateReplicationProtectionContainerMapping @PSBoundParameters -ErrorVariable notPresent -ErrorAction SilentlyContinue
        if ($mappingObject -and ($mappingObject.Count -ge 1)) {
            $TargetRegion = $mappingObject.ProviderSpecificDetail.TargetLocation
        }
        else {
            throw "The replication infrastructure is not initialized. Run the initialize-azmigratereplicationinfrastructure script again."
        }
        $null = $PSBoundParameters.Remove('MappingName')

        # Validate sku size
        $hasAzComputeModule = $true
        try { Import-Module Az.Compute }catch { $hasAzComputeModule = $false }
        if ($hasAzComputeModule -and $HasTargetVMSize) {
            $null = $PSBoundParameters.Remove("ProtectionContainerName")
            $null = $PSBoundParameters.Remove("FabricName")
            $null = $PSBoundParameters.Remove('ResourceGroupName')
            $null = $PSBoundParameters.Remove('ResourceName')
            $null = $PSBoundParameters.Remove('SubscriptionId')
            $null = $PSBoundParameters.Add('Location', $TargetRegion)
            $allAvailableSkus = Get-AzVMSize @PSBoundParameters -ErrorVariable notPresent -ErrorAction SilentlyContinue
            if ($null -ne $allAvailableSkus) {
                $matchingComputeSku = $allAvailableSkus | Where-Object { $_.Name -eq $TargetVMSize }
                if ($null -ne $matchingComputeSku) {
                    $TargetVMSize = $matchingComputeSku.Name
                }
            }

            $null = $PSBoundParameters.Remove('Location')
            $null = $PSBoundParameters.Add("ProtectionContainerName", $ProtectionContainerName)
            $null = $PSBoundParameters.Add('FabricName', $FabricName)
            $null = $PSBoundParameters.Add("ResourceGroupName", $ResourceGroupName)
            $null = $PSBoundParameters.Add('ResourceName', $VaultName)
            $null = $PSBoundParameters.Add('SubscriptionId', $SubscriptionId)
        }

        $HashCodeInput = $SiteName + $TargetRegion
        $Source = @"
using System;
public class HashFunctions
{
public static int hashForArtifact(String artifact)
{
        int hash = 0;
        int al = artifact.Length;
        int tl = 0;
        char[] ac = artifact.ToCharArray();
        while (tl < al)
        {
            hash = ((hash << 5) - hash) + ac[tl++] | 0;
        }
        return Math.Abs(hash);
}
}
"@
        Add-Type -TypeDefinition $Source -Language CSharp
        $hash = [HashFunctions]::hashForArtifact($HashCodeInput)

        $LogStorageAccountID = "/subscriptions/" + $SubscriptionId + "/resourceGroups/" +
        $ResourceGroupName + "/providers/Microsoft.Storage/storageAccounts/migratelsa" + $hash
        $LogStorageAccountSas = "migratelsa" + $hash + '-cacheSas'
        if (!$HasTargetBDStorage) {
            $TargetBootDiagnosticsStorageAccount = $LogStorageAccountID
        }

        # Storage accounts need to be in the same subscription as that of the VM.
        if (($null -ne $TargetBootDiagnosticsStorageAccount) -and ($TargetBootDiagnosticsStorageAccount.length -gt 1)) {
            $TargetBDSASubscriptionId = $TargetBootDiagnosticsStorageAccount.Split('/')[2]
            $TargetSubscriptionId = $TargetResourceGroupId.Split('/')[2]
            if ($TargetBDSASubscriptionId -ne $TargetSubscriptionId) {
                $TargetBootDiagnosticsStorageAccount = $null
            }
        }
            
        if (!$HasResync) {
            $PerformAutoResync = "true"
        }
        $validBooleanSpellings = @{ 
            true  = "true";
            false = "false"
        }
        $PerformAutoResync = $validBooleanSpellings[$PerformAutoResync]

        $null = $PSBoundParameters.Add("MigrationItemName", $MachineName)
        $null = $PSBoundParameters.Add("PolicyId", $PolicyId)

        $ProviderSpecificDetails = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20180110.VMwareCbtEnableMigrationInput]::new()
        $ProviderSpecificDetails.DataMoverRunAsAccountId = $VMWarerunasaccountID
        $ProviderSpecificDetails.SnapshotRunAsAccountId = $VMWarerunasaccountID
        $ProviderSpecificDetails.InstanceType = 'VMwareCbt'
        $ProviderSpecificDetails.LicenseType = $LicenseType
        $ProviderSpecificDetails.PerformAutoResync = $PerformAutoResync
        if ($HasTargetAVSet) {
            $ProviderSpecificDetails.TargetAvailabilitySetId = $TargetAvailabilitySet
        }
        if ($HasTargetAVZone) {
            $ProviderSpecificDetails.TargetAvailabilityZone = $TargetAvailabilityZone
        }
        $ProviderSpecificDetails.TargetBootDiagnosticsStorageAccountId = $TargetBootDiagnosticsStorageAccount
        $ProviderSpecificDetails.TargetNetworkId = $TargetNetworkId
        $ProviderSpecificDetails.TargetResourceGroupId = $TargetResourceGroupId
        $ProviderSpecificDetails.TargetSubnetName = $TargetSubnetName
        $ProviderSpecificDetails.TargetVMName = $TargetVMName
        if ($HasTargetVMSize) { $ProviderSpecificDetails.TargetVMSize = $TargetVMSize }
        $ProviderSpecificDetails.VmwareMachineId = $MachineId


        if ($parameterSet -match 'DefaultUser') {
            [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20180110.IVMwareCbtDiskInput[]]$DiskToInclude = @()
            if ($parameterSet -eq 'ByInputObjectDefaultUser') {
                foreach ($onPremDisk in $InputObject.Disk) {
                    if ($onPremDisk.Uuid -ne $OSDiskID) {
                        $DiskObject = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20180110.VMwareCbtDiskInput]::new()
                        $DiskObject.DiskId = $onPremDisk.Uuid
                        $DiskObject.DiskType = "Standard_LRS"
                        $DiskObject.IsOSDisk = "false"
                        $DiskObject.LogStorageAccountSasSecretName = $LogStorageAccountSas
                        $DiskObject.LogStorageAccountId = $LogStorageAccountID
                        if ($HasDiskEncryptionSetID) {
                            $DiskObject.DiskEncryptionSetId = $DiskEncryptionSetID
                        }
                        $DiskToInclude += $DiskObject
                    }
                }
            }
            $DiskObject = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20180110.VMwareCbtDiskInput]::new()
            $DiskObject.DiskId = $OSDiskID
            $DiskObject.DiskType = $DiskType
            $DiskObject.IsOSDisk = "true"
            $DiskObject.LogStorageAccountSasSecretName = $LogStorageAccountSas
            $DiskObject.LogStorageAccountId = $LogStorageAccountID
            if ($HasDiskEncryptionSetID) {
                $DiskObject.DiskEncryptionSetId = $DiskEncryptionSetID
            }
                
            $DiskToInclude += $DiskObject
            $ProviderSpecificDetails.DisksToInclude = $DiskToInclude
                
        }
        else {
            foreach ($DiskObject in $DiskToInclude) {
                $DiskObject.LogStorageAccountSasSecretName = $LogStorageAccountSas
                $DiskObject.LogStorageAccountId = $LogStorageAccountID
            }
            $ProviderSpecificDetails.DisksToInclude = $DiskToInclude
        }

        $null = $PSBoundParameters.add('ProviderSpecificDetail', $ProviderSpecificDetails)
        $null = $PSBoundParameters.Add('NoWait', $true)
        $output = Az.Migrate.internal\New-AzMigrateReplicationMigrationItem @PSBoundParameters
        $JobName = $output.Target.Split("/")[12].Split("?")[0]
        $null = $PSBoundParameters.Remove('NoWait')
        $null = $PSBoundParameters.Remove('ProviderSpecificDetail')
        $null = $PSBoundParameters.Remove("ResourceGroupName")
        $null = $PSBoundParameters.Remove("ResourceName")
        $null = $PSBoundParameters.Remove("FabricName")
        $null = $PSBoundParameters.Remove("MigrationItemName")
        $null = $PSBoundParameters.Remove("ProtectionContainerName")
        $null = $PSBoundParameters.Remove("PolicyId")

        $null = $PSBoundParameters.Add('JobName', $JobName)
        $null = $PSBoundParameters.Add('ResourceName', $VaultName)
        $null = $PSBoundParameters.Add('ResourceGroupName', $ResourceGroupName)
        
        return Az.Migrate.internal\Get-AzMigrateReplicationJob @PSBoundParameters
        
    }

}   
# SIG # Begin signature block
# MIIjkgYJKoZIhvcNAQcCoIIjgzCCI38CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBUHk3x0KS9Q847
# 913Qi1KjTAmHgL0OYtEJhiFwoqpaZaCCDYEwggX/MIID56ADAgECAhMzAAAB32vw
# LpKnSrTQAAAAAAHfMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjAxMjE1MjEzMTQ1WhcNMjExMjAyMjEzMTQ1WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQC2uxlZEACjqfHkuFyoCwfL25ofI9DZWKt4wEj3JBQ48GPt1UsDv834CcoUUPMn
# s/6CtPoaQ4Thy/kbOOg/zJAnrJeiMQqRe2Lsdb/NSI2gXXX9lad1/yPUDOXo4GNw
# PjXq1JZi+HZV91bUr6ZjzePj1g+bepsqd/HC1XScj0fT3aAxLRykJSzExEBmU9eS
# yuOwUuq+CriudQtWGMdJU650v/KmzfM46Y6lo/MCnnpvz3zEL7PMdUdwqj/nYhGG
# 3UVILxX7tAdMbz7LN+6WOIpT1A41rwaoOVnv+8Ua94HwhjZmu1S73yeV7RZZNxoh
# EegJi9YYssXa7UZUUkCCA+KnAgMBAAGjggF+MIIBejAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUOPbML8IdkNGtCfMmVPtvI6VZ8+Mw
# UAYDVR0RBEkwR6RFMEMxKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1
# ZXJ0byBSaWNvMRYwFAYDVQQFEw0yMzAwMTIrNDYzMDA5MB8GA1UdIwQYMBaAFEhu
# ZOVQBdOCqhc3NyK1bajKdQKVMFQGA1UdHwRNMEswSaBHoEWGQ2h0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY0NvZFNpZ1BDQTIwMTFfMjAxMS0w
# Ny0wOC5jcmwwYQYIKwYBBQUHAQEEVTBTMFEGCCsGAQUFBzAChkVodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY0NvZFNpZ1BDQTIwMTFfMjAx
# MS0wNy0wOC5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAnnqH
# tDyYUFaVAkvAK0eqq6nhoL95SZQu3RnpZ7tdQ89QR3++7A+4hrr7V4xxmkB5BObS
# 0YK+MALE02atjwWgPdpYQ68WdLGroJZHkbZdgERG+7tETFl3aKF4KpoSaGOskZXp
# TPnCaMo2PXoAMVMGpsQEQswimZq3IQ3nRQfBlJ0PoMMcN/+Pks8ZTL1BoPYsJpok
# t6cql59q6CypZYIwgyJ892HpttybHKg1ZtQLUlSXccRMlugPgEcNZJagPEgPYni4
# b11snjRAgf0dyQ0zI9aLXqTxWUU5pCIFiPT0b2wsxzRqCtyGqpkGM8P9GazO8eao
# mVItCYBcJSByBx/pS0cSYwBBHAZxJODUqxSXoSGDvmTfqUJXntnWkL4okok1FiCD
# Z4jpyXOQunb6egIXvkgQ7jb2uO26Ow0m8RwleDvhOMrnHsupiOPbozKroSa6paFt
# VSh89abUSooR8QdZciemmoFhcWkEwFg4spzvYNP4nIs193261WyTaRMZoceGun7G
# CT2Rl653uUj+F+g94c63AhzSq4khdL4HlFIP2ePv29smfUnHtGq6yYFDLnT0q/Y+
# Di3jwloF8EWkkHRtSuXlFUbTmwr/lDDgbpZiKhLS7CBTDj32I0L5i532+uHczw82
# oZDmYmYmIUSMbZOgS65h797rj5JJ6OkeEUJoAVwwggd6MIIFYqADAgECAgphDpDS
# AAAAAAADMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0
# ZSBBdXRob3JpdHkgMjAxMTAeFw0xMTA3MDgyMDU5MDlaFw0yNjA3MDgyMTA5MDla
# MH4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMT
# H01pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTEwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCr8PpyEBwurdhuqoIQTTS68rZYIZ9CGypr6VpQqrgG
# OBoESbp/wwwe3TdrxhLYC/A4wpkGsMg51QEUMULTiQ15ZId+lGAkbK+eSZzpaF7S
# 35tTsgosw6/ZqSuuegmv15ZZymAaBelmdugyUiYSL+erCFDPs0S3XdjELgN1q2jz
# y23zOlyhFvRGuuA4ZKxuZDV4pqBjDy3TQJP4494HDdVceaVJKecNvqATd76UPe/7
# 4ytaEB9NViiienLgEjq3SV7Y7e1DkYPZe7J7hhvZPrGMXeiJT4Qa8qEvWeSQOy2u
# M1jFtz7+MtOzAz2xsq+SOH7SnYAs9U5WkSE1JcM5bmR/U7qcD60ZI4TL9LoDho33
# X/DQUr+MlIe8wCF0JV8YKLbMJyg4JZg5SjbPfLGSrhwjp6lm7GEfauEoSZ1fiOIl
# XdMhSz5SxLVXPyQD8NF6Wy/VI+NwXQ9RRnez+ADhvKwCgl/bwBWzvRvUVUvnOaEP
# 6SNJvBi4RHxF5MHDcnrgcuck379GmcXvwhxX24ON7E1JMKerjt/sW5+v/N2wZuLB
# l4F77dbtS+dJKacTKKanfWeA5opieF+yL4TXV5xcv3coKPHtbcMojyyPQDdPweGF
# RInECUzF1KVDL3SV9274eCBYLBNdYJWaPk8zhNqwiBfenk70lrC8RqBsmNLg1oiM
# CwIDAQABo4IB7TCCAekwEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFEhuZOVQ
# BdOCqhc3NyK1bajKdQKVMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1Ud
# DwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFHItOgIxkEO5FAVO
# 4eqnxzHRI4k0MFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwubWljcm9zb2Z0
# LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcmwwXgYIKwYBBQUHAQEEUjBQME4GCCsGAQUFBzAChkJodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcnQwgZ8GA1UdIASBlzCBlDCBkQYJKwYBBAGCNy4DMIGDMD8GCCsGAQUFBwIB
# FjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2RvY3MvcHJpbWFyeWNw
# cy5odG0wQAYIKwYBBQUHAgIwNB4yIB0ATABlAGcAYQBsAF8AcABvAGwAaQBjAHkA
# XwBzAHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJKoZIhvcNAQELBQADggIBAGfyhqWY
# 4FR5Gi7T2HRnIpsLlhHhY5KZQpZ90nkMkMFlXy4sPvjDctFtg/6+P+gKyju/R6mj
# 82nbY78iNaWXXWWEkH2LRlBV2AySfNIaSxzzPEKLUtCw/WvjPgcuKZvmPRul1LUd
# d5Q54ulkyUQ9eHoj8xN9ppB0g430yyYCRirCihC7pKkFDJvtaPpoLpWgKj8qa1hJ
# Yx8JaW5amJbkg/TAj/NGK978O9C9Ne9uJa7lryft0N3zDq+ZKJeYTQ49C/IIidYf
# wzIY4vDFLc5bnrRJOQrGCsLGra7lstnbFYhRRVg4MnEnGn+x9Cf43iw6IGmYslmJ
# aG5vp7d0w0AFBqYBKig+gj8TTWYLwLNN9eGPfxxvFX1Fp3blQCplo8NdUmKGwx1j
# NpeG39rz+PIWoZon4c2ll9DuXWNB41sHnIc+BncG0QaxdR8UvmFhtfDcxhsEvt9B
# xw4o7t5lL+yX9qFcltgA1qFGvVnzl6UJS0gQmYAf0AApxbGbpT9Fdx41xtKiop96
# eiL6SJUfq/tHI4D1nvi/a7dLl+LrdXga7Oo3mXkYS//WsyNodeav+vyL6wuA6mk7
# r/ww7QRMjt/fdW1jkT3RnVZOT7+AVyKheBEyIXrvQQqxP/uozKRdwaGIm1dxVk5I
# RcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIVZzCCFWMCAQEwgZUwfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAd9r8C6Sp0q00AAAAAAB3zAN
# BglghkgBZQMEAgEFAKCBrjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgp+86fq4p
# 3m4XBUYhm4wQEi6aozXKLinZWWis2FctwtkwQgYKKwYBBAGCNwIBDDE0MDKgFIAS
# AE0AaQBjAHIAbwBzAG8AZgB0oRqAGGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbTAN
# BgkqhkiG9w0BAQEFAASCAQB3lWYVNsD4wKRSZs+eFG8oK1pcy8ZgJxbiplldBGJj
# 11NTqd1+ACFRTAQIprYnjqn/NTNFCDsKHDk33H9dX8OzJedM70zzqIvPVYyw9OS1
# 4SaoZxq2FTEls6lNGm5Z7D0xi0IoO3ARPRB0eoA+Neh6Ug6aY51P+HAu28YaLJpx
# TqPgq+t2RC0gBOeSjHMBhEPmw/PdtaH0tMtVHYIWgXGZ2WjXcb73Px2PlnDFh6Oy
# KSTcPWvDt8eTZo55xv4UrpVBat0qXxVDph3kDnyrNTDtBdtTmSk7R62jxXA9uobD
# vYBJjDHKOwQCK0bGyFLvZAx6amVlvN5FcHkEX+zLgN2woYIS8TCCEu0GCisGAQQB
# gjcDAwExghLdMIIS2QYJKoZIhvcNAQcCoIISyjCCEsYCAQMxDzANBglghkgBZQME
# AgEFADCCAVUGCyqGSIb3DQEJEAEEoIIBRASCAUAwggE8AgEBBgorBgEEAYRZCgMB
# MDEwDQYJYIZIAWUDBAIBBQAEIPTLEAdoxVAJRMBQKFTO+618/N2a3qTQODl+7pDz
# CKsiAgZgifnyIkoYEzIwMjEwNTIwMDk0MzQzLjE0M1owBIACAfSggdSkgdEwgc4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKTAnBgNVBAsTIE1p
# Y3Jvc29mdCBPcGVyYXRpb25zIFB1ZXJ0byBSaWNvMSYwJAYDVQQLEx1UaGFsZXMg
# VFNTIEVTTjo2MEJDLUUzODMtMjYzNTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgU2VydmljZaCCDkQwggT1MIID3aADAgECAhMzAAABWiy5bkQ0y28oAAAA
# AAFaMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEw
# MB4XDTIxMDExNDE5MDIxNloXDTIyMDQxMTE5MDIxNlowgc4xCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVy
# YXRpb25zIFB1ZXJ0byBSaWNvMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjo2MEJD
# LUUzODMtMjYzNTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2Vydmlj
# ZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALC9XBxXDa0nCK70Hf+G
# ih6NxRl1mAhzFJdok8bs3xpJ87TM28rEeHkZAaE+Kb9Gi9UvTpQ3zrEWyWSpIQky
# xv/Wf0cIhA1mJOqyu20TN3l96ZvgzYrzO/rQlPvbKW79oAO4+YFsekQCtrzM9hQo
# S5BYGwPh9Qz66BuSxH9QweywNBQsjkVoikpBxkS+EXSIzpba2afvnRMX7LLe2ery
# c+PlPXmTSOfH1WNykc25u9zo6ZX0gAd4jUpBzdMLnHCtE62bL2PO00cmAJsitqga
# ov+3lFrfd0sPACwTGO9iymlJlb2savwjqSnj5RzG4RxG6rU2i7etbnQTozR73OHM
# GOUCAwEAAaOCARswggEXMB0GA1UdDgQWBBRkcyU/9RyPkn7QBoXZOTQ8wN4xZzAf
# BgNVHSMEGDAWgBTVYzpcijGQ80N7fEYbxTNoWoVtVTBWBgNVHR8ETzBNMEugSaBH
# hkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNU
# aW1TdGFQQ0FfMjAxMC0wNy0wMS5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUF
# BzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1RpbVN0
# YVBDQV8yMDEwLTA3LTAxLmNydDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoGCCsG
# AQUFBwMIMA0GCSqGSIb3DQEBCwUAA4IBAQAAAG3sfFgbUiw4gWMV8VOxlbIG/CIM
# SiciDtIZnPL84OMN4lJeV5LeJr+HYBcox5ruWZm49K29iBmJv6ViXMtP81pYZ1EF
# M7306Y+zLIh/tS574PeWsHvPD0QOxQ4HOM2GNPvFAdUvo8z5pgV/5E+lPu61uUCI
# BTDESiHO+N7ragqb3METPqRKPLNAJcKPDcalKznmGPlnzY6P1zop/7a90VcBHRKK
# Q/hTvn/8C8Y6b+Mvk5kYJh67KNbVVcuuBWyFSMZTHGenHnuHVg9svH7+lm/V/wIb
# ZUKKJJO0HQmyodySeD/JLC7NNsDYRpFN+29dLRtx0eWyZosJmT8qKbBIMIIGcTCC
# BFmgAwIBAgIKYQmBKgAAAAAAAjANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJv
# b3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIwMTAwHhcNMTAwNzAxMjEzNjU1WhcN
# MjUwNzAxMjE0NjU1WjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3Rv
# bjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
# aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDCCASIw
# DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKkdDbx3EYo6IOz8E5f1+n9plGt0
# VBDVpQoAgoX77XxoSyxfxcPlYcJ2tz5mK1vwFVMnBDEfQRsalR3OCROOfGEwWbEw
# RA/xYIiEVEMM1024OAizQt2TrNZzMFcmgqNFDdDq9UeBzb8kYDJYYEbyWEeGMoQe
# dGFnkV+BVLHPk0ySwcSmXdFhE24oxhr5hoC732H8RsEnHSRnEnIaIYqvS2SJUGKx
# Xf13Hz3wV3WsvYpCTUBR0Q+cBj5nf/VmwAOWRH7v0Ev9buWayrGo8noqCjHw2k4G
# kbaICDXoeByw6ZnNPOcvRLqn9NxkvaQBwSAJk3jN/LzAyURdXhacAQVPIk0CAwEA
# AaOCAeYwggHiMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBTVYzpcijGQ80N7
# fEYbxTNoWoVtVTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMC
# AYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvX
# zpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20v
# cGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYI
# KwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNydDCBoAYDVR0g
# AQH/BIGVMIGSMIGPBgkrBgEEAYI3LgMwgYEwPQYIKwYBBQUHAgEWMWh0dHA6Ly93
# d3cubWljcm9zb2Z0LmNvbS9QS0kvZG9jcy9DUFMvZGVmYXVsdC5odG0wQAYIKwYB
# BQUHAgIwNB4yIB0ATABlAGcAYQBsAF8AUABvAGwAaQBjAHkAXwBTAHQAYQB0AGUA
# bQBlAG4AdAAuIB0wDQYJKoZIhvcNAQELBQADggIBAAfmiFEN4sbgmD+BcQM9naOh
# IW+z66bM9TG+zwXiqf76V20ZMLPCxWbJat/15/B4vceoniXj+bzta1RXCCtRgkQS
# +7lTjMz0YBKKdsxAQEGb3FwX/1z5Xhc1mCRWS3TvQhDIr79/xn/yN31aPxzymXlK
# kVIArzgPF/UveYFl2am1a+THzvbKegBvSzBEJCI8z+0DpZaPWSm8tv0E4XCfMkon
# /VWvL/625Y4zu2JfmttXQOnxzplmkIz/amJ/3cVKC5Em4jnsGUpxY517IW3DnKOi
# PPp/fZZqkHimbdLhnPkd/DjYlPTGpQqWhqS9nhquBEKDuLWAmyI4ILUl5WTs9/S/
# fmNZJQ96LjlXdqJxqgaKD4kWumGnEcua2A5HmoDF0M2n0O99g/DhO3EJ3110mCII
# YdqwUB5vvfHhAN/nMQekkzr3ZUd46PioSKv33nJ+YWtvd6mBy6cJrDm77MbL2IK0
# cs0d9LiFAR6A+xuJKlQ5slvayA1VmXqHczsI5pgt6o3gMy4SKfXAL1QnIffIrE7a
# KLixqduWsqdCosnPGUFN4Ib5KpqjEWYw07t0MkvfY3v1mYovG8chr1m1rtxEPJdQ
# cdeh0sVV42neV8HR3jDA/czmTfsNv11P6Z0eGTgvvM9YBS7vDaBQNdrvCScc1bN+
# NR4Iuto229Nfj950iEkSoYIC0jCCAjsCAQEwgfyhgdSkgdEwgc4xCzAJBgNVBAYT
# AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKTAnBgNVBAsTIE1pY3Jvc29mdCBP
# cGVyYXRpb25zIFB1ZXJ0byBSaWNvMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjo2
# MEJDLUUzODMtMjYzNTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2Vy
# dmljZaIjCgEBMAcGBSsOAwIaAxUAzIAFmL3GHHWcAJYi3haGwlplGi6ggYMwgYCk
# fjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
# Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDANBgkqhkiG9w0BAQUFAAIF
# AORQJ1EwIhgPMjAyMTA1MjAwNDA5NTNaGA8yMDIxMDUyMTA0MDk1M1owdzA9Bgor
# BgEEAYRZCgQBMS8wLTAKAgUA5FAnUQIBADAKAgEAAgIjhwIB/zAHAgEAAgIRBjAK
# AgUA5FF40QIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgorBgEEAYRZCgMCoAowCAIB
# AAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBBQUAA4GBAMicoE919n4iFesF
# lYSo+31Rq88sMAyerPM/t9FFf8zZ12wNJDdiR1Ou91hLvyY7ytYO47utHUmyTFn6
# bVgLK38rppACEmSE5Uo8kV04x/UTv5xJSJPVHiPM9c/9N7dq6lzzrpMhBiySxoBI
# beeIhD5W07xY5iYGdohq+wpGZMHGMYIDDTCCAwkCAQEwgZMwfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTACEzMAAAFaLLluRDTLbygAAAAAAVowDQYJYIZIAWUD
# BAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0B
# CQQxIgQgBLTytY3S+L1K6e2hdkO2Han6ZZqzoPSak8+PxVpcaoEwgfoGCyqGSIb3
# DQEJEAIvMYHqMIHnMIHkMIG9BCCT/KgmdMSy5F0ww4Iar9cmf5Is3pM0hUuIInL5
# bbF/sDCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAB
# Wiy5bkQ0y28oAAAAAAFaMCIEIOnnONg9w4fZ4PxJXnEa57XocM91u6qhCdKxijOP
# hnP9MA0GCSqGSIb3DQEBCwUABIIBAEJIJ4ORCc+mAFdf8huBhgzI4nn33fUMKmm9
# 9AYx6kYiy65YStexlk43FDN51Q+CbE6BBs4Dep791XVu1Yx75C7sGZzNRhVvonZo
# 7/zs7/ieaJyywZm4lCBS3WevWR2+Xw1oqS8eO2e5pwHuXNGDQ6MCezMGgmbe0BUy
# jyyBr7FQ0UKZEsninrwA9VYzq1BK2/hIZk5DebMknUr0A8ARhjjj7zPd4C1yFHTU
# RZzNxBTv5E3zx/b2w9NDgxh0Gc6TlJDK0T239mbEGCgi8xrAWGReZECvqIq7wIEq
# SjRkvbDMJL90h4JAjcJ8fAlUdx5UsminGyD8upyt6cEu4BKnHPs=
# SIG # End signature block