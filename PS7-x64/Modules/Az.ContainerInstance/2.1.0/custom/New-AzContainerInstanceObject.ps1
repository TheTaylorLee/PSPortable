
# ----------------------------------------------------------------------------------
#
# Copyright Microsoft Corporation
# Licensed under the Apache License, Version 2.0 (the \"License\");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an \"AS IS\" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ----------------------------------------------------------------------------------

<#
.Synopsis
Create a in-memory object for Container
.Description
Create a in-memory object for Container

.Outputs
Microsoft.Azure.PowerShell.Cmdlets.ContainerInstance.Models.Api20210301.Container
.Link
https://docs.microsoft.com/powershell/module/az.ContainerInstance/new-AzContainerInstanceObject
#>
function New-AzContainerInstanceObject {
    [OutputType('Microsoft.Azure.PowerShell.Cmdlets.ContainerInstance.Models.Api20210301.Container')]
    [CmdletBinding(PositionalBinding=$false)]
    Param(

        [Parameter(HelpMessage="The commands to execute within the container instance in exec form.")]
        [string[]]
        $Command,
        [Parameter(HelpMessage="The environment variables to set in the container instance.")]
        [Microsoft.Azure.PowerShell.Cmdlets.ContainerInstance.Models.Api20210301.IEnvironmentVariable[]]
        $EnvironmentVariable,
        [Parameter(Mandatory, HelpMessage="The name of the image used to create the container instance.")]
        [string]
        $Image,
        [Parameter(HelpMessage="The CPU limit of this container instance.")]
        [double]
        $LimitCpu,
        [Parameter(HelpMessage="The memory limit in GB of this container instance.")]
        [double]
        $LimitMemoryInGb,
        [Parameter(HelpMessage="The count of the GPU resource.")]
        [int]
        $LimitsGpuCount,
        [Parameter(HelpMessage="The SKU of the GPU resource.")]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.ContainerInstance.Support.GpuSku])]
        [string]
        $LimitsGpuSku,
        [Parameter(HelpMessage="The commands to execute within the container.")]
        [string[]]
        $LivenessProbeExecCommand,
        [Parameter(HelpMessage="The failure threshold.")]
        [int]
        $LivenessProbeFailureThreshold,
        [Parameter(HelpMessage="The header name.")]
        [string]
        $LivenessProbeHttpGetHttpHeadersName,
        [Parameter(HelpMessage="The header value.")]
        [string]
        $LivenessProbeHttpGetHttpHeadersValue,
        [Parameter(HelpMessage="The path to probe.")]
        [string]
        $LivenessProbeHttpGetPath,
        [Parameter(HelpMessage="The port number to probe.")]
        [int]
        $LivenessProbeHttpGetPort,
        [Parameter(HelpMessage="The scheme.")]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.ContainerInstance.Support.Scheme])]
        [string]
        $LivenessProbeHttpGetScheme,
        [Parameter(HelpMessage="The initial delay seconds.")]
        [int]
        $LivenessProbeInitialDelaySecond,
        [Parameter(HelpMessage="The period seconds.")]
        [int]
        $LivenessProbePeriodSecond,
        [Parameter(HelpMessage="The success threshold.")]
        [int]
        $LivenessProbeSuccessThreshold,
        [Parameter(HelpMessage="The timeout seconds.")]
        [int]
        $LivenessProbeTimeoutSecond,
        [Parameter(Mandatory, HelpMessage="The user-provided name of the container instance.")]
        [string]
        $Name,
        [Parameter(HelpMessage="The exposed ports on the container instance.")]
        [Microsoft.Azure.PowerShell.Cmdlets.ContainerInstance.Models.Api20210301.IContainerPort[]]
        $Port,
        [Parameter(HelpMessage="The commands to execute within the container.")]
        [string[]]
        $ReadinessProbeExecCommand,
        [Parameter(HelpMessage="The failure threshold.")]
        [int]
        $ReadinessProbeFailureThreshold,
        [Parameter(HelpMessage="The header name.")]
        [string]
        $ReadinessProbeHttpGetHttpHeadersName,
        [Parameter(HelpMessage="The header value.")]
        [string]
        $ReadinessProbeHttpGetHttpHeadersValue,
        [Parameter(HelpMessage="The path to probe.")]
        [string]
        $ReadinessProbeHttpGetPath,
        [Parameter(HelpMessage="The port number to probe.")]
        [int]
        $ReadinessProbeHttpGetPort,
        [Parameter(HelpMessage="The scheme.")]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.ContainerInstance.Support.Scheme])]
        [string]
        $ReadinessProbeHttpGetScheme,
        [Parameter(HelpMessage="The initial delay seconds.")]
        [int]
        $ReadinessProbeInitialDelaySecond,
        [Parameter(HelpMessage="The period seconds.")]
        [int]
        $ReadinessProbePeriodSecond,
        [Parameter(HelpMessage="The success threshold.")]
        [int]
        $ReadinessProbeSuccessThreshold,
        [Parameter(HelpMessage="The timeout seconds.")]
        [int]
        $ReadinessProbeTimeoutSecond,
        [Parameter(HelpMessage="The CPU request of this container instance.")]
        [double]
        $RequestCpu,
        [Parameter(HelpMessage="The memory request in GB of this container instance.")]
        [double]
        $RequestMemoryInGb,
        [Parameter(HelpMessage="The count of the GPU resource.")]
        [int]
        $RequestsGpuCount,
        [Parameter(HelpMessage="The SKU of the GPU resource.")]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.ContainerInstance.Support.GpuSku])]
        [string]
        $RequestsGpuSku,
        [Parameter(HelpMessage="The volume mounts available to the container instance.")]
        [Microsoft.Azure.PowerShell.Cmdlets.ContainerInstance.Models.Api20210301.IVolumeMount[]]
        $VolumeMount
    )

    process {
        $Object = [Microsoft.Azure.PowerShell.Cmdlets.ContainerInstance.Models.Api20210301.Container]::New()

        $Object.Command = $Command
        $Object.EnvironmentVariable = $EnvironmentVariable
        $Object.Image = $Image
        $Object.LimitCpu = $LimitCpu
        $Object.LimitMemoryInGb = $LimitMemoryInGb
        $Object.LimitsGpuCount = $LimitsGpuCount
        $Object.LimitsGpuSku = $LimitsGpuSku
        $Object.LivenessProbeExecCommand = $LivenessProbeExecCommand
        $Object.LivenessProbeFailureThreshold = $LivenessProbeFailureThreshold
        $Object.LivenessProbeHttpGetHttpHeadersName = $LivenessProbeHttpGetHttpHeadersName
        $Object.LivenessProbeHttpGetHttpHeadersValue = $LivenessProbeHttpGetHttpHeadersValue
        $Object.LivenessProbeHttpGetPath = $LivenessProbeHttpGetPath
        $Object.LivenessProbeHttpGetPort = $LivenessProbeHttpGetPort
        $Object.LivenessProbeHttpGetScheme = $LivenessProbeHttpGetScheme
        $Object.LivenessProbeInitialDelaySecond = $LivenessProbeInitialDelaySecond
        $Object.LivenessProbePeriodSecond = $LivenessProbePeriodSecond
        $Object.LivenessProbeSuccessThreshold = $LivenessProbeSuccessThreshold
        $Object.LivenessProbeTimeoutSecond = $LivenessProbeTimeoutSecond
        $Object.Name = $Name
        if(!$PSBoundParameters.ContainsKey("Port"))
        {
            $Port = New-AzContainerInstancePortObject -Port 80
        }
        $Object.Port = $Port
        $Object.ReadinessProbeExecCommand = $ReadinessProbeExecCommand
        $Object.ReadinessProbeFailureThreshold = $ReadinessProbeFailureThreshold
        $Object.ReadinessProbeHttpGetHttpHeadersName = $ReadinessProbeHttpGetHttpHeadersName
        $Object.ReadinessProbeHttpGetHttpHeadersValue = $ReadinessProbeHttpGetHttpHeadersValue
        $Object.ReadinessProbeHttpGetPath = $ReadinessProbeHttpGetPath
        $Object.ReadinessProbeHttpGetPort = $ReadinessProbeHttpGetPort
        $Object.ReadinessProbeHttpGetScheme = $ReadinessProbeHttpGetScheme
        $Object.ReadinessProbeInitialDelaySecond = $ReadinessProbeInitialDelaySecond
        $Object.ReadinessProbePeriodSecond = $ReadinessProbePeriodSecond
        $Object.ReadinessProbeSuccessThreshold = $ReadinessProbeSuccessThreshold
        $Object.ReadinessProbeTimeoutSecond = $ReadinessProbeTimeoutSecond
        if(!$PSBoundParameters.ContainsKey("RequestCpu"))
        {
            $RequestCpu = 1.0
        }
        $Object.RequestCpu = $RequestCpu
        if(!$PSBoundParameters.ContainsKey("RequestMemoryInGb"))
        {
            $RequestMemoryInGb = 1.5
        }
        $Object.RequestMemoryInGb = $RequestMemoryInGb
        $Object.RequestsGpuCount = $RequestsGpuCount
        $Object.RequestsGpuSku = $RequestsGpuSku
        $Object.VolumeMount = $VolumeMount
        return $Object
    }
}


# SIG # Begin signature block
# MIIjkgYJKoZIhvcNAQcCoIIjgzCCI38CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBMUqxVybfr/Sgi
# r6/RrplA6ZoNE/XIFoIFeYxJLlBWQKCCDYEwggX/MIID56ADAgECAhMzAAAB32vw
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
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg91gWPenX
# rScrb6sF+StVugeKLtPHsd/M4eDIxuU1yUUwQgYKKwYBBAGCNwIBDDE0MDKgFIAS
# AE0AaQBjAHIAbwBzAG8AZgB0oRqAGGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbTAN
# BgkqhkiG9w0BAQEFAASCAQCO9krK4THjW3nxe9VATsh2F2KS53LlHJobN1tkpO91
# /y8y+X5NkTjIHJiwKL48a0R4oGEXQGlvYkTBlYacsrZpYBxgYgHV0t67UshFAxfX
# RCUoZ96Cb7v1ygpFB4cMNOF+d5drClOq2TXCqgxHB3xd4t7lrw7h2SSGyjW7pvmA
# 2Q/tJQ5as/Q3C4eYuSJrbtFY/etrLNfFBxTpmvQhKBviyp+Tqh0oM7XurLhsmkZl
# BDt69kjgWxQcjzDk582uUzvn8dGjpUw5/gcO9Os4R2allodTSsY9LWic0nx3kAit
# FGEef8pyznJ0xpsh44/2K873zDwVJGJV4lWFcNrN/5Z1oYIS8TCCEu0GCisGAQQB
# gjcDAwExghLdMIIS2QYJKoZIhvcNAQcCoIISyjCCEsYCAQMxDzANBglghkgBZQME
# AgEFADCCAVUGCyqGSIb3DQEJEAEEoIIBRASCAUAwggE8AgEBBgorBgEEAYRZCgMB
# MDEwDQYJYIZIAWUDBAIBBQAEIJUOBG3Yq0slLK1YwTN/gKWRn7Dgzh2XooR0VBTI
# lcrcAgZgrrQijnUYEzIwMjEwNjExMTEzMzQ5LjM2M1owBIACAfSggdSkgdEwgc4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKTAnBgNVBAsTIE1p
# Y3Jvc29mdCBPcGVyYXRpb25zIFB1ZXJ0byBSaWNvMSYwJAYDVQQLEx1UaGFsZXMg
# VFNTIEVTTjpGNzdGLUUzNTYtNUJBRTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgU2VydmljZaCCDkQwggT1MIID3aADAgECAhMzAAABXp0px1+HBaHqAAAA
# AAFeMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEw
# MB4XDTIxMDExNDE5MDIxOVoXDTIyMDQxMTE5MDIxOVowgc4xCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVy
# YXRpb25zIFB1ZXJ0byBSaWNvMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjpGNzdG
# LUUzNTYtNUJBRTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2Vydmlj
# ZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJrTI4OQehn3oKp2zuh6
# WP2Zib/Dxw/srLeeyTb9ed7PX+fLg7zBA0yl6ivF2n6lauGH8W7EBwRPEv7ZCSXw
# XgYZ6GGaH8aU+OrDXAbc4BXTO5XnLGwSbaye9R2+uQHdCJmaMtz/lEBWUK5xvHoj
# 0TUrXOZdZ/vv7TqMWA4h1AT1w/JBR4kHtV1i8KWdlQ+dZX/gNHpA72IoLoOmpImb
# GRzcGQ4Z2Kzq4eMB9wjaFRV1JF/wz1hLFIjGtlU3eGjRBiBEEVI7UEMMSvI4rK+C
# fLAIZnULu7SzlIfqSU3R0pSNUahwpWdCiB6fKzIq94Z+9888moQuo95RAPmzHQW1
# MI0CAwEAAaOCARswggEXMB0GA1UdDgQWBBSqcny6Dd1L5VTCEACezlR41fgfKzAf
# BgNVHSMEGDAWgBTVYzpcijGQ80N7fEYbxTNoWoVtVTBWBgNVHR8ETzBNMEugSaBH
# hkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNU
# aW1TdGFQQ0FfMjAxMC0wNy0wMS5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUF
# BzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1RpbVN0
# YVBDQV8yMDEwLTA3LTAxLmNydDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoGCCsG
# AQUFBwMIMA0GCSqGSIb3DQEBCwUAA4IBAQB/IfxZhMYkBMqRmXnh/Vit4bfxyioA
# lr7HJ1XDSHTIvRwDD1PGr0upZE/vrrI/QN/1Wi6vDcKmnJ2r7Xj6pWZOZqc9Bp+u
# BvpPaulue4stu3TqKTc9Fu2K5ibctpF4oHPfZ+IKeChop+Mk9g7N5llHzv0aCDia
# M0w2aAT3rj3QHQS8ijnQ5/qhtzwo1AoUnV1y2urWwX5aHdUzaoeAJrvnf2ee89Kf
# 4ycjjyafNJSUp/qaXBlbjMu90vNubJstdSxOtvwcxeeHP6ZaYbTl2cOla4cokiPU
# +BUjIZA/t/IZfYoazMGmBtLWFJZdC9LYWWmLLsNJ2W21qkeSSpEAw4pmMIIGcTCC
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
# cGVyYXRpb25zIFB1ZXJ0byBSaWNvMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjpG
# NzdGLUUzNTYtNUJBRTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2Vy
# dmljZaIjCgEBMAcGBSsOAwIaAxUAVkmPV/8hZVS9FzbtoX2x3Z2xYyqggYMwgYCk
# fjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
# Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDANBgkqhkiG9w0BAQUFAAIF
# AORtoWYwIhgPMjAyMTA2MTExMjQ2MzBaGA8yMDIxMDYxMjEyNDYzMFowdzA9Bgor
# BgEEAYRZCgQBMS8wLTAKAgUA5G2hZgIBADAKAgEAAgIplQIB/zAHAgEAAgIRWDAK
# AgUA5G7y5gIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgorBgEEAYRZCgMCoAowCAIB
# AAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBBQUAA4GBAFf2JaKDDgsuSYhj
# B893KRYDoVzrmMeMWoJvS2N7OKBrgECWMxPi6s3PZxwNKY05tJVMTpdUaQAZF8WR
# SEGhgz5g5CmW2IJuwU2LQRQ6kota2C8Kl2iJoETOpWJiXOc7d5czLY2+ZHjBVEdx
# fPqUSl+zrrg1Z5KpdKHPpFIzCGhOMYIDDTCCAwkCAQEwgZMwfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTACEzMAAAFenSnHX4cFoeoAAAAAAV4wDQYJYIZIAWUD
# BAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0B
# CQQxIgQgnagghg3z3QesY+eY/Rq/yuh2b6GvFYDvgsk+9TtXlJAwgfoGCyqGSIb3
# DQEJEAIvMYHqMIHnMIHkMIG9BCB+5YTslNSXjuB+5mQDTKRkM7prkewhXnevXpLv
# 8RLT4jCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAB
# Xp0px1+HBaHqAAAAAAFeMCIEIN4VE4lxuzqjzpHSCcQFwmPJ6FD7BiNVCUXrW8Ku
# fEI4MA0GCSqGSIb3DQEBCwUABIIBAGvEI7XT2LvFDw1oQgCStHZG3HSaGPPC/6Q3
# YuEYOvxVLJRg/DrQlQpO9n8T0ehx078tPk3OmR3CzpmrWx+GmOqaxQbVjgnoL87D
# q+8SSbDeHgiqaEpz7bPh/8Yl/TMPJ6re/RJXT969Tca+X/5CkzR877AzJr5CIufU
# SjMNUsPi3ezUVVpbm0pSuBzLsp1MILeutB09lJNHfdIS8f22RBPNhOCtadXBkNC0
# JTX2bPBfRvUA5h+hpRDAU57+vU2EpIDhEX4Rp+vsYCIKt16FJkDiBCnt9TSu0EEO
# 8JSglf8eGMRqcCVf1RQTPaBWxh4A4TMqrZrziIar9ZHloXJoMQc=
# SIG # End signature block
