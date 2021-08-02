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
$constants["SupportedFunctionsVersion"] = @('3')
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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

    $suffix = GetEndpointSuffix
    $accountKey = $keys[0].Value

    $connectionString = "DefaultEndpointsProtocol=https;AccountName=$StorageAccountName;AccountKey=$accountKey" + $suffix

    return $connectionString
}

function GetEndpointSuffix
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param()

    $environmentName = (Get-AzContext).Environment.Name

    switch ($environmentName)
    {
        "AzureUSGovernment" { ';EndpointSuffix=core.usgovcloudapi.net' }
        "AzureChinaCloud"   { ';EndpointSuffix=core.chinacloudapi.cn' }
        "AzureGermanCloud"  { ';EndpointSuffix=core.cloudapi.de' }
        "AzureCloud"        { ';EndpointSuffix=core.windows.net' }
        default { '' }
    }
}

function NewAppSetting
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [Parameter(Mandatory=$false)]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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

    $guidanceUrl = 'https://docs.microsoft.com/azure/azure-functions/functions-premium-plan#plan-and-sku-settings'

    $errorMessage = "Invalid sku (pricing tier), please refer to '$guidanceUrl' for valid values."
    $exception = [System.InvalidOperationException]::New($errorMessage)
    ThrowTerminatingError -ErrorId "InvalidSkuPricingTier" `
                          -ErrorMessage $errorMessage `
                          -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                          -Exception $exception
}

function ThrowTerminatingError
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
        ThrowTerminatingError -ErrorId "FunctionsVersionNotSupported" `
                              -ErrorMessage $errorMessage `
                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                              -Exception $exception
    }
}

function ValidateFunctionsV2NotAvailableLocation
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    $Message += "For supported languages, please visit 'https://docs.microsoft.com/azure/azure-functions/functions-versions#languages'."

    $exception = [System.InvalidOperationException]::New($Message)
    ThrowTerminatingError -ErrorId $ErrorId `
                          -ErrorMessage $Message `
                          -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                          -Exception $exception
}

function GetSupportedRuntimeVersions
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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

    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
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

function GetShareSuffix
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Int]
        $Length = 8
    )

    $letters = 'a'..'z'
    $numbers = 0..9
    $alphanumericLowerCase = $letters + $numbers

    $suffix = [System.Text.StringBuilder]::new()

    for ($index = 0; $index -lt $Length; $index++)
    {
        $value = $alphanumericLowerCase | Get-Random
        $suffix.Append($value) | Out-Null
    }

    $suffix.ToString()
}

function GetShareName
{
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $FunctionAppName
    )

    $FunctionAppName = $FunctionAppName.ToLower()

    if ($env:FunctionsTestMode)
    {
        # To support the tests' playback mode, we need to have the same values for each function app creation payload.
        # Adding this test hook will allows us to have a constant share name when creation an app.

        return $FunctionAppName
    }

    <#
    Share name restrictions:
        - A share name must be a valid DNS name.
        - Share names must start with a letter or number, and can contain only letters, numbers, and the dash (-) character.
        - Every dash (-) character must be immediately preceded and followed by a letter or number; consecutive dashes are not permitted in share names.
        - All letters in a share name must be lowercase.
        - Share names must be from 3 through 63 characters long.

    Docs: https://docs.microsoft.com/en-us/rest/api/storageservices/naming-and-referencing-shares--directories--files--and-metadata#share-names
    #>

    # Share name will be function app name + 8 random char suffix with a max length of 60
    $MAXLENGTH = 60
    $SUFFIXLENGTH = 8
    if (($FunctionAppName.Length + $SUFFIXLENGTH) -lt $MAXLENGTH)
    {
        $name = $FunctionAppName
    }
    else
    {
        $endIndex = $MAXLENGTH - $SUFFIXLENGTH - 1
        $name = $FunctionAppName.Substring(0, $endIndex)
    }

    $suffix = GetShareSuffix -Length $SUFFIXLENGTH
    $shareName = $name + $suffix

    return $shareName
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
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.DoNotExportAttribute()]
    param
    (
    )
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

                # Skip hidden runtimes if $env:FunctionsDisplayHiddenRuntimes is set to false
                if ($majorVersion.isHidden -and (-not $env:FunctionsDisplayHiddenRuntimes))
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
# MIIjnAYJKoZIhvcNAQcCoIIjjTCCI4kCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBCoy63BgY1mfvr
# BH1sqJ0Bj3oaLbSUvCMAY8gY0kQH3qCCDYEwggX/MIID56ADAgECAhMzAAAB32vw
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
# RcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIVcTCCFW0CAQEwgZUwfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAd9r8C6Sp0q00AAAAAAB3zAN
# BglghkgBZQMEAgEFAKCBrjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg5bg0hbqb
# Tu5ULFFANr2OKGqAPEwg6FxcnPCb/zfb89UwQgYKKwYBBAGCNwIBDDE0MDKgFIAS
# AE0AaQBjAHIAbwBzAG8AZgB0oRqAGGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbTAN
# BgkqhkiG9w0BAQEFAASCAQCzR9tTTqkvpEP04hkKayVOhAR9g4qjWDGfECkVcE4w
# 3ewuo41WSjZlUhm0Iur5+iRGG00OMizrJ87e4FbJyT01jkzC5n1HepijrU5L/OXG
# BhGq6QInvYQzbVLj4wfTNolqH6yi4Wp+QCMdf14LwkkCMbn0VX1hbkhn9LVOLz+4
# db0rVX/D1LYSl0iKsrDAea4ur74oZaiI1pp6KM5Z88RurKHYrl5r/v2I+dy945u1
# jsTNy5kdLQg3lU+DuEmfDA+Y8KhafgxE/FDElT4UF2mtTIbd71DYGpgw7jrb5Pmw
# BtbATcQJ8nsYd9Ie0I4Ubjv9YIF6yNyzfXTMTSl09oLooYIS+zCCEvcGCisGAQQB
# gjcDAwExghLnMIIS4wYJKoZIhvcNAQcCoIIS1DCCEtACAQMxDzANBglghkgBZQME
# AgEFADCCAVkGCyqGSIb3DQEJEAEEoIIBSASCAUQwggFAAgEBBgorBgEEAYRZCgMB
# MDEwDQYJYIZIAWUDBAIBBQAEINPToQuCVQL77/DaCafbDvt+vaKNrfIitWhZwT7P
# 9wPfAgZg1JBJhCMYEzIwMjEwNzAyMDUxNzM1LjUyM1owBIACAfSggdikgdUwgdIx
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1p
# Y3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEmMCQGA1UECxMdVGhh
# bGVzIFRTUyBFU046RDA4Mi00QkZELUVFQkExJTAjBgNVBAMTHE1pY3Jvc29mdCBU
# aW1lLVN0YW1wIFNlcnZpY2Wggg5KMIIE+TCCA+GgAwIBAgITMwAAAUGvf1KXXPLc
# RQAAAAABQTANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0Eg
# MjAxMDAeFw0yMDEwMTUxNzI4MjdaFw0yMjAxMTIxNzI4MjdaMIHSMQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQg
# SXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxlcyBUU1Mg
# RVNOOkQwODItNEJGRC1FRUJBMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFt
# cCBTZXJ2aWNlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA8irLqL28
# dal+PJUmUJOwvYn/sOCEzQzZyj94XbFPtRhDhPjagvvKOv1GgMoOuXvkpM3uM5E6
# 7vyOCPxqhTAzq7Ak3zkEXXBv7JoM8Xm0x5UcnAkpUiEo0eycRl6bnYIB3KlZW3uz
# 4Jc2v2FV0KCGkLrvqfKP8V/i2hVyN854OejWpx8wGUazM4CYUVowcgEDc76OY+Xa
# 4W27DCZJm2f9ol4BjSL+b2L/T8n/LEGknaUxwSQTN1LQCt+uBDCASd6VQR5CLLJV
# t6MBL0W1NlaWxEAJwlIdyBnS1ihLvRg1jc/KUZe0sRFdD3fhKrjPac3hoy007Fvr
# 6Go0WJ4pr2rJdQIDAQABo4IBGzCCARcwHQYDVR0OBBYEFC0oPyxuLpD9RXBr9c8N
# O0EFEsbEMB8GA1UdIwQYMBaAFNVjOlyKMZDzQ3t8RhvFM2hahW1VMFYGA1UdHwRP
# ME0wS6BJoEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1
# Y3RzL01pY1RpbVN0YVBDQV8yMDEwLTA3LTAxLmNybDBaBggrBgEFBQcBAQROMEww
# SgYIKwYBBQUHMAKGPmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMv
# TWljVGltU3RhUENBXzIwMTAtMDctMDEuY3J0MAwGA1UdEwEB/wQCMAAwEwYDVR0l
# BAwwCgYIKwYBBQUHAwgwDQYJKoZIhvcNAQELBQADggEBAFJ63yJ92ChqCgpexD48
# okviGuC4ikNsvmwlCSet1sFpvJEzLJB8cTF4z4qQTz8AsQtcew6mAVmQCYDu9f5e
# e11xXj1LwHYsZGnSs/OfRul1VKmY51OQpqvK5O/Ct4fs0Iblzo8eyOLJygTk97aX
# VA4Uzq8GblL7LQ5XiwAY446MOALnNXFo/Kq9tvzipwY1YcRn/nlMQ+b92OiLLmHV
# Mi2wAUORiKFvaAfYWjhQd+2qHLMsdpNluwBbWe7FF5ABsDo0HROMWyCgxdLQ3vqr
# 3DMSH3ZWKiirFsvWJmchfZPGRObwqszvSXPFmPBZ9o+er+4UoLV+50GWnnQky7HV
# gLkwggZxMIIEWaADAgECAgphCYEqAAAAAAACMA0GCSqGSIb3DQEBCwUAMIGIMQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNy
# b3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAxMDAeFw0xMDA3MDEy
# MTM2NTVaFw0yNTA3MDEyMTQ2NTVaMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX
# YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
# Q29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAy
# MDEwMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqR0NvHcRijog7PwT
# l/X6f2mUa3RUENWlCgCChfvtfGhLLF/Fw+Vhwna3PmYrW/AVUycEMR9BGxqVHc4J
# E458YTBZsTBED/FgiIRUQwzXTbg4CLNC3ZOs1nMwVyaCo0UN0Or1R4HNvyRgMlhg
# RvJYR4YyhB50YWeRX4FUsc+TTJLBxKZd0WETbijGGvmGgLvfYfxGwScdJGcSchoh
# iq9LZIlQYrFd/XcfPfBXday9ikJNQFHRD5wGPmd/9WbAA5ZEfu/QS/1u5ZrKsajy
# eioKMfDaTgaRtogINeh4HLDpmc085y9Euqf03GS9pAHBIAmTeM38vMDJRF1eFpwB
# BU8iTQIDAQABo4IB5jCCAeIwEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFNVj
# OlyKMZDzQ3t8RhvFM2hahW1VMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsG
# A1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFNX2VsuP6KJc
# YmjRPZSQW9fOmhjEMFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9jcmwubWljcm9z
# b2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIz
# LmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0dHA6Ly93d3cubWlj
# cm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3J0
# MIGgBgNVHSABAf8EgZUwgZIwgY8GCSsGAQQBgjcuAzCBgTA9BggrBgEFBQcCARYx
# aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL1BLSS9kb2NzL0NQUy9kZWZhdWx0Lmh0
# bTBABggrBgEFBQcCAjA0HjIgHQBMAGUAZwBhAGwAXwBQAG8AbABpAGMAeQBfAFMA
# dABhAHQAZQBtAGUAbgB0AC4gHTANBgkqhkiG9w0BAQsFAAOCAgEAB+aIUQ3ixuCY
# P4FxAz2do6Ehb7Prpsz1Mb7PBeKp/vpXbRkws8LFZslq3/Xn8Hi9x6ieJeP5vO1r
# VFcIK1GCRBL7uVOMzPRgEop2zEBAQZvcXBf/XPleFzWYJFZLdO9CEMivv3/Gf/I3
# fVo/HPKZeUqRUgCvOA8X9S95gWXZqbVr5MfO9sp6AG9LMEQkIjzP7QOllo9ZKby2
# /QThcJ8ySif9Va8v/rbljjO7Yl+a21dA6fHOmWaQjP9qYn/dxUoLkSbiOewZSnFj
# nXshbcOco6I8+n99lmqQeKZt0uGc+R38ONiU9MalCpaGpL2eGq4EQoO4tYCbIjgg
# tSXlZOz39L9+Y1klD3ouOVd2onGqBooPiRa6YacRy5rYDkeagMXQzafQ732D8OE7
# cQnfXXSYIghh2rBQHm+98eEA3+cxB6STOvdlR3jo+KhIq/fecn5ha293qYHLpwms
# ObvsxsvYgrRyzR30uIUBHoD7G4kqVDmyW9rIDVWZeodzOwjmmC3qjeAzLhIp9cAv
# VCch98isTtoouLGp25ayp0Kiyc8ZQU3ghvkqmqMRZjDTu3QyS99je/WZii8bxyGv
# WbWu3EQ8l1Bx16HSxVXjad5XwdHeMMD9zOZN+w2/XU/pnR4ZOC+8z1gFLu8NoFA1
# 2u8JJxzVs341Hgi62jbb01+P3nSISRKhggLUMIICPQIBATCCAQChgdikgdUwgdIx
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1p
# Y3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEmMCQGA1UECxMdVGhh
# bGVzIFRTUyBFU046RDA4Mi00QkZELUVFQkExJTAjBgNVBAMTHE1pY3Jvc29mdCBU
# aW1lLVN0YW1wIFNlcnZpY2WiIwoBATAHBgUrDgMCGgMVAKrlvym1CquIoQcrzncL
# vkD1WpUDoIGDMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
# b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
# dGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwDQYJ
# KoZIhvcNAQEFBQACBQDkiPG9MCIYDzIwMjEwNzAyMTAwMDI5WhgPMjAyMTA3MDMx
# MDAwMjlaMHQwOgYKKwYBBAGEWQoEATEsMCowCgIFAOSI8b0CAQAwBwIBAAICAwww
# BwIBAAICES8wCgIFAOSKQz0CAQAwNgYKKwYBBAGEWQoEAjEoMCYwDAYKKwYBBAGE
# WQoDAqAKMAgCAQACAwehIKEKMAgCAQACAwGGoDANBgkqhkiG9w0BAQUFAAOBgQBR
# wxmQQKDHVS8CJ91Fq1+xT4SAm9bD2+oj5h7KhhttOsnvsc5r87Pd0lYDl/0Ddv3g
# agocB6V7hG8Tp9SreEjKMli1BaSfpN3qVssktCwDMBeSYP+fEtpMxFt5zTIJ3rjH
# FGUCdYmy/T+vKtcl+W03nNjZBc4gbE1Zjw6k6pv6XzGCAw0wggMJAgEBMIGTMHwx
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1p
# Y3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAABQa9/Updc8txFAAAAAAFB
# MA0GCWCGSAFlAwQCAQUAoIIBSjAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQw
# LwYJKoZIhvcNAQkEMSIEIDYyWMzbnzsbSlVikvrGu++cKMQ7+ZurSA38NdiHKC5g
# MIH6BgsqhkiG9w0BCRACLzGB6jCB5zCB5DCBvQQgUT8BPIzqc3SecHRPLKBtW0vO
# OnT+78haWo+XcxVerd4wgZgwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0Eg
# MjAxMAITMwAAAUGvf1KXXPLcRQAAAAABQTAiBCD1+IJg2GDVBHffuActygQG0ivw
# ABywGtr1lx9Ivxo/AjANBgkqhkiG9w0BAQsFAASCAQAxaYn9DRyBn0T55JunYp/s
# zsak/XBOQFF6CyMN+9pCvzGPMIDaPHwGLnkEHrjLs531QsKHq1vrZJojgysOuk39
# gX+YmnTT5ObtiTNgiwVwVK379xuc3R3GKR+dd9oHhuHn+kiymqgONMxJG5w/IqXG
# tD14c1b8qhklunTZyOf9W9GWPtyYV9i8NuC3bZ8jL2ma85iUHwn04dxXkp2+Cabi
# mdyERWPJPbAymtWFMEMsX3RhFxOg2ri0Eyj9ZQtLLan6rBWz2K59fHAObWC9YKP1
# GP4ZJSx4p/+e8U7DWtnXT2hAX8fiVe+wm2OF+I+dMXiBXE5yl3bgtklyWvQfT0Bh
# SIG # End signature block
