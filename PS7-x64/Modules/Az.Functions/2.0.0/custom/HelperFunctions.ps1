# Load Az.Functions module constants
$constants = @{}
$constants["AllowedStorageTypes"] = @('Standard_GRS', 'Standard_RAGRS', 'Standard_LRS', 'Standard_ZRS', 'Premium_LRS')
$constants["RequiredStorageEndpoints"] = @('PrimaryEndpointFile', 'PrimaryEndpointQueue', 'PrimaryEndpointTable')
$constants["DefaultFunctionsVersion"] = '3'
$constants["RuntimeToFormattedName"] = @{
    'node' = 'Node'
    'dotnet' = 'DotNet'
    'python' = 'Python'
    'java' = 'Java'
    'powershell' = 'PowerShell'
}
$constants["RuntimeToDefaultOSType"] = @{
    'DotNet'= 'Windows'
    'Node' = 'Windows'
    'Java' = 'Windows'
    'PowerShell' = 'Windows'
    'Python' = 'Linux'
}
$constants["ReservedFunctionAppSettingNames"] = @(
    'FUNCTIONS_WORKER_RUNTIME'
    'DOCKER_CUSTOM_IMAGE_NAME'
    'FUNCTION_APP_EDIT_MODE'
    'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
    'DOCKER_REGISTRY_SERVER_URL'
    'DOCKER_REGISTRY_SERVER_USERNAME'
    'DOCKER_REGISTRY_SERVER_PASSWORD'
    'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
    'WEBSITE_NODE_DEFAULT_VERSION'
    'AzureWebJobsStorage'
    'AzureWebJobsDashboard'
    'FUNCTIONS_EXTENSION_VERSION'
    'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
    'WEBSITE_CONTENTSHARE'
    'APPINSIGHTS_INSTRUMENTATIONKEY'
)
$constants["SupportedFunctionsVersion"] = @('2', '3')
$constants["FunctionsNoV2Version"] = @(
    "USNat West"
    "USNat East"
    "USSec West"
    "USSec East"
)

foreach ($variableName in $constants.Keys)
{
    if (-not (Get-Variable $variableName -ErrorAction SilentlyContinue))
    {
        Set-Variable $variableName -value $constants[$variableName] -option ReadOnly
    }
}

function GetConnectionString
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $StorageAccountName,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    if ($PSBoundParameters.ContainsKey("StorageAccountName"))
    {
        $PSBoundParameters.Remove("StorageAccountName") | Out-Null
    }

    $storageAccountInfo = GetStorageAccount -Name $StorageAccountName @PSBoundParameters
    if (-not $storageAccountInfo)
    {
        $errorMessage = "Storage account '$StorageAccountName' does not exist."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "StorageAccountNotFound" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }

    if ($storageAccountInfo.ProvisioningState -ne "Succeeded")
    {
        $errorMessage = "Storage account '$StorageAccountName' is not ready. Please run 'Get-AzStorageAccount' and ensure that the ProvisioningState is 'Succeeded'"
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "StorageAccountNotFound" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }
    
    $skuName = $storageAccountInfo.SkuName
    if (-not ($AllowedStorageTypes -contains $skuName))
    {
        $storageOptions = $AllowedStorageTypes -join ", "
        $errorMessage = "Storage type '$skuName' is not allowed'. Currently supported storage options: $storageOptions"
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "StorageTypeNotSupported" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }

    foreach ($endpoint in $RequiredStorageEndpoints)
    {
        if ([string]::IsNullOrEmpty($storageAccountInfo.$endpoint))
        {
            $errorMessage = "Storage account '$StorageAccountName' has no '$endpoint' endpoint. It must have table, queue, and blob endpoints all enabled."
            $exception = [System.InvalidOperationException]::New($errorMessage)
            ThrowTerminatingError -ErrorId "StorageAccountRequiredEndpointNotAvailable" `
                                  -ErrorMessage $errorMessage `
                                  -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                                  -Exception $exception
        }
    }

    $resourceGroupName = ($storageAccountInfo.Id -split "/")[4]
    $keys = Az.Functions.internal\Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountInfo.Name @PSBoundParameters -ErrorAction SilentlyContinue

    if (-not $keys)
    {
        $errorMessage = "Failed to get key for storage account '$StorageAccountName'."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "FailedToGetStorageAccountKey" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }

    if ([string]::IsNullOrEmpty($keys[0].Value))
    {
        $errorMessage = "Storage account '$StorageAccountName' has no key value."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "StorageAccountHasNoKeyValue" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }

    $accountKey = $keys[0].Value
    $connectionString = "DefaultEndpointsProtocol=https;AccountName=$StorageAccountName;AccountKey=$accountKey"

    return $connectionString
}

function NewAppSetting
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Value
    )

    $setting = New-Object -TypeName Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.Api20190801.NameValuePair
    $setting.Name = $Name
    $setting.Value = $Value

    return $setting
}

function GetServicePlan
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    if ($PSBoundParameters.ContainsKey("Name"))
    {
        $PSBoundParameters.Remove("Name") | Out-Null
    }

    $plans = @(Az.Functions\Get-AzFunctionAppPlan @PSBoundParameters)

    foreach ($plan in $plans)
    {
        if ($plan.Name -eq $Name)
        {
            return $plan
        }
    }

    # The plan name was not found, error out
    $errorMessage = "Service plan '$Name' does not exist."
    $exception = [System.InvalidOperationException]::New($errorMessage)
    ThrowTerminatingError -ErrorId "ServicePlanDoesNotExist" `
                          -ErrorMessage $errorMessage `
                          -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                          -Exception $exception
}

function GetStorageAccount
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    if ($PSBoundParameters.ContainsKey("Name"))
    {
        $PSBoundParameters.Remove("Name") | Out-Null
    }

    $storageAccounts = @(Az.Functions.internal\Get-AzStorageAccount @PSBoundParameters -ErrorAction SilentlyContinue)
    foreach ($account in $storageAccounts)
    {
        if ($account.Name -eq $Name)
        {
            return $account
        }
    }
}

function GetApplicationInsightsProject
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    if ($PSBoundParameters.ContainsKey("Name"))
    {
        $PSBoundParameters.Remove("Name") | Out-Null
    }

    $projects = @(Az.Functions.internal\Get-AzAppInsights @PSBoundParameters)
    
    foreach ($project in $projects)
    {
        if ($project.Name -eq $Name)
        {
            return $project
        }
    }
}

function CreateApplicationInsightsProject
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ResourceName,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ResourceGroupName,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Location,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    $paramsToRemove = @(
        "ResourceGroupName",
        "ResourceName",
        "Location"
    )
    foreach ($paramName in $paramsToRemove)
    {
        if ($PSBoundParameters.ContainsKey($paramName))
        {
            $PSBoundParameters.Remove($paramName)  | Out-Null
        }
    }

    # Create a new ApplicationInsights
    $maxNumberOfTries = 3
    $tries = 1

    while ($true)
    {
        try
        {
            $newAppInsightsProject = Az.Functions.internal\New-AzAppInsights -ResourceGroupName $ResourceGroupName `
                                                                             -ResourceName $ResourceName  `
                                                                             -Location $Location `
                                                                             -Kind web `
                                                                             -RequestSource "AzurePowerShell" `
                                                                             -ErrorAction Stop `
                                                                             @PSBoundParameters
            if ($newAppInsightsProject)
            {
                return $newAppInsightsProject
            }
        }
        catch
        {
            # Ignore the failure and continue
        }

        if ($tries -ge $maxNumberOfTries)
        {
            break
        }

        # Wait for 2^(tries-1) seconds between retries. In this case, it would be 1, 2, and 4 seconds, respectively.
        $waitInSeconds = [Math]::Pow(2, $tries - 1)
        Start-Sleep -Seconds $waitInSeconds

        $tries++
    }
}

function ConvertWebAppApplicationSettingToHashtable
{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Object]
        $ApplicationSetting
    )

    # Create a key value pair to hold the function app settings
    $applicationSettings = @{}
    foreach ($keyName in $ApplicationSetting.Property.Keys)
    {
        $applicationSettings[$keyName] = $ApplicationSetting.Property[$keyName]
    }

    return $applicationSettings
}

function AddFunctionAppSettings
{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Object]
        $App,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    if ($PSBoundParameters.ContainsKey("App"))
    {
        $PSBoundParameters.Remove("App") | Out-Null
    }

    $App.AppServicePlan = ($App.ServerFarmId -split "/")[-1]
    $App.OSType = if ($App.kind.ToLower().Contains("linux")){ "Linux" } else { "Windows" }

    if ($App.Type -eq "Microsoft.Web/sites/slots")
    {
        return $App
    }
    
    $currentSubscription = $null
    $resetDefaultSubscription = $false
    
    try
    {
        $settings = Az.Functions.internal\Get-AzWebAppApplicationSetting -Name $App.Name `
                                                                         -ResourceGroupName $App.ResourceGroup `
                                                                         -ErrorAction SilentlyContinue `
                                                                         @PSBoundParameters
        if ($null -eq $settings)
        {
            $resetDefaultSubscription = $true
            $currentSubscription = (Get-AzContext).Subscription.Id
            $null = Select-AzSubscription $App.SubscriptionId

            $settings = Az.Functions.internal\Get-AzWebAppApplicationSetting -Name $App.Name `
                                                                             -ResourceGroupName $App.ResourceGroup `
                                                                             -ErrorAction SilentlyContinue `
                                                                             @PSBoundParameters
            if ($null -eq $settings)
            {
                # We are unable to get the app settings, return the app
                return $App
            }
        }
    }
    finally
    {
        if ($resetDefaultSubscription)
        {
            $null = Select-AzSubscription $currentSubscription
        }
    }

    # Add application settings
    $App.ApplicationSettings = ConvertWebAppApplicationSettingToHashtable -ApplicationSetting $settings

    $runtimeName = $App.ApplicationSettings["FUNCTIONS_WORKER_RUNTIME"]
    $App.Runtime = if (($null -ne $runtimeName) -and ($RuntimeToFormattedName.ContainsKey($runtimeName)))
                   {
                       $RuntimeToFormattedName[$runtimeName]
                   }
                   elseif ($App.ApplicationSettings.ContainsKey("DOCKER_CUSTOM_IMAGE_NAME"))
                   {
                       "Custom Image"
                   }
                   else {""}

    # Get the app site config
    $config = GetAzWebAppConfig -Name $App.Name -ResourceGroupName $App.ResourceGroup @PSBoundParameters
    # Add all site config properties as a hash table
    $SiteConfig = @{}
    foreach ($property in $config.PSObject.Properties)
    {
        if ($property.Name)
        {
            $SiteConfig.Add($property.Name, $property.Value)
        }
    }

    $App.SiteConfig = $SiteConfig

    return $App
}

function GetFunctionApps
{
    param
    (
        [Parameter(Mandatory=$true)]
        [AllowEmptyCollection()]
        [Object[]]
        $Apps,

        [System.String]
        $Location,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    $paramsToRemove = @(
        "Apps",
        "Location"
    )
    foreach ($paramName in $paramsToRemove)
    {
        if ($PSBoundParameters.ContainsKey($paramName))
        {
            $PSBoundParameters.Remove($paramName)  | Out-Null
        }
    }

    if ($Apps.Count -eq 0)
    {
        return
    }

    $activityName = "Getting function apps"

    for ($index = 0; $index -lt $Apps.Count; $index++)
    {
        $app = $Apps[$index]

        $percentageCompleted = [int]((100 * ($index + 1)) / $Apps.Count)
        $status = "Complete: $($index + 1)/$($Apps.Count) function apps processed."
        Write-Progress -Activity "Getting function apps" -Status $status -PercentComplete $percentageCompleted
        
        if ($app.kind.ToLower().Contains("functionapp"))
        {
            if ($Location)
            {
                if ($app.Location -eq $Location)
                {
                    $app = AddFunctionAppSettings -App $app @PSBoundParameters
                    $app
                }
            }
            else
            {
                $app = AddFunctionAppSettings -App $app @PSBoundParameters
                $app
            }
        }
    }

    Write-Progress -Activity $activityName -Status "Completed" -Completed
}

function AddFunctionAppPlanWorkerType
{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $AppPlan,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    if ($PSBoundParameters.ContainsKey("AppPlan"))
    {
        $PSBoundParameters.Remove("AppPlan") | Out-Null
    }

    # The GetList api for service plan that does not set the Reserved property, which is needed to figure out if the OSType is Linux.
    # TODO: Remove this code once  https://msazure.visualstudio.com/Antares/_workitems/edit/5623226 is fixed.
    if ($null -eq $AppPlan.Reserved)
    {
        # Get the service plan by name does set the Reserved property
        $planObject = Az.Functions.internal\Get-AzFunctionAppPlan -Name $AppPlan.Name `
                                                                  -ResourceGroupName $AppPlan.ResourceGroup `
                                                                  -ErrorAction SilentlyContinue `
                                                                  @PSBoundParameters
        $AppPlan = $planObject
    }

    $AppPlan.WorkerType = if ($AppPlan.Reserved){ "Linux" } else { "Windows" }

    return $AppPlan
}

function GetFunctionAppPlans
{
    param
    (
        [Parameter(Mandatory=$true)]
        [AllowEmptyCollection()]
        [Object[]]
        $Plans,

        [System.String]
        $Location,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    $paramsToRemove = @(
        "Plans",
        "Location"
    )
    foreach ($paramName in $paramsToRemove)
    {
        if ($PSBoundParameters.ContainsKey($paramName))
        {
            $PSBoundParameters.Remove($paramName)  | Out-Null
        }
    }

    if ($Plans.Count -eq 0)
    {
        return
    }

    $activityName = "Getting function app plans"

    for ($index = 0; $index -lt $Plans.Count; $index++)
    {
        $plan = $Plans[$index]
        
        $percentageCompleted = [int]((100 * ($index + 1)) / $Plans.Count)
        $status = "Complete: $($index + 1)/$($Plans.Count) function apps plans processed."
        Write-Progress -Activity $activityName -Status $status -PercentComplete $percentageCompleted

        try {
            if ($Location)
            {
                if ($plan.Location -eq $Location)
                {
                    $plan = AddFunctionAppPlanWorkerType -AppPlan $plan @PSBoundParameters
                    $plan
                }
            }
            else
            {
                $plan = AddFunctionAppPlanWorkerType -AppPlan $plan @PSBoundParameters
                $plan
            }
        }
        catch {
            continue;
        }
    }

    Write-Progress -Activity $activityName -Status "Completed" -Completed
}

function ValidateFunctionName
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    $result = Az.Functions.internal\Test-AzNameAvailability -Type Site @PSBoundParameters

    if (-not $result.NameAvailable)
    {
        $errorMessage = "Function name '$Name' is not available.  Please try a different name."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "FunctionAppNameIsNotAvailable" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }
}

function NormalizeSku
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Sku
    )    
    if ($Sku -eq "SHARED")
    {
        return "D1"
    }
    return $Sku
}

function CreateFunctionsIdentity
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $InputObject
    )

    if (-not ($InputObject.Name -and $InputObject.ResourceGroupName -and $InputObject.SubscriptionId))
    {
        $errorMessage = "Input object '$InputObject' is missing one or more of the following properties: Name, ResourceGroupName, SubscriptionId"
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "FailedToCreateFunctionsIdentity" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }

    $functionsIdentity = New-Object -TypeName Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.FunctionsIdentity
    $functionsIdentity.Name = $InputObject.Name
    $functionsIdentity.SubscriptionId = $InputObject.SubscriptionId
    $functionsIdentity.ResourceGroupName = $InputObject.ResourceGroupName

    return $functionsIdentity
}

function GetSkuName
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Sku
    )

    if (($Sku -eq "D1") -or ($Sku -eq "SHARED"))
    {
        return "SHARED"
    }
    elseif (($Sku -eq "B1") -or ($Sku -eq "B2") -or ($Sku -eq "B3") -or ($Sku -eq "BASIC"))
    {
        return "BASIC"
    }
    elseif (($Sku -eq "S1") -or ($Sku -eq "S2") -or ($Sku -eq "S3"))
    {
        return "STANDARD"
    }
    elseif (($Sku -eq "P1") -or ($Sku -eq "P2") -or ($Sku -eq "P3"))
    {
        return "PREMIUM"
    }
    elseif (($Sku -eq "P1V2") -or ($Sku -eq "P2V2") -or ($Sku -eq "P3V2"))
    {
        return "PREMIUMV2"
    }
    elseif (($Sku -eq "PC2") -or ($Sku -eq "PC3") -or ($Sku -eq "PC4"))
    {
        return "PremiumContainer"
    }
    elseif (($Sku -eq "EP1") -or ($Sku -eq "EP2") -or ($Sku -eq "EP3"))
    {
        return "ElasticPremium"
    }
    elseif (($Sku -eq "I1") -or ($Sku -eq "I2") -or ($Sku -eq "I3"))
    {
        return "Isolated"
    }

    $guidanceUrl = 'https://docs.microsoft.com/en-us/azure/azure-functions/functions-premium-plan#plan-and-sku-settings'

    $errorMessage = "Invalid sku (pricing tier), please refer to '$guidanceUrl' for valid values."
    $exception = [System.InvalidOperationException]::New($errorMessage)
    ThrowTerminatingError -ErrorId "InvalidSkuPricingTier" `
                          -ErrorMessage $errorMessage `
                          -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                          -Exception $exception
}

function ThrowTerminatingError
{
    param 
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ErrorId,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ErrorMessage,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.ErrorCategory]
        $ErrorCategory,

        [Exception]
        $Exception,

        [object]
        $TargetObject
    )

    if (-not $Exception)
    {
        $Exception = New-Object -TypeName System.Exception -ArgumentList $ErrorMessage
    }

    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList ($Exception, $ErrorId, $ErrorCategory, $TargetObject)
    #$PSCmdlet.ThrowTerminatingError($errorRecord)
    throw $errorRecord
}

function GetErrorMessage
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        $Response
    )

    if ($Response.Exception.ResponseBody)
    {
        try
        {
            $details = ConvertFrom-Json $Response.Exception.ResponseBody
            if ($details.Message)
            {
                return $details.Message
            }
        }
        catch 
        {
            # Ignore the deserialization error
        }
    }
}

function GetSupportedRuntimes
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $OSType
    )

    if ($OSType -eq "Linux")
    {
        return $LinuxRuntimes
    }
    elseif ($OSType -eq "Windows")
    {
        return $WindowsRuntimes
    }

    throw "Unknown OS type '$OSType'"
}

function ValidateFunctionsVersion
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $FunctionsVersion
    )

    if ($SupportedFunctionsVersion -notcontains $FunctionsVersion)
    {
        $currentlySupportedFunctionsVersions = $SupportedFunctionsVersion -join ' and '
        $errorMessage = "Functions version not supported. Currently supported version are: $($currentlySupportedFunctionsVersions)."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "FunctionsVersionIsInvalid" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }
}

function ValidateFunctionsV2NotAvailableLocation
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Location
    )

    $Location = $Location.Trim()

    $locationsWithNoV2Version = $FunctionsNoV2Version

    if (-not $Location.Contains(" "))
    {
        $locationsWithNoV2Version = @($FunctionsNoV2Version | ForEach-Object { $_.Replace(" ", "") })
    }

    if ($locationsWithNoV2Version -contains $Location)
    {
        $errorMessage = "Functions version 2 is not supported in this region. To create a version 3 function, specify -FunctionsVersion 3"
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "FunctionsV2IsNotSuportedInThisRegion" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }
}

function GetDefaultOSType
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Runtime
    )

    $defaultOSType = $RuntimeToDefaultOSType[$Runtime]

    if (-not $defaultOSType)
    {
        # The specified runtime did not match, error out
        $runtimeOptions = FormatListToString -List @($RuntimeToDefaultOSType.Keys | Sort-Object)
        $errorMessage = "Runtime '$Runtime' is not supported. Currently supported runtimes: " + $runtimeOptions + "."
        ThrowRuntimeNotSupportedException -Message $errorMessage -ErrorId "RuntimeNotSupported"
    }

    return $defaultOSType
}

function GetRuntimeJsonDefinition
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $FunctionsVersion,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Runtime,

        [Parameter(Mandatory=$false)]
        [System.String]
        $RuntimeVersion,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $OSType
    )

    $functionsExtensionVersion = "~$FunctionsVersion"
    $supportedRuntimes = GetSupportedRuntimes -OSType $OSType

    if (-not $supportedRuntimes.ContainsKey($Runtime))
    {
        $runtimeOptions = FormatListToString -List @($supportedRuntimes.Keys | ForEach-Object { $RuntimeToFormattedName[$_]} | Sort-Object)
        $errorMessage = "Runtime '$Runtime' in Functions version '$FunctionsVersion' on '$OSType' is not supported. Currently supported runtimes: " + $runtimeOptions + "."

        ThrowRuntimeNotSupportedException -Message $errorMessage -ErrorId "RuntimeNotSupported"
    }

    # If runtime version is not provided, iterate through the SupportedRuntimes to get the default version
    # based the function extension version, os type and runtime. 
    if (-not $RuntimeVersion)
    {
        $latestVersion = [Version]::new("0.0")
        $defaultVersionFound = $false
        $versionIsInt = $false

        foreach ($version in $supportedRuntimes[$Runtime].MajorVersions.Keys)
        {
            $majorVersion = $supportedRuntimes[$Runtime].MajorVersions[$version]

            if ($majorVersion.IsDefault -and ($majorVersion.SupportedFunctionsExtensionVersions -contains $functionsExtensionVersion))
            {
                if (-not $version.Contains("."))
                {
                    $versionIsInt = $true
                    $version = $version + ".0"
                }

                $thisVersion = $null
                [Version]::TryParse($version, [ref]$thisVersion)

                if (($null -ne $thisVersion ) -and ($thisVersion -gt $latestVersion))
                {
                    $latestVersion = $thisVersion
                    $defaultVersionFound = $true
                }
            }
        }

        # Error out if we could not find a default version for the given runtime, functions extension version, and os type
        if (-not $defaultVersionFound)
        {
            $errorMessage = "Runtime '$Runtime' in Functions version '$FunctionsVersion' on '$OSType' is not supported."
            ThrowRuntimeNotSupportedException -Message $errorMessage -ErrorId "RuntimeVersionNotSupported"
        }

        if ($versionIsInt)
        {
            $RuntimeVersion = $latestVersion.Major
        }
        else
        {
            $RuntimeVersion = $latestVersion.ToString()
        }

        Write-Verbose "RuntimeVersion not specified. Setting default runtime version for '$Runtime' to '$RuntimeVersion'." -Verbose
    }

    # Get the RuntimeJsonDefinition
    $runtimeJsonDefinition = $supportedRuntimes[$Runtime].MajorVersions[$RuntimeVersion]
    
    if ((-not $runtimeJsonDefinition) -or (-not ($runtimeJsonDefinition.SupportedFunctionsExtensionVersions -contains $functionsExtensionVersion)))
    {
        $errorMessage = "Runtime '$Runtime' version '$RuntimeVersion' in Functions version '$FunctionsVersion' on '$OSType' is not supported."
        $supporedVersions = @(GetSupportedRuntimeVersions -FunctionsVersion $FunctionsVersion -Runtime $Runtime -OSType $OSType)

        if ($supporedVersions.Count -gt 0)
        {
            $runtimeVersionOptions = FormatListToString -List @($supporedVersions | Sort-Object)
            $errorMessage += " Currently supported runtime versions for '$($Runtime)' are: $runtimeVersionOptions."
        }

        ThrowRuntimeNotSupportedException -Message $errorMessage -ErrorId "RuntimeVersionNotSupported"
    }
    
    if ($runtimeJsonDefinition.IsPreview)
    {
        # Write a verbose message to the user if the current runtime is in Preview
        Write-Verbose "Runtime '$Runtime' version '$RuntimeVersion' is in Preview." -Verbose
    }

    return $runtimeJsonDefinition
}

function ThrowRuntimeNotSupportedException
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Message,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ErrorId
    )

    $Message += [System.Environment]::NewLine
    $Message += "For supported languages, please visit 'https://docs.microsoft.com/en-us/azure/azure-functions/functions-versions#languages'."

    $exception = [System.InvalidOperationException]::New($Message)
    ThrowTerminatingError -ErrorId $ErrorId `
                          -ErrorMessage $Message `
                          -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                          -Exception $exception
}

function GetSupportedRuntimeVersions
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $FunctionsVersion,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Runtime,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $OSType
    )

    $functionsExtensionVersion = "~$FunctionsVersion"
    $supportedRuntimes = GetSupportedRuntimes -OSType $OSType

    $result = @()

    foreach ($runtimeVersion in $supportedRuntimes[$Runtime].MajorVersions.Keys)
    {
        $majorVersion = $supportedRuntimes[$Runtime].MajorVersions[$runtimeVersion]
        if ($majorVersion.SupportedFunctionsExtensionVersions -contains $functionsExtensionVersion)
        {
            $result += $runtimeVersion
        }
    }

    return ($result | Sort-Object)
}

function FormatListToString
{
    param
    (
        [Parameter(Mandatory=$true)]
        [System.String[]]
        $List
    )
    
    if ($List.Count -eq 0)
    {
        return
    }

    $result = ""

    if ($List.Count -eq 1)
    {
        $result = "'" + $List[0] + "'"
    }
    
    else
    {
        for ($index = 0; $index -lt ($List.Count - 1); $index++)
        {
            $item = $List[$index]
            $result += "'" + $item + "', "
        }

        $result += "'" + $List[$List.Count - 1] + "'"
    }
    
    return $result
}

function ValidatePlanLocation
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Location,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        [ValidateSet("Dynamic", "ElasticPremium")]
        $PlanType,

        [Parameter(Mandatory=$false)]
        [System.Management.Automation.SwitchParameter]
        $OSIsLinux,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    $paramsToRemove = @(
        "PlanType",
        "OSIsLinux",
        "Location"
    )
    foreach ($paramName in $paramsToRemove)
    {
        if ($PSBoundParameters.ContainsKey($paramName))
        {
            $PSBoundParameters.Remove($paramName)  | Out-Null
        }
    }

    $Location = $Location.Trim()
    $locationContainsSpace = $Location.Contains(" ")

    $availableLocations = @(Az.Functions.internal\Get-AzFunctionAppAvailableLocation -Sku $PlanType `
                                                                                     -LinuxWorkersEnabled:$OSIsLinux `
                                                                                     @PSBoundParameters | ForEach-Object { $_.Name })

    if (-not $locationContainsSpace)
    {
        $availableLocations = @($availableLocations | ForEach-Object { $_.Replace(" ", "") })
    }

    if (-not ($availableLocations -contains $Location))
    {
        $errorMessage = "Location is invalid. Use 'Get-AzFunctionAppAvailableLocation' to see available locations for running function apps."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "LocationIsInvalid" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }
}

function ValidatePremiumPlanLocation
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Location,

        [Parameter(Mandatory=$false)]
        [System.Management.Automation.SwitchParameter]
        $OSIsLinux,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    ValidatePlanLocation -PlanType ElasticPremium @PSBoundParameters
}

function ValidateConsumptionPlanLocation
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Location,

        [Parameter(Mandatory=$false)]
        [System.Management.Automation.SwitchParameter]
        $OSIsLinux,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    ValidatePlanLocation -PlanType Dynamic @PSBoundParameters
}

function GetParameterKeyValues
{
    param
    (
        [Parameter(Mandatory=$true)]
        [System.Collections.Generic.Dictionary[string, object]]
        [ValidateNotNull()]
        $PSBoundParametersDictionary,

        [Parameter(Mandatory=$true)]
        [System.String[]]
        [ValidateNotNull()]
        $ParameterList
    )

    $params = @{}
    if ($ParameterList.Count -gt 0)
    {
        foreach ($paramName in $ParameterList)
        {
            if ($PSBoundParametersDictionary.ContainsKey($paramName))
            {
                $params[$paramName] = $PSBoundParametersDictionary[$paramName]
            }
        }
    }
    return $params
}

function NewResourceTag
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [hashtable]
        $Tag
    )

    $resourceTag = [Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.Api20190801.ResourceTags]::new()

    foreach ($tagName in $Tag.Keys)
    {
        $resourceTag.Add($tagName, $Tag[$tagName])
    }
    return $resourceTag
}

function ParseDockerImage
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DockerImageName
    )

    # Sample urls:
    # myacr.azurecr.io/myimage:tag
    # mcr.microsoft.com/azure-functions/powershell:2.0
    if ($DockerImageName.Contains("/"))
    {
        $index = $DockerImageName.LastIndexOf("/")
        $value = $DockerImageName.Substring(0,$index)
        if ($value.Contains(".") -or $value.Contains(":"))
        {
            return $value
        }
    }
}

function GetFunctionAppServicePlanInfo
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ServerFarmId,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    if ($PSBoundParameters.ContainsKey("ServerFarmId"))
    {
        $PSBoundParameters.Remove("ServerFarmId") | Out-Null
    }

    $planInfo = $null

    if ($ServerFarmId.Contains("/"))
    {
        $parts = $ServerFarmId -split "/"

        $planName = $parts[-1]
        $resourceGroupName = $parts[-5]

        $planInfo = Az.Functions\Get-AzFunctionAppPlan -Name $planName `
                                                       -ResourceGroupName $resourceGroupName `
                                                       @PSBoundParameters
    }

    if (-not $planInfo)
    {
        $errorMessage = "Could not determine the current plan of the functionapp."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "CouldNotDetermineFunctionAppPlan" `
                            -ErrorMessage $errorMessage `
                            -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                            -Exception $exception

    }

    return $planInfo
}

function ValidatePlanSwitchCompatibility
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $CurrentServicePlan,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $NewServicePlan
    )

    if (-not (($CurrentServicePlan.SkuTier -eq "ElasticPremium") -or ($CurrentServicePlan.SkuTier -eq "Dynamic") -or
              ($NewServicePlan.SkuTier -eq "ElasticPremium") -or ($NewServicePlan.SkuTier -eq "Dynamic")))
    {
        $errorMessage = "Currently the switch is only allowed between a Consumption or an Elastic Premium plan."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "InvalidFunctionAppPlanSwitch" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }
}

function NewAppSettingObject
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Hashtable]
        $CurrentAppSetting
    )

    # Create StringDictionaryProperties (hash table) with the app settings
    $properties = New-Object -TypeName Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.Api20190801.StringDictionaryProperties

    foreach ($keyName in $currentAppSettings.Keys)
    {
        $properties.Add($keyName, $currentAppSettings[$keyName])
    }

    $appSettings = New-Object -TypeName Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.Api20190801.StringDictionary
    $appSettings.Property = $properties

    return $appSettings
}

function ContainsReservedFunctionAppSettingName
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $AppSettingName
    )

    foreach ($name in $AppSettingName)
    {
        if ($ReservedFunctionAppSettingNames.Contains($name))
        {
            return $true
        }
    }

    return $false
}

function GetFunctionAppByName
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ResourceGroupName,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    $paramsToRemove = @(
        "Name",
        "ResourceGroupName"
    )
    foreach ($paramName in $paramsToRemove)
    {
        if ($PSBoundParameters.ContainsKey($paramName))
        {
            $PSBoundParameters.Remove($paramName)  | Out-Null
        }
    }

    $existingFunctionApp = Az.Functions\Get-AzFunctionApp -ResourceGroupName $ResourceGroupName `
                                                          -Name $Name `
                                                          -ErrorAction SilentlyContinue `
                                                          @PSBoundParameters

    if (-not $existingFunctionApp)
    {
        $errorMessage = "Function app name '$Name' in resource group name '$ResourceGroupName' does not exist."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "FunctionAppDoesNotExist" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }

    return $existingFunctionApp
}

function GetAzWebAppConfig
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ResourceGroupName,

        [Switch]
        $ErrorIfResultIsNull,

        $SubscriptionId,
        $HttpPipelineAppend,
        $HttpPipelinePrepend
    )

    if ($PSBoundParameters.ContainsKey("ErrorIfResultIsNull"))
    {
        $PSBoundParameters.Remove("ErrorIfResultIsNull") | Out-Null
    }

    $resetDefaultSubscription = $false
    $webAppConfig = $null
    try
    {
        $webAppConfig = Az.Functions.internal\Get-AzWebAppConfiguration -ErrorAction SilentlyContinue `
                                                                        @PSBoundParameters

        if ($null -eq $webAppConfig)
        {
            $resetDefaultSubscription = $true

            $currentSubscription = (Get-AzContext).Subscription.Id
            $null = Select-AzSubscription $App.SubscriptionId

            $webAppConfig = Az.Functions.internal\Get-AzWebAppConfiguration -ResourceGroupName $ResourceGroupName `
                                                                            -Name $Name `
                                                                            -ErrorAction SilentlyContinue `
                                                                            @PSBoundParameters
        }
    }
    finally
    {
        if ($resetDefaultSubscription)
        {
            $null = Select-AzSubscription $currentSubscription
        }
    }

    if ((-not $webAppConfig) -and $ErrorIfResultIsNull)
    {
        $errorMessage = "Falied to get config for function app name '$Name' in resource group name '$ResourceGroupName'."
        $exception = [System.InvalidOperationException]::New($errorMessage)
        ThrowTerminatingError -ErrorId "FaliedToGetFunctionAppConfig" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }

    return $webAppConfig
}

function NewIdentityUserAssignedIdentity
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $IdentityID
    )

    # If creating user assigned identities, only alphanumeric characters (0-9, a-z, A-Z), the underscore (_) and the hyphen (-) are supported.
    $msiUserAssignedIdentities = New-Object -TypeName Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.Api20190801.ManagedServiceIdentityUserAssignedIdentities

    foreach ($id in $IdentityID)
    {
        $functionAppUserAssignedIdentitiesValue = New-Object -TypeName Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.Api20190801.Components1Jq1T4ISchemasManagedserviceidentityPropertiesUserassignedidentitiesAdditionalproperties
        $msiUserAssignedIdentities.Add($IdentityID, $functionAppUserAssignedIdentitiesValue)
    }

    return $msiUserAssignedIdentities
}

# Set Linux and Windows supported runtimes
Class Runtime {
    [string]$Name
    [hashtable]$MajorVersions
}

Class MajorVersion {
    [string]$DisplayVersion
    [string]$RuntimeVersion
    [string[]]$SupportedFunctionsExtensionVersions
    [hashtable]$AppSettingsDictionary
    [hashtable]$SiteConfigPropertiesDictionary
    [bool]$IsPreview
    [bool]$IsDeprecated
    [bool]$IsHidden
    [bool]$IsDefault
}

$LinuxRuntimes = @{}
$WindowsRuntimes = @{}
$RuntimeVersions = @{}

function SetLinuxandWindowsSupportedRuntimes
{
    foreach ($fileName in @("LinuxFunctionsStacks.json", "WindowsFunctionsStacks.json"))
    {
        $filePath = Join-Path "$PSScriptRoot/FunctionsStack" $fileName

        if (-not (Test-Path $filePath))
        {
            throw "Unable to create list of supported runtimes. File path '$filePath' does not exist."
        }

        $functionsStack = Get-Content -Path $filePath -Raw | ConvertFrom-Json

        foreach ($stack in $functionsStack.value)
        {
            $runtime = [Runtime]::new()
            $runtime.name = $stack.name
            $majorVersions = @{}

            foreach ($version in $stack.properties.majorVersions)
            {
                if ([String]::IsNullOrEmpty($version.displayVersion))
                {
                    throw "DisplayVersion cannot be null or empty for '$($runtime.name)."
                }

                $majorVersion = [MajorVersion]::new()

                # For DotNet, the runtime version is the same as FunctionsVersion, e.g., 3 for 3.1 and 2 for 2.2
                $displayVersion = $version.displayVersion
                
                if ($runtime.name -eq "DotNet")
                {
                    $displayVersion = [int]$displayVersion
                }

                $majorVersion.DisplayVersion = $displayVersion
                $majorVersion.RuntimeVersion = $version.runtimeVersion
                $majorVersion.SupportedFunctionsExtensionVersions = $version.supportedFunctionsExtensionVersions

                # Add the optional properties if available
                foreach ($propertyName in @("isPreview", "isDeprecated", "isHidden", "isDefault"))
                {
                    if (-not [String]::IsNullOrEmpty($version.$propertyName))
                    {
                        $majorVersion.$propertyName = $version.$propertyName
                    }
                }

                # Skip deprecated runtimes
                if ($majorVersion.IsDeprecated)
                {
                    continue
                }

                # Skip hidden runtimes if $env:DisplayHiddenRuntimes is set to false
                if ($majorVersion.isHidden -and (-not $env:DisplayHiddenRuntimes))
                {
                    continue
                }

                # Add AppSettingsDictionary properties
                if (-not $version.appSettingsDictionary)
                {
                    throw "AppSettingsDictionary for $($runtime.name) $($majorVersion.DisplayVersion) cannot be null or empty"
                }

                $appSettings = @{}
                foreach ($property in $version.appSettingsDictionary.PSObject.Properties)
                {
                    $appSettings.Add($property.Name, $property.Value)
                }

                $majorVersion.appSettingsDictionary = $appSettings

                # Add siteConfigPropertiesDictionary properties
                if (-not $version.siteConfigPropertiesDictionary)
                {
                    throw "SiteConfigPropertiesDictionary for $($runtime.name) $($majorVersion.DisplayVersion) cannot be null or empty"
                }

                $siteConfigProperties = @{}
                foreach ($property in $version.siteConfigPropertiesDictionary.PSObject.Properties)
                {
                    $siteConfigProperties.Add($property.Name, $property.Value)
                }

                $majorVersion.SiteConfigPropertiesDictionary = $siteConfigProperties

                # Add the major version as a key value pair. These properties will be retrieved via $supportedRuntimes[$Runtime].MajorVersions[$RuntimeVersion]
                $majorVersions[[string]$displayVersion] = $majorVersion

                # Create a dictionary where the key is the runtime and the value is a list of runtime versions.
                # This will be used to register the tab completer for -RuntimeVersion based on the selection of -Runtime parameter.
                if ($RuntimeVersions.ContainsKey($runtime.name))
                {
                    $list = $RuntimeVersions[$runtime.name]
                }
                else
                {
                    $list = @()
                }

                # Sort-Object works differently when sorting strings vs numeric values.
                # Because of this, if the runtimeVersion value contains a ".", we cast this to [double]; otherwise, we cast it to an [int].
                # For the case when the Runtime is PowerShell, we cast the value to string. Otherwise, casting 7.0 to [double] results in 7, which is not correct for our scenario. 
                if ($runtime.name -eq "PowerShell")
                {
                    $displayVersion = [string]$displayVersion
                }
                elseif (([string]$displayVersion).Contains("."))
                {
                    $displayVersion = [double]$displayVersion
                }
                else
                {
                    $displayVersion = [int]$displayVersion
                }

                if (-not $list.Contains($displayVersion))
                {
                    $list += $displayVersion
                    $list = @($list | Sort-Object -Descending)
                    $RuntimeVersions[$runtime.name] = $list
                }
            }

            $runtime.MajorVersions = $majorVersions

            if ($stack.type -like "*LinuxFunctions")
            {
                if (-not $LinuxRuntimes.ContainsKey($runtime.name))
                {
                    $LinuxRuntimes[$runtime.name] = $runtime
                }
            }
            elseif ($stack.type -like "*WindowsFunctions")
            {
                if (-not $WindowsRuntimes.ContainsKey($runtime.name))
                {
                    $WindowsRuntimes[$runtime.name] = $runtime
                }
            }
            else
            {
                throw "Unknown stack type '$($stack.type)'"
            }
        }
    }
}
SetLinuxandWindowsSupportedRuntimes

# New-AzFunction app ArgumentCompleter for the RuntimeVersion parameter
# The values of RuntimeVersion depend on the selection of the Runtime parameter
$GetRuntimeVersionCompleter = {

    param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    if ($fakeBoundParameters.ContainsKey('Runtime'))
    {
        # RuntimeVersions is defined in SetLinuxandWindowsSupportedRuntimes
        $RuntimeVersions[$fakeBoundParameters.Runtime] | Where-Object {
            $_ -like "$wordToComplete*"
        } | ForEach-Object { [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_) }
    }
    else
    {
        $RuntimeVersions.RuntimeVersion | Sort-Object -Descending | ForEach-Object { $_ }
    }
}
Register-ArgumentCompleter -CommandName New-AzFunctionApp -ParameterName RuntimeVersion -ScriptBlock $GetRuntimeVersionCompleter

# SIG # Begin signature block
# MIIjkgYJKoZIhvcNAQcCoIIjgzCCI38CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAzu8dft70vbsAj
# 5/RtCgDXC435+qHDkHCatQ94Y2JP8qCCDYEwggX/MIID56ADAgECAhMzAAABh3IX
# chVZQMcJAAAAAAGHMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjAwMzA0MTgzOTQ3WhcNMjEwMzAzMTgzOTQ3WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDOt8kLc7P3T7MKIhouYHewMFmnq8Ayu7FOhZCQabVwBp2VS4WyB2Qe4TQBT8aB
# znANDEPjHKNdPT8Xz5cNali6XHefS8i/WXtF0vSsP8NEv6mBHuA2p1fw2wB/F0dH
# sJ3GfZ5c0sPJjklsiYqPw59xJ54kM91IOgiO2OUzjNAljPibjCWfH7UzQ1TPHc4d
# weils8GEIrbBRb7IWwiObL12jWT4Yh71NQgvJ9Fn6+UhD9x2uk3dLj84vwt1NuFQ
# itKJxIV0fVsRNR3abQVOLqpDugbr0SzNL6o8xzOHL5OXiGGwg6ekiXA1/2XXY7yV
# Fc39tledDtZjSjNbex1zzwSXAgMBAAGjggF+MIIBejAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUhov4ZyO96axkJdMjpzu2zVXOJcsw
# UAYDVR0RBEkwR6RFMEMxKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1
# ZXJ0byBSaWNvMRYwFAYDVQQFEw0yMzAwMTIrNDU4Mzg1MB8GA1UdIwQYMBaAFEhu
# ZOVQBdOCqhc3NyK1bajKdQKVMFQGA1UdHwRNMEswSaBHoEWGQ2h0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY0NvZFNpZ1BDQTIwMTFfMjAxMS0w
# Ny0wOC5jcmwwYQYIKwYBBQUHAQEEVTBTMFEGCCsGAQUFBzAChkVodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY0NvZFNpZ1BDQTIwMTFfMjAx
# MS0wNy0wOC5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAixmy
# S6E6vprWD9KFNIB9G5zyMuIjZAOuUJ1EK/Vlg6Fb3ZHXjjUwATKIcXbFuFC6Wr4K
# NrU4DY/sBVqmab5AC/je3bpUpjtxpEyqUqtPc30wEg/rO9vmKmqKoLPT37svc2NV
# BmGNl+85qO4fV/w7Cx7J0Bbqk19KcRNdjt6eKoTnTPHBHlVHQIHZpMxacbFOAkJr
# qAVkYZdz7ikNXTxV+GRb36tC4ByMNxE2DF7vFdvaiZP0CVZ5ByJ2gAhXMdK9+usx
# zVk913qKde1OAuWdv+rndqkAIm8fUlRnr4saSCg7cIbUwCCf116wUJ7EuJDg0vHe
# yhnCeHnBbyH3RZkHEi2ofmfgnFISJZDdMAeVZGVOh20Jp50XBzqokpPzeZ6zc1/g
# yILNyiVgE+RPkjnUQshd1f1PMgn3tns2Cz7bJiVUaqEO3n9qRFgy5JuLae6UweGf
# AeOo3dgLZxikKzYs3hDMaEtJq8IP71cX7QXe6lnMmXU/Hdfz2p897Zd+kU+vZvKI
# 3cwLfuVQgK2RZ2z+Kc3K3dRPz2rXycK5XCuRZmvGab/WbrZiC7wJQapgBodltMI5
# GMdFrBg9IeF7/rP4EqVQXeKtevTlZXjpuNhhjuR+2DMt/dWufjXpiW91bo3aH6Ea
# jOALXmoxgltCp1K7hrS6gmsvj94cLRf50QQ4U8Qwggd6MIIFYqADAgECAgphDpDS
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
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAYdyF3IVWUDHCQAAAAABhzAN
# BglghkgBZQMEAgEFAKCBrjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgdfFeeAmx
# z+S9zXid1otxyOyu59udkIXFqhrErFwdaUswQgYKKwYBBAGCNwIBDDE0MDKgFIAS
# AE0AaQBjAHIAbwBzAG8AZgB0oRqAGGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbTAN
# BgkqhkiG9w0BAQEFAASCAQCf7vV39ikYaPUXwSctn+CpKVjpLif06wzpoEbMMaHu
# rSBIIMWj3Pe7hcNWg3ioBMScRcbt1qIbow2rvngLh0jJJT94BoSOcveRX//uztBo
# VszJn8tsx9jkFzRfz7gnAdq/ynp6Gjq1FBTFEWF7WCs9H1xCCgu/rQje4w5Xnyh0
# chSkpqfo6vejL91U+MItqS7c4hOaDGDmEcygMZjNjC2lLcDT44G6/xZMQ7cZh+3Q
# 8Ck9pSK7ErnJrE8bJaQ9vkl5ka3+SS/0ZkJC7hp4L7bIkYcIHd1Ly/7x54KWU7Ur
# bZxvPVzAuOHmfCW/L3ZUKwb8jIzZUawO9nV+W941vXv4oYIS8TCCEu0GCisGAQQB
# gjcDAwExghLdMIIS2QYJKoZIhvcNAQcCoIISyjCCEsYCAQMxDzANBglghkgBZQME
# AgEFADCCAVUGCyqGSIb3DQEJEAEEoIIBRASCAUAwggE8AgEBBgorBgEEAYRZCgMB
# MDEwDQYJYIZIAWUDBAIBBQAEIAlp0jLq1w+EQGJwbPcKvwgjmJKEqesWPD0V4ug5
# 34NQAgZfiENfmYYYEzIwMjAxMDIzMDM1NzIwLjk3MlowBIACAfSggdSkgdEwgc4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKTAnBgNVBAsTIE1p
# Y3Jvc29mdCBPcGVyYXRpb25zIFB1ZXJ0byBSaWNvMSYwJAYDVQQLEx1UaGFsZXMg
# VFNTIEVTTjo3ODgwLUUzOTAtODAxNDElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgU2VydmljZaCCDkQwggT1MIID3aADAgECAhMzAAABKKAOgeE21U/CAAAA
# AAEoMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEw
# MB4XDTE5MTIxOTAxMTUwMFoXDTIxMDMxNzAxMTUwMFowgc4xCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVy
# YXRpb25zIFB1ZXJ0byBSaWNvMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjo3ODgw
# LUUzOTAtODAxNDElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2Vydmlj
# ZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJ2Rsdb3VNuGPs2/Dgpc
# 9gt77LG0JPkD4VWTlEJLkqznTJl+RoZfiOwN6iWfPu4k/kj8nwY7pvLs1OsBy494
# yusg4rHLwHNUJPtw1Tc54MOLgdcosA4Nxki73fDyqWwDtjOdk6H7kNczBPqADD6B
# 98ot77/wSACBJIxm9qAUudquS5fczCF0++aWUavDu46U3cv6HEjIdV2ZdJTUKg4W
# UIdTYMQXI082+qSs45WBZjcK98/tIfx8uq8q8ksWF9+zUjGTFiMaKHhn7cSCoEj7
# E1tVmW08ISpS678WFP2+A0OQwaWcJKNACK+J+La7Lz2bGupCidOGz5XDewc1lD9n
# LPcCAwEAAaOCARswggEXMB0GA1UdDgQWBBSE4vKD8X61N5vUAcNOdH9QBMum8jAf
# BgNVHSMEGDAWgBTVYzpcijGQ80N7fEYbxTNoWoVtVTBWBgNVHR8ETzBNMEugSaBH
# hkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNU
# aW1TdGFQQ0FfMjAxMC0wNy0wMS5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUF
# BzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1RpbVN0
# YVBDQV8yMDEwLTA3LTAxLmNydDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoGCCsG
# AQUFBwMIMA0GCSqGSIb3DQEBCwUAA4IBAQCLX2ZHGIULgDk/iccHWUywjDyAsBHl
# hkmtmBp4lldwL3dNo0bXZZHiSZB+c2KzvPqY64BlECjS/Pqur2m9UaT1N0BeUowR
# HQT88wdzd94gYqKXmLDbVR8yeVgBkcP/JiVWbXdQzcz1ETHgWrh+uzA8BwUgAaHJ
# w+nXYccIuDgPJM1UTeNl9R5Ovf+6zR2E5ZI4DrIqvS4jH4QsoMPTn27AjN7VZt4a
# moRxMLEcQAS7vPT1JUUaRFpFHmkUYVln1YMsw///6968aRvy3cmClS44uxkkaILb
# hh1h09ejZjHhrEn+k9McVkWiuY724jJ/57tylM7A/jzIWNj1F8VlhkyyMIIGcTCC
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
# cGVyYXRpb25zIFB1ZXJ0byBSaWNvMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjo3
# ODgwLUUzOTAtODAxNDElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2Vy
# dmljZaIjCgEBMAcGBSsOAwIaAxUAMT1LG/KAEj0XsiL9n7mxmX1afZuggYMwgYCk
# fjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
# Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDANBgkqhkiG9w0BAQUFAAIF
# AOM8pKkwIhgPMjAyMDEwMjMwNDM5MDVaGA8yMDIwMTAyNDA0MzkwNVowdzA9Bgor
# BgEEAYRZCgQBMS8wLTAKAgUA4zykqQIBADAKAgEAAgIg/AIB/zAHAgEAAgISKTAK
# AgUA4z32KQIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgorBgEEAYRZCgMCoAowCAIB
# AAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBBQUAA4GBAGBprzQOd8tLezMs
# +5ldTBOQNz7uZbdBUid/pGyL7sswt3DAJ+POm8WwWSF9BQLBC9xwIP3h43ldUdtT
# Z41yjN00Hu+bJRtyxIz0Zy9N/pDRyIQX4NlIG+8nNYRyn2Z17hFfOsgrJyYrUb59
# AHiuOxJR8JsnHG0MAZl+nPLwWc6ZMYIDDTCCAwkCAQEwgZMwfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTACEzMAAAEooA6B4TbVT8IAAAAAASgwDQYJYIZIAWUD
# BAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0B
# CQQxIgQgFjkMb/LU1CYISeNAV8fpYX2JPZRisa4LzyYIgKL92fcwgfoGCyqGSIb3
# DQEJEAIvMYHqMIHnMIHkMIG9BCC8RWqLrwVSd+/cGxDfBqS4b1tPXhoPFrC615vV
# 1ugU2jCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAB
# KKAOgeE21U/CAAAAAAEoMCIEIIvyjals9k62oKwHPrLwT81E8LeXYyFvr7fSrBT3
# 8jM1MA0GCSqGSIb3DQEBCwUABIIBADSdq2YUrIdV+TYI5vOBL8cf1g44Doy0A+pJ
# a77/7uSyT7FUTZPzlPoWfSBmfCN5zBmoB/yDpBn3Pj+KtBBTDxCrj0r0zKOCG51m
# j+PIgdeft4aD4Muj4qvB/R2uFZvYoe4irQ7ZNHCGpHqa531hMYDEc9E6ZyOyzR12
# EsumBYI69XUlOs8jC2lcp1YKtUaLfM34EOHoP++RmXLIju6eR+ym1BccaueDMGW1
# JHrWESNlY3I/NC4YEMff0S77LQrDRLroXZwshjpzJrnCRwvv9SGV3ZomRfyjpB/s
# mDmWFdWh48uQIZ4ctqwz8Xa1+KbsKhob6hUojZzRFy9kH0F+6ds=
# SIG # End signature block
