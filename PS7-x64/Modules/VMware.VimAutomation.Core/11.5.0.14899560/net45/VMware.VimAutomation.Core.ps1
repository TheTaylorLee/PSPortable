[VMware.VimAutomation.Sdk.Interop.V1.CoreServiceFactory]::CoreService.OnImportModule(
    "VMware.VimAutomation.ViCore.Cmdlets",
    (Split-Path $script:MyInvocation.MyCommand.Path));

function global:New-DatastoreDrive([string] $Name, $Datastore){
<#
.SYNOPSIS
This function creates a new datastore drive.
.DESCRIPTION
This function creates a new drive that is mapped to a location in a datastore.
.PARAMETER Name
Specifies a name for the new drive.
.PARAMETER Datastore
Specifies the datastore for which you want to create a new drive.
#>
	begin {
		if ($Datastore) {
			Write-Output $Datastore | New-DatastoreDrive -Name $Name
		}
	}
	process {
		if ($_) {
			$ds = $_
			New-PSDrive -Name $Name -Root \ -PSProvider VimDatastore -Datastore $ds -Scope global
		}
	}
	end {
	}
}

function global:New-VIInventoryDrive([string] $Name, $Location){
<#
.SYNOPSIS
This function creates a new drive for an inventory item.
.DESCRIPTION
This function creates a new inventory drive that is mapped to a location in a datastore.
.PARAMETER Name
Specifies the name of the new inventory drive.
.PARAMETER Location
Specifies the vSphere container objects (such as folders, data centers, and clusters) for which you want to create the drive.
#>
	begin {
		if ($Location) {
			Write-Output $Location | New-VIInventoryDrive -Name $Name
		}
	}
	process {
		if ($_) {
			$location = $_
			New-PSDrive -Name $name -Root \ -PSProvider VimInventory -Location $location -Scope global
		}
	}
	end {
	}
}

function global:Get-VICommand([string] $Name = "*") {
<#
.SYNOPSIS
This function retrieves all commands of the VMware modules.
.DESCRIPTION
This function retrieves all commands of the imported VMware modules, including cmdlets, aliases, and functions.
.PARAMETER Name
Specifies the name of the command you want to retrieve.
#>
  Get-Command -Module VMware.* -Name $Name
}


function HookGetViewAutoCompleter() {	
	if ( -not (Test-Path Function:\TabExpansionDefault) ) {
		
		# This is the new definition of the TabExpansion2 function
		$tabExpansionProxyFunction = 
		'
			[CmdletBinding(DefaultParameterSetName = ''ScriptInputSet'')]
			Param(
				[Parameter(ParameterSetName = ''ScriptInputSet'', Mandatory = $true, Position = 0)]
				[string] $inputScript,

				[Parameter(ParameterSetName = ''ScriptInputSet'', Mandatory = $true, Position = 1)]
				[int] $cursorColumn,

				[Parameter(ParameterSetName = ''AstInputSet'', Mandatory = $true, Position = 0)]
				[System.Management.Automation.Language.Ast] $ast,

				[Parameter(ParameterSetName = ''AstInputSet'', Mandatory = $true, Position = 1)]
				[System.Management.Automation.Language.Token[]] $tokens,

				[Parameter(ParameterSetName = ''AstInputSet'', Mandatory = $true, Position = 2)]
				[System.Management.Automation.Language.IScriptPosition] $positionOfCursor,

				[Parameter(ParameterSetName = ''ScriptInputSet'', Position = 2)]
				[Parameter(ParameterSetName = ''AstInputSet'', Position = 3)]
				[Hashtable] $options = $null
			)

			End
			{
				if ($psCmdlet.ParameterSetName -eq ''ScriptInputSet'') {
					$shouldProcessInput = [VMware.VimAutomation.ViCore.Cmdlets.Commands.DotNetInterop.GetViewAutoCompleter]::ShouldProcess(
						<#inputScript#>  $inputScript,
						<#cursorColumn#> $cursorColumn,
						<#options#>        $options)
					
					if ($shouldProcessInput) {
						return [VMware.VimAutomation.ViCore.Cmdlets.Commands.DotNetInterop.GetViewAutoCompleter]::CompleteInput(
							<#inputScript#>  $inputScript,
							<#cursorColumn#> $cursorColumn,
							<#options#>        $options)
					} else {
						return global:TabExpansionDefault $inputScript $cursorColumn $options
					}
				} else {
					$shouldProcessInput = [VMware.VimAutomation.ViCore.Cmdlets.Commands.DotNetInterop.GetViewAutoCompleter]::ShouldProcess(
						<#ast#>              $ast,
						<#tokens#>           $tokens,
						<#positionOfCursor#> $positionOfCursor,
						<#options#>          $options)
					
					if ($shouldProcessInput) {
						return [VMware.VimAutomation.ViCore.Cmdlets.Commands.DotNetInterop.GetViewAutoCompleter]::CompleteInput(
							<#ast#>              $ast,
							<#tokens#>           $tokens,
							<#positionOfCursor#> $positionOfCursor,
							<#options#>          $options)
					} else {
						return global:TabExpansionDefault $ast $tokens $positionOfCursor $options
					}
				}
			}
		'
	
		# Declare a new function that will hold the current tab expansion implementation
		Copy-Item Function:\TabExpansion2 Function:\global:TabExpansionDefault
		
		# Override the current tab expansion implementation to hook our proxy
		Set-Item -Path Function:\TabExpansion2 -Value $tabExpansionProxyFunction
	}
}


# Aliases
set-alias Get-VIServer Connect-VIServer -Scope Global
set-alias Get-VC Connect-VIServer -Scope Global
set-alias Get-ESX Connect-VIServer -Scope Global
set-alias Answer-VMQuestion Set-VMQuestion -Scope Global
set-alias Get-PowerCLIDocumentation Get-PowerCLIHelp -Scope Global
set-alias Get-VIToolkitVersion Get-PowerCLIVersion -Scope Global
set-alias Get-VIToolkitConfiguration Get-PowerCLIConfiguration -Scope Global
set-alias Set-VIToolkitConfiguration Set-PowerCLIConfiguration -Scope Global
set-alias Export-VM Export-VApp -Scope Global
set-alias Apply-VMHostProfile Invoke-VMHostProfile -Scope Global
set-alias Apply-DrsRecommendation Invoke-DrsRecommendation -Scope Global
set-alias Shutdown-VMGuest Stop-VMGuest -Scope Global

# Uid utilities
$global:UidUtil = [VMware.VimAutomation.ViCore.Cmdlets.Utilities.UidUtil]::Create()
add-member -inputobject $global:UidUtil -membertype scriptmethod -name GetHelp -Value { Get-Help about_uid }

HookGetViewAutoCompleter

# SIG # Begin signature block
# MIIdUQYJKoZIhvcNAQcCoIIdQjCCHT4CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUmi95Kw21sa44pQBm05tg5qgC
# SUagghhkMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggTMMIIDtKADAgECAhBdqtQcwalQC13tonk09GI7MA0GCSqGSIb3DQEBCwUAMH8x
# CzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0G
# A1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0d29yazEwMC4GA1UEAxMnU3ltYW50ZWMg
# Q2xhc3MgMyBTSEEyNTYgQ29kZSBTaWduaW5nIENBMB4XDTE4MDgxMzAwMDAwMFoX
# DTIxMDkxMTIzNTk1OVowZDELMAkGA1UEBhMCVVMxEzARBgNVBAgMCkNhbGlmb3Ju
# aWExEjAQBgNVBAcMCVBhbG8gQWx0bzEVMBMGA1UECgwMVk13YXJlLCBJbmMuMRUw
# EwYDVQQDDAxWTXdhcmUsIEluYy4wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQCuswYfqnKot0mNu9VhCCCRvVcCrxoSdB6G30MlukAVxgQ8qTyJwr7IVBJX
# EKJYpzv63/iDYiNAY3MOW+Pb4qGIbNpafqxc2WLW17vtQO3QZwscIVRapLV1xFpw
# uxJ4LYdsxHPZaGq9rOPBOKqTP7JyKQxE/1ysjzacA4NXHORf2iars70VpZRksBzk
# niDmurvwCkjtof+5krxXd9XSDEFZ9oxeUGUOBCvSLwOOuBkWPlvCnzEqMUeSoXJa
# vl1QSJvUOOQeoKUHRycc54S6Lern2ddmdUDPwjD2cQ3PL8cgVqTsjRGDrCgOT7Gw
# ShW3EsRsOwc7o5nsiqg/x7ZmFpSJAgMBAAGjggFdMIIBWTAJBgNVHRMEAjAAMA4G
# A1UdDwEB/wQEAwIHgDArBgNVHR8EJDAiMCCgHqAchhpodHRwOi8vc3Yuc3ltY2Iu
# Y29tL3N2LmNybDBhBgNVHSAEWjBYMFYGBmeBDAEEATBMMCMGCCsGAQUFBwIBFhdo
# dHRwczovL2Quc3ltY2IuY29tL2NwczAlBggrBgEFBQcCAjAZDBdodHRwczovL2Qu
# c3ltY2IuY29tL3JwYTATBgNVHSUEDDAKBggrBgEFBQcDAzBXBggrBgEFBQcBAQRL
# MEkwHwYIKwYBBQUHMAGGE2h0dHA6Ly9zdi5zeW1jZC5jb20wJgYIKwYBBQUHMAKG
# Gmh0dHA6Ly9zdi5zeW1jYi5jb20vc3YuY3J0MB8GA1UdIwQYMBaAFJY7U/B5M5ev
# fYPvLivMyreGHnJmMB0GA1UdDgQWBBTVp9RQKpAUKYYLZ70Ta983qBUJ1TANBgkq
# hkiG9w0BAQsFAAOCAQEAlnsx3io+W/9i0QtDDhosvG+zTubTNCPtyYpv59Nhi81M
# 0GbGOPNO3kVavCpBA11Enf0CZuEqf/ctbzYlMRONwQtGZ0GexfD/RhaORSKib/AC
# t70siKYBHyTL1jmHfIfi2yajKkMxUrPM9nHjKeagXTCGthD/kYW6o7YKKcD7kQUy
# BhofimeSgumQlm12KSmkW0cHwSSXTUNWtshVz+74EcnZtGFI6bwYmhvnTp05hWJ8
# EU2Y1LdBwgTaRTxlSDP9JK+e63vmSXElMqnn1DDXABT5RW8lNt6g9P09a2J8p63J
# GgwMBhmnatw7yrMm5EAo+K6gVliJLUMlTW3O09MbDTCCBVkwggRBoAMCAQICED14
# 1/l2SWCyYX308B7KhiowDQYJKoZIhvcNAQELBQAwgcoxCzAJBgNVBAYTAlVTMRcw
# FQYDVQQKEw5WZXJpU2lnbiwgSW5jLjEfMB0GA1UECxMWVmVyaVNpZ24gVHJ1c3Qg
# TmV0d29yazE6MDgGA1UECxMxKGMpIDIwMDYgVmVyaVNpZ24sIEluYy4gLSBGb3Ig
# YXV0aG9yaXplZCB1c2Ugb25seTFFMEMGA1UEAxM8VmVyaVNpZ24gQ2xhc3MgMyBQ
# dWJsaWMgUHJpbWFyeSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eSAtIEc1MB4XDTEz
# MTIxMDAwMDAwMFoXDTIzMTIwOTIzNTk1OVowfzELMAkGA1UEBhMCVVMxHTAbBgNV
# BAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMR8wHQYDVQQLExZTeW1hbnRlYyBUcnVz
# dCBOZXR3b3JrMTAwLgYDVQQDEydTeW1hbnRlYyBDbGFzcyAzIFNIQTI1NiBDb2Rl
# IFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCXgx4A
# Fq8ssdIIxNdok1FgHnH24ke021hNI2JqtL9aG1H3ow0Yd2i72DarLyFQ2p7z518n
# TgvCl8gJcJOp2lwNTqQNkaC07BTOkXJULs6j20TpUhs/QTzKSuSqwOg5q1PMIdDM
# z3+b5sLMWGqCFe49Ns8cxZcHJI7xe74xLT1u3LWZQp9LYZVfHHDuF33bi+VhiXjH
# aBuvEXgamK7EVUdT2bMy1qEORkDFl5KK0VOnmVuFNVfT6pNiYSAKxzB3JBFNYoO2
# untogjHuZcrf+dWNsjXcjCtvanJcYISc8gyUXsBWUgBIzNP4pX3eL9cT5DiohNVG
# uBOGwhud6lo43ZvbAgMBAAGjggGDMIIBfzAvBggrBgEFBQcBAQQjMCEwHwYIKwYB
# BQUHMAGGE2h0dHA6Ly9zMi5zeW1jYi5jb20wEgYDVR0TAQH/BAgwBgEB/wIBADBs
# BgNVHSAEZTBjMGEGC2CGSAGG+EUBBxcDMFIwJgYIKwYBBQUHAgEWGmh0dHA6Ly93
# d3cuc3ltYXV0aC5jb20vY3BzMCgGCCsGAQUFBwICMBwaGmh0dHA6Ly93d3cuc3lt
# YXV0aC5jb20vcnBhMDAGA1UdHwQpMCcwJaAjoCGGH2h0dHA6Ly9zMS5zeW1jYi5j
# b20vcGNhMy1nNS5jcmwwHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMDMA4G
# A1UdDwEB/wQEAwIBBjApBgNVHREEIjAgpB4wHDEaMBgGA1UEAxMRU3ltYW50ZWNQ
# S0ktMS01NjcwHQYDVR0OBBYEFJY7U/B5M5evfYPvLivMyreGHnJmMB8GA1UdIwQY
# MBaAFH/TZafC3ey78DAJ80M5+gKvMzEzMA0GCSqGSIb3DQEBCwUAA4IBAQAThRoe
# aak396C9pK9+HWFT/p2MXgymdR54FyPd/ewaA1U5+3GVx2Vap44w0kRaYdtwb9oh
# BcIuc7pJ8dGT/l3JzV4D4ImeP3Qe1/c4i6nWz7s1LzNYqJJW0chNO4LmeYQW/Ciw
# sUfzHaI+7ofZpn+kVqU/rYQuKd58vKiqoz0EAeq6k6IOUCIpF0yH5DoRX9akJYmb
# BWsvtMkBTCd7C6wZBSKgYBU/2sn7TUyP+3Jnd/0nlMe6NQ6ISf6N/SivShK9DbOX
# Bd5EDBX6NisD3MFQAfGhEV0U5eK9J0tUviuEXg+mw3QFCu+Xw4kisR93873NQ9Tx
# TKk/tYuEr2Ty0BQhMIIFmjCCA4KgAwIBAgIKYRmT5AAAAAAAHDANBgkqhkiG9w0B
# AQUFADB/MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSkwJwYD
# VQQDEyBNaWNyb3NvZnQgQ29kZSBWZXJpZmljYXRpb24gUm9vdDAeFw0xMTAyMjIx
# OTI1MTdaFw0yMTAyMjIxOTM1MTdaMIHKMQswCQYDVQQGEwJVUzEXMBUGA1UEChMO
# VmVyaVNpZ24sIEluYy4xHzAdBgNVBAsTFlZlcmlTaWduIFRydXN0IE5ldHdvcmsx
# OjA4BgNVBAsTMShjKSAyMDA2IFZlcmlTaWduLCBJbmMuIC0gRm9yIGF1dGhvcml6
# ZWQgdXNlIG9ubHkxRTBDBgNVBAMTPFZlcmlTaWduIENsYXNzIDMgUHVibGljIFBy
# aW1hcnkgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkgLSBHNTCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBAK8kCAgpejWeYAyq50s7Ttx8vDxFHLsr4P4pAvlX
# CKNkhRUn9fGtyDGJXSLoKqqmQrOP+LlVt7G3S7P+j34HV+zvQ9tmYhVhz2ANpNje
# +ODDYgg9VBPrScpZVIUm5SuPG5/r9aGRwjNJ2ENjalJL0o/ocFFN0Ylpe8dw9rPc
# EnTbe11LVtOWvxV3obD0oiXyrxySZxjl9AYE75C55ADk3Tq1Gf8CuvQ87uCL6zeL
# 7PTXrPL28D2v3XWRMxkdHEDLdCQZIZPZFP6sKlLHj9UESeSNY0eIPGmDy/5HvSt+
# T8WVrg6d1NFDwGdz4xQIfuU/n3O4MwrPXT80h5aK7lPoJRUCAwEAAaOByzCByDAR
# BgNVHSAECjAIMAYGBFUdIAAwDwYDVR0TAQH/BAUwAwEB/zALBgNVHQ8EBAMCAYYw
# HQYDVR0OBBYEFH/TZafC3ey78DAJ80M5+gKvMzEzMB8GA1UdIwQYMBaAFGL7CiFb
# f0NuEdoJVFBr9dKWcfGeMFUGA1UdHwROMEwwSqBIoEaGRGh0dHA6Ly9jcmwubWlj
# cm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY3Jvc29mdENvZGVWZXJpZlJv
# b3QuY3JsMA0GCSqGSIb3DQEBBQUAA4ICAQCBKoIWjDRnK+UD6zR7jKKjUIr0VYbx
# HoyOrn3uAxnOcpUYSK1iEf0g/T9HBgFa4uBvjBUsTjxqUGwLNqPPeg2cQrxc+BnV
# YONp5uIjQWeMaIN2K4+Toyq1f75Z+6nJsiaPyqLzghuYPpGVJ5eGYe5bXQdrzYao
# 4mWAqOIV4rK+IwVqugzzR5NNrKSMB3k5wGESOgUNiaPsn1eJhPvsynxHZhSR2LYP
# GV3muEqsvEfIcUOW5jIgpdx3hv0844tx23ubA/y3HTJk6xZSoEOj+i6tWZJOfMfy
# M0JIOFE6fDjHGyQiKEAeGkYfF9sY9/AnNWy4Y9nNuWRdK6Ve78YptPLH+CHMBLpX
# /QG2q8Zn+efTmX/09SL6cvX9/zocQjqh+YAYpe6NHNRmnkUB/qru//sXjzD38c0p
# xZ3stdVJAD2FuMu7kzonaknAMK5myfcjKDJ2+aSDVshIzlqWqqDMDMR/tI6Xr23j
# VCfDn4bA1uRzCJcF29BUYl4DSMLVn3+nZozQnbBP1NOYX0t6yX+yKVLQEoDHD1S2
# HmfNxqBsEQOE00h15yr+sDtuCjqma3aZBaPxd2hhMxRHBvxTf1K9khRcSiRqZ4yv
# jZCq0PZ5IRuTJnzDzh69iDiSrkXGGWpJULMF+K5ZN4pqJQOUsVmBUOi6g4C3IzX0
# drlnHVkYrSCNlDGCBFcwggRTAgEBMIGTMH8xCzAJBgNVBAYTAlVTMR0wGwYDVQQK
# ExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0GA1UECxMWU3ltYW50ZWMgVHJ1c3Qg
# TmV0d29yazEwMC4GA1UEAxMnU3ltYW50ZWMgQ2xhc3MgMyBTSEEyNTYgQ29kZSBT
# aWduaW5nIENBAhBdqtQcwalQC13tonk09GI7MAkGBSsOAwIaBQCggYowGQYJKoZI
# hvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcC
# ARUwIwYJKoZIhvcNAQkEMRYEFOXvkfhRk6qCRfgp4aYbnSj+QTaAMCoGCisGAQQB
# gjcCAQwxHDAaoRiAFmh0dHA6Ly93d3cudm13YXJlLmNvbS8wDQYJKoZIhvcNAQEB
# BQAEggEAScFWKYfeyEG3lz5iLK1VLr+Uf8M15Tup51o6eeL3V1gMIPYwzXX8Iutn
# PVFcbvy9IaktDd1GhBPUHRHlMA0vMpNHofFGdt2Jl/1stEngpxRaAUPNaObd0I3x
# G/yoAVVNi3ybdY43nyEIkynIggu5W7J9dYUx6e2fXVELtNaFvRx+GHkT4RTjz34K
# jk9JIHQVpW+UuaU4WuD+YJOkjDyDa0wSFcP7qRSCIjIHo/4xh5kWuubdGh2OueSZ
# PZBe+o9dZIznL6DVGKw0fE9To7WHrbxnOrVjC18LlxKT+1StdAFeUD//kXSte99v
# 0k3g9atxCm2X0W1ePADAtpSpZ+OCQaGCAgswggIHBgkqhkiG9w0BCQYxggH4MIIB
# 9AIBATByMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyAhAOz/Q4yP6/NW4E2GqYGxpQMAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0B
# CQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xOTEwMTgxOTA1NDZaMCMG
# CSqGSIb3DQEJBDEWBBRzN6QGNQt4/RcHlgFbq6LHdaAOnDANBgkqhkiG9w0BAQEF
# AASCAQBhzoDcsiwybGtJdDfV02dPLEreH84yiq07P5xykAV/i8TtqtP6Wht3I7sE
# zLSEJzZ0iN9EkEm3FQm9kjjUXp/LEDRW7rjlRV7OJnvoTob8Bt11NRNdmDkJU6A6
# y2uX0MQO4/cbxQwFe+nZOKnTsubYsCi4tT4XqhuLUL+KcR9deKZmSkBjx+rNm6bG
# 2LIeDM7djok9HKOBWGDwEjjfNUVL+a7QVr4yQuMqdhjkS4/ngDzFymll49CsN3V/
# SmY/QyUDS+7PtHj9LSGCZwz5ezuz+HRVuBDEv3MpDwf0bPUQK9si7c4EZoak5vaG
# 0itQtzCFtJc+xyl4sthgw3QiQBfe
# SIG # End signature block
