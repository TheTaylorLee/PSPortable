
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

.Description

.Example
PS C:\> {{ Add code here }}

{{ Add output here }}
.Example
PS C:\> {{ Add code here }}

{{ Add output here }}

.Inputs
Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IConfigApiBasedCmdletsIdentity
.Inputs
Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IMicrosoftSkypeSyncPstnTnmReleaseApiModelsCreateOrderReleaseRequest
.Outputs
Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IMicrosoftSkypeSyncPstnTnmServiceModelsErrorBody
.Outputs
System.String
.Notes
COMPLEX PARAMETER PROPERTIES

To create the parameters described below, construct a hash table containing the appropriate properties. For information on hash tables, run Get-Help about_Hash_Tables.

BODY <IMicrosoftSkypeSyncPstnTnmReleaseApiModelsCreateOrderReleaseRequest>: ReleaseRequest
  [TelephoneNumber <String[]>]: 

INPUTOBJECT <IConfigApiBasedCmdletsIdentity>: Identity Parameter
  [BridgeId <String>]: Identity of the bridge.
  [CivicAddressId <String>]: Civic address id.
  [Country <String>]: 
  [GroupId <String>]: The ID of a group whose policy assignments will be returned.
  [Identity <String>]: 
  [Locale <String>]: 
  [LocationId <String>]: Location id.
  [Name <String>]: Name of the bridge.
  [OdataId <String>]: A composite URI of a template.
  [OperationId <String>]: The ID of a batch policy assignment operation.
  [OrderId <String>]: 
  [PackageName <String>]: The name of a specific policy package
  [PolicyType <String>]: The policy type for which group policy assignments will be returned.
  [PortInOrderId <String>]: 
  [PublicTemplateLocale <String>]: Language and country code for localization of publicly available templates.
  [TenantId <String>]: 
  [UserId <String>]: UserId. Supports Guid. Eventually UPN and SIP.
.Link
https://docs.microsoft.com/en-us/powershell/module/teams/new-csreleaseorderv2async
#>
function New-CsReleaseOrderV2Async {
[OutputType([System.String], [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IMicrosoftSkypeSyncPstnTnmServiceModelsErrorBody])]
[CmdletBinding(DefaultParameterSetName='CreateExpanded', PositionalBinding=$false, SupportsShouldProcess, ConfirmImpact='Medium')]
param(
    [Parameter(ParameterSetName='Create', Mandatory)]
    [Parameter(ParameterSetName='CreateExpanded', Mandatory)]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Path')]
    [System.String]
    # .
    ${TenantId},

    [Parameter(ParameterSetName='CreateViaIdentity', Mandatory, ValueFromPipeline)]
    [Parameter(ParameterSetName='CreateViaIdentityExpanded', Mandatory, ValueFromPipeline)]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Path')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IConfigApiBasedCmdletsIdentity]
    # Identity Parameter
    # To construct, see NOTES section for INPUTOBJECT properties and create a hash table.
    ${InputObject},

    [Parameter(ParameterSetName='Create', Mandatory, ValueFromPipeline)]
    [Parameter(ParameterSetName='CreateViaIdentity', Mandatory, ValueFromPipeline)]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Body')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Models.IMicrosoftSkypeSyncPstnTnmReleaseApiModelsCreateOrderReleaseRequest]
    # ReleaseRequest
    # To construct, see NOTES section for BODY properties and create a hash table.
    ${Body},

    [Parameter(ParameterSetName='CreateExpanded')]
    [Parameter(ParameterSetName='CreateViaIdentityExpanded')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Body')]
    [System.String[]]
    # .
    ${TelephoneNumber},

    [Parameter(DontShow)]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Runtime')]
    [System.Management.Automation.SwitchParameter]
    # Wait for .NET debugger to attach
    ${Break},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Runtime')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Runtime.SendAsyncStep[]]
    # SendAsync Pipeline Steps to be appended to the front of the pipeline
    ${HttpPipelineAppend},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Runtime')]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Runtime.SendAsyncStep[]]
    # SendAsync Pipeline Steps to be prepended to the front of the pipeline
    ${HttpPipelinePrepend},

    [Parameter(DontShow)]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Runtime')]
    [System.Uri]
    # The URI for the proxy server to use
    ${Proxy},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Runtime')]
    [System.Management.Automation.PSCredential]
    # Credentials for a proxy server to use for the remote call
    ${ProxyCredential},

    [Parameter(DontShow)]
    [Microsoft.Teams.ConfigAPI.Cmdlets.Generated.Category('Runtime')]
    [System.Management.Automation.SwitchParameter]
    # Use the default credentials for the proxy
    ${ProxyUseDefaultCredentials}
)

begin {
    try {
        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $parameterSet = $PSCmdlet.ParameterSetName
        $mapping = @{
            Create = 'Microsoft.Teams.ConfigAPI.Cmdlets.private\New-CsReleaseOrderV2Async_Create';
            CreateExpanded = 'Microsoft.Teams.ConfigAPI.Cmdlets.private\New-CsReleaseOrderV2Async_CreateExpanded';
            CreateViaIdentity = 'Microsoft.Teams.ConfigAPI.Cmdlets.private\New-CsReleaseOrderV2Async_CreateViaIdentity';
            CreateViaIdentityExpanded = 'Microsoft.Teams.ConfigAPI.Cmdlets.private\New-CsReleaseOrderV2Async_CreateViaIdentityExpanded';
        }
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand(($mapping[$parameterSet]), [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = {& $wrappedCmd @PSBoundParameters}
        $steppablePipeline = $scriptCmd.GetSteppablePipeline($MyInvocation.CommandOrigin)
        $steppablePipeline.Begin($PSCmdlet)
    } catch {
        throw
    }
}

process {
    try {
        $steppablePipeline.Process($_)
    } catch {
        throw
    }
}

end {
    try {
        $steppablePipeline.End()
    } catch {
        throw
    }
}
}

# SIG # Begin signature block
# MIIjewYJKoZIhvcNAQcCoIIjbDCCI2gCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBD4veRXp+hWIIw
# DTpOAarRfcjWQJlsO7zY1n0UFN/WxKCCDXMwggXxMIID2aADAgECAhMzAAABxC/f
# loSRukyuAAAAAAHEMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjAwOTI0MTkxMzE5WhcNMjEwOTIzMTkxMzE5WjByMQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMRwwGgYDVQQDExNTa3lw
# ZSBTb2Z0d2FyZSBTYXJsMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# mukxYIUP1RzxkmQLx6QILvQ0OryT3S4v7iazKVoNAAlLN59fvb/nxpcjbXKmB8s3
# 801nLYnNH9YOucqXe+1eow6Y860VqLf9WotFnVPXi8qyGF3HRz5WOnpJpp+EPR4I
# lq/oRc6MBpHGPiYqGbg/uRHs/Mo6j4iM5hhpiKYgvNDVIJ5Yq1JgUVrptKJyhg0A
# DlbCfJ3QjuJ9OhHhjsjOTDRamD8EFrEUkEhIWkQSwLlCCyxEOnTmYeCkz5LLM6sB
# 00mBXKSxyXnCeWGOHv3rweBf6r0Ba4Ugw66re4A+jEPA01evnBJMKFsPM3au5u+2
# OC2DMVn1jJ0ZSuPXAuDBJwIDAQABo4IBcjCCAW4wEwYDVR0lBAwwCgYIKwYBBQUH
# AwMwHQYDVR0OBBYEFDns7CCDCh3DFePbm/aHoX4oSgW0MFAGA1UdEQRJMEekRTBD
# MSkwJwYDVQQLEyBNaWNyb3NvZnQgT3BlcmF0aW9ucyBQdWVydG8gUmljbzEWMBQG
# A1UEBRMNMjMwMjU0KzQ2MTIyOTAfBgNVHSMEGDAWgBRIbmTlUAXTgqoXNzcitW2o
# ynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20v
# cGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3JsMGEGCCsG
# AQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3J0MAwG
# A1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIBAAWAmK5K7a9OXogJHeKetzTZ
# Dxo29fkF9YFuQpZsqiIYE4GplRWEeA32nRSR7GVaPtN2q6sSr+uJVegqHhbPrRnL
# dHw7Pbt4KXnTXEJmhhI8EoNZkL/LZa68pqwTEoUye6MkHj/UO6jq+bJ2c3Rh80zE
# 1msYbm2F5BdCLhDlC42R0Sf2coXQCmg8bg5DQZOO3J1w/hI2Zzd8SemVhwNhzgQX
# jc7VCr00VZamP8/Wmr+App+meaApN2CnRTdOvE1sxoV7u0VBC0rfYCMkKl9nQBKr
# 42dz/nOf9bqMNUMqoBkb0ts3WSbzrFG9+RFRI81tyyN5RtsdhSKxKz5tsp3Fus4m
# vnfnosNG7eT3va4ftNP2Kxv/ZrCHONCEmij89KLr/u6If7JYUUwY8L7gwX/Uwa/O
# quz9ITaYVu0h5h+/2eZ2fMU90VIB22/c4XiWQ6OkmcDmW1H2SPiUrnsYq/nmAwP2
# ZTwNBr2qL00ApUrlJxgzj9nrFTFBdfg3zb5DTLUNujRveXqRTMQSDkv6Zz6oMl+v
# Rs1TJwbVpP9D+XyyzO3uWuEFWFDbzxwC60ZlNAXfiAF8f8lNJmDylVzyB5kqcWtV
# zUx52QuL71s3UJakArS36QebQhfzBBh8KM2JkDQGPP2nNxomg7k7qGIrLOvFzIMs
# IwKg0F+Q2PdHuEaIAGM4MIIHejCCBWKgAwIBAgIKYQ6Q0gAAAAAAAzANBgkqhkiG
# 9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAO
# BgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEy
# MDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIw
# MTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEwOTA5WjB+MQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQgQ29k
# ZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKC
# AgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+laUKq4BjgaBEm6f8MMHt03a8YS
# 2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc6Whe0t+bU7IKLMOv2akrrnoJ
# r9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4Ddato88tt8zpcoRb0RrrgOGSs
# bmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+lD3v++MrWhAfTVYoonpy4BI6
# t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nkkDstrjNYxbc+/jLTswM9sbKv
# kjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6A4aN91/w0FK/jJSHvMAhdCVf
# GCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmdX4jiJV3TIUs+UsS1Vz8kA/DR
# elsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL5zmhD+kjSbwYuER8ReTBw3J6
# 4HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zdsGbiwZeBe+3W7UvnSSmnEyim
# p31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3T8HhhUSJxAlMxdSlQy90lfdu
# +HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS4NaIjAsCAwEAAaOCAe0wggHp
# MBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRIbmTlUAXTgqoXNzcitW2oynUC
# lTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0T
# AQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBDuRQFTuHqp8cx0SOJNDBaBgNV
# HR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9w
# cm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3JsMF4GCCsGAQUF
# BwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3Br
# aS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3J0MIGfBgNVHSAE
# gZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5t
# aWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1hcnljcHMuaHRtMEAGCCsGAQUF
# BwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkAYwB5AF8AcwB0AGEAdABlAG0A
# ZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn8oalmOBUeRou09h0ZyKbC5YR
# 4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7v0epo/Np22O/IjWll11lhJB9
# i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0bpdS1HXeUOeLpZMlEPXh6I/MT
# faaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/KmtYSWMfCWluWpiW5IP0wI/z
# Rive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvyCInWH8MyGOLwxS3OW560STkK
# xgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBpmLJZiWhub6e3dMNABQamASoo
# PoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJihsMdYzaXht/a8/jyFqGaJ+HN
# pZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYbBL7fQccOKO7eZS/sl/ahXJbY
# ANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbSoqKfenoi+kiVH6v7RyOA9Z74
# v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sLgOppO6/8MO0ETI7f33VtY5E9
# 0Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtXcVZOSEXAQsmbdlsKgEhr/Xmf
# wb1tbWrJUnMTDXpQzTGCFV4wghVaAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTECEzMAAAHEL9+WhJG6TK4AAAAAAcQwDQYJYIZIAWUDBAIBBQCg
# gaYwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwG
# CisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIC+d23IOiXud4F32L6T6Pw/mLRqp
# GpARbdGIMKZhKZsiMDoGCisGAQQBgjcCAQwxLDAqoAyACgBTAGsAeQBwAGWhGoAY
# aHR0cDovL3d3dy5taWNyb3NvZnQuY29tMA0GCSqGSIb3DQEBAQUABIIBAIC2ushZ
# DiIjlRsyozBPi5mLGPrBqDYS51wlIvCwGC5SH7fdiLw/O/Sbvr7EgrYZ8dhXtrk4
# xZM+e7GwNrwsAXyWiT0J5JiVUuGIpfKBpk2MigGpOFaundqlGBbESzFBN3mswyX8
# 80BkFWP79Npccr54yiGvSOTjuJknPvCzgKYcgM1m8TGJIkLVwhNwxhOxUnJmBwUW
# LNBEgYh2bE/D3z/zTfZm0ZPVj0C8C0QL05PfdJBE3dnG61CUpDY5xPuObIWawzAA
# Ch0jwXDU1oiHE85l9Y8khNfSDEvMb+GGFoycSNg+IsKG+Q7tslv4k5xfnUnnUtIn
# dXtxAsVD5LwFrYehghLwMIIS7AYKKwYBBAGCNwMDATGCEtwwghLYBgkqhkiG9w0B
# BwKgghLJMIISxQIBAzEPMA0GCWCGSAFlAwQCAQUAMIIBVAYLKoZIhvcNAQkQAQSg
# ggFDBIIBPzCCATsCAQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEFAAQg4nDO
# /rFnIORPQGzoDnmlWX3qV/4H5dFzyN61TnG6NhkCBmCJ5a4EURgSMjAyMTA1MDcw
# MzM1NDEuMDNaMASAAgH0oIHUpIHRMIHOMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSkwJwYDVQQLEyBNaWNyb3NvZnQgT3BlcmF0aW9ucyBQdWVy
# dG8gUmljbzEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046ODk3QS1FMzU2LTE3MDEx
# JTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wggg5EMIIE9TCC
# A92gAwIBAgITMwAAAWAHIPCSSNq+6wAAAAABYDANBgkqhkiG9w0BAQsFADB8MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNy
# b3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yMTAxMTQxOTAyMjBaFw0yMjA0
# MTExOTAyMjBaMIHOMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQ
# MA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
# MSkwJwYDVQQLEyBNaWNyb3NvZnQgT3BlcmF0aW9ucyBQdWVydG8gUmljbzEmMCQG
# A1UECxMdVGhhbGVzIFRTUyBFU046ODk3QS1FMzU2LTE3MDExJTAjBgNVBAMTHE1p
# Y3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggEiMA0GCSqGSIb3DQEBAQUAA4IB
# DwAwggEKAoIBAQC0MYAc0PLGzPFSMz4JjfU1pFrNpPEtQmVMjefEi8y1t9efK2Wf
# zuJevBm+EpBP4gVEpOMlXrASjlaJ2yy95wMCF5rGIZ+QUdEVzyPVy4s81arJVIBz
# 80z0bTLWbvo7coAqYeTH6rgYmv0qdB44+5RA6zR0fwv9f8QmmckKYCEe5QESSGkV
# Yecvlqm6pm1LBSKBeVB8MMyRSaTl8WLQNLlrq2iqXQlMwM4esJCmYDJEa1z9xP8O
# XLOFO3GImI2URpZtxq/ryYJMk7CltzgYk7ZGlv3o7aVvkuqbvzXs1xagM8Lkg43i
# CJjjnhGr5QPTvVaQnsaNc+lQqadBG9/dOLoTAgMBAAGjggEbMIIBFzAdBgNVHQ4E
# FgQUp5se+LeoF+Ca4XUyCXV80Ou+H2MwHwYDVR0jBBgwFoAU1WM6XIoxkPNDe3xG
# G8UzaFqFbVUwVgYDVR0fBE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQu
# Y29tL3BraS9jcmwvcHJvZHVjdHMvTWljVGltU3RhUENBXzIwMTAtMDctMDEuY3Js
# MFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3Nv
# ZnQuY29tL3BraS9jZXJ0cy9NaWNUaW1TdGFQQ0FfMjAxMC0wNy0wMS5jcnQwDAYD
# VR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDCDANBgkqhkiG9w0BAQsFAAOC
# AQEAFTSYCJs6BaaJUHVPJ2HXF+8kpShD9+faoOUP0hae3uI+XQNVfpLL5inWQdY4
# Y7AbNiJjTiLcjWNrtjcI2uCTcRX/tsvyk3D/BhPex/KIK/XPlW9bhxe4LZ3txfL5
# 79Am+/SuJm4YuktECIaj3CPHN+lKnj8CjC5t9ifrzvcLiltjSvL/WwOYELvdgI+r
# n+wBgLjWByIdImaJPm3LiaWDyimNZ70thGtYM5hfCf4qz2ODFvL+P4GnpCaLH5HO
# oG6JmuMNYBQxioCob+7ZU9fud7hxkdk0tajGHjcBnxrY4k8UNQZUBGYm5OzxXwnv
# ikYU0Uwkbc1p0oNzRBNMtqi51DCCBnEwggRZoAMCAQICCmEJgSoAAAAAAAIwDQYJ
# KoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0
# eSAyMDEwMB4XDTEwMDcwMTIxMzY1NVoXDTI1MDcwMTIxNDY1NVowfDELMAkGA1UE
# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0
# IFRpbWUtU3RhbXAgUENBIDIwMTAwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQCpHQ28dxGKOiDs/BOX9fp/aZRrdFQQ1aUKAIKF++18aEssX8XD5WHCdrc+
# Zitb8BVTJwQxH0EbGpUdzgkTjnxhMFmxMEQP8WCIhFRDDNdNuDgIs0Ldk6zWczBX
# JoKjRQ3Q6vVHgc2/JGAyWGBG8lhHhjKEHnRhZ5FfgVSxz5NMksHEpl3RYRNuKMYa
# +YaAu99h/EbBJx0kZxJyGiGKr0tkiVBisV39dx898Fd1rL2KQk1AUdEPnAY+Z3/1
# ZsADlkR+79BL/W7lmsqxqPJ6Kgox8NpOBpG2iAg16HgcsOmZzTznL0S6p/TcZL2k
# AcEgCZN4zfy8wMlEXV4WnAEFTyJNAgMBAAGjggHmMIIB4jAQBgkrBgEEAYI3FQEE
# AwIBADAdBgNVHQ4EFgQU1WM6XIoxkPNDe3xGG8UzaFqFbVUwGQYJKwYBBAGCNxQC
# BAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYD
# VR0jBBgwFoAU1fZWy4/oolxiaNE9lJBb186aGMQwVgYDVR0fBE8wTTBLoEmgR4ZF
# aHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljUm9v
# Q2VyQXV0XzIwMTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcw
# AoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJB
# dXRfMjAxMC0wNi0yMy5jcnQwgaAGA1UdIAEB/wSBlTCBkjCBjwYJKwYBBAGCNy4D
# MIGBMD0GCCsGAQUFBwIBFjFodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vUEtJL2Rv
# Y3MvQ1BTL2RlZmF1bHQuaHRtMEAGCCsGAQUFBwICMDQeMiAdAEwAZQBnAGEAbABf
# AFAAbwBsAGkAYwB5AF8AUwB0AGEAdABlAG0AZQBuAHQALiAdMA0GCSqGSIb3DQEB
# CwUAA4ICAQAH5ohRDeLG4Jg/gXEDPZ2joSFvs+umzPUxvs8F4qn++ldtGTCzwsVm
# yWrf9efweL3HqJ4l4/m87WtUVwgrUYJEEvu5U4zM9GASinbMQEBBm9xcF/9c+V4X
# NZgkVkt070IQyK+/f8Z/8jd9Wj8c8pl5SpFSAK84Dxf1L3mBZdmptWvkx872ynoA
# b0swRCQiPM/tA6WWj1kpvLb9BOFwnzJKJ/1Vry/+tuWOM7tiX5rbV0Dp8c6ZZpCM
# /2pif93FSguRJuI57BlKcWOdeyFtw5yjojz6f32WapB4pm3S4Zz5Hfw42JT0xqUK
# loakvZ4argRCg7i1gJsiOCC1JeVk7Pf0v35jWSUPei45V3aicaoGig+JFrphpxHL
# mtgOR5qAxdDNp9DvfYPw4TtxCd9ddJgiCGHasFAeb73x4QDf5zEHpJM692VHeOj4
# qEir995yfmFrb3epgcunCaw5u+zGy9iCtHLNHfS4hQEegPsbiSpUObJb2sgNVZl6
# h3M7COaYLeqN4DMuEin1wC9UJyH3yKxO2ii4sanblrKnQqLJzxlBTeCG+SqaoxFm
# MNO7dDJL32N79ZmKLxvHIa9Zta7cRDyXUHHXodLFVeNp3lfB0d4wwP3M5k37Db9d
# T+mdHhk4L7zPWAUu7w2gUDXa7wknHNWzfjUeCLraNtvTX4/edIhJEqGCAtIwggI7
# AgEBMIH8oYHUpIHRMIHOMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3Rv
# bjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
# aW9uMSkwJwYDVQQLEyBNaWNyb3NvZnQgT3BlcmF0aW9ucyBQdWVydG8gUmljbzEm
# MCQGA1UECxMdVGhhbGVzIFRTUyBFU046ODk3QS1FMzU2LTE3MDExJTAjBgNVBAMT
# HE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2WiIwoBATAHBgUrDgMCGgMVAPsy
# knR1i0TcyJcqh1cV2YCp2dCioIGDMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# UENBIDIwMTAwDQYJKoZIhvcNAQEFBQACBQDkPu/uMCIYDzIwMjEwNTA3MDI0NTAy
# WhgPMjAyMTA1MDgwMjQ1MDJaMHcwPQYKKwYBBAGEWQoEATEvMC0wCgIFAOQ+7+4C
# AQAwCgIBAAICDIwCAf8wBwIBAAICEc0wCgIFAORAQW4CAQAwNgYKKwYBBAGEWQoE
# AjEoMCYwDAYKKwYBBAGEWQoDAqAKMAgCAQACAwehIKEKMAgCAQACAwGGoDANBgkq
# hkiG9w0BAQUFAAOBgQBmH5A2IKWX1RuqMxcPFOkS2xBDOwZQ9/Ztn5GICkbA6gl9
# UrsJ/4K5vmC1c/UJaEb6ihfctlCtW9KNk4Rk4/yhICPjd23uFimR90pzOQZjEGR8
# dwSgBFCAFz0XJQZ2Kq+lsNTMoMe5U1RcWsm6KKjAASYBge46MlROC7LRudNRxDGC
# Aw0wggMJAgEBMIGTMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAB
# YAcg8JJI2r7rAAAAAAFgMA0GCWCGSAFlAwQCAQUAoIIBSjAaBgkqhkiG9w0BCQMx
# DQYLKoZIhvcNAQkQAQQwLwYJKoZIhvcNAQkEMSIEIJn7nNcyf5zOG8P8aaOYfI7M
# sL81LSWWVVrnP2RJINNcMIH6BgsqhkiG9w0BCRACLzGB6jCB5zCB5DCBvQQgAhKj
# vaNzLpdbRaevHuoryn6V0v+PXBcJ4l5I96iwZbkwgZgwgYCkfjB8MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQg
# VGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAWAHIPCSSNq+6wAAAAABYDAiBCCqe8I/
# lqXXMlgqRonkRAUhWtRwBFIbw/urHIQ0HstBODANBgkqhkiG9w0BAQsFAASCAQB5
# bWcz6QKALCj9e4a/fkFYRUwM3TVBZMwltgYkL0BcYJSblsm+5ED49FmFWw8s4Zic
# ZJPRBrrxFNaSLZ/QYaycWCiEBMdJ6K4gGIeU3pXeIJER4k7wAtBkR/ZI05aTuXU4
# x33jzOEqqD12bv5b3bGEC/zivAoYZyhuGGFCzX0NGZ18puqwySnx7C9wSMF6iKdQ
# 9FzlqFpFZ2Lv5qYAuN6L3Cm9Xl5Lp40hlrmyOCsWjnBq9SHq4vLjEFOskkQ5QzgA
# abjNKkVhk2P3AbMaFHCnHtQS+MIY9fIY6pFipW+g07e+1zyCdNN6Y+UdLS53khtC
# trhs4/LXZ7Ia7tSryaqm
# SIG # End signature block