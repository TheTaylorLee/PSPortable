
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
Initialises the infrastructure for the migrate project.
.Description
The Initialize-AzMigrateReplicationInfrastructure cmdlet initialises the infrastructure for the migrate project.
.Link
https://docs.microsoft.com/powershell/module/az.migrate/initialize-azmigratereplicationinfrastructure
#>
function Initialize-AzMigrateReplicationInfrastructure {
    [OutputType([System.Boolean])]
    [CmdletBinding(DefaultParameterSetName = 'agentlessVMware', PositionalBinding = $false, SupportsShouldProcess, ConfirmImpact = 'Medium')]
    
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the Resource Group of the Azure Migrate Project in the current subscription.
        ${ResourceGroupName},

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the name of the Azure Migrate project to be used for server migration.
        ${ProjectName},

        [Parameter(Mandatory)]
        [ValidateSet("agentlessVMware")]
        [ArgumentCompleter({"agentlessVMware"})]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the server migration scenario for which the replication infrastructure needs to be initialized.
        ${Scenario},

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Category('Path')]
        [System.String]
        # Specifies the target Azure region for server migrations.
        ${TargetRegion},

        [Parameter()]
        [System.String]
        [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Runtime.DefaultInfo(Script = '(Get-AzContext).Subscription.Id')]
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
        Import-Module Az.Resources
        Import-Module Az.KeyVault
        Import-Module Az.Storage
        Import-Module Az.ServiceBus
        
        # Validate user specified target region
        $TargetRegion = $TargetRegion.ToLower()
        $allAvailableAzureLocations = Get-AzLocation
        $matchingLocationByLocationName = $allAvailableAzureLocations | Where-Object { $_.Location -eq $TargetRegion }
        $matchingLocationByDisplayName = $allAvailableAzureLocations | Where-Object { $_.DisplayName -eq $TargetRegion }
       
        if ($matchingLocationByLocationName) {
            $TargetRegion = $matchingLocationByLocationName.Location
        }
        elseif ($matchingLocationByDisplayName) {
            $TargetRegion = $matchingLocationByDisplayName.Location
        }
        elseif ($TargetRegion -match "euap") {
        }
        else {
            throw "Creation of resources required for replication failed due to invalid location. Run Get-AzLocation to verify the validity of the location and retry this step."
        }
       
        # Get/Set SubscriptionId
        if (($null -eq $SubscriptionId) -or ($SubscriptionId -eq "")) {
            $context = Get-AzContext
            $SubscriptionId = $context.Subscription.Id
            if (($null -eq $SubscriptionId) -or ($SubscriptionId -eq "")) {
                throw "Please login to Azure to select a subscription."
            }
        }
        else {
            Select-AzSubscription -SubscriptionId $SubscriptionId
        }
        $context = Get-AzContext
        Write-Host "Using Subscription Id: ", $SubscriptionId
        Write-Host "Selected Target Region: ", $TargetRegion
        
        $rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue
        if (!$rg) {
            Write-Host "Creating Resource Group ", $ResourceGroupName
            $output = New-AzResourceGroup -Name $ResourceGroupName -Location $TargetRegion
            Write-Host $ResourceGroupName, " created."
        }
        Write-Host "Selected resource group : ", $ResourceGroupName

        $LogStringCreated = "Created : "
        $LogStringSkipping = " already exists."

        # Hash code source code
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

        # Get all appliances and sites in the project
        $solution = Get-AzMigrateSolution -MigrateProjectName $ProjectName -ResourceGroupName $ResourceGroupName -Name "Servers-Migration-ServerMigration"
        $VaultName = $solution.DetailExtendedDetail.AdditionalProperties.vaultId.Split("/")[8]

        $appMap = @{}

        if ($null -ne $solution.DetailExtendedDetail["applianceNameToSiteIdMapV2"]) {
            $appMapV2 = $solution.DetailExtendedDetail["applianceNameToSiteIdMapV2"] | ConvertFrom-Json
            # Fetch all appliance from V2 map first. Then these can be updated if found again in V3 map.
            foreach ($item in $appMapV2) {
                $appMap[$item.ApplianceName] = $item.SiteId
            }
        }
        
        if ($null -ne $solution.DetailExtendedDetail["applianceNameToSiteIdMapV3"]) {
            $appMapV3 = $solution.DetailExtendedDetail["applianceNameToSiteIdMapV3"] | ConvertFrom-Json
            foreach ($item in $appMapV3) {
                $t = $item.psobject.properties
                $appMap[$t.Name] = $t.Value.SiteId
            }    
        }

        if ($null -eq $solution.DetailExtendedDetail["applianceNameToSiteIdMapV2"] -And
             $null -eq $solution.DetailExtendedDetail["applianceNameToSiteIdMapV3"] ) {
            throw "Server Migration Solution missing Appliance Details. Invalid Solution."           
        }

        foreach ($eachApp in $appMap.GetEnumerator()) {
            $SiteName = $eachApp.Value.Split("/")[8]
            $applianceName = $eachApp.Key
            $HashCodeInput = $SiteName + $TargetRegion

            # User cannot change location if it's already set in mapping.
            $mappingName = "containermapping"
            $allFabrics = Get-AzMigrateReplicationFabric -ResourceGroupName $ResourceGroupName -ResourceName $VaultName

            foreach ($fabric in $allFabrics) {
                if (($fabric.Property.CustomDetail.InstanceType -ceq "VMwareV2") -and ($fabric.Property.CustomDetail.VmwareSiteId.Split("/")[8] -ceq $SiteName)) {
                    $peContainers = Get-AzMigrateReplicationProtectionContainer -FabricName $fabric.Name -ResourceGroupName $ResourceGroupName -ResourceName $VaultName
                    $peContainer = $peContainers[0]
                    $existingMapping = Get-AzMigrateReplicationProtectionContainerMapping -ResourceGroupName $ResourceGroupName -ResourceName $VaultName -FabricName $fabric.Name -ProtectionContainerName $peContainer.Name -MappingName $mappingName -ErrorVariable notPresent -ErrorAction SilentlyContinue
                    if (($existingMapping) -and ($existingMapping.ProviderSpecificDetail.TargetLocation -ne $TargetRegion)) {
                        $targetRegionMismatchExceptionMsg = $ProjectName + " is already configured for migrating servers to " + $TargetRegion + ". Target Region cannot be modified once configured."
                        throw $targetRegionMismatchExceptionMsg
                    }   
                }
            }

            $job = Start-Job -ScriptBlock {
                Add-Type -TypeDefinition $args[0] -Language CSharp 
                $hash = [HashFunctions]::hashForArtifact($args[1]) 
                $hash
            } -ArgumentList $Source, $HashCodeInput
            Wait-Job $job
            $hash = Receive-Job $job

            Write-Host "Initiating Artifact Creation for Appliance: ", $applianceName

            # Phase 1
            # Storage account
            $MigratePrefix = "migrate"            
            $LogStorageAcName = $MigratePrefix + "lsa" + $hash
            $GateWayStorageAcName = $MigratePrefix + "gwsa" + $hash
            $StorageType = "Microsoft.Storage/storageAccounts"
            $StorageApiVersion = "2017-10-01" 
            $LogStorageProperties = @{
                encryption               = @{
                    services  = @{
                        blob  = @{enabled = $true };
                        file  = @{enabled = $true };
                        table = @{enabled = $true };
                        queue = @{enabled = $true }
                    };
                    keySource = "Microsoft.Storage"
                };
                supportsHttpsTrafficOnly = $true
            }
            $ResourceTag = @{"Migrate Project" = $ProjectName }
            $StorageSku = @{name = "Standard_LRS" }
            $ResourceKind = "Storage"
            
            $lsaStorageAccount = Get-AzResource -ResourceGroupName $ResourceGroupName -Name $LogStorageAcName -ErrorVariable notPresent -ErrorAction SilentlyContinue
            if (!$lsaStorageAccount) {
                $output = New-AzResource -ResourceGroupName $ResourceGroupName -Location $TargetRegion -Properties  $LogStorageProperties -ResourceName $LogStorageAcName -ResourceType  $StorageType -ApiVersion $StorageApiVersion -Kind  $ResourceKind -Sku  $StorageSku -Tag $ResourceTag -Force
                Write-Host $LogStringCreated, $LogStorageAcName
            }
            else {
                Write-Host $LogStorageAcName, $LogStringSkipping
            }

            $gwyStorageAccount = Get-AzResource -ResourceGroupName $ResourceGroupName -Name $GateWayStorageAcName -ErrorVariable notPresent -ErrorAction SilentlyContinue
            if (!$gwyStorageAccount) {
                $output = New-AzResource -ResourceGroupName $ResourceGroupName -Location $TargetRegion -Properties  $LogStorageProperties -ResourceName $GateWayStorageAcName -ResourceType  $StorageType -ApiVersion $StorageApiVersion -Kind  $ResourceKind -Sku  $StorageSku -Tag $ResourceTag -Force
                Write-Host $LogStringCreated, $GateWayStorageAcName
            }
            else {
                Write-Host $GateWayStorageAcName, $LogStringSkipping
            }

            # Service bus namespace
            $ServiceBusNamespace = $MigratePrefix + "sbns" + $hash
            $ServiceBusType = "Microsoft.ServiceBus/namespaces"
            $ServiceBusApiVersion = "2017-04-01"
            $ServiceBusSku = @{
                name = "Standard";
                tier = "Standard"
            }
            $ServiceBusProperties = @{}
            $ServieBusKind = "ServiceBusNameSpace"
    
            $serviceBusAccount = Get-AzResource -ResourceGroupName $ResourceGroupName -Name $ServiceBusNamespace -ErrorVariable notPresent -ErrorAction SilentlyContinue
            if (!$serviceBusAccount) {
                $output = New-AzResource -ResourceGroupName $ResourceGroupName -Location $TargetRegion -Properties  $ServiceBusProperties -ResourceName $ServiceBusNamespace -ResourceType  $ServiceBusType -ApiVersion $ServiceBusApiVersion -Kind  $ServieBusKind -Sku  $ServiceBusSku -Tag $ResourceTag -Force
                Write-Host $LogStringCreated, $ServiceBusNamespace
            }
            else {
                Write-Host $ServiceBusNamespace, $LogStringSkipping
            }
           
            # Key vault
            $KeyVaultName = $MigratePrefix + "kv" + $hash
            $KeyVaultType = "Microsoft.KeyVault/vaults"
            $KeyVaultApiVersion = "2016-10-01"
            $KeyVaultKind = "KeyVault"
            
            $existingKeyVaultAccount = Get-AzResource -ResourceGroupName $ResourceGroupName -Name $KeyVaultName -ErrorVariable notPresent -ErrorAction SilentlyContinue
            if ($existingKeyVaultAccount) {
                Write-Host $KeyVaultName, $LogStringSkipping
            }
            else {
                $tenantID = $context.Tenant.TenantId 

                $KeyVaultPermissions = @{
                    keys         = @("Get", "List", "Create", "Update", "Delete");
                    secrets      = @("Get", "Set", "List", "Delete");
                    certificates = @("Get", "List");
                    storage      = @("get", "list", "delete", "set", "update", "regeneratekey", "getsas",
                        "listsas", "deletesas", "setsas", "recover", "backup", "restore", "purge")
                }

                $CloudEnvironMent = $context.Environment.Name
                $HyperVManagerAppId = "b8340c3b-9267-498f-b21a-15d5547fd85e"
                if ($CloudEnvironMent -eq "AzureUSGovernment") {
                    $HyperVManagerAppId = "AFAE2AF7-62E0-4AA4-8F66-B11F74F56326"
                }
                $hyperVManagerObject = Get-AzADServicePrincipal -ApplicationID $HyperVManagerAppId
                $userObject = Get-AzADUser -UserPrincipalName $context.Subscription.ExtendedProperties.Account
                $accessPolicies = @()
                $userAccessPolicy = @{
                    "tenantId"    = $tenantID;
                    "objectId"    = $userObject.Id;
                    "permissions" = $KeyVaultPermissions
                }
                $hyperVAccessPolicy = @{
                    "tenantId"    = $tenantID;
                    "objectId"    = $hyperVManagerObject.Id;
                    "permissions" = $KeyVaultPermissions
                }
                $accessPolicies += $userAccessPolicy
                $accessPolicies += $hyperVAccessPolicy

                $allFabrics = Get-AzMigrateReplicationFabric -ResourceGroupName $ResourceGroupName -ResourceName $VaultName
                $selectedFabricName = ""
                foreach ($fabric in $allFabrics) {
                    if (($fabric.Property.CustomDetail.InstanceType -ceq "VMwareV2") -and ($fabric.Property.CustomDetail.VmwareSiteId.Split("/")[8] -ceq $SiteName)) {
                        $projectRSPObject = Get-AzMigrateReplicationRecoveryServicesProvider -ResourceGroupName $ResourceGroupName -ResourceName $VaultName
                        foreach ($projectRSP in $projectRSPObject) {
                            $projectRSPFabricName = $projectRSP.Id.Split("/")[10]
                            if (($projectRSP.FabricType -eq "VMwareV2") -and ($fabric.Name -eq $projectRSPFabricName)) {
                                $projectAccessPolicy = @{
                                    "tenantId"    = $tenantID;
                                    "objectId"    = $projectRSP.ResourceAccessIdentityDetailObjectId;
                                    "permissions" = $KeyVaultPermissions
                                }
                                $accessPolicies += $projectAccessPolicy
                            }
                        }
                    }
                }
                
                $keyVaultProperties = @{
                    sku                          = @{
                        family = "A";
                        name   = "standard"
                    };
                    tenantId                     = $tenantID;
                    enabledForDeployment         = $true;
                    enabledForDiskEncryption     = $false;
                    enabledForTemplateDeployment = $true;
                    enableSoftDelete             = $true;
                    accessPolicies               = $accessPolicies
                }

                $output = New-AzResource -ResourceGroupName $ResourceGroupName -Location $TargetRegion -Properties  $keyVaultProperties -ResourceName $KeyVaultName -ResourceType  $KeyVaultType -ApiVersion $KeyVaultApiVersion -Kind $KeyVaultKind -Tag $ResourceTag -Force
                Write-Host $LogStringCreated, $KeyVaultName
            }

            # Locks
            $CommonLockName = $ProjectName + "lock"
            $lockNotes = "This is in use by Azure Migrate project"
            $lsaLock = Get-AzResourceLock -LockName $CommonLockName -ResourceName $LogStorageAcName -ResourceType $StorageType -ResourceGroupName $ResourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue
            if (!$lsaLock) {
                $output = New-AzResourceLock -LockLevel CanNotDelete -LockName $CommonLockName -ResourceName $LogStorageAcName -ResourceType $StorageType -ResourceGroupName $ResourceGroupName -LockNotes $lockNotes -Force
                Write-Host $LogStringCreated, $CommonLockName, " for ", $LogStorageAcName
            }
            else {
                Write-Host $CommonLockName, " for ", $LogStorageAcName, $LogStringSkipping
            }
            
            $gwyLock = Get-AzResourceLock -LockName $CommonLockName -ResourceName $GateWayStorageAcName -ResourceType $StorageType -ResourceGroupName $ResourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue
            if (!$gwyLock) {
                $output = New-AzResourceLock -LockLevel CanNotDelete -LockName $CommonLockName -ResourceName $GateWayStorageAcName -ResourceType $StorageType -ResourceGroupName $ResourceGroupName -LockNotes $lockNotes -Force
                Write-Host $LogStringCreated, $CommonLockName, " for ", $GateWayStorageAcName
            }
            else {
                Write-Host $CommonLockName, " for ", $LogStorageAcName, $LogStringSkipping
            }

            $sbsnsLock = Get-AzResourceLock -LockName $CommonLockName -ResourceName $ServiceBusNamespace -ResourceType $ServiceBusType -ResourceGroupName $ResourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue
            if (!$sbsnsLock) {
                $output = New-AzResourceLock -LockLevel CanNotDelete -LockName $CommonLockName -ResourceName $ServiceBusNamespace -ResourceType $ServiceBusType -ResourceGroupName $ResourceGroupName -LockNotes $lockNotes -Force
                Write-Host $LogStringCreated, $CommonLockName, " for ", $ServiceBusNamespace
            }
            else {
                Write-Host $CommonLockName, " for ", $ServiceBusNamespace, $LogStringSkipping
            }

            $kvLock = Get-AzResourceLock -LockName $CommonLockName -ResourceName $KeyVaultName -ResourceType $KeyVaultType -ResourceGroupName $ResourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue
            if (!$kvLock) {
                $output = New-AzResourceLock -LockLevel CanNotDelete -LockName $CommonLockName -ResourceName $KeyVaultName -ResourceType $KeyVaultType -ResourceGroupName $ResourceGroupName -LockNotes $lockNotes -Force
                Write-Host $LogStringCreated, $CommonLockName, " for ", $KeyVaultName
            }
            else {
                Write-Host $CommonLockName, " for ", $KeyVaultName, $LogStringSkipping
            }
            

            # Intermediate phase
            # RoleAssignments
            
            $roleDefinitionId = "81a9662b-bebf-436f-a333-f67b29880f12"
            $kvspnid = (Get-AzADServicePrincipal -DisplayName "Azure Key Vault" )[0].Id
            $gwyStorageAccount = Get-AzResource -ResourceName $GateWayStorageAcName -ResourceGroupName $ResourceGroupName 
            $lsaStorageAccount = Get-AzResource -ResourceName $LogStorageAcName -ResourceGroupName $ResourceGroupName
            $gwyRoleAssignments = Get-AzRoleAssignment -ObjectId $kvspnid -Scope $gwyStorageAccount.Id -ErrorVariable notPresent -ErrorAction SilentlyContinue
            $lsaRoleAssignments = Get-AzRoleAssignment -ObjectId $kvspnid -Scope $lsaStorageAccount.Id -ErrorVariable notPresent -ErrorAction SilentlyContinue
            if (!$lsaRoleAssignments) {
                $output = New-AzRoleAssignment -ObjectId $kvspnid -Scope $lsaStorageAccount.Id -RoleDefinitionId $roleDefinitionId
            }
            if (!$gwyRoleAssignments) {
                $output = New-AzRoleAssignment -ObjectId $kvspnid -Scope $gwyStorageAccount.Id -RoleDefinitionId $roleDefinitionId
            }

            # SA. SAS definition

            $gatewayStorageAccountSasSecretName = "gwySas"
            $cacheStorageAccountSasSecretName = "cacheSas"
            $regenerationPeriod = [System.Timespan]::FromDays(30)
            $keyName = 'Key2'
            Add-AzKeyVaultManagedStorageAccount -VaultName $KeyVaultName -AccountName $LogStorageAcName -AccountResourceId  $lsaStorageAccount.Id  -ActiveKeyName $keyName -RegenerationPeriod $regenerationPeriod
            Add-AzKeyVaultManagedStorageAccount -VaultName $KeyVaultName -AccountName $GateWayStorageAcName -AccountResourceId  $gwyStorageAccount.Id  -ActiveKeyName $keyName -RegenerationPeriod $regenerationPeriod

            $lsasctx = New-AzStorageContext -StorageAccountName $LogStorageAcName -Protocol Https -StorageAccountKey $keyName
            $gwysctx = New-AzStorageContext -StorageAccountName $GateWayStorageAcName -Protocol Https -StorageAccountKey $keyName

            $lsaat = New-AzStorageAccountSasToken -Service blob, file, Table, Queue -ResourceType Service, Container, Object -Permission "racwdlup" -Protocol HttpsOnly -Context $lsasctx
            $gwyat = New-AzStorageAccountSasToken -Service blob, file, Table, Queue -ResourceType Service, Container, Object -Permission "racwdlup" -Protocol HttpsOnly -Context $gwysctx

            Set-AzKeyVaultManagedStorageSasDefinition -AccountName $LogStorageAcName -VaultName $KeyVaultName -Name $cacheStorageAccountSasSecretName -TemplateUri $lsaat -SasType 'account' -ValidityPeriod ([System.Timespan]::FromDays(30))
            Set-AzKeyVaultManagedStorageSasDefinition -AccountName $GateWayStorageAcName -VaultName $KeyVaultName -Name $gatewayStorageAccountSasSecretName -TemplateUri $gwyat -SasType 'account' -ValidityPeriod ([System.Timespan]::FromDays(30))
            
            # Phase 2
           
            # ServiceBusConnectionString
            $serviceBusConnString = "ServiceBusConnectionString"
            $serviceBusSecretObject = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $serviceBusConnString -ErrorVariable notPresent -ErrorAction SilentlyContinue
            if ($serviceBusSecretObject) {
                Write-Host $serviceBusConnString, " for ", $applianceName, $LogStringSkipping
            }
            else {
                $serviceBusRootKey = Get-AzServiceBusKey -ResourceGroupName $ResourceGroupName -Namespace $ServiceBusNamespace -Name "RootManageSharedAccessKey"
                $secret = ConvertTo-SecureString -String $serviceBusRootKey.PrimaryConnectionString -AsPlainText -Force
                $output = Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $serviceBusConnString -SecretValue $secret
                Write-Host $LogStringCreated, $serviceBusConnString, " for ", $applianceName
            }  

            # Policy
            $policyName = $MigratePrefix + $SiteName + "policy"
            $existingPolicyObject = Get-AzMigrateReplicationPolicy -PolicyName $policyName -ResourceGroupName $ResourceGroupName -ResourceName $VaultName -ErrorVariable notPresent -ErrorAction SilentlyContinue
            if (!$existingPolicyObject) {
                $providerSpecificPolicy = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20180110.VMwareCbtPolicyCreationInput]::new()
                $providerSpecificPolicy.AppConsistentFrequencyInMinute = 240
                $providerSpecificPolicy.InstanceType = "VMwareCbt"
                $providerSpecificPolicy.RecoveryPointHistoryInMinute = 4320
                $providerSpecificPolicy.CrashConsistentFrequencyInMinute = 60
                $existingPolicyObject = New-AzMigrateReplicationPolicy -PolicyName $policyName -ResourceGroupName $ResourceGroupName -ResourceName $VaultName -ProviderSpecificInput $providerSpecificPolicy
                Write-Host $LogStringCreated, $policyName
            }
            else {
                Write-Host $policyName, $LogStringSkipping
            }

            # Policy-container mapping
            $mappingName = "containermapping"
            $allFabrics = Get-AzMigrateReplicationFabric -ResourceGroupName $ResourceGroupName -ResourceName $VaultName
            foreach ($fabric in $allFabrics) {
                if (($fabric.Property.CustomDetail.InstanceType -ceq "VMwareV2") -and ($fabric.Property.CustomDetail.VmwareSiteId.Split("/")[8] -ceq $SiteName)) {
                    $peContainers = Get-AzMigrateReplicationProtectionContainer -FabricName $fabric.Name -ResourceGroupName $ResourceGroupName -ResourceName $VaultName
                    $peContainer = $peContainers[0]
                    $existingMapping = Get-AzMigrateReplicationProtectionContainerMapping -ResourceGroupName $ResourceGroupName -ResourceName $VaultName -FabricName $fabric.Name -ProtectionContainerName $peContainer.Name -MappingName $mappingName -ErrorVariable notPresent -ErrorAction SilentlyContinue
                    if ($existingMapping) {
                        Write-Host $mappingName, " for ", $applianceName, $LogStringSkipping
                    }
                    else {
                        $keyVaultAccountDetails = Get-AzKeyVault -ResourceGroupName $ResourceGroupName -Name $KeyVaultName
                        $gwyStorageAccount = Get-AzResource -ResourceGroupName $ResourceGroupName -ResourceName $GateWayStorageAcName
                        $providerSpecificInput = [Microsoft.Azure.PowerShell.Cmdlets.Migrate.Models.Api20180110.VMwareCbtContainerMappingInput]::new()
                        $providerSpecificInput.InstanceType = "VMwareCbt"
                        $providerSpecificInput.KeyVaultId = $keyVaultAccountDetails.ResourceId
                        $providerSpecificInput.KeyVaultUri = $keyVaultAccountDetails.VaultUri
                        $providerSpecificInput.ServiceBusConnectionStringSecretName = $serviceBusConnString
                        $providerSpecificInput.StorageAccountId = $gwyStorageAccount.Id
                        $providerSpecificInput.StorageAccountSasSecretName = $GateWayStorageAcName + "-gwySas"
                        $providerSpecificInput.TargetLocation = $TargetRegion
                        $output = New-AzMigrateReplicationProtectionContainerMapping -FabricName $fabric.Name -MappingName $mappingName -ProtectionContainerName $peContainer.Name -ResourceGroupName $ResourceGroupName -ResourceName $VaultName -PolicyId $existingPolicyObject.Id -ProviderSpecificInput $providerSpecificInput -TargetProtectionContainerId  "Microsoft Azure"
                        Write-Host $LogStringCreated, $mappingName, " for ", $applianceName
                    } 
                }
            }  
        }
        Write-Host "Finished successfully."
        return $true
    }
}
# SIG # Begin signature block
# MIIjgwYJKoZIhvcNAQcCoIIjdDCCI3ACAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCC4XWa3px4NlMDG
# SutB1YND8wh0VamuTPbJBOccDkX2NaCCDYEwggX/MIID56ADAgECAhMzAAAB32vw
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
# RcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIVWDCCFVQCAQEwgZUwfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAd9r8C6Sp0q00AAAAAAB3zAN
# BglghkgBZQMEAgEFAKCBrjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgK9DlLsS+
# Sj9FpqJv/GzHODsGe08PXx3tfUXKIw8naScwQgYKKwYBBAGCNwIBDDE0MDKgFIAS
# AE0AaQBjAHIAbwBzAG8AZgB0oRqAGGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbTAN
# BgkqhkiG9w0BAQEFAASCAQCAMSUjmXrpq9NV0ZJJSSdigYNNqpWGhwwJXifJdUJB
# vMow3savCwatlL6/TLmfU0kQp4KIkgRt6/Hd1cS/i+ruwZq12EikS5GrIjLz+7YE
# ZOeSxrrYogp8Zu0neewBpcvuFrC8zo82RY00DUY8Ix3wanQIeou/H6X+1LQW57h7
# QzFMKOMS8jOPstP8Iju4IiTWOsmr+ftnZLiOVqStYXNTHoIIgVfBdYwXQqrf5yVG
# nHYYkoSpwgiBh1hgml3T/+v1b0EX3Qqb3t+R5nH67dh0bER50++OL7QDCd4noksb
# NnXJJ+xoN3LUx+5Iy/OAgSD4manfqS205IiH63/X7YOroYIS4jCCEt4GCisGAQQB
# gjcDAwExghLOMIISygYJKoZIhvcNAQcCoIISuzCCErcCAQMxDzANBglghkgBZQME
# AgEFADCCAVEGCyqGSIb3DQEJEAEEoIIBQASCATwwggE4AgEBBgorBgEEAYRZCgMB
# MDEwDQYJYIZIAWUDBAIBBQAEIJlHBvTfoWlVGmXVbQmFmO5GSeHWJL3DOwg+zF9S
# dfSkAgZgWLzCzsYYEzIwMjEwMzIzMTAwNzE4LjkzNlowBIACAfSggdCkgc0wgcox
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1p
# Y3Jvc29mdCBBbWVyaWNhIE9wZXJhdGlvbnMxJjAkBgNVBAsTHVRoYWxlcyBUU1Mg
# RVNOOjNFN0EtRTM1OS1BMjVEMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFt
# cCBTZXJ2aWNloIIOOTCCBPEwggPZoAMCAQICEzMAAAFSMEtdiazmcEcAAAAAAVIw
# DQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
# b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
# dGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwHhcN
# MjAxMTEyMTgyNjA1WhcNMjIwMjExMTgyNjA1WjCByjELMAkGA1UEBhMCVVMxEzAR
# BgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1p
# Y3Jvc29mdCBDb3Jwb3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2Eg
# T3BlcmF0aW9uczEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046M0U3QS1FMzU5LUEy
# NUQxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCuzG6EiZh0taCSbswMiupMTYnbboFz
# jj1DuDbbvT0RXKBCVl/umA+Uy214DmHiFhkeuRdlLB0ya5S9um5aKr7lBBqZzvtK
# gGNgCRbDTG9Yu6kzDzPTzQRulVIvoWVy0gITnEyoJ1O3m5IPpsLBNQCdXsh+3TZF
# 73JAcub21bnxm/4sxe4zTdbdttBrqX8/JJF2VEnAP+MBvF2UQSo6XUAaTKC/HPDP
# Cce/IsNoAxxLDI1wHhIlqjRBnt4HM5HcKHrZrvH+vHnihikdlEzh3fjQFowk1fG7
# PVhmO60O5vVdqA+H9314hHENQI0cbo+SkSi8SSJSLNixgj0eWePTh7pbAgMBAAGj
# ggEbMIIBFzAdBgNVHQ4EFgQUhN2u2qwj1l2c2h/kULDuBRJsexQwHwYDVR0jBBgw
# FoAU1WM6XIoxkPNDe3xGG8UzaFqFbVUwVgYDVR0fBE8wTTBLoEmgR4ZFaHR0cDov
# L2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljVGltU3RhUENB
# XzIwMTAtMDctMDEuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcwAoY+aHR0
# cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNUaW1TdGFQQ0FfMjAx
# MC0wNy0wMS5jcnQwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDCDAN
# BgkqhkiG9w0BAQsFAAOCAQEAVcUncfFqSazQbDEXf3d10/upiWQU5HdTbwG9v9be
# VIDaG4oELyIcNE6e6CbOBMlPU+smpYYcnK3jucNqChwquLmxdi2iPy4iQ6vjAdBp
# 9+VFWlrBqUsNXZzjCpgMCZj6bu8Xq0Nndl4WyBbI0Jku68vUNG4wsMdKP3dz+1Mz
# k9SUma3j7HyNA559do9nhKmoZMn5dtf03QvxlaEwMAaPk9xuUv9BN8cNvFnpWk4m
# LERQW6tA3rXK0soEISKTYG7Ose7oMXZDYPWxf9oFhYKzZw/SwnhdBoj2S5eyYE3A
# uF/ZXzR3hdp3/XGzZeOdERfFy1rC7ZBwhDIajeFMi53GnzCCBnEwggRZoAMCAQIC
# CmEJgSoAAAAAAAIwDQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRp
# ZmljYXRlIEF1dGhvcml0eSAyMDEwMB4XDTEwMDcwMTIxMzY1NVoXDTI1MDcwMTIx
# NDY1NVowfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
# BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQG
# A1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQCpHQ28dxGKOiDs/BOX9fp/aZRrdFQQ1aUKAIKF
# ++18aEssX8XD5WHCdrc+Zitb8BVTJwQxH0EbGpUdzgkTjnxhMFmxMEQP8WCIhFRD
# DNdNuDgIs0Ldk6zWczBXJoKjRQ3Q6vVHgc2/JGAyWGBG8lhHhjKEHnRhZ5FfgVSx
# z5NMksHEpl3RYRNuKMYa+YaAu99h/EbBJx0kZxJyGiGKr0tkiVBisV39dx898Fd1
# rL2KQk1AUdEPnAY+Z3/1ZsADlkR+79BL/W7lmsqxqPJ6Kgox8NpOBpG2iAg16Hgc
# sOmZzTznL0S6p/TcZL2kAcEgCZN4zfy8wMlEXV4WnAEFTyJNAgMBAAGjggHmMIIB
# 4jAQBgkrBgEEAYI3FQEEAwIBADAdBgNVHQ4EFgQU1WM6XIoxkPNDe3xGG8UzaFqF
# bVUwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGGMA8GA1Ud
# EwEB/wQFMAMBAf8wHwYDVR0jBBgwFoAU1fZWy4/oolxiaNE9lJBb186aGMQwVgYD
# VR0fBE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwv
# cHJvZHVjdHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEB
# BE4wTDBKBggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9j
# ZXJ0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcnQwgaAGA1UdIAEB/wSBlTCB
# kjCBjwYJKwYBBAGCNy4DMIGBMD0GCCsGAQUFBwIBFjFodHRwOi8vd3d3Lm1pY3Jv
# c29mdC5jb20vUEtJL2RvY3MvQ1BTL2RlZmF1bHQuaHRtMEAGCCsGAQUFBwICMDQe
# MiAdAEwAZQBnAGEAbABfAFAAbwBsAGkAYwB5AF8AUwB0AGEAdABlAG0AZQBuAHQA
# LiAdMA0GCSqGSIb3DQEBCwUAA4ICAQAH5ohRDeLG4Jg/gXEDPZ2joSFvs+umzPUx
# vs8F4qn++ldtGTCzwsVmyWrf9efweL3HqJ4l4/m87WtUVwgrUYJEEvu5U4zM9GAS
# inbMQEBBm9xcF/9c+V4XNZgkVkt070IQyK+/f8Z/8jd9Wj8c8pl5SpFSAK84Dxf1
# L3mBZdmptWvkx872ynoAb0swRCQiPM/tA6WWj1kpvLb9BOFwnzJKJ/1Vry/+tuWO
# M7tiX5rbV0Dp8c6ZZpCM/2pif93FSguRJuI57BlKcWOdeyFtw5yjojz6f32WapB4
# pm3S4Zz5Hfw42JT0xqUKloakvZ4argRCg7i1gJsiOCC1JeVk7Pf0v35jWSUPei45
# V3aicaoGig+JFrphpxHLmtgOR5qAxdDNp9DvfYPw4TtxCd9ddJgiCGHasFAeb73x
# 4QDf5zEHpJM692VHeOj4qEir995yfmFrb3epgcunCaw5u+zGy9iCtHLNHfS4hQEe
# gPsbiSpUObJb2sgNVZl6h3M7COaYLeqN4DMuEin1wC9UJyH3yKxO2ii4sanblrKn
# QqLJzxlBTeCG+SqaoxFmMNO7dDJL32N79ZmKLxvHIa9Zta7cRDyXUHHXodLFVeNp
# 3lfB0d4wwP3M5k37Db9dT+mdHhk4L7zPWAUu7w2gUDXa7wknHNWzfjUeCLraNtvT
# X4/edIhJEqGCAsswggI0AgEBMIH4oYHQpIHNMIHKMQswCQYDVQQGEwJVUzETMBEG
# A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWlj
# cm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBP
# cGVyYXRpb25zMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjozRTdBLUUzNTktQTI1
# RDElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZaIjCgEBMAcG
# BSsOAwIaAxUAv26eVJaumcmTchd6hqayQMNDXluggYMwgYCkfjB8MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQg
# VGltZS1TdGFtcCBQQ0EgMjAxMDANBgkqhkiG9w0BAQUFAAIFAOQD4/8wIhgPMjAy
# MTAzMjMxMTUwMjNaGA8yMDIxMDMyNDExNTAyM1owdDA6BgorBgEEAYRZCgQBMSww
# KjAKAgUA5APj/wIBADAHAgEAAgIRbzAHAgEAAgIRODAKAgUA5AU1fwIBADA2Bgor
# BgEEAYRZCgQCMSgwJjAMBgorBgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAID
# AYagMA0GCSqGSIb3DQEBBQUAA4GBACT7Feg092TeeGQk2QRtUWSsXysNjMO0Ec+K
# y76easKmb/zkO2RpJ4eQYYQLq3J48ir1MeqnOoM6lwYAyIAjskkZ714UNBGPsDhi
# X0AwNLFBw66lPnKKs3qU2hbTp9A2COB1MXzeEpGqmDWF84DOdp+fTxudjPGk3As0
# CynpDCVTMYIDDTCCAwkCAQEwgZMwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTACEzMAAAFSMEtdiazmcEcAAAAAAVIwDQYJYIZIAWUDBAIBBQCgggFKMBoGCSqG
# SIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0BCQQxIgQgPFXyUdgx34qk
# gUdVIkCiu/ZDs0wHkQWBYLAYTLHmjuUwgfoGCyqGSIb3DQEJEAIvMYHqMIHnMIHk
# MIG9BCCT7lzHo4slUIxfEGp8LXQNik/ecK6vuuGWIcmBrrsnpjCBmDCBgKR+MHwx
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1p
# Y3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAABUjBLXYms5nBHAAAAAAFS
# MCIEIO72aLsIwWYiMnaRfxfCXzw+PFNrjaPUU9RMOJqN0xSwMA0GCSqGSIb3DQEB
# CwUABIIBACtA5oqSFUo+agqxrS5Z6Zph1d1N6JZMd0OZ+SnI29Jh6BPPfpPdXYwm
# XPQuxXVcOlClLHRT/DfM+lz5D6QPOgjh7uEU1jsLhgj3ON0jObV5vbSuAb09UihY
# xeHkPWV1UYbpxH/uplWFhnchJG/GTWIyGuufonI65hd0JMICPovKqbL+R9kTN81l
# ajitlXI5qzEhjby21Cc4jQrBNueWHQtRj55lFA7iAyi0oOUmXhkjl5jk47h2kw+5
# jBdVSXMrE2Bd9ICu8Np8HgzxgReXxm6g7pERm9c6knFp5aVh8BYopyuOvI4vEBY6
# ofMGf+Wlg2XsVyf/4a+u5d1p6S1t1F0=
# SIG # End signature block
