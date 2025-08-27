################################
# Start: Internal use functions
################################

function Get-AccessTokenFromSessionData() {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [System.Management.Automation.SessionState]
    $SessionState
  )

  if ($null -eq $SessionState.PSVariable) {
    throw "unable to access SessionState. PSVariable, Please call Connect-MSCommerce before calling any other Powershell CmdLet for the MSCommerce Module"
  }

  $token = $SessionState.PSVariable.GetValue("token");

  if ($null -eq $token) {
    throw "You must call the Connect-MSCommerce cmdlet before calling any other cmdlets"
  }

  return $token
}

function HandleError() {
  param(
    [Parameter(Mandatory = $true)]
    $ErrorContext,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $CustomErrorMessage
  )

  $errorMessage = $ErrorContext.Exception.Message
  $errorDetails = $ErrorContext.ErrorDetails.Message

  if ($_.Exception.Response.StatusCode -eq 401) {
    Write-Error "Your credentials have expired. Please, call Connect-MSCommerce again to regain access to MSCommerce Module."

    return
  }

  write-error "$CustomErrorMessage, ErrorMessage - $errorMessage ErrorDetails - $errorDetails"
}

################################
# End: Internal use functions
################################


################################
# Start: Exported functions
################################

<#
    .SYNOPSIS
    Method to connect to MSCommerce with the credentials specified
#>
function Connect-MSCommerce() {
  [CmdletBinding()]
  param(
    [string]
    $ClientId = "3d5cffa9-04da-4657-8cab-c7f074657cad",

    [Uri]
    $RedirectUri = [uri] "http://localhost/m365/commerce",

    [string]
    $Resource = "aeb86249-8ea3-49e2-900b-54cc8e308f85/.default"   #LicenseManager App Id
  )

  # Create a public client application
  $publicClientApplicationBuilder = [Microsoft.Identity.Client.PublicClientApplicationBuilder]::Create($ClientId)
  $publicClientApplicationBuilder = $publicClientApplicationBuilder.WithRedirectUri($RedirectUri.AbsoluteUri)
  $clientApplication = $publicClientApplicationBuilder.Build()
  $scopes = New-Object Collections.Generic.List[string]
  $scopes.Add($Resource)
  $authenticationResult = $clientApplication.AcquireTokenInteractive($scopes).ExecuteAsync().GetAwaiter().GetResult()
  $token = $authenticationResult.AccessToken

  if ($null -eq $token) {
    Write-Error "Unable to establish connection"

    return
  }

  $sessionState = $PSCmdlet.SessionState

  $sessionState.PSVariable.Set("token", $token)

  Write-Host "Connection established successfully"
}

<#
    .SYNOPSIS
    Method to retrieve configurable policies
#>
function Get-MSCommercePolicies() {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $false)]
    [string] $Token
  )

  if (!$Token) {
    $Token = Get-AccessTokenFromSessionData -SessionState $PSCmdlet.SessionState
  }
  $correlationId = New-Guid
  $baseUri = "https://licensing.m365.microsoft.com"

  $restPath = "$baseUri/v1.0/policies"

  try {
    $response = Invoke-RestMethod `
      -Method GET `
      -Uri $restPath `
      -Headers @{
        "x-ms-correlation-id" = $correlationId
        "Authorization" = "Bearer $($Token)"
      }

    foreach ($policy in $response.items) {
      New-Object PSObject -Property @{
        PolicyId = $policy.id
        Description = $policy.description
        DefaultValue = $policy.defaultValue
      }
    }
  } catch {
    HandleError -ErrorContext $_ -CustomErrorMessage "Failed to retrieve policies"
  }
}

<#
    .SYNOPSIS
    Method to retrieve a description of the specified policy
#>
function Get-MSCommercePolicy() {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $PolicyId,
    [Parameter(Mandatory = $false)]
    [string] $Token
  )

  if (!$Token) {
    $Token = Get-AccessTokenFromSessionData -SessionState $PSCmdlet.SessionState
  }

  $correlationId = New-Guid
  $baseUri = "https://licensing.m365.microsoft.com"

  $restPath = "$baseUri/v1.0/policies/$PolicyId"

  try {
    $response = Invoke-RestMethod `
      -Method GET `
      -Uri $restPath `
        -Headers @{
        "x-ms-correlation-id" = $correlationId
        "Authorization" = "Bearer $($Token)"
      }

    New-Object PSObject -Property @{
      PolicyId = $response.id
      Description = $response.description
      DefaultValue = $response.defaultValue
    }
  } catch {
    HandleError -ErrorContext $_ -CustomErrorMessage "Failed to retrieve policy with PolicyId '$PolicyId'"
  }
}

<#
    .SYNOPSIS
    Method to retrieve applicable products for the specified policy and their current settings
#>
function Get-MSCommerceProductPolicies() {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $PolicyId,
    [Parameter(Mandatory = $false)]
    [string] $Scope,
    [Parameter(Mandatory = $false)]
    [string] $Token
  )

  if (!$Token) {
    $Token = Get-AccessTokenFromSessionData -SessionState $PSCmdlet.SessionState
  }
  $correlationId = New-Guid
  $baseUri = "https://licensing.m365.microsoft.com"

  $query = "scope=product"
  if($false -eq [string]::IsNullOrWhiteSpace($Scope)){
    $query = "scope=$Scope"
  }
  
  $restPath = "$baseUri/v1.0/policies/$PolicyId/products"
  if($false -eq [string]::IsNullOrWhiteSpace($query)){
    $restPath += "?$query"
  }

  try {
    $response = Invoke-RestMethod `
      -Method GET `
      -Uri $restPath `
      -Headers @{
        "x-ms-correlation-id" = $correlationId
        "Authorization" = "Bearer $($Token)"
      }

    foreach ($product in $response.items) {
      $properties = @{}
      $properties.Add("PolicyId", $product.policyId)
      $properties.Add("PolicyValue", $product.policyValue)

      if ($product.scope -eq "product") {
        $properties.Add("ProductName", $product.productName)
        $properties.Add("ProductId", $product.productId)
      }
      else {
        $properties.Add("ScopeId", $product.scopeId)
        $properties.Add("ScopeValue", $product.scopeValue)
        $properties.Add("Scope", $product.scope)
      }
      New-Object PSObject -Property $properties
    }
  } catch {
    HandleError -ErrorContext $_ -CustomErrorMessage "Failed to retrieve product policy with PolicyId '$PolicyId'"
  }
}

<#
    .SYNOPSIS
    Method to retrieve the current setting for the policy for the specified product
#>
function Get-MSCommerceProductPolicy() {
  [CmdletBinding(DefaultParameterSetName = "Product")]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $PolicyId,
    [Parameter(Mandatory = $true, ParameterSetName = "Product")]
    [ValidateNotNullOrEmpty()]
    [string] $ProductId,
    [Parameter(Mandatory = $true, ParameterSetName = "OfferType")]
    [ValidateNotNullOrEmpty()]
    [string] $OfferType,
    [Parameter(Mandatory = $false)]
    [string] $Token
  )

  if (!$Token) {
    $Token = Get-AccessTokenFromSessionData -SessionState $PSCmdlet.SessionState
  }
  $correlationId = New-Guid
  $baseUri = "https://licensing.m365.microsoft.com"

  $restPath = "$baseUri/v1.0/policies/$PolicyId"
  if ($PSBoundParameters.ContainsKey("OfferType")) {
    $restPath += "/offerTypes/$OfferType"
  }
  else {
    $restPath += "/products/$ProductId"
  }

  try {
    $response = Invoke-RestMethod `
      -Method GET `
      -Uri $restPath `
      -Headers @{
        "x-ms-correlation-id" = $correlationId
        "Authorization" = "Bearer $($Token)"
      }

    $properties = @{}
    $properties.Add("PolicyId", $response.policyId)
    $properties.Add("PolicyValue", $response.policyValue)

    if ($PSBoundParameters.ContainsKey("ProductId")) {
      $properties.Add("ProductName", $response.productName)
      $properties.Add("ProductId", $response.productId)
    }
    else {
      $properties.Add("Scope", $response.scope)
      $properties.Add("ScopeValue", $response.scopeValue)
      $properties.Add("ScopeId", $response.scopeId)
    }
    New-Object PSObject -Property $properties
  } catch {
    HandleError -ErrorContext $_ -CustomErrorMessage "Failed to retrieve product policy with PolicyId '$PolicyId' ProductId '$ProductId'"
  }
}

<#
    .SYNOPSIS
    Method to modify the current setting for the policy for the specified product
#>
function Update-MSCommerceProductPolicy() {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium', DefaultParameterSetName = "ProductEnum")]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $PolicyId,
    [Parameter(Mandatory = $true, ParameterSetName = "ProductToggle")]
    [Parameter(Mandatory = $true, ParameterSetName = "ProductEnum")]
    [ValidateNotNullOrEmpty()]
    [string] $ProductId,
    [Parameter(Mandatory = $true, ParameterSetName = "OfferTypeToggle")]
    [Parameter(Mandatory = $true, ParameterSetName = "OfferTypeEnum")]
    [string] $OfferType,
    [Parameter(Mandatory = $true, ParameterSetName = "ProductToggle")]
    [Parameter(Mandatory = $true, ParameterSetName = "OfferTypeToggle")]
    [ValidateNotNullOrEmpty()]
    [string] $Enabled,
    [Parameter(Mandatory = $true, ParameterSetName = "ProductEnum")]
    [Parameter(Mandatory = $true, ParameterSetName = "OfferTypeEnum")]
    [ValidateSet("Enabled", "Disabled", "OnlyTrialsWithoutPaymentMethod")]
    [string] $Value,
    [Parameter(Mandatory = $false)]
    [string] $Token
  )

  if ($PSBoundParameters.ContainsKey("Enabled")) {
    if ("True" -ne $Enabled -and "False" -ne $Enabled) {
      Write-Error "Value of `$Enabled must be one of the following: `$True, `$true, `$False, `$false"
      return
    }
  }

  if (!$Token) {
    $Token = Get-AccessTokenFromSessionData -SessionState $PSCmdlet.SessionState
  }
  $correlationId = New-Guid
  $baseUri = "https://licensing.m365.microsoft.com"

  $restPath = "$baseUri/v1.0/policies/$PolicyId"
  if ($PSBoundParameters.ContainsKey("OfferType")) {
    $restPath += "/offerTypes/$OfferType"
  }
  else{
    $restPath += "/products/$ProductId"
  }

  if ($PSBoundParameters.ContainsKey("Enabled")) {
    $policyValue = if ("True" -eq $Enabled -or "true" -eq $Enabled) {"Enabled"} else {"Disabled"}
  }
  else {
    $policyValue = $Value
  }

  $body = @{
    policyValue = $policyValue
  }

  if ($False -eq $PSCmdlet.ShouldProcess("ShouldProcess?")) {
    Write-Host "Updating product policy aborted"

    return
  }

  try {
    $response = Invoke-RestMethod `
      -Method PUT `
      -Uri $restPath `
      -Body ($body | ConvertTo-Json)`
      -ContentType 'application/json' `
      -Headers @{
        "x-ms-correlation-id" = $correlationId
        "Authorization" = "Bearer $($Token)"
      }

    Write-Host "Update policy product success"
    $properties = @{}
    $properties.Add("PolicyId", $response.policyId)
    $properties.Add("PolicyValue", $response.policyValue)

    if ($PSBoundParameters.ContainsKey("ProductId")) {
      $properties.Add("ProductName", $response.productName)
      $properties.Add("ProductId", $response.productId)
    }
    else {
      $properties.Add("Scope", $response.scope)
      $properties.Add("ScopeValue", $response.scopeValue)
      $properties.Add("ScopeId", $response.scopeId)
    }
    return New-Object PSObject -Property $properties
  }
  catch {
    HandleError -ErrorContext $_ -CustomErrorMessage "Failed to update product policy"
  }
}

################################
# End: Exported functions
################################

Write-Host "MSCommerce module loaded"

# SIG # Begin signature block
# MIIoKgYJKoZIhvcNAQcCoIIoGzCCKBcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCJ+Fk1uBry4ilc
# mA823vKlgJ3IiuuRWLejgxLg3hjiHqCCDXYwggX0MIID3KADAgECAhMzAAADrzBA
# DkyjTQVBAAAAAAOvMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjMxMTE2MTkwOTAwWhcNMjQxMTE0MTkwOTAwWjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDOS8s1ra6f0YGtg0OhEaQa/t3Q+q1MEHhWJhqQVuO5amYXQpy8MDPNoJYk+FWA
# hePP5LxwcSge5aen+f5Q6WNPd6EDxGzotvVpNi5ve0H97S3F7C/axDfKxyNh21MG
# 0W8Sb0vxi/vorcLHOL9i+t2D6yvvDzLlEefUCbQV/zGCBjXGlYJcUj6RAzXyeNAN
# xSpKXAGd7Fh+ocGHPPphcD9LQTOJgG7Y7aYztHqBLJiQQ4eAgZNU4ac6+8LnEGAL
# go1ydC5BJEuJQjYKbNTy959HrKSu7LO3Ws0w8jw6pYdC1IMpdTkk2puTgY2PDNzB
# tLM4evG7FYer3WX+8t1UMYNTAgMBAAGjggFzMIIBbzAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQURxxxNPIEPGSO8kqz+bgCAQWGXsEw
# RQYDVR0RBD4wPKQ6MDgxHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEW
# MBQGA1UEBRMNMjMwMDEyKzUwMTgyNjAfBgNVHSMEGDAWgBRIbmTlUAXTgqoXNzci
# tW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3JsMGEG
# CCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3J0
# MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIBAISxFt/zR2frTFPB45Yd
# mhZpB2nNJoOoi+qlgcTlnO4QwlYN1w/vYwbDy/oFJolD5r6FMJd0RGcgEM8q9TgQ
# 2OC7gQEmhweVJ7yuKJlQBH7P7Pg5RiqgV3cSonJ+OM4kFHbP3gPLiyzssSQdRuPY
# 1mIWoGg9i7Y4ZC8ST7WhpSyc0pns2XsUe1XsIjaUcGu7zd7gg97eCUiLRdVklPmp
# XobH9CEAWakRUGNICYN2AgjhRTC4j3KJfqMkU04R6Toyh4/Toswm1uoDcGr5laYn
# TfcX3u5WnJqJLhuPe8Uj9kGAOcyo0O1mNwDa+LhFEzB6CB32+wfJMumfr6degvLT
# e8x55urQLeTjimBQgS49BSUkhFN7ois3cZyNpnrMca5AZaC7pLI72vuqSsSlLalG
# OcZmPHZGYJqZ0BacN274OZ80Q8B11iNokns9Od348bMb5Z4fihxaBWebl8kWEi2O
# PvQImOAeq3nt7UWJBzJYLAGEpfasaA3ZQgIcEXdD+uwo6ymMzDY6UamFOfYqYWXk
# ntxDGu7ngD2ugKUuccYKJJRiiz+LAUcj90BVcSHRLQop9N8zoALr/1sJuwPrVAtx
# HNEgSW+AKBqIxYWM4Ev32l6agSUAezLMbq5f3d8x9qzT031jMDT+sUAoCw0M5wVt
# CUQcqINPuYjbS1WgJyZIiEkBMIIHejCCBWKgAwIBAgIKYQ6Q0gAAAAAAAzANBgkq
# hkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
# IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEwOTA5WjB+MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQg
# Q29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
# CgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+laUKq4BjgaBEm6f8MMHt03
# a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc6Whe0t+bU7IKLMOv2akr
# rnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4Ddato88tt8zpcoRb0Rrrg
# OGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+lD3v++MrWhAfTVYoonpy
# 4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nkkDstrjNYxbc+/jLTswM9
# sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6A4aN91/w0FK/jJSHvMAh
# dCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmdX4jiJV3TIUs+UsS1Vz8k
# A/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL5zmhD+kjSbwYuER8ReTB
# w3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zdsGbiwZeBe+3W7UvnSSmn
# Eyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3T8HhhUSJxAlMxdSlQy90
# lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS4NaIjAsCAwEAAaOCAe0w
# ggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRIbmTlUAXTgqoXNzcitW2o
# ynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYD
# VR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBDuRQFTuHqp8cx0SOJNDBa
# BgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2Ny
# bC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3JsMF4GCCsG
# AQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3J0MIGfBgNV
# HSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEFBQcCARYzaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1hcnljcHMuaHRtMEAGCCsG
# AQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkAYwB5AF8AcwB0AGEAdABl
# AG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn8oalmOBUeRou09h0ZyKb
# C5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7v0epo/Np22O/IjWll11l
# hJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0bpdS1HXeUOeLpZMlEPXh6
# I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/KmtYSWMfCWluWpiW5IP0
# wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvyCInWH8MyGOLwxS3OW560
# STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBpmLJZiWhub6e3dMNABQam
# ASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJihsMdYzaXht/a8/jyFqGa
# J+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYbBL7fQccOKO7eZS/sl/ah
# XJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbSoqKfenoi+kiVH6v7RyOA
# 9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sLgOppO6/8MO0ETI7f33Vt
# Y5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtXcVZOSEXAQsmbdlsKgEhr
# /Xmfwb1tbWrJUnMTDXpQzTGCGgowghoGAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAAOvMEAOTKNNBUEAAAAAA68wDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEINyFp8i5Ja/aOo/687ke9+3J
# T22eJ0mNp/LoGI2nM86VMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAeozLU6oYf92fa2i4jFK/DA+mkKcqAiyzjSkA1ROk08IwLDcW5zkmNymq
# x6sw1nwpVGlrI1fpjhemZRSQ4YCnWoNhgJJGnGpTSCWhizZnOdZhbJmgsY+rRoRw
# 2hibMSm/x+l5q5j91ZQMJuNsajpHZVGd89+606XKzserPTS8BCLGwM50D0Lxy6jJ
# QOyCgquRUeJyLWUEe3DluFa1AhVUTIaROBIlEIjKJYF+67jrSRoLQOw1INaumRue
# 7jE7ETggtmNlNiGUNkUuejc/1cqAzutjEifBzh72TFh0k2KB60uteOcNrCWhtiQN
# c9uBrjbNzNLw61S5g1RHFGz08Q2k4KGCF5QwgheQBgorBgEEAYI3AwMBMYIXgDCC
# F3wGCSqGSIb3DQEHAqCCF20wghdpAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCDPWFo3ovNFOwZVXSLv6dklP7lUZvRGXt3tLgfAXs8lpgIGZfMs8ffe
# GBMyMDI0MDQxMDE4NTc0OS4xMzhaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046RTAwMi0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHqMIIHIDCCBQigAwIBAgITMwAAAe4F0wIwspqdpwABAAAB7jANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yMzEyMDYxODQ1
# NDRaFw0yNTAzMDUxODQ1NDRaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046RTAwMi0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQC+8byl16KEia8xKS4vVL7REOOR7LzYCLXEtWgeqyOV
# lrzuEz+AoCa4tBGESjbHTXECeMOwP9TPeKaKalfTU5XSGjpJhpGx59fxMJoTYWPz
# zD0O2RAlyBmOBBmiLDXRDQJL1RtuAjvCiLulVQeiPI8V7+HhTR391TbC1beSxwXf
# dKJqY1onjDawqDJAmtwsA/gmqXgHwF9fZWcwKSuXiZBTbU5fcm3bhhlRNw5d04Ld
# 15ZWzVl/VDp/iRerGo2Is/0Wwn/a3eGOdHrvfwIbfk6lVqwbNQE11Oedn2uvRjKW
# EwerXL70OuDZ8vLzxry0yEdvQ8ky+Vfq8mfEXS907Y7rN/HYX6cCsC2soyXG3OwC
# tLA7o0/+kKJZuOrD5HUrSz3kfqgDlmWy67z8ZZPjkiDC1dYW1jN77t5iSl5Wp1HK
# Bp7JU8RiRI+vY2i1cb5X2REkw3WrNW/jbofXEs9t4bgd+yU8sgKn9MtVnQ65s6QG
# 72M/yaUZG2HMI31tm9mooH29vPBO9jDMOIu0LwzUTkIWflgd/vEWfTNcPWEQj7fs
# WuSoVuJ3uBqwNmRSpmQDzSfMaIzuys0pvV1jFWqtqwwCcaY/WXsb/axkxB/zCTdH
# SBUJ8Tm3i4PM9skiunXY+cSqH58jWkpHbbLA3Ofss7e+JbMjKmTdcjmSkb5oN8qU
# 1wIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFBCIzT8a2dwgnr37xd+2v1/cdqYIMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQB3ZyAva2EKOWSVpBnYkzX8f8GZjaOs577F
# 9o14Anh9lKy6tS34wXoPXEyQp1v1iI7rJzZVG7rpUznay2n9csfn3p6y7kYkHqtS
# ugCGmTiiBkwhFfSByKPI08MklgvJvKTZb673yGfpFwPjQwZeI6EPj/OAtpYkT7IU
# XqMki1CRMJKgeY4wURCccIujdWRkoVv4J3q/87KE0qPQmAR9fqMNxjI3ZClVxA4w
# iM3tNVlRbF9SgpOnjVo3P/I5p8Jd41hNSVCx/8j3qM7aLSKtDzOEUNs+ZtjhznmZ
# gUd7/AWHDhwBHdL57TI9h7niZkfOZOXncYsKxG4gryTshU6G6sAYpbqdME/+/g1u
# er7VGIHUtLq3W0Anm8lAfS9PqthskZt54JF28CHdsFq/7XVBtFlxL/KgcQylJNni
# a+anixUG60yUDt3FMGSJI34xG9NHsz3BpqSWueGtJhQ5ZN0K8ju0vNVgF+Dv05si
# rPg0ftSKf9FVECp93o8ogF48jh8CT/B32lz1D6Truk4Ezcw7E1OhtOMf7DHgPMWf
# 6WOdYnf+HaSJx7ZTXCJsW5oOkM0sLitxBpSpGcj2YjnNznCpsEPZat0h+6d7ulRa
# WR5RHAUyFFQ9jRa7KWaNGdELTs+nHSlYjYeQpK5QSXjigdKlLQPBlX+9zOoGAJho
# Zfrpjq4nQDCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
# hvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# MjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eSAy
# MDEwMB4XDTIxMDkzMDE4MjIyNVoXDTMwMDkzMDE4MzIyNVowfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTAwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoIC
# AQDk4aZM57RyIQt5osvXJHm9DtWC0/3unAcH0qlsTnXIyjVX9gF/bErg4r25Phdg
# M/9cT8dm95VTcVrifkpa/rg2Z4VGIwy1jRPPdzLAEBjoYH1qUoNEt6aORmsHFPPF
# dvWGUNzBRMhxXFExN6AKOG6N7dcP2CZTfDlhAnrEqv1yaa8dq6z2Nr41JmTamDu6
# GnszrYBbfowQHJ1S/rboYiXcag/PXfT+jlPP1uyFVk3v3byNpOORj7I5LFGc6XBp
# Dco2LXCOMcg1KL3jtIckw+DJj361VI/c+gVVmG1oO5pGve2krnopN6zL64NF50Zu
# yjLVwIYwXE8s4mKyzbnijYjklqwBSru+cakXW2dg3viSkR4dPf0gz3N9QZpGdc3E
# XzTdEonW/aUgfX782Z5F37ZyL9t9X4C626p+Nuw2TPYrbqgSUei/BQOj0XOmTTd0
# lBw0gg/wEPK3Rxjtp+iZfD9M269ewvPV2HM9Q07BMzlMjgK8QmguEOqEUUbi0b1q
# GFphAXPKZ6Je1yh2AuIzGHLXpyDwwvoSCtdjbwzJNmSLW6CmgyFdXzB0kZSU2LlQ
# +QuJYfM2BjUYhEfb3BvR/bLUHMVr9lxSUV0S2yW6r1AFemzFER1y7435UsSFF5PA
# PBXbGjfHCBUYP3irRbb1Hode2o+eFnJpxq57t7c+auIurQIDAQABo4IB3TCCAdkw
# EgYJKwYBBAGCNxUBBAUCAwEAATAjBgkrBgEEAYI3FQIEFgQUKqdS/mTEmr6CkTxG
# NSnPEP8vBO4wHQYDVR0OBBYEFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMFwGA1UdIARV
# MFMwUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWlj
# cm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTATBgNVHSUEDDAK
# BggrBgEFBQcDCDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMC
# AYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvX
# zpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20v
# cGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYI
# KwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNydDANBgkqhkiG
# 9w0BAQsFAAOCAgEAnVV9/Cqt4SwfZwExJFvhnnJL/Klv6lwUtj5OR2R4sQaTlz0x
# M7U518JxNj/aZGx80HU5bbsPMeTCj/ts0aGUGCLu6WZnOlNN3Zi6th542DYunKmC
# VgADsAW+iehp4LoJ7nvfam++Kctu2D9IdQHZGN5tggz1bSNU5HhTdSRXud2f8449
# xvNo32X2pFaq95W2KFUn0CS9QKC/GbYSEhFdPSfgQJY4rPf5KYnDvBewVIVCs/wM
# nosZiefwC2qBwoEZQhlSdYo2wh3DYXMuLGt7bj8sCXgU6ZGyqVvfSaN0DLzskYDS
# PeZKPmY7T7uG+jIa2Zb0j/aRAfbOxnT99kxybxCrdTDFNLB62FD+CljdQDzHVG2d
# Y3RILLFORy3BFARxv2T5JL5zbcqOCb2zAVdJVGTZc9d/HltEAY5aGZFrDZ+kKNxn
# GSgkujhLmm77IVRrakURR6nxt67I6IleT53S0Ex2tVdUCbFpAUR+fKFhbHP+Crvs
# QWY9af3LwUFJfn6Tvsv4O+S3Fb+0zj6lMVGEvL8CwYKiexcdFYmNcP7ntdAoGokL
# jzbaukz5m/8K6TT4JDVnK+ANuOaMmdbhIurwJ0I9JZTmdHRbatGePu1+oDEzfbzL
# 6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZqELQdVTNYs6FwZvKhggNN
# MIICNQIBATCB+aGB0aSBzjCByzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEn
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOkUwMDItMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQCI
# o6bVNvflFxbUWCDQ3YYKy6O+k6CBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA6cFB6TAiGA8yMDI0MDQxMDE2NTA0
# OVoYDzIwMjQwNDExMTY1MDQ5WjB0MDoGCisGAQQBhFkKBAExLDAqMAoCBQDpwUHp
# AgEAMAcCAQACAhSYMAcCAQACAhOgMAoCBQDpwpNpAgEAMDYGCisGAQQBhFkKBAIx
# KDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJKoZI
# hvcNAQELBQADggEBAJNlafGoVCaxCgkyoCWaxpYTjVSV9EKq6it7h/L4q17Rf6qu
# Ly09gj0u7k+z4x3tCE3XsO2ZKk+zOdViHu9ink4EFCAdtbi+eyvAsMvrABxI12Ke
# IOSbkJDJTkUSUf8akc3rKMaDEP0bW3WVji++kGwOzNzM8nS2FTJalJ8YtRFhdkTG
# uqSfioI3CGmNpLv6xQ/IOww7Noeme2XhiNHe+GqBut1ZrlJ8f2CxmhMGFqG/Jf9G
# EOcV1JcI2/55F7nAEi40JzjjlxQnoO4R2IcUw3O6kG7CqEgyxR1XXAHejxPqBBFZ
# a+jfbFLJSCKnZmAPVC2gKLpzb1FJtJxo1Q7Y+YkxggQNMIIECQIBATCBkzB8MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNy
# b3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAe4F0wIwspqdpwABAAAB7jAN
# BglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8G
# CSqGSIb3DQEJBDEiBCBnUikncTovdNSeii2mcQDoI0GuPz2KDt5Yvs2F9R6c9jCB
# +gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIE9QdxSVhfq+Vdf+DPs+5EIkBz9o
# CS/OQflHkVRhfjAhMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTACEzMAAAHuBdMCMLKanacAAQAAAe4wIgQgS+PLZdbHvZpnvMKHfer0Eq3NOIea
# inq3rvQ8w0qT3NkwDQYJKoZIhvcNAQELBQAEggIAgq1Tmd9/L7gqVUCTguvilDs3
# 2crXxS2tEg7RbN5NRRGTlscADZhJ3rcD08AUNN30ulDMNoY6reHjt5+PGOu/X5uJ
# CUChMxEyv21uhWRKwUnxNhMpL9hYU/BqBRNaQ1YxhDkhrAXrtAzpaHNU72u6GCBQ
# likWNbYFhdgtf/t5LR+52izevSpdWRFK14K3RVettzgMcs7nPK/X2TrHC6BehcPV
# zSUBoIlzicyT1iXHc8A3vnFcSm+ETU4ObCGpdppiCLlLCPLD4lSdKX+7H1TT3moy
# QxedPNkehVeuwsbbWqq5+FzwKEJEZ/f5B6raBUBjxqDE5bW2tCqz78BsxZYyo08k
# Vt68dK0dHCHlRy4BGOhECSjIPHzvjInHga/2y72Tpqq4ZCtUZBu6GCnsf9Vq6G0Q
# YUHS2DW/VyqCu6GHs/cARY03lp3dPkXU6OUL3tdjzs7FiZVhXp+sUcpNupk+1GQL
# Abh/dUa73T7kU8cffEqBIm48MH+/yUUJuZijkwVOlzZqqOZe5tT523R08+xQzWyD
# oA++hwcp0LubyvgVa3eD9UdjYVDs6Z2L7w3XTG5+bL0/pgyqwNuuTadjIeW75mCK
# 5nY67jeVO7YQtLh0f8OEIXe1DC02ejHxs+PybeiVJfMKJ24MHVtQlvKGXzfeGWOk
# r0vnLCQKur81RpDMwjE=
# SIG # End signature block
