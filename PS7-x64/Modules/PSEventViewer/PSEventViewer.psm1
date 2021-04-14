function Add-ToHashTable {
    param($Hashtable, $Key, $Value)
    if ($null -ne $Value -and $Value -ne '') { $Hashtable.Add($Key, $Value) }
}
function Convert-Size {
    [cmdletbinding()]
    param([validateset("Bytes", "KB", "MB", "GB", "TB")]
        [string]$From,
        [validateset("Bytes", "KB", "MB", "GB", "TB")]
        [string]$To,
        [Parameter(Mandatory = $true)]
        [double]$Value,
        [int]$Precision = 4,
        [switch]$Display)
    switch ($From) {
        "Bytes" { $value = $Value }
        "KB" { $value = $Value * 1024 }
        "MB" { $value = $Value * 1024 * 1024 }
        "GB" { $value = $Value * 1024 * 1024 * 1024 }
        "TB" { $value = $Value * 1024 * 1024 * 1024 * 1024 }
    }
    switch ($To) {
        "Bytes" { return $value }
        "KB" { $Value = $Value / 1KB }
        "MB" { $Value = $Value / 1MB }
        "GB" { $Value = $Value / 1GB }
        "TB" { $Value = $Value / 1TB }
    }
    if ($Display) { return "$([Math]::Round($value,$Precision,[MidPointRounding]::AwayFromZero)) $To" } else { return [Math]::Round($value, $Precision, [MidPointRounding]::AwayFromZero) }
}
function Get-PSRegistry {
    [cmdletbinding()]
    param([alias('Path')][string[]] $RegistryPath,
        [string[]] $ComputerName = $Env:COMPUTERNAME)
    $RootKeyDictionary = @{HKEY_CLASSES_ROOT = 2147483648
        HKCR                                 = 2147483648
        HKEY_CURRENT_USER                    = 2147483649
        HKCU                                 = 2147483649
        HKEY_LOCAL_MACHINE                   = 2147483650
        HKLM                                 = 2147483650
        HKEY_USERS                           = 2147483651
        HKU                                  = 2147483651
        HKEY_CURRENT_CONFIG                  = 2147483653
        HKCC                                 = 2147483653
        HKEY_DYN_DATA                        = 2147483654
        HKDD                                 = 2147483654
    }
    $TypesDictionary = @{'1' = 'GetStringValue'
        '2'                  = 'GetExpandedStringValue'
        '3'                  = 'GetBinaryValue'
        '4'                  = 'GetDWORDValue'
        '7'                  = 'GetMultiStringValue'
        '11'                 = 'GetQWORDValue'
    }
    $Dictionary = @{'HKCR:' = 'HKEY_CLASSES_ROOT'
        'HKCU:'             = 'HKEY_CURRENT_USER'
        'HKLM:'             = 'HKEY_LOCAL_MACHINE'
        'HKU:'              = 'HKEY_USERS'
        'HKCC:'             = 'HKEY_CURRENT_CONFIG'
        'HKDD:'             = 'HKEY_DYN_DATA'
    }
    [uint32] $RootKey = $null
    [Array] $Computers = Get-ComputerSplit -ComputerName $ComputerName
    foreach ($Registry in $RegistryPath) {
        If ($Registry -like '*:*') {
            foreach ($Key in $Dictionary.Keys) {
                if ($Registry.StartsWith($Key)) {
                    $Registry = $Registry -replace $Key, $Dictionary[$Key]
                    break
                }
            }
        }
        for ($ComputerSplit = 0; $ComputerSplit -lt $Computers.Count; $ComputerSplit++) {
            if ($Computers[$ComputerSplit].Count -gt 0) {
                $Arguments = foreach ($_ in $RootKeyDictionary.Keys) {
                    if ($Registry.StartsWith($_)) {
                        $RootKey = [uint32] $RootKeyDictionary[$_]
                        @{hDefKey       = [uint32] $RootKeyDictionary[$_]
                            sSubKeyName = $Registry.substring($_.Length + 1)
                        }
                        break
                    }
                }
                if ($ComputerSplit -eq 0) {
                    $Output2 = Invoke-CimMethod -Namespace root\cimv2 -ClassName StdRegProv -MethodName EnumValues -Arguments $Arguments -Verbose:$false
                    $OutputKeys = Invoke-CimMethod -Namespace root\cimv2 -ClassName StdRegProv -MethodName EnumKey -Arguments $Arguments -Verbose:$false
                } else {
                    $Output2 = Invoke-CimMethod -Namespace root\cimv2 -ClassName StdRegProv -MethodName EnumValues -Arguments $Arguments -ComputerName $Computers[$ComputerSplit] -Verbose:$false
                    $OutputKeys = Invoke-CimMethod -Namespace root\cimv2 -ClassName StdRegProv -MethodName EnumKey -ComputerName $Computers[$ComputerSplit] -Arguments $Arguments -Verbose:$false
                }
                foreach ($Entry in $Output2) {
                    $RegistryOutput = [ordered] @{}
                    if ($Entry.ReturnValue -ne 0) { $RegistryOutput['PSError'] = $true } else {
                        $RegistryOutput['PSError'] = $false
                        $Types = $Entry.Types
                        $Names = $Entry.sNames
                        for ($i = 0; $i -lt $Names.Count; $i++) {
                            $Arguments['sValueName'] = $Names[$i]
                            $MethodName = $TypesDictionary["$($Types[$i])"]
                            if ($ComputerSplit -eq 0) { $Values = Invoke-CimMethod -Namespace root\cimv2 -ClassName StdRegProv -MethodName $MethodName -Arguments $Arguments -Verbose:$false } else { $Values = Invoke-CimMethod -Namespace root\cimv2 -ClassName StdRegProv -MethodName $MethodName -Arguments $Arguments -ComputerName $Entry.PSComputerName -Verbose:$false }
                            if ($null -ne $Values.sValue) { if ($Names[$i]) { $RegistryOutput[$Names[$i]] = $Values.sValue } else { $RegistryOutput['DefaultKey'] = $Values.sValue } } elseif ($null -ne $Values.uValue) { if ($Names[$i]) { $RegistryOutput[$Names[$i]] = $Values.uValue } else { $RegistryOutput['DefaultKey'] = $Values.sValue } }
                        }
                    }
                    if (-not $RegistryOutput['PSComputerName']) { if ($ComputerSplit -eq 0) { $RegistryOutput['PSComputerName'] = $ENV:COMPUTERNAME } else { $RegistryOutput['PSComputerName'] = $Entry.PSComputerName } } else { if ($ComputerSplit -eq 0) { $RegistryOutput['ComputerName'] = $ENV:COMPUTERNAME } else { $RegistryOutput['ComputerName'] = $Entry.PSComputerName } }
                    if (-not $RegistryOutput['PSSubKeys']) { $RegistryOutput['PSSubKeys'] = $OutputKeys.sNames } else { $RegistryOutput['SubKeys'] = $OutputKeys.sNames }
                    $RegistryOutput['PSPath'] = $Registry
                    [PSCustomObject] $RegistryOutput
                }
            }
        }
    }
}
function Get-WinADForestControllers {
    [alias('Get-WinADDomainControllers')]
    <#
    .SYNOPSIS


    .DESCRIPTION
    Long description

    .PARAMETER TestAvailability
    Parameter description

    .EXAMPLE
    Get-WinADForestControllers -TestAvailability | Format-Table

    .EXAMPLE
    Get-WinADDomainControllers

    .EXAMPLE
    Get-WinADDomainControllers | Format-Table *

    Output:

    Domain        HostName          Forest        IPV4Address     IsGlobalCatalog IsReadOnly SchemaMaster DomainNamingMasterMaster PDCEmulator RIDMaster InfrastructureMaster Comment
    ------        --------          ------        -----------     --------------- ---------- ------------ ------------------------ ----------- --------- -------------------- -------
    ad.evotec.xyz AD1.ad.evotec.xyz ad.evotec.xyz 192.168.240.189            True      False         True                     True        True      True                 True
    ad.evotec.xyz AD2.ad.evotec.xyz ad.evotec.xyz 192.168.240.192            True      False        False                    False       False     False                False
    ad.evotec.pl                    ad.evotec.xyz                                                   False                    False       False     False                False Unable to contact the server. This may be becau...

    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param([string[]] $Domain,
        [switch] $TestAvailability,
        [switch] $SkipEmpty)
    try {
        $Forest = Get-ADForest
        if (-not $Domain) { $Domain = $Forest.Domains }
    } catch {
        $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
        Write-Warning "Get-WinADForestControllers - Couldn't use Get-ADForest feature. Error: $ErrorMessage"
        return
    }
    $Servers = foreach ($D in $Domain) {
        try {
            $LocalServer = Get-ADDomainController -Discover -DomainName $D -ErrorAction Stop
            $DC = Get-ADDomainController -Server $LocalServer.HostName[0] -Filter * -ErrorAction Stop
            foreach ($S in $DC) {
                $Server = [ordered] @{Domain = $D
                    HostName                 = $S.HostName
                    Name                     = $S.Name
                    Forest                   = $Forest.RootDomain
                    IPV4Address              = $S.IPV4Address
                    IPV6Address              = $S.IPV6Address
                    IsGlobalCatalog          = $S.IsGlobalCatalog
                    IsReadOnly               = $S.IsReadOnly
                    Site                     = $S.Site
                    SchemaMaster             = ($S.OperationMasterRoles -contains 'SchemaMaster')
                    DomainNamingMaster       = ($S.OperationMasterRoles -contains 'DomainNamingMaster')
                    PDCEmulator              = ($S.OperationMasterRoles -contains 'PDCEmulator')
                    RIDMaster                = ($S.OperationMasterRoles -contains 'RIDMaster')
                    InfrastructureMaster     = ($S.OperationMasterRoles -contains 'InfrastructureMaster')
                    LdapPort                 = $S.LdapPort
                    SslPort                  = $S.SslPort
                    Pingable                 = $null
                    Comment                  = ''
                }
                if ($TestAvailability) { $Server['Pingable'] = foreach ($_ in $Server.IPV4Address) { Test-Connection -Count 1 -Server $_ -Quiet -ErrorAction SilentlyContinue } }
                [PSCustomObject] $Server
            }
        } catch {
            [PSCustomObject]@{Domain     = $D
                HostName                 = ''
                Name                     = ''
                Forest                   = $Forest.RootDomain
                IPV4Address              = ''
                IPV6Address              = ''
                IsGlobalCatalog          = ''
                IsReadOnly               = ''
                Site                     = ''
                SchemaMaster             = $false
                DomainNamingMasterMaster = $false
                PDCEmulator              = $false
                RIDMaster                = $false
                InfrastructureMaster     = $false
                LdapPort                 = ''
                SslPort                  = ''
                Pingable                 = $null
                Comment                  = $_.Exception.Message -replace "`n", " " -replace "`r", " "
            }
        }
    }
    if ($SkipEmpty) { return $Servers | Where-Object { $_.HostName -ne '' } }
    return $Servers
}
function New-Runspace {
    [cmdletbinding()]
    param ([int] $minRunspaces = 1,
        [int] $maxRunspaces = [int]$env:NUMBER_OF_PROCESSORS + 1)
    $RunspacePool = [RunspaceFactory]::CreateRunspacePool($minRunspaces, $maxRunspaces)
    $RunspacePool.Open()
    return $RunspacePool
}
function Set-PSRegistry {
    [cmdletbinding()]
    param([string[]] $ComputerName = $Env:COMPUTERNAME,
        [Parameter(Mandatory)][string] $RegistryPath,
        [Parameter(Mandatory)][ValidateSet('REG_SZ', 'REG_EXPAND_SZ', 'REG_BINARY', 'REG_DWORD', 'REG_MULTI_SZ', 'REG_QWORD')][string] $Type,
        [Parameter(Mandatory)][string] $Key,
        [Parameter(Mandatory)][object] $Value)
    [Array] $ComputersSplit = Get-ComputerSplit -ComputerName $ComputerName
    [uint32] $RootKey = $null
    $RootKeyDictionary = @{HKEY_CLASSES_ROOT = 2147483648
        HKCR                                 = 2147483648
        HKEY_CURRENT_USER                    = 2147483649
        HKCU                                 = 2147483649
        HKEY_LOCAL_MACHINE                   = 2147483650
        HKLM                                 = 2147483650
        HKEY_USERS                           = 2147483651
        HKU                                  = 2147483651
        HKEY_CURRENT_CONFIG                  = 2147483653
        HKCC                                 = 2147483653
        HKEY_DYN_DATA                        = 2147483654
        HKDD                                 = 2147483654
    }
    $TypesDictionary = @{'REG_SZ' = 'SetStringValue'
        'REG_EXPAND_SZ'           = 'SetExpandedStringValue'
        'REG_BINARY'              = 'SetBinaryValue'
        'REG_DWORD'               = 'SetDWORDValue'
        'REG_MULTI_SZ'            = 'SetMultiStringValue'
        'REG_QWORD'               = 'SetQWORDValue'
    }
    $MethodName = $TypesDictionary["$($Type)"]
    $Arguments = foreach ($_ in $RootKeyDictionary.Keys) {
        if ($RegistryPath.StartsWith($_)) {
            $RootKey = [uint32] $RootKeyDictionary[$_]
            $RegistryValue = @{hDefKey = [uint32] $RootKeyDictionary[$_]
                sSubKeyName            = $RegistryPath.substring($_.Length + 1)
                sValueName             = $Key
            }
            if ($Type -in ('REG_SZ', 'REG_EXPAND_SZ', 'REG_MULTI_SZ')) { $RegistryValue['sValue'] = [string] $Value } elseif ($Type -in ('REG_DWORD', 'REG_QWORD')) { $RegistryValue['uValue'] = [uint32] $Value } elseif ($Type -in ('REG_BINARY')) { $RegistryValue['uValue'] = [uint8] $Value }
            $RegistryValue
            break
        }
    }
    foreach ($Computer in $ComputersSplit[0]) {
        try {
            $ReturnValues = Invoke-CimMethod -Namespace root\cimv2 -ClassName StdRegProv -MethodName $MethodName -Arguments $Arguments -ErrorAction Stop -Verbose:$false
            if ($ReturnValues.ReturnValue -ne 0) { Write-Warning "Set-PSRegistry - Setting registry to $RegistryPath on $Computer may have failed. Please verify." }
        } catch { Write-Warning "Set-PSRegistry - Setting registry to $RegistryPath on $Computer have failed. Error: $($_.Exception.Message)" }
    }
    foreach ($Computer in $ComputersSplit[1]) {
        try {
            $ReturnValues = Invoke-CimMethod -Namespace root\cimv2 -ClassName StdRegProv -MethodName $MethodName -Arguments $Arguments -ComputerName $Computer -ErrorAction Stop -Verbose:$false
            if ($ReturnValues.ReturnValue -ne 0) { Write-Warning "Set-PSRegistry - Setting registry to $RegistryPath on $Computer may have failed. Please verify." }
        } catch { Write-Warning "Set-PSRegistry - Setting registry to $RegistryPath on $Computer have failed. Error: $($_.Exception.Message)" }
    }
}
function Split-Array {
    [CmdletBinding()]
    <#
        .SYNOPSIS
        Split an array
        .NOTES
        Version : July 2, 2017 - implemented suggestions from ShadowSHarmon for performance
        .PARAMETER inArray
        A one dimensional array you want to split
        .EXAMPLE
        This splits array into multiple arrays of 3
        Example below wil return 1,2,3  + 4,5,6 + 7,8,9

        Split-array -inArray @(1,2,3,4,5,6,7,8,9,10) -parts 3
        .EXAMPLE
        This splits array into 3 parts regardless of amount of elements


        Split-array -inArray @(1,2,3,4,5,6,7,8,9,10) -size 3

        # Link: https://gallery.technet.microsoft.com/scriptcenter/Split-an-array-into-parts-4357dcc1
    #>
    param([Object] $inArray,
        [int]$parts,
        [int]$size)
    if ($inArray.Count -eq 1) { return $inArray }
    if ($parts) { $PartSize = [Math]::Ceiling($inArray.count / $parts) }
    if ($size) {
        $PartSize = $size
        $parts = [Math]::Ceiling($inArray.count / $size)
    }
    $outArray = New-Object 'System.Collections.Generic.List[psobject]'
    for ($i = 1; $i -le $parts; $i++) {
        $start = (($i - 1) * $PartSize)
        $end = (($i) * $PartSize) - 1
        if ($end -ge $inArray.count) { $end = $inArray.count - 1 }
        $outArray.Add(@($inArray[$start..$end]))
    }
    return , $outArray
}
function Start-Runspace {
    [cmdletbinding()]
    param ([ScriptBlock] $ScriptBlock,
        [System.Collections.IDictionary] $Parameters,
        [System.Management.Automation.Runspaces.RunspacePool] $RunspacePool)
    if ($ScriptBlock -ne '') {
        $runspace = [PowerShell]::Create()
        $null = $runspace.AddScript($ScriptBlock)
        if ($null -ne $Parameters) { $null = $runspace.AddParameters($Parameters) }
        $runspace.RunspacePool = $RunspacePool
        [PSCustomObject]@{Pipe = $runspace
            Status             = $runspace.BeginInvoke()
        }
    }
}
function Start-TimeLog {
    [CmdletBinding()]
    param()
    [System.Diagnostics.Stopwatch]::StartNew()
}
function Stop-Runspace {
    [cmdletbinding()]
    param([Array] $Runspaces,
        [string] $FunctionName,
        [System.Management.Automation.Runspaces.RunspacePool] $RunspacePool,
        [switch] $ExtendedOutput)
    [Array] $List = While (@($Runspaces | Where-Object -FilterScript { $null -ne $_.Status }).count -gt 0) {
        foreach ($Runspace in $Runspaces | Where-Object { $_.Status.IsCompleted -eq $true }) {
            $Errors = foreach ($e in $($Runspace.Pipe.Streams.Error)) {
                Write-Error -ErrorRecord $e
                $e
            }
            foreach ($w in $($Runspace.Pipe.Streams.Warning)) { Write-Warning -Message $w }
            foreach ($v in $($Runspace.Pipe.Streams.Verbose)) { Write-Verbose -Message $v }
            if ($ExtendedOutput) {
                @{Output   = $Runspace.Pipe.EndInvoke($Runspace.Status)
                    Errors = $Errors
                }
            } else { $Runspace.Pipe.EndInvoke($Runspace.Status) }
            $Runspace.Status = $null
        }
    }
    $RunspacePool.Close()
    $RunspacePool.Dispose()
    if ($List.Count -eq 1) { return , $List } else { return $List }
}
function Stop-TimeLog {
    [CmdletBinding()]
    param ([Parameter(ValueFromPipeline = $true)][System.Diagnostics.Stopwatch] $Time,
        [ValidateSet('OneLiner', 'Array')][string] $Option = 'OneLiner',
        [switch] $Continue)
    Begin {}
    Process { if ($Option -eq 'Array') { $TimeToExecute = "$($Time.Elapsed.Days) days", "$($Time.Elapsed.Hours) hours", "$($Time.Elapsed.Minutes) minutes", "$($Time.Elapsed.Seconds) seconds", "$($Time.Elapsed.Milliseconds) milliseconds" } else { $TimeToExecute = "$($Time.Elapsed.Days) days, $($Time.Elapsed.Hours) hours, $($Time.Elapsed.Minutes) minutes, $($Time.Elapsed.Seconds) seconds, $($Time.Elapsed.Milliseconds) milliseconds" } }
    End {
        if (-not $Continue) { $Time.Stop() }
        return $TimeToExecute
    }
}
function Get-ComputerSplit {
    [CmdletBinding()]
    param([string[]] $ComputerName)
    if ($null -eq $ComputerName) { $ComputerName = $Env:COMPUTERNAME }
    try { $LocalComputerDNSName = [System.Net.Dns]::GetHostByName($Env:COMPUTERNAME).HostName } catch { $LocalComputerDNSName = $Env:COMPUTERNAME }
    $ComputersLocal = $null
    [Array] $Computers = foreach ($_ in $ComputerName) {
        if ($_ -eq '' -or $null -eq $_) { $_ = $Env:COMPUTERNAME }
        if ($_ -ne $Env:COMPUTERNAME -and $_ -ne $LocalComputerDNSName) { $_ } else { $ComputersLocal = $_ }
    }
    , @($ComputersLocal, $Computers)
}
Add-Type -TypeDefinition @"
using System;

namespace PSEventViewer
{
    public enum Keywords : long {
        AuditFailure     = (long) 4503599627370496,
        AuditSuccess     = (long) 9007199254740992,
        CorrelationHint2 = (long) 18014398509481984,
        EventLogClassic  = (long) 36028797018963968,
        Sqm              = (long) 2251799813685248,
        WdiDiagnostic    = (long) 1125899906842624,
        WdiContext       = (long) 562949953421312,
        ResponseTime     = (long) 281474976710656,
        None             = (long) 0
    }
}
"@
Add-Type -TypeDefinition @"
using System;

namespace PSEventViewer
{
    public enum Level {
        Verbose       = 5,
        Informational = 4,
        Warning       = 3,
        Error         = 2,
        Critical      = 1,
        LogAlways     = 0
    }
}
"@
$Script:ScriptBlock = { Param ([string]$Comp,
        [ValidateNotNull()]
        [alias('Credentials')][System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty,
        [hashtable]$EventFilter,
        [int]$MaxEvents,
        [bool] $Oldest,
        [bool] $Verbose)
    if ($Verbose) { $VerbosePreference = 'continue' }
    function Get-EventsFilter {
        <#
        .SYNOPSIS
        This function generates an xpath filter that can be used with the -FilterXPath
        parameter of Get-WinEvent.  It may also be used inside the <Select></Select tags
        of a Custom View in Event Viewer.
        .DESCRIPTION
        This function generates an xpath filter that can be used with the -FilterXPath
        parameter of Get-WinEvent.  It may also be used inside the <Select></Select tags
        of a Custom View in Event Viewer.

        This function allows for the create of xpath which can select events based on
        many properties of the event including those of named data nodes in the event's
        XML.

        XPath is case sensetive and the data passed to the parameters here must
        match the case of the data in the event's XML.
        .NOTES
        Original Code by https://community.spiceworks.com/scripts/show/3238-powershell-xpath-generator-for-windows-events
        Extended by Justin Grote
        Extended by Przemyslaw Klys
        .LINK

        .PARAMETER ID
        This parameter accepts and array of event ids to include in the xpath filter.
        .PARAMETER StartTime
        This parameter sets the oldest event that may be returned by the xpath.

        Please, note that the xpath time selector created here is based of of the
        time the xpath is generated.  XPath uses a time difference method to select
        events by time; that time difference being the number of milliseconds between
        the time and now.
        .PARAMETER EndTime
        This parameter sets the newest event that may be returned by the xpath.

        Please, note that the xpath time selector created here is based of of the
        time the xpath is generated.  XPath uses a time difference method to select
        events by time; that time difference being the number of milliseconds between
        the time and now.
        .PARAMETER Data
        This parameter will accept an array of values that may be found in the data
        section of the event's XML.
        .PARAMETER ProviderName
        This parameter will accept an array of values that select events from event
        providers.
        .PARAMETER Level
        This parameter will accept an array of values that specify the severity
        rating of the events to be returned.

        It accepts the following values.

        'Critical',
        'Error',
        'Informational',
        'LogAlways',
        'Verbose',
        'Warning'
        .PARAMETER Keywords
        This parameter accepts and array of long integer keywords. You must
        pass this parameter the long integer value of the keywords you want
        to search and not the keyword description.
        .PARAMETER UserID
        This parameter will accept an array of SIDs or domain accounts.
        .PARAMETER NamedDataFilter
        This parameter will accept and array of hashtables that define the key
        value pairs for which you want to filter against the event's named data
        fields.

        Key values, as with XPath filters, are case sensetive.

        You may assign an array as the value of any key. This will search
        for events where any of the values are present in that particular
        data field. If you wanted to define a filter that searches for a SubjectUserName
        of either john.doe or jane.doe, pass the following

        @{'SubjectUserName'=('john.doe','jane.doe')}

        You may specify multiple data files and values. Doing so will create
        an XPath filter that will only return results where both values
        are found. If you only wanted to return events where both the
        SubjectUserName is john.doe and the TargetUserName is jane.doe, then
        pass the following

        @{'SubjectUserName'='john.doe';'TargetUserName'='jane.doe'}

        You may pass an array of hash tables to create an 'or' XPath filter
        that will return objects where either key value set will be returned.
        If you wanted to define a filter that searches for either a
        SubjectUserName of john.doe or a TargetUserName of jane.doe then pass
        the following

        (@{'SubjectUserName'='john.doe'},@{'TargetUserName'='jane.doe'})
        .EXAMPLE
        Get-EventsFilter -ID 4663 -NamedDataFilter @{'SubjectUserName'='john.doe'} -LogName 'ForwardedEvents'

        This will return an XPath filter that will return any events with
        the id of 4663 and has a SubjectUserName of 'john.doe'

        Output:
        <QueryList>
            <Query Id="0" Path="ForwardedEvents">
                <Select Path="ForwardedEvents">
                        (*[System[EventID=4663]]) and (*[EventData[Data[@Name='SubjectUserName'] = 'john.doe']])
                </Select>
            </Query>
        </QueryList>

        .EXAMPLE
        Get-EventsFilter -StartTime '1/1/2015 01:30:00 PM' -EndTime '1/1/2015 02:00:00 PM' -LogName 'ForwardedEvents

        This will return an XPath filter that will return events that occured between 1:30
        2:00 PM on 1/1/2015.  The filter will only be good if used immediately.  XPath time
        filters are based on the number of milliseconds that have occured since the event
        and when the filter is used.  StartTime and EndTime simply calculate the number of
        milliseconds and use that for the filter.

        Output:
        <QueryList>
            <Query Id="0" Path="ForwardedEvents">
                <Select Path="ForwardedEvents">
                        (*[System[TimeCreated[timediff(@SystemTime) &lt;= 125812885399]]]) and (*[System[TimeCreated[timediff(@SystemTime)
    &gt;= 125811085399]]])
                </Select>
            </Query>
        </QueryList>

        .EXAMPLE
        Get-EventsFilter -StartTime (Get-Date).AddDays(-1) -LogName System

        This will return an XPath filter that will get events that occured within the last 24 hours.

        Output:
        <QueryList>
            <Query Id="0" Path="System">
                    <Select Path="System">
                        *[System[TimeCreated[timediff(@SystemTime) &lt;= 86404194]]]
                </Select>
            </Query>
        </QueryList>

        .EXAMPLE
        Get-EventsFilter -ID 1105 -LogName 'ForwardedEvents' -RecordID '3512231','3512232'

        This will return an XPath filter that will get events with EventRecordID 3512231 or 3512232 in Log ForwardedEvents with EventID 1105

        Output:
        <QueryList>
            <Query Id="0" Path="ForwardedEvents">
                    <Select Path="ForwardedEvents">
                        (*[System[EventID=1105]]) and (*[System[(EventRecordID=3512231) or (EventRecordID=3512232)]])
                </Select>
            </Query>
        </QueryList>
        #>
        [CmdletBinding()]
        Param
        ([String[]]
            $ID,
            [alias('RecordID')][string[]]
            $EventRecordID,
            [DateTime]
            $StartTime,
            [DateTime]
            $EndTime,
            [String[]]
            $Data,
            [String[]]
            $ProviderName,
            [Long[]]
            $Keywords,
            [ValidateSet('Critical',
                'Error',
                'Informational',
                'LogAlways',
                'Verbose',
                'Warning')]
            [String[]]
            $Level,
            [String[]]
            $UserID,
            [Hashtable[]]
            $NamedDataFilter,
            [Hashtable[]]
            $NamedDataExcludeFilter,
            [String[]]
            $ExcludeID,
            [String]
            $LogName,
            [String]
            $Path,
            [switch] $XPathOnly)
        Function Join-XPathFilter {
            Param
            ([Parameter(Mandatory = $True,
                    Position = 0)]
                [String]
                $NewFilter,
                [Parameter(Position = 1)]
                [String]
                $ExistingFilter = '',
                [Parameter(Position = 2)]
                [ValidateSet("and",
                    "or",
                    IgnoreCase = $False)]
                [String]
                $Logic = 'and',
                [switch]$NoParenthesis)
            If ($ExistingFilter) { if ($NoParenthesis) { Return "$ExistingFilter $Logic $NewFilter" } Else { Return "($ExistingFilter) $Logic ($NewFilter)" } } Else { Return $NewFilter }
            <#
        .SYNOPSIS
        This function handles the parenthesis and logical joining
        of XPath statements inside of Get-EventsFilter
        #>
        }
        Function Initialize-XPathFilter {
            Param
            ([Object[]]
                $Items,
                [String]
                $ForEachFormatString,
                [String]
                $FinalizeFormatString,
                [ValidateSet("and", "or", IgnoreCase = $False)]
                [String]
                $Logic = 'or',
                [switch]$NoParenthesis)
            $filter = ''
            ForEach ($item in $Items) {
                $options = @{'NewFilter' = ($ForEachFormatString -f $item)
                    'ExistingFilter'     = $filter
                    'Logic'              = $logic
                    'NoParenthesis'      = $NoParenthesis
                }
                $filter = Join-XPathFilter @options
            }
            Return $FinalizeFormatString -f $filter
            <#
        .SYNOPSIS
        This function loops thru a set of items and injecting each
        item in the format string given by ForEachFormatString, then
        combines each of those items together with 'or' logic
        using the function Join-XPathFilter, which handles the
        joining and parenthesis.  Before returning the result,
        it injects the resultant xpath into FinalizeFormatString.

        This function is a part of Get-EventsFilter
        #>
        }
        [string] $filter = ''
        If ($ID) {
            $options = @{'Items'       = $ID
                'ForEachFormatString'  = "EventID={0}"
                'FinalizeFormatString' = "*[System[{0}]]"
            }
            $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
        }
        If ($EventRecordID) {
            $options = @{'Items'       = $EventRecordID
                'ForEachFormatString'  = "EventRecordID={0}"
                'FinalizeFormatString' = "*[System[{0}]]"
            }
            $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
        }
        If ($ExcludeID) {
            $options = @{'Items'       = $ExcludeID
                'ForEachFormatString'  = "EventID!={0}"
                'FinalizeFormatString' = "*[System[{0}]]"
            }
            $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
        }
        $Now = Get-Date
        If ($StartTime) {
            $Diff = [Math]::Round($Now.Subtract($StartTime).TotalMilliseconds)
            $filter = Join-XPathFilter -NewFilter "*[System[TimeCreated[timediff(@SystemTime) &lt;= $Diff]]]" -ExistingFilter $filter
        }
        If ($EndTime) {
            $Diff = [Math]::Round($Now.Subtract($EndTime).TotalMilliseconds)
            $filter = Join-XPathFilter -NewFilter "*[System[TimeCreated[timediff(@SystemTime) &gt;= $Diff]]]" -ExistingFilter $filter
        }
        If ($Data) {
            $options = @{'Items'       = $Data
                'ForEachFormatString'  = "Data='{0}'"
                'FinalizeFormatString' = "*[EventData[{0}]]"
            }
            $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
        }
        If ($ProviderName) {
            $options = @{'Items'       = $ProviderName
                'ForEachFormatString'  = "@Name='{0}'"
                'FinalizeFormatString' = "*[System[Provider[{0}]]]"
            }
            $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
        }
        If ($Level) {
            $levels = ForEach ($item in $Level) { [Int][System.Diagnostics.Tracing.EventLevel]::$item }
            $options = @{'Items'       = $levels
                'ForEachFormatString'  = "Level={0}"
                'FinalizeFormatString' = "*[System[{0}]]"
            }
            $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
        }
        If ($Keywords) {
            $keyword_filter = ''
            ForEach ($item in $Keywords) { If ($keyword_filter) { $keyword_filter = $keyword_filter -bor $item } Else { $keyword_filter = $item } }
            $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter "*[System[band(Keywords,$keyword_filter)]]"
        }
        If ($UserID) {
            $sids = ForEach ($item in $UserID) {
                Try {
                    $sid = [System.Security.Principal.SecurityIdentifier]($item)
                    $sid = $sid.Translate([System.Security.Principal.SecurityIdentifier])
                } Catch [System.Management.Automation.RuntimeException] {
                    If ($Error[0].CategoryInfo.Category -eq 'InvalidArgument') {
                        Try {
                            $user = [System.Security.Principal.NTAccount]($item)
                            $sid = $user.Translate([System.Security.Principal.SecurityIdentifier])
                        } Catch { Throw $Error[0] }
                    } Else { Throw $Error[0] }
                } Catch { Throw $Error[0] }
                $sid.Value
            }
            $options = @{'Items'       = $sids
                'ForEachFormatString'  = "@UserID='{0}'"
                'FinalizeFormatString' = "*[System[Security[{0}]]]"
            }
            $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
        }
        If ($NamedDataFilter) {
            $options = @{'Items'       = $(ForEach ($item in $NamedDataFilter) {
                        $options = @{'Items'       = $(ForEach ($key in $item.Keys) {
                                    If ($item[$key]) {
                                        $options = @{'Items'       = $item[$key]
                                            'NoParenthesis'        = $true
                                            'ForEachFormatString'  = "Data[@Name='$key'] = '{0}'"
                                            'FinalizeFormatString' = "{0}"
                                        }
                                        Initialize-XPathFilter @options
                                    } Else { "Data[@Name='$key']" }
                                })
                            'ForEachFormatString'  = "{0}"
                            'FinalizeFormatString' = "{0}"
                        }
                        Initialize-XPathFilter @options
                    })
                'ForEachFormatString'  = "{0}"
                'FinalizeFormatString' = "*[EventData[{0}]]"
            }
            $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
        }
        If ($NamedDataExcludeFilter) {
            $options = @{'Items'       = $(ForEach ($item in $NamedDataExcludeFilter) {
                        $options = @{'Items'       = $(ForEach ($key in $item.Keys) {
                                    If ($item[$key]) {
                                        $options = @{'Items'       = $item[$key]
                                            'NoParenthesis'        = $true
                                            'ForEachFormatString'  = "Data[@Name='$key'] != '{0}'"
                                            'FinalizeFormatString' = "{0}"
                                            'Logic'                = 'and'
                                        }
                                        Initialize-XPathFilter @options
                                    } Else { "Data[@Name='$key']" }
                                })
                            'ForEachFormatString'  = "{0}"
                            'FinalizeFormatString' = "{0}"
                        }
                        Initialize-XPathFilter @options
                    })
                'ForEachFormatString'  = "{0}"
                'FinalizeFormatString' = "*[EventData[{0}]]"
            }
            $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
        }
        if ($XPathOnly) { return $Filter } else {
            if ($Path -ne '') {
                $FilterXML = @"
                    <QueryList>
                        <Query Id="0" Path="file://$Path">
                            <Select>
                                    $filter
                            </Select>
                        </Query>
                    </QueryList>
"@
            } else {
                $FilterXML = @"
                    <QueryList>
                        <Query Id="0" Path="$LogName">
                            <Select Path="$LogName">
                                    $filter
                            </Select>
                        </Query>
                    </QueryList>
"@
            }
            return $FilterXML
        }
    }
    function Get-EventsInternal () {
        [CmdLetBinding()]
        param ([string]$Comp,
            [ValidateNotNull()]
            [alias('Credentials')][System.Management.Automation.PSCredential]
            [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty,
            [hashtable]$EventFilter,
            [int]$MaxEvents,
            [switch] $Oldest)
        $Measure = [System.Diagnostics.Stopwatch]::StartNew()
        Write-Verbose "Get-Events - Inside $Comp for Events ID: $($EventFilter.ID)"
        Write-Verbose "Get-Events - Inside $Comp for Events LogName: $($EventFilter.LogName)"
        Write-Verbose "Get-Events - Inside $Comp for Events RecordID: $($EventFilter.RecordID)"
        Write-Verbose "Get-Events - Inside $Comp for Events Oldest: $Oldest"
        try {
            [Array] $Events = @(if ($null -ne $EventFilter.RecordID -or $null -ne $EventFilter.NamedDataFilter -or $null -ne $EventFilter.ExcludeID -or $null -ne $EventFilter.NamedDataExcludeFilter -or $null -ne $EventFilter.UserID) {
                    $FilterXML = Get-EventsFilter @EventFilter
                    $SplatEvents = @{ErrorAction = 'Stop'
                        ComputerName             = $Comp
                        Oldest                   = $Oldest
                        FilterXml                = $FilterXML
                    }
                    Write-Verbose "Get-Events - Inside $Comp - Custom FilterXML: `n$FilterXML"
                } else {
                    $SplatEvents = @{ErrorAction = 'Stop'
                        ComputerName             = $Comp
                        Oldest                   = $Oldest
                        FilterHashtable          = $EventFilter
                    }
                    foreach ($k in $EventFilter.Keys) { Write-Verbose "Get-Events - Inside $Comp Data in FilterHashTable $k $($EventFilter[$k])" }
                }
                if ($MaxEvents -ne 0) {
                    $SplatEvents.MaxEvents = $MaxEvents
                    Write-Verbose "Get-Events - Inside $Comp for Events Max Events: $MaxEvents"
                }
                if ($Credential -ne [System.Management.Automation.PSCredential]::Empty) {
                    $SplatEvents.Credential = $Credential
                    Write-Verbose "Get-Events - Inside $Comp for Events Credential: $Credential"
                }
                Get-WinEvent @SplatEvents)
            Write-Verbose -Message "Get-Events - Inside $Comp Events found $($Events.Count)"
        } catch {
            if ($_.Exception -match "No events were found that match the specified selection criteria") { Write-Verbose -Message "Get-Events - Inside $Comp No events found." } elseif ($_.Exception -match "There are no more endpoints available from the endpoint") {
                Write-Verbose -Message "Get-Events - Inside $Comp Error $($_.Exception.Message)"
                Write-Error -Message "$Comp`: $_"
            } else {
                Write-Verbose -Message "Get-Events - Inside $Comp Error $($_.Exception.Message)"
                Write-Error -Message "$Comp`: $_"
            }
            Write-Verbose "Get-Events - Inside $Comp Time to generate $($Measure.Elapsed.Hours) hours, $($Measure.Elapsed.Minutes) minutes, $($Measure.Elapsed.Seconds) seconds, $($Measure.Elapsed.Milliseconds) milliseconds"
            $Measure.Stop()
            return
        }
        Write-Verbose "Get-Events - Inside $Comp Processing events..."
        ForEach ($Event in $Events) {
            $eventXML = [xml]$Event.ToXml()
            Add-Member -InputObject $Event -MemberType NoteProperty -Name "Computer" -Value $event.MachineName.ToString() -Force
            Add-Member -InputObject $Event -MemberType NoteProperty -Name "Date" -Value $Event.TimeCreated -Force
            $EventTopNodes = Get-Member -InputObject $eventXML.Event -MemberType Properties | Where-Object { $_.Name -ne 'System' -and $_.Name -ne 'xmlns' }
            foreach ($EventTopNode in $EventTopNodes) {
                $TopNode = $EventTopNode.Name
                $EventSubsSubs = Get-Member -InputObject $eventXML.Event.$TopNode -MemberType Properties
                $h = 0
                foreach ($EventSubSub in $EventSubsSubs) {
                    $SubNode = $EventSubSub.Name
                    if ($EventSubSub.Definition -like "System.Object*") {
                        if (Get-Member -InputObject $eventXML.Event.$TopNode -Name "$SubNode" -MemberType Properties) {
                            $SubSubNode = Get-Member -InputObject $eventXML.Event.$TopNode.$SubNode -MemberType Properties | Where-Object { $_.Name -ne 'xmlns' -and $_.Definition -like "string*" }
                            foreach ($Name in $SubSubNode.Name) {
                                $fieldName = $Name
                                $fieldValue = $eventXML.Event.$TopNode.$SubNode.$Name
                                Add-Member -InputObject $Event -MemberType NoteProperty -Name $fieldName -Value $fieldValue -Force
                            }
                            For ($i = 0; $i -lt $eventXML.Event.$TopNode.$SubNode.Count; $i++) {
                                if (Get-Member -InputObject $eventXML.Event.$TopNode.$SubNode[$i] -Name "Name" -MemberType Properties) {
                                    $fieldName = $eventXML.Event.$TopNode.$SubNode[$i].Name
                                    if (Get-Member -InputObject $eventXML.Event.$TopNode.$SubNode[$i] -Name "#text" -MemberType Properties) {
                                        $fieldValue = $eventXML.Event.$TopNode.$SubNode[$i]."#text"
                                        if ($fieldValue -eq "-".Trim()) { $fieldValue = $fieldValue -replace "-" }
                                    } else { $fieldValue = "" }
                                    if ($fieldName -ne "") { Add-Member -InputObject $Event -MemberType NoteProperty -Name $fieldName -Value $fieldValue -Force }
                                } else {
                                    $Value = $eventXML.Event.$TopNode.$SubNode[$i]
                                    if ($Value.Name -ne 'Name' -and $Value.Name -ne '#text') {
                                        $fieldName = "NoNameA$i"
                                        $fieldValue = $Value
                                        Add-Member -InputObject $Event -MemberType NoteProperty -Name $fieldName -Value $fieldValue -Force
                                    }
                                }
                            }
                        }
                    } elseif ($EventSubSub.Definition -like "System.Xml.XmlElement*") {
                        $SubSubNode = Get-Member -InputObject $eventXML.Event.$TopNode.$SubNode -MemberType Properties | Where-Object { $_.Name -ne 'xmlns' -and $_.Definition -like "string*" }
                        foreach ($Name in $SubSubNode.Name) {
                            $fieldName = $Name
                            $fieldValue = $eventXML.Event.$TopNode.$SubNode.$Name
                            Add-Member -InputObject $Event -MemberType NoteProperty -Name $fieldName -Value $fieldValue -Force
                        }
                    } else {
                        $fieldValue = $eventXML.Event.$TopNode.$SubNode
                        if ($fieldValue -match "\n") {
                            $SplittedValues = $fieldValue -split '\n'
                            foreach ($Split in $SplittedValues) {
                                $h++
                                $fieldName = "NoNameB$h"
                                Add-Member -InputObject $Event -MemberType NoteProperty -Name $fieldName -Value $Split -Force
                            }
                        } else {
                            $h++
                            $fieldName = "NoNameB$h"
                            Add-Member -InputObject $Event -MemberType NoteProperty -Name $fieldName -Value $fieldValue -Force
                        }
                    }
                }
            }
            [string] $MessageSubject = ($Event.Message -split '\n')[0] -replace "`n", '' -replace "`r", '' -replace "`t", ''
            Add-Member -InputObject $Event -MemberType NoteProperty -Name 'MessageSubject' -Value $MessageSubject -Force
            Add-Member -InputObject $Event -MemberType NoteProperty -Name 'Action' -Value $MessageSubject -Force
            Add-Member -InputObject $Event -MemberType NoteProperty -Name 'KeywordDisplayName' -Value ($Event.KeywordsDisplayNames -join ',') -Force
            if ($Event.SubjectDomainName -and $Event.SubjectUserName) { Add-Member -InputObject $Event -MemberType NoteProperty -Name 'Who' -Value "$($Event.SubjectDomainName)\$($Event.SubjectUserName)" -Force }
            if ($Event.TargetDomainName -and $Event.TargetUserName) { Add-Member -InputObject $Event -MemberType NoteProperty -Name 'ObjectAffected' -Value "$($Event.TargetDomainName)\$($Event.TargetUserName)" -Force }
            if ($Event.MemberName) {
                [string] $MemberNameWithoutCN = $Event.MemberName -replace 'CN=|\\|,(OU|DC|CN).*$'
                Add-Member -InputObject $Event -MemberType NoteProperty -Name 'MemberNameWithoutCN' -Value $MemberNameWithoutCN -Force
            }
            if ($EventFilter.Path) { Add-Member -InputObject $Event -MemberType NoteProperty -Name "GatheredFrom" -Value $EventFilter.Path -Force } else { Add-Member -InputObject $Event -MemberType NoteProperty -Name "GatheredFrom" -Value $Comp -Force }
            Add-Member -InputObject $Event -MemberType NoteProperty -Name "GatheredLogName" -Value $EventFilter.LogName -Force
        }
        Write-Verbose "Get-Events - Inside $Comp Time to generate $($Measure.Elapsed.Hours) hours, $($Measure.Elapsed.Minutes) minutes, $($Measure.Elapsed.Seconds) seconds, $($Measure.Elapsed.Milliseconds) milliseconds"
        $Measure.Stop()
        return $Events
    }
    Write-Verbose "Get-Events -------------START---------------------"
    [Array] $Data = Get-EventsInternal -Comp $Comp -EventFilter $EventFilter -MaxEvents $MaxEvents -Oldest:$Oldest -Verbose:$Verbose -Credential $Credential
    Write-Verbose "Get-Events --------------END----------------------"
    return $Data }
$Script:ScriptBlockEventsInformation = { Param ([string]$Computer,
        [string]$Path,
        [string]$LogName,
        [bool] $Verbose)
    if ($Verbose) { $VerbosePreference = 'continue' }
    function Convert-Size {
        [cmdletbinding()]
        param([validateset("Bytes", "KB", "MB", "GB", "TB")]
            [string]$From,
            [validateset("Bytes", "KB", "MB", "GB", "TB")]
            [string]$To,
            [Parameter(Mandatory = $true)]
            [double]$Value,
            [int]$Precision = 4,
            [switch]$Display)
        switch ($From) {
            "Bytes" { $value = $Value }
            "KB" { $value = $Value * 1024 }
            "MB" { $value = $Value * 1024 * 1024 }
            "GB" { $value = $Value * 1024 * 1024 * 1024 }
            "TB" { $value = $Value * 1024 * 1024 * 1024 * 1024 }
        }
        switch ($To) {
            "Bytes" { return $value }
            "KB" { $Value = $Value / 1KB }
            "MB" { $Value = $Value / 1MB }
            "GB" { $Value = $Value / 1GB }
            "TB" { $Value = $Value / 1TB }
        }
        if ($Display) { return "$([Math]::Round($value,$Precision,[MidPointRounding]::AwayFromZero)) $To" } else { return [Math]::Round($value, $Precision, [MidPointRounding]::AwayFromZero) }
    }
    try {
        if ($Computer -eq '') {
            $FileInformation = Get-ChildItem -File $Path
            $EventsOldest = Get-WinEvent -MaxEvents 1 -Oldest -Path $Path -Verbose:$false
            $EventsNewest = Get-WinEvent -MaxEvents 1 -Path $Path -Verbose:$false
            $RecordCount = $EventsNewest.RecordID - $EventsOldest.RecordID
            $EventsInfo = [PSCustomObject]@{EventNewest = $EventsNewest.TimeCreated
                EventOldest                             = $EventsOldest.TimeCreated
                FileSize                                = $FileInformation.Length
                FileSizeMaximum                         = $null
                FileSizeCurrentMB                       = Convert-Size -Value $FileInformation.Length -From Bytes -To MB -Precision 2
                FileSizeMaximumMB                       = Convert-Size -Value $FileInformation.Length -From Bytes -To MB -Precision 2
                IsClassicLog                            = $false
                IsEnabled                               = $false
                IsLogFull                               = $false
                LastAccessTime                          = $FileInformation.LastAccessTime
                LastWriteTime                           = $FileInformation.LastWriteTime
                LogFilePath                             = $Path
                LogIsolation                            = $false
                LogMode                                 = 'N/A'
                LogName                                 = 'N/A'
                LogType                                 = 'N/A'
                MaximumSizeInBytes                      = $FileInformation.Length
                MachineName                             = (@($EventsOldest.MachineName) + @($EventsNewest.MachineName) | Sort-Object -Unique) -join ', '
                OldestRecordNumber                      = $EventsOldest.RecordID
                OwningProviderName                      = ''
                ProviderBufferSize                      = 0
                ProviderControlGuid                     = ''
                ProviderKeywords                        = ''
                ProviderLatency                         = 1000
                ProviderLevel                           = ''
                ProviderMaximumNumberOfBuffers          = 16
                ProviderMinimumNumberOfBuffers          = 0
                ProviderNames                           = ''
                ProviderNamesExpanded                   = ''
                RecordCount                             = $RecordCount
                SecurityDescriptor                      = $null
                SecurityDescriptorOwner                 = $null
                SecurityDescriptorGroup                 = $null
                SecurityDescriptorDiscretionaryAcl      = $null
                SecurityDescriptorSystemAcl             = $null
                Source                                  = 'File'
            }
        } else {
            $EventsInfo = Get-WinEvent -ListLog $LogName -ComputerName $Computer
            $FileSizeCurrentMB = Convert-Size -Value $EventsInfo.FileSize -From Bytes -To MB -Precision 2
            $FileSizeMaximumMB = Convert-Size -Value $EventsInfo.MaximumSizeInBytes -From Bytes -To MB -Precision 2
            $EventOldest = (Get-WinEvent -MaxEvents 1 -LogName $LogName -Oldest -ComputerName $Computer).TimeCreated
            $EventNewest = (Get-WinEvent -MaxEvents 1 -LogName $LogName -ComputerName $Computer).TimeCreated
            $ProviderNamesExpanded = $EventsInfo.ProviderNames -join ', '
            $SecurityDescriptorTranslated = ConvertFrom-SddlString -Sddl $EventsInfo.SecurityDescriptor
            Add-Member -InputObject $EventsInfo -MemberType NoteProperty -Name "FileSizeCurrentMB" -Value $FileSizeCurrentMB -Force
            Add-Member -InputObject $EventsInfo -MemberType NoteProperty -Name "FileSizeMaximumMB" -Value $FileSizeMaximumMB -Force
            Add-Member -InputObject $EventsInfo -MemberType NoteProperty -Name "EventOldest" -Value $EventOldest -Force
            Add-Member -InputObject $EventsInfo -MemberType NoteProperty -Name "EventNewest" -Value $EventNewest -Force
            Add-Member -InputObject $EventsInfo -MemberType NoteProperty -Name "ProviderNamesExpanded" -Value $ProviderNamesExpanded -Force
            Add-Member -InputObject $EventsInfo -MemberType NoteProperty -Name "MachineName" -Value $Computer -Force
            Add-Member -InputObject $EventsInfo -MemberType NoteProperty -Name "Source" -Value $Computer -Force
            Add-Member -InputObject $EventsInfo -MemberType NoteProperty -Name 'SecurityDescriptorOwner' -Value $SecurityDescriptorTranslated.Owner -Force
            Add-Member -InputObject $EventsInfo -MemberType NoteProperty -Name 'SecurityDescriptorGroup' -Value $SecurityDescriptorTranslated.Group -Force
            Add-Member -InputObject $EventsInfo -MemberType NoteProperty -Name 'SecurityDescriptorDiscretionaryAcl' -Value $SecurityDescriptorTranslated.DiscretionaryAcl -Force
            Add-Member -InputObject $EventsInfo -MemberType NoteProperty -Name 'SecurityDescriptorSystemAcl' -Value $SecurityDescriptorTranslated.SystemACL -Force
        }
    } catch {
        $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
        switch ($ErrorMessage) {
            { $_ -match 'No events were found' } { Write-Verbose -Message "$Computer Reading Event Log ($LogName) size failed. No events found." }
            { $_ -match 'Attempted to perform an unauthorized operation' } {
                Write-Verbose -Message "$Computer Reading Event Log ($LogName) size failed. Unauthorized operation."
                Write-Error -Message "$Computer`: $_"
            }
            default {
                Write-Verbose -Message "$Computer Reading Event Log ($LogName) size failed. Error occured: $ErrorMessage"
                Write-Error -Message "$Computer`: $_"
            }
        }
    }
    $Properties = $EventsInfo.PSObject.Properties.Name | Sort-Object
    $EventsInfo | Select-Object $Properties }
function Get-Events {
    <#
    .SYNOPSIS
    Get-Events is a wrapper function around Get-WinEvent providing additional features and options.

    .DESCRIPTION
    Long description

    .PARAMETER Machine
    ComputerName or Server you want to query. Takes an array of servers as well.

    .PARAMETER DateFrom
    Parameter description

    .PARAMETER DateTo
    Parameter description

    .PARAMETER ID
    Parameter description

    .PARAMETER ExcludeID
    Parameter description

    .PARAMETER LogName
    Parameter description

    .PARAMETER ProviderName
    Parameter description

    .PARAMETER NamedDataFilter
    Parameter description

    .PARAMETER NamedDataExcludeFilter
    Parameter description

    .PARAMETER UserID
    Parameter description

    .PARAMETER Level
    Parameter description

    .PARAMETER UserSID
    Parameter description

    .PARAMETER Data
    Parameter description

    .PARAMETER MaxEvents
    Parameter description

    .PARAMETER Credentials
    Parameter description

    .PARAMETER Path
    Parameter description

    .PARAMETER Keywords
    Parameter description

    .PARAMETER RecordID
    Parameter description

    .PARAMETER MaxRunspaces
    Parameter description

    .PARAMETER Oldest
    Parameter description

    .PARAMETER DisableParallel
    Parameter description

    .PARAMETER ExtendedOutput
    Parameter description

    .PARAMETER ExtendedInput
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    [CmdLetBinding()]
    param ([alias ("ADDomainControllers", "DomainController", "Server", "Servers", "Computer", "Computers", "ComputerName")] [string[]] $Machine = $Env:COMPUTERNAME,
        [alias ("StartTime", "From")][nullable[DateTime]] $DateFrom = $null,
        [alias ("EndTime", "To")][nullable[DateTime]] $DateTo = $null,
        [alias ("Ids", "EventID", "EventIds")] [int[]] $ID = $null,
        [alias ("ExludeEventID")][int[]] $ExcludeID = $null,
        [alias ("LogType", "Log")][string] $LogName = $null,
        [alias ("Provider", "Source")] [string] $ProviderName,
        [hashtable] $NamedDataFilter,
        [hashtable] $NamedDataExcludeFilter,
        [string[]] $UserID,
        [PSEventViewer.Level[]] $Level = $null,
        [string] $UserSID = $null,
        [string[]]$Data = $null,
        [int] $MaxEvents = $null,
        [ValidateNotNull()]
        [alias('Credentials')][System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty,
        [string] $Path = $null,
        [PSEventViewer.Keywords[]] $Keywords = $null,
        [alias("EventRecordID")][int64] $RecordID,
        [int] $MaxRunspaces = [int]$env:NUMBER_OF_PROCESSORS + 1,
        [switch] $Oldest,
        [switch] $DisableParallel,
        [switch] $ExtendedOutput,
        [Array] $ExtendedInput)
    if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) { $Verbose = $true } else { $Verbose = $false }
    $MeasureTotal = [System.Diagnostics.Stopwatch]::StartNew()
    $ParametersList = [System.Collections.Generic.List[Object]]::new()
    if ($ExtendedInput.Count -gt 0) {
        [Array] $Param = foreach ($EventEntry in $ExtendedInput) {
            $EventFilter = @{}
            if ($EventEntry.Type -eq 'File') {
                Write-Verbose "Get-Events - Preparing data to scan file $($EventEntry.Server)"
                Add-ToHashTable -Hashtable $EventFilter -Key "Path" -Value $EventEntry.Server
                $Comp = $Env:COMPUTERNAME
            } else {
                Write-Verbose "Get-Events - Preparing data to scan computer $($EventEntry.Server)"
                $Comp = $EventEntry.Server
            }
            $ConvertedLevels = foreach ($Data in $EventEntry.Level) { ([PSEventViewer.Level]::$Data).value__ }
            $ConvertedKeywords = foreach ($Data in $EventEntry.Keywords) { ([PSEventViewer.Keywords]::$Data).value__ }
            Add-ToHashTable -Hashtable $EventFilter -Key "LogName" -Value $EventEntry.LogName
            Add-ToHashTable -Hashtable $EventFilter -Key "StartTime" -Value $EventEntry.DateFrom
            Add-ToHashTable -Hashtable $EventFilter -Key "EndTime" -Value $EventEntry.DateTo
            Add-ToHashTable -Hashtable $EventFilter -Key "Keywords" -Value $ConvertedKeywords
            Add-ToHashTable -Hashtable $EventFilter -Key "Level" -Value $ConvertedLevels
            Add-ToHashTable -Hashtable $EventFilter -Key "UserID" -Value $EventEntry.UserSID
            Add-ToHashTable -Hashtable $EventFilter -Key "Data" -Value $EventEntry.Data
            Add-ToHashTable -Hashtable $EventFilter -Key "RecordID" -Value $EventEntry.RecordID
            Add-ToHashTable -Hashtable $EventFilter -Key "NamedDataFilter" -Value $EventEntry.NamedDataFilter
            Add-ToHashTable -Hashtable $EventFilter -Key "NamedDataExcludeFilter" -Value $EventEntry.NamedDataExcludeFilter
            Add-ToHashTable -Hashtable $EventFilter -Key "UserID" -Value $EventEntry.UserID
            Add-ToHashTable -Hashtable $EventFilter -Key "ExcludeID" -Value $EventEntry.ExcludeID
            if ($Verbose) { foreach ($Key in $EventFilter.Keys) { if ($Key -eq 'NamedDataFilter' -or $Key -eq 'NamedDataExcludeFilter') { foreach ($SubKey in $($EventFilter.$Key).Keys) { Write-Verbose "Get-Events - Filter parameters provided $Key with SubKey $SubKey = $(($EventFilter.$Key.$SubKey) -join ', ')" } } else { Write-Verbose "Get-Events - Filter parameters provided $Key = $(($EventFilter.$Key) -join ', ')" } } }
            if ($null -ne $EventEntry.EventID) {
                $ID = $EventEntry.EventID | Sort-Object -Unique
                Write-Verbose "Get-Events - Events to process in Total (unique): $($Id.Count)"
                Write-Verbose "Get-Events - Events to process in Total ID: $($ID -join ', ')"
                if ($Id.Count -gt 22) { Write-Verbose "Get-Events - There are more events to process then 22, split will be required." }
                $SplitArrayID = Split-Array -inArray $ID -size 22
                foreach ($EventIdGroup in $SplitArrayID) {
                    $EventFilter.Id = @($EventIdGroup)
                    @{Comp          = $Comp
                        Credential  = $Credential
                        EventFilter = $EventFilter.Clone()
                        MaxEvents   = $EventEntry.MaxEvents
                        Oldest      = $Oldest
                        Verbose     = $Verbose
                    }
                }
            } else {
                @{Comp          = $Comp
                    Credential  = $Credential
                    EventFilter = $EventFilter
                    MaxEvents   = $EventEntry.MaxEvents
                    Oldest      = $Oldest
                    Verbose     = $Verbose
                }
            }
        }
        if ($null -ne $Param) { $null = $ParametersList.AddRange($Param) }
    } else {
        $EventFilter = @{}
        Add-ToHashTable -Hashtable $EventFilter -Key "LogName" -Value $LogName
        Add-ToHashTable -Hashtable $EventFilter -Key "ProviderName" -Value $ProviderName
        Add-ToHashTable -Hashtable $EventFilter -Key "Path" -Value $Path
        Add-ToHashTable -Hashtable $EventFilter -Key "Keywords" -Value $Keywords.value__
        Add-ToHashTable -Hashtable $EventFilter -Key "Level" -Value $Level.value__
        Add-ToHashTable -Hashtable $EventFilter -Key "StartTime" -Value $DateFrom
        Add-ToHashTable -Hashtable $EventFilter -Key "EndTime" -Value $DateTo
        Add-ToHashTable -Hashtable $EventFilter -Key "UserID" -Value $UserSID
        Add-ToHashTable -Hashtable $EventFilter -Key "Data" -Value $Data
        Add-ToHashTable -Hashtable $EventFilter -Key "RecordID" -Value $RecordID
        Add-ToHashTable -Hashtable $EventFilter -Key "NamedDataFilter" -Value $NamedDataFilter
        Add-ToHashTable -Hashtable $EventFilter -Key "NamedDataExcludeFilter" -Value $NamedDataExcludeFilter
        Add-ToHashTable -Hashtable $EventFilter -Key "UserID" -Value $UserID
        Add-ToHashTable -Hashtable $EventFilter -Key "ExcludeID" -Value $ExcludeID
        [Array] $Param = foreach ($Comp in $Machine) {
            if ($Verbose) {
                Write-Verbose "Get-Events - Preparing data to scan computer $Comp"
                foreach ($Key in $EventFilter.Keys) { if ($Key -eq 'NamedDataFilter' -or $Key -eq 'NamedDataExcludeFilter') { foreach ($SubKey in $($EventFilter.$Key).Keys) { Write-Verbose "Get-Events - Filter parameters provided $Key with SubKey $SubKey = $(($EventFilter.$Key.$SubKey) -join ', ')" } } else { Write-Verbose "Get-Events - Filter parameters provided $Key = $(($EventFilter.$Key) -join ', ')" } }
            }
            if ($null -ne $ID) {
                $ID = $ID | Sort-Object -Unique
                Write-Verbose "Get-Events - Events to process in Total (unique): $($Id.Count)"
                Write-Verbose "Get-Events - Events to process in Total ID: $($ID -join ', ')"
                if ($Id.Count -gt 22) { Write-Verbose "Get-Events - There are more events to process then 22, split will be required." }
                $SplitArrayID = Split-Array -inArray $ID -size 22
                foreach ($EventIdGroup in $SplitArrayID) {
                    $EventFilter.Id = @($EventIdGroup)
                    @{Comp          = $Comp
                        Credential  = $Credential
                        EventFilter = $EventFilter.Clone()
                        MaxEvents   = $MaxEvents
                        Oldest      = $Oldest
                        Verbose     = $Verbose
                    }
                }
            } else {
                @{Comp          = $Comp
                    Credential  = $Credential
                    EventFilter = $EventFilter
                    MaxEvents   = $MaxEvents
                    Oldest      = $Oldest
                    Verbose     = $Verbose
                }
            }
        }
        if ($null -ne $Param) { $null = $ParametersList.AddRange($Param) }
    }
    $AllErrors = @()
    if ($DisableParallel) {
        Write-Verbose 'Get-Events - Running query with parallel disabled...'
        [Array] $AllEvents = foreach ($Parameter in $ParametersList) { Invoke-Command -ScriptBlock $Script:ScriptBlock -ArgumentList $Parameter.Comp, $Parameter.Credential, $Parameter.EventFilter, $Parameter.MaxEvents, $Parameter.Oldest, $Parameter.Verbose }
    } else {
        Write-Verbose 'Get-Events - Running query with parallel enabled...'
        $RunspacePool = New-Runspace -maxRunspaces $maxRunspaces -Verbose:$Verbose
        $Runspaces = foreach ($Parameter in $ParametersList) { Start-Runspace -ScriptBlock $Script:ScriptBlock -Parameters $Parameter -RunspacePool $RunspacePool -Verbose:$Verbose }
        [Array] $AllEvents = Stop-Runspace -Runspaces $Runspaces -FunctionName "Get-Events" -RunspacePool $RunspacePool -Verbose:$Verbose -ErrorAction SilentlyContinue -ErrorVariable +AllErrors -ExtendedOutput:$ExtendedOutput
    }
    Write-Verbose "Get-Events - Overall errors: $($AllErrors.Count)"
    Write-Verbose "Get-Events - Overall events processed in total for the report: $($AllEvents.Count)"
    Write-Verbose "Get-Events - Overall time to generate $($MeasureTotal.Elapsed.Hours) hours, $($MeasureTotal.Elapsed.Minutes) minutes, $($MeasureTotal.Elapsed.Seconds) seconds, $($MeasureTotal.Elapsed.Milliseconds) milliseconds"
    $MeasureTotal.Stop()
    Write-Verbose "Get-Events - Overall events processing end"
    if ($AllEvents.Count -eq 1) { return , $AllEvents } else { return $AllEvents }
}
function Get-EventsFilter {
    <#
    .SYNOPSIS
    This function generates an xpath filter that can be used with the -FilterXPath
    parameter of Get-WinEvent.  It may also be used inside the <Select></Select tags
    of a Custom View in Event Viewer.
    .DESCRIPTION
    This function generates an xpath filter that can be used with the -FilterXPath
    parameter of Get-WinEvent.  It may also be used inside the <Select></Select tags
    of a Custom View in Event Viewer.

    This function allows for the create of xpath which can select events based on
    many properties of the event including those of named data nodes in the event's
    XML.

    XPath is case sensetive and the data passed to the parameters here must
    match the case of the data in the event's XML.
    .NOTES
    Original Code by https://community.spiceworks.com/scripts/show/3238-powershell-xpath-generator-for-windows-events
    Extended by Justin Grote
    Extended by Przemyslaw Klys
    .LINK

    .PARAMETER ID
    This parameter accepts and array of event ids to include in the xpath filter.
    .PARAMETER StartTime
    This parameter sets the oldest event that may be returned by the xpath.

    Please, note that the xpath time selector created here is based of of the
    time the xpath is generated.  XPath uses a time difference method to select
    events by time; that time difference being the number of milliseconds between
    the time and now.
    .PARAMETER EndTime
    This parameter sets the newest event that may be returned by the xpath.

    Please, note that the xpath time selector created here is based of of the
    time the xpath is generated.  XPath uses a time difference method to select
    events by time; that time difference being the number of milliseconds between
    the time and now.
    .PARAMETER Data
    This parameter will accept an array of values that may be found in the data
    section of the event's XML.
    .PARAMETER ProviderName
    This parameter will accept an array of values that select events from event
    providers.
    .PARAMETER Level
    This parameter will accept an array of values that specify the severity
    rating of the events to be returned.

    It accepts the following values.

    'Critical',
    'Error',
    'Informational',
    'LogAlways',
    'Verbose',
    'Warning'
    .PARAMETER Keywords
    This parameter accepts and array of long integer keywords. You must
    pass this parameter the long integer value of the keywords you want
    to search and not the keyword description.
    .PARAMETER UserID
    This parameter will accept an array of SIDs or domain accounts.
    .PARAMETER NamedDataFilter
    This parameter will accept and array of hashtables that define the key
    value pairs for which you want to filter against the event's named data
    fields.

    Key values, as with XPath filters, are case sensetive.

    You may assign an array as the value of any key. This will search
    for events where any of the values are present in that particular
    data field. If you wanted to define a filter that searches for a SubjectUserName
    of either john.doe or jane.doe, pass the following

    @{'SubjectUserName'=('john.doe','jane.doe')}

    You may specify multiple data files and values. Doing so will create
    an XPath filter that will only return results where both values
    are found. If you only wanted to return events where both the
    SubjectUserName is john.doe and the TargetUserName is jane.doe, then
    pass the following

    @{'SubjectUserName'='john.doe';'TargetUserName'='jane.doe'}

    You may pass an array of hash tables to create an 'or' XPath filter
    that will return objects where either key value set will be returned.
    If you wanted to define a filter that searches for either a
    SubjectUserName of john.doe or a TargetUserName of jane.doe then pass
    the following

    (@{'SubjectUserName'='john.doe'},@{'TargetUserName'='jane.doe'})
    .EXAMPLE
    Get-EventsFilter -ID 4663 -NamedDataFilter @{'SubjectUserName'='john.doe'} -LogName 'ForwardedEvents'

    This will return an XPath filter that will return any events with
    the id of 4663 and has a SubjectUserName of 'john.doe'

    Output:
    <QueryList>
        <Query Id="0" Path="ForwardedEvents">
            <Select Path="ForwardedEvents">
                    (*[System[EventID=4663]]) and (*[EventData[Data[@Name='SubjectUserName'] = 'john.doe']])
            </Select>
        </Query>
    </QueryList>

    .EXAMPLE
    Get-EventsFilter -StartTime '1/1/2015 01:30:00 PM' -EndTime '1/1/2015 02:00:00 PM' -LogName 'ForwardedEvents

    This will return an XPath filter that will return events that occured between 1:30
    2:00 PM on 1/1/2015.  The filter will only be good if used immediately.  XPath time
    filters are based on the number of milliseconds that have occured since the event
    and when the filter is used.  StartTime and EndTime simply calculate the number of
    milliseconds and use that for the filter.

    Output:
    <QueryList>
        <Query Id="0" Path="ForwardedEvents">
            <Select Path="ForwardedEvents">
                    (*[System[TimeCreated[timediff(@SystemTime) &lt;= 125812885399]]]) and (*[System[TimeCreated[timediff(@SystemTime)
&gt;= 125811085399]]])
            </Select>
        </Query>
    </QueryList>

    .EXAMPLE
    Get-EventsFilter -StartTime (Get-Date).AddDays(-1) -LogName System

    This will return an XPath filter that will get events that occured within the last 24 hours.

    Output:
    <QueryList>
        <Query Id="0" Path="System">
                <Select Path="System">
                    *[System[TimeCreated[timediff(@SystemTime) &lt;= 86404194]]]
            </Select>
        </Query>
    </QueryList>

    .EXAMPLE
    Get-EventsFilter -ID 1105 -LogName 'ForwardedEvents' -RecordID '3512231','3512232'

    This will return an XPath filter that will get events with EventRecordID 3512231 or 3512232 in Log ForwardedEvents with EventID 1105

    Output:
    <QueryList>
        <Query Id="0" Path="ForwardedEvents">
                <Select Path="ForwardedEvents">
                    (*[System[EventID=1105]]) and (*[System[(EventRecordID=3512231) or (EventRecordID=3512232)]])
            </Select>
        </Query>
    </QueryList>

    .EXAMPLE
    Get-EventsFilter -LogName 'System' -id 7040 -NamedDataFilter @{ param4 = ('TrustedInstaller','BITS') }

    Will return a XPath filter that will check the systemlog for events generated by these events

    <QueryList>
        <Query Id="0" Path="System">
            <Select Path="System">
                    (*[System[EventID=7040]]) and (*[EventData[Data[@Name='param4'] = 'TrustedInstaller' or Data[@Name='param4'] = 'BITS']])
            </Select>
        </Query>
    </QueryList>


    .EXAMPLE
    Get-EventsFilter -LogName 'System' -id 7040 -NamedDataExcludeFilter  @{ param4 = ('TrustedInstaller','BITS') }

    Will return a XPath filter that will check the systemlog for all events with ID 7040 (change starttype) except those two

    <QueryList>
        <Query Id="0" Path="System">
            <Select Path="System">
                    (*[System[EventID=7040]]) and (*[EventData[Data[@Name='param4'] != 'TrustedInstaller' and Data[@Name='param4'] != 'BITS']])
            </Select>
        </Query>
    </QueryList>
    #>
    [CmdletBinding()]
    Param
    ([String[]]
        $ID,
        [alias('RecordID')][string[]]
        $EventRecordID,
        [DateTime]
        $StartTime,
        [DateTime]
        $EndTime,
        [String[]]
        $Data,
        [String[]]
        $ProviderName,
        [Long[]]
        $Keywords,
        [ValidateSet('Critical',
            'Error',
            'Informational',
            'LogAlways',
            'Verbose',
            'Warning')]
        [String[]]
        $Level,
        [String[]]
        $UserID,
        [Hashtable[]]
        $NamedDataFilter,
        [Hashtable[]]
        $NamedDataExcludeFilter,
        [String[]]
        $ExcludeID,
        [String]
        $LogName,
        [String]
        $Path,
        [switch] $XPathOnly)
    Function Join-XPathFilter {
        Param
        ([Parameter(Mandatory = $True,
                Position = 0)]
            [String]
            $NewFilter,
            [Parameter(Position = 1)]
            [String]
            $ExistingFilter = '',
            [Parameter(Position = 2)]
            [ValidateSet("and",
                "or",
                IgnoreCase = $False)]
            [String]
            $Logic = 'and',
            [switch]$NoParenthesis)
        If ($ExistingFilter) { if ($NoParenthesis) { Return "$ExistingFilter $Logic $NewFilter" } Else { Return "($ExistingFilter) $Logic ($NewFilter)" } } Else { Return $NewFilter }
        <#
    .SYNOPSIS
    This function handles the parenthesis and logical joining
    of XPath statements inside of Get-EventsFilter
    #>
    }
    Function Initialize-XPathFilter {
        Param
        ([Object[]]
            $Items,
            [String]
            $ForEachFormatString,
            [String]
            $FinalizeFormatString,
            [ValidateSet("and", "or", IgnoreCase = $False)]
            [String]
            $Logic = 'or',
            [switch]$NoParenthesis)
        $filter = ''
        ForEach ($item in $Items) {
            $options = @{'NewFilter' = ($ForEachFormatString -f $item)
                'ExistingFilter'     = $filter
                'Logic'              = $logic
                'NoParenthesis'      = $NoParenthesis
            }
            $filter = Join-XPathFilter @options
        }
        Return $FinalizeFormatString -f $filter
        <#
    .SYNOPSIS
    This function loops thru a set of items and injecting each
    item in the format string given by ForEachFormatString, then
    combines each of those items together with 'or' logic
    using the function Join-XPathFilter, which handles the
    joining and parenthesis.  Before returning the result,
    it injects the resultant xpath into FinalizeFormatString.

    This function is a part of Get-EventsFilter
    #>
    }
    [string] $filter = ''
    If ($ID) {
        $options = @{'Items'       = $ID
            'ForEachFormatString'  = "EventID={0}"
            'FinalizeFormatString' = "*[System[{0}]]"
        }
        $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
    }
    If ($EventRecordID) {
        $options = @{'Items'       = $EventRecordID
            'ForEachFormatString'  = "EventRecordID={0}"
            'FinalizeFormatString' = "*[System[{0}]]"
        }
        $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
    }
    If ($ExcludeID) {
        $options = @{'Items'       = $ExcludeID
            'ForEachFormatString'  = "EventID!={0}"
            'FinalizeFormatString' = "*[System[{0}]]"
        }
        $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
    }
    $Now = Get-Date
    If ($StartTime) {
        $Diff = [Math]::Round($Now.Subtract($StartTime).TotalMilliseconds)
        $filter = Join-XPathFilter -NewFilter "*[System[TimeCreated[timediff(@SystemTime) &lt;= $Diff]]]" -ExistingFilter $filter
    }
    If ($EndTime) {
        $Diff = [Math]::Round($Now.Subtract($EndTime).TotalMilliseconds)
        $filter = Join-XPathFilter -NewFilter "*[System[TimeCreated[timediff(@SystemTime) &gt;= $Diff]]]" -ExistingFilter $filter
    }
    If ($Data) {
        $options = @{'Items'       = $Data
            'ForEachFormatString'  = "Data='{0}'"
            'FinalizeFormatString' = "*[EventData[{0}]]"
        }
        $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
    }
    If ($ProviderName) {
        $options = @{'Items'       = $ProviderName
            'ForEachFormatString'  = "@Name='{0}'"
            'FinalizeFormatString' = "*[System[Provider[{0}]]]"
        }
        $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
    }
    If ($Level) {
        $levels = ForEach ($item in $Level) { [Int][System.Diagnostics.Tracing.EventLevel]::$item }
        $options = @{'Items'       = $levels
            'ForEachFormatString'  = "Level={0}"
            'FinalizeFormatString' = "*[System[{0}]]"
        }
        $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
    }
    If ($Keywords) {
        $keyword_filter = ''
        ForEach ($item in $Keywords) { If ($keyword_filter) { $keyword_filter = $keyword_filter -bor $item } Else { $keyword_filter = $item } }
        $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter "*[System[band(Keywords,$keyword_filter)]]"
    }
    If ($UserID) {
        $sids = ForEach ($item in $UserID) {
            Try {
                $sid = [System.Security.Principal.SecurityIdentifier]($item)
                $sid = $sid.Translate([System.Security.Principal.SecurityIdentifier])
            } Catch [System.Management.Automation.RuntimeException] {
                If ($Error[0].CategoryInfo.Category -eq 'InvalidArgument') {
                    Try {
                        $user = [System.Security.Principal.NTAccount]($item)
                        $sid = $user.Translate([System.Security.Principal.SecurityIdentifier])
                    } Catch { Throw $Error[0] }
                } Else { Throw $Error[0] }
            } Catch { Throw $Error[0] }
            $sid.Value
        }
        $options = @{'Items'       = $sids
            'ForEachFormatString'  = "@UserID='{0}'"
            'FinalizeFormatString' = "*[System[Security[{0}]]]"
        }
        $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
    }
    If ($NamedDataFilter) {
        $options = @{'Items'       = $(ForEach ($item in $NamedDataFilter) {
                    $options = @{'Items'       = $(ForEach ($key in $item.Keys) {
                                If ($item[$key]) {
                                    $options = @{'Items'       = $item[$key]
                                        'NoParenthesis'        = $true
                                        'ForEachFormatString'  = "Data[@Name='$key'] = '{0}'"
                                        'FinalizeFormatString' = "{0}"
                                    }
                                    Initialize-XPathFilter @options
                                } Else { "Data[@Name='$key']" }
                            })
                        'ForEachFormatString'  = "{0}"
                        'FinalizeFormatString' = "{0}"
                    }
                    Initialize-XPathFilter @options
                })
            'ForEachFormatString'  = "{0}"
            'FinalizeFormatString' = "*[EventData[{0}]]"
        }
        $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
    }
    If ($NamedDataExcludeFilter) {
        $options = @{'Items'       = $(ForEach ($item in $NamedDataExcludeFilter) {
                    $options = @{'Items'       = $(ForEach ($key in $item.Keys) {
                                If ($item[$key]) {
                                    $options = @{'Items'       = $item[$key]
                                        'NoParenthesis'        = $true
                                        'ForEachFormatString'  = "Data[@Name='$key'] != '{0}'"
                                        'FinalizeFormatString' = "{0}"
                                        'Logic'                = 'and'
                                    }
                                    Initialize-XPathFilter @options
                                } Else { "Data[@Name='$key']" }
                            })
                        'ForEachFormatString'  = "{0}"
                        'FinalizeFormatString' = "{0}"
                    }
                    Initialize-XPathFilter @options
                })
            'ForEachFormatString'  = "{0}"
            'FinalizeFormatString' = "*[EventData[{0}]]"
        }
        $filter = Join-XPathFilter -ExistingFilter $filter -NewFilter (Initialize-XPathFilter @options)
    }
    if ($XPathOnly) { return $Filter } else {
        if ($Path -ne '') {
            $FilterXML = @"
                <QueryList>
                    <Query Id="0" Path="file://$Path">
                        <Select>
                                $filter
                        </Select>
                    </Query>
                </QueryList>
"@
        } else {
            $FilterXML = @"
                <QueryList>
                    <Query Id="0" Path="$LogName">
                        <Select Path="$LogName">
                                $filter
                        </Select>
                    </Query>
                </QueryList>
"@
        }
        return $FilterXML
    }
}
function Get-EventsInformation {
    <#
    .SYNOPSIS
    Small wrapper against Get-WinEvent providing easy way to gather statistics for Event Logs.

    .DESCRIPTION
    Small wrapper against Get-WinEvent providing easy way to gather statistics for Event Logs.
    It provides option to ask for multiple machines, multiple files at the same time.
    It runs on steroids (runspaces) which allows youto process everything at same time.
    This basically allows you to query 50 servers at same time and do it in finite way.

    .PARAMETER Machine
    ComputerName or Server you want to query. Takes an array of servers as well.

    .PARAMETER FilePath
    FilePath to Event Log file (with .EVTX). Takes an array of Event Log files.

    .PARAMETER LogName
    LogName such as Security or System. Works in conjuction with Machine (s). Default is Security.

    .PARAMETER MaxRunspaces
    Maximum number of runspaces running at same time. For optimum performance decide on your own. Default is 50.

    .EXAMPLE
    $Computer = 'EVO1','AD1','AD2'
    $LogName = 'Security'

    $Size = Get-EventsInformation -Computer $Computer -LogName $LogName
    $Size | ft -A

    Output:

    EventNewest         EventOldest          FileSize FileSizeCurrentGB FileSizeMaximumGB IsClassicLog IsEnabled IsLogFull LastAccessTime      LastWriteTime
    -----------         -----------          -------- ----------------- ----------------- ------------ --------- --------- --------------      -------------
    28.12.2018 12:47:14 20.12.2018 19:29:57 110170112 0.1 GB            0.11 GB                   True      True     False 27.05.2018 14:18:36 28.12.2018 12:33:24
    28.12.2018 12:46:51 26.12.2018 12:54:16  20975616 0.02 GB           0.02 GB                   True      True     False 28.12.2018 12:46:57 28.12.2018 12:46:57

    .EXAMPLE

    Due to AD2 being down time to run is 22 seconds. This is actual timeout before letting it go.

    $Computers = 'EVO1', 'AD1', 'AD2'
    $LogName = 'Security'

    $EventLogsDirectory = Get-ChildItem -Path 'C:\MyEvents'

    $Size = Get-EventsInformation -FilePath $EventLogsDirectory.FullName -Computer $Computers -LogName 'Security'
    $Size | ft -a

    Output:

    VERBOSE: Get-EventsInformation - processing start
    VERBOSE: Get-EventsInformation - Setting up runspace for EVO1
    VERBOSE: Get-EventsInformation - Setting up runspace for AD1
    VERBOSE: Get-EventsInformation - Setting up runspace for AD2
    VERBOSE: Get-EventsInformation - Setting up runspace for C:\MyEvents\Archive-Security-2018-08-21-23-49-19-424.evtx
    VERBOSE: Get-EventsInformation - Setting up runspace for C:\MyEvents\Archive-Security-2018-09-08-02-53-53-711.evtx
    VERBOSE: Get-EventsInformation - Setting up runspace for C:\MyEvents\Archive-Security-2018-09-14-22-13-07-710.evtx
    VERBOSE: Get-EventsInformation - Setting up runspace for C:\MyEvents\Archive-Security-2018-09-15-09-27-52-679.evtx
    VERBOSE: AD2 Reading Event Log (Security) size failed. Error occured: The RPC server is unavailable
    VERBOSE: Get-EventsInformation - processing end - 0 days, 0 hours, 0 minutes, 22 seconds, 648 milliseconds

    EventNewest         EventOldest          FileSize FileSizeCurrentGB FileSizeMaximumGB IsClassicLog IsEnabled IsLogFull LastAccessTime      LastWriteTime
    -----------         -----------          -------- ----------------- ----------------- ------------ --------- --------- --------------      -------------
    28.12.2018 15:56:54 20.12.2018 19:29:57 111218688 0.1 GB            0.11 GB                   True      True     False 27.05.2018 14:18:36 28.12.2018 14:18:24
    22.08.2018 01:48:57 11.08.2018 09:28:06 115740672 0.11 GB           0.11 GB                  False     False     False 16.09.2018 09:27:04 22.08.2018 01:49:20
    08.09.2018 04:53:52 03.09.2018 23:50:15 115740672 0.11 GB           0.11 GB                  False     False     False 12.09.2018 13:18:25 08.09.2018 04:53:53
    15.09.2018 00:13:06 08.09.2018 04:53:53 115740672 0.11 GB           0.11 GB                  False     False     False 15.09.2018 00:13:26 15.09.2018 00:13:08
    15.09.2018 11:27:51 22.08.2018 01:49:20 115740672 0.11 GB           0.11 GB                  False     False     False 15.09.2018 11:28:13 15.09.2018 11:27:55
    28.12.2018 15:56:56 26.12.2018 15:56:31  20975616 0.02 GB           0.02 GB                   True      True     False 28.12.2018 15:56:47 28.12.2018 15:56:47

    .EXAMPLE

    $Computers = 'EVO1', 'AD1','AD1'
    $LogName = 'Security'

    $EventLogsDirectory = Get-ChildItem -Path 'C:\MyEvents'

    $Size = Get-EventsInformation -FilePath $EventLogsDirectory.FullName -Computer $Computers -LogName 'Security' -Verbose
    $Size | ft -a Source, EventNewest, EventOldest,FileSize, FileSizeCurrentGB, FileSizeMaximumGB, IsEnabled, IsLogFull, LastAccessTime, LastWriteTime

    Output:

    VERBOSE: Get-EventsInformation - processing start
    VERBOSE: Get-EventsInformation - Setting up runspace for EVO1
    VERBOSE: Get-EventsInformation - Setting up runspace for AD1
    VERBOSE: Get-EventsInformation - Setting up runspace for AD1
    VERBOSE: Get-EventsInformation - Setting up runspace for C:\MyEvents\Archive-Security-2018-08-21-23-49-19-424.evtx
    VERBOSE: Get-EventsInformation - Setting up runspace for C:\MyEvents\Archive-Security-2018-09-08-02-53-53-711.evtx
    VERBOSE: Get-EventsInformation - Setting up runspace for C:\MyEvents\Archive-Security-2018-09-14-22-13-07-710.evtx
    VERBOSE: Get-EventsInformation - Setting up runspace for C:\MyEvents\Archive-Security-2018-09-15-09-27-52-679.evtx
    VERBOSE: Get-EventsInformation - processing end - 0 days, 0 hours, 0 minutes, 1 seconds, 739 milliseconds

    Source EventNewest         EventOldest          FileSize FileSizeCurrentGB FileSizeMaximumGB IsEnabled IsLogFull LastAccessTime      LastWriteTime
    ------ -----------         -----------          -------- ----------------- ----------------- --------- --------- --------------      -------------
    AD1    28.12.2018 15:59:22 20.12.2018 19:29:57 111218688 0.1 GB            0.11 GB                True     False 27.05.2018 14:18:36 28.12.2018 14:18:24
    AD1    28.12.2018 15:59:22 20.12.2018 19:29:57 111218688 0.1 GB            0.11 GB                True     False 27.05.2018 14:18:36 28.12.2018 14:18:24
    File   22.08.2018 01:48:57 11.08.2018 09:28:06 115740672 0.11 GB           0.11 GB               False     False 16.09.2018 09:27:04 22.08.2018 01:49:20
    File   08.09.2018 04:53:52 03.09.2018 23:50:15 115740672 0.11 GB           0.11 GB               False     False 12.09.2018 13:18:25 08.09.2018 04:53:53
    File   15.09.2018 00:13:06 08.09.2018 04:53:53 115740672 0.11 GB           0.11 GB               False     False 15.09.2018 00:13:26 15.09.2018 00:13:08
    File   15.09.2018 11:27:51 22.08.2018 01:49:20 115740672 0.11 GB           0.11 GB               False     False 15.09.2018 11:28:13 15.09.2018 11:27:55
    EVO1   28.12.2018 15:59:22 26.12.2018 15:56:31  20975616 0.02 GB           0.02 GB                True     False 28.12.2018 15:58:47 28.12.2018 15:58:47

    .EXAMPLE

    $Computers = 'EVO1', 'AD1'
    $EventLogsDirectory = Get-ChildItem -Path 'C:\MyEvents'

    $Size = Get-EventsInformation -FilePath $EventLogsDirectory.FullName -Computer $Computers -LogName 'Security','System' -Verbose
    $Size | ft -a Source, EventNewest, EventOldest,FileSize, FileSizeCurrentGB, FileSizeMaximumGB, IsEnabled, IsLogFull, LastAccessTime, LastWriteTime, LogFilePath, LOgName

    VERBOSE: Get-EventsInformation - processing start
    VERBOSE: Get-EventsInformation - Setting up runspace for EVO1
    VERBOSE: Get-EventsInformation - Setting up runspace for AD1
    VERBOSE: Get-EventsInformation - Setting up runspace for C:\MyEvents\Archive-Security-2018-08-21-23-49-19-424.evtx
    VERBOSE: Get-EventsInformation - Setting up runspace for C:\MyEvents\Archive-Security-2018-09-08-02-53-53-711.evtx
    VERBOSE: Get-EventsInformation - Setting up runspace for C:\MyEvents\Archive-Security-2018-09-14-22-13-07-710.evtx
    VERBOSE: Get-EventsInformation - Setting up runspace for C:\MyEvents\Archive-Security-2018-09-15-09-27-52-679.evtx
    VERBOSE: Get-EventsInformation - processing end - 0 days, 0 hours, 0 minutes, 0 seconds, 137 milliseconds

    Source EventNewest         EventOldest          FileSize FileSizeCurrentGB FileSizeMaximumGB IsEnabled IsLogFull LastAccessTime      LastWriteTime       LogFilePath                                               LogName
    ------ -----------         -----------          -------- ----------------- ----------------- --------- --------- --------------      -------------       -----------                                               -------
    File   22.08.2018 01:48:57 11.08.2018 09:28:06 115740672 0.11 GB           0.11 GB               False     False 16.09.2018 09:27:04 22.08.2018 01:49:20 C:\MyEvents\Archive-Security-2018-08-21-23-49-19-424.evtx N/A
    File   08.09.2018 04:53:52 03.09.2018 23:50:15 115740672 0.11 GB           0.11 GB               False     False 12.09.2018 13:18:25 08.09.2018 04:53:53 C:\MyEvents\Archive-Security-2018-09-08-02-53-53-711.evtx N/A
    EVO1   28.12.2018 18:19:48 26.12.2018 17:27:30  20975616 0.02 GB           0.02 GB                True     False 28.12.2018 18:19:47 28.12.2018 18:19:47 %SystemRoot%\System32\Winevt\Logs\Security.evtx           Security
    AD1    28.12.2018 18:20:01 20.12.2018 19:29:57 113315840 0.11 GB           0.11 GB                True     False 27.05.2018 14:18:36 28.12.2018 17:48:24 %SystemRoot%\System32\Winevt\Logs\Security.evtx           Security
    File   15.09.2018 00:13:06 08.09.2018 04:53:53 115740672 0.11 GB           0.11 GB               False     False 15.09.2018 00:13:26 15.09.2018 00:13:08 C:\MyEvents\Archive-Security-2018-09-14-22-13-07-710.evtx N/A
    EVO1   28.12.2018 18:20:01 05.10.2018 01:33:48  12652544 0.01 GB           0.02 GB                True     False 28.12.2018 18:18:01 28.12.2018 18:18:01 %SystemRoot%\System32\Winevt\Logs\System.evtx             System
    AD1    28.12.2018 18:12:47 03.12.2018 17:20:48   2166784 0 GB              0.01 GB                True     False 19.05.2018 20:05:07 27.12.2018 12:00:32 %SystemRoot%\System32\Winevt\Logs\System.evtx             System
    File   15.09.2018 11:27:51 22.08.2018 01:49:20 115740672 0.11 GB           0.11 GB               False     False 15.09.2018 11:28:13 15.09.2018 11:27:55 C:\MyEvents\Archive-Security-2018-09-15-09-27-52-679.evtx N/A

    .NOTES
    General notes
    #>
    [CmdLetBinding()]
    param([alias ("ADDomainControllers", "DomainController", "Server", "Servers", "Computer", "Computers", "ComputerName")]
        [string[]] $Machine = $Env:COMPUTERNAME,
        [string[]] $FilePath,
        [alias ("LogType", "Log")][string[]] $LogName = 'Security',
        [int] $MaxRunspaces = 50,
        [alias('AskDC', 'QueryDomainControllers', 'AskForest')][switch] $RunAgainstDC)
    Write-Verbose "Get-EventsInformation - processing start"
    if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) { $Verbose = $true } else { $Verbose = $false }
    $Time = Start-TimeLog
    $Pool = New-Runspace -maxRunspaces $maxRunspaces -Verbose:$Verbose
    if ($RunAgainstDC) {
        Write-Verbose 'Get-EventsInformation - scanning for domain controllers'
        $ForestInformation = Get-WinADForestControllers
        $MachineWithErrors = $ForestInformation | Where-Object { $_.HostName -eq '' }
        foreach ($Computer in $MachineWithErrors) { Write-Warning "Get-EventsInformation - Error scanning forest $($Computer.Forest) (domain: $($Computer.Domain)) error: $($Computer.Comment)" }
        $Machine = ($ForestInformation | Where-Object { $_.HostName -ne '' }).HostName
    }
    $RunSpaces = @(foreach ($Computer in $Machine) {
            foreach ($Log in $LogName) {
                Write-Verbose "Get-EventsInformation - Setting up runspace for $Computer on $Log log"
                $Parameters = [ordered] @{Computer = $Computer
                    LogName                        = $Log
                    Verbose                        = $Verbose
                }
                Start-Runspace -ScriptBlock $Script:ScriptBlockEventsInformation -Parameters $Parameters -RunspacePool $Pool -Verbose:$Verbose
            }
        }
        foreach ($Path in $FilePath) {
            Write-Verbose "Get-EventsInformation - Setting up runspace for $Path"
            $Parameters = [ordered] @{Path = $Path
                Verbose                    = $Verbose
            }
            Start-Runspace -ScriptBlock $Script:ScriptBlockEventsInformation -Parameters $Parameters -RunspacePool $Pool -Verbose:$Verbose
        })
    $AllEvents = Stop-Runspace -Runspaces $RunSpaces -FunctionName "Get-EventsInformation" -RunspacePool $pool -Verbose:$Verbose -ErrorAction SilentlyContinue -ErrorVariable +AllErrors
    foreach ($Error in $AllErrors) { Write-Warning "Get-EventsInformation - Error: $Error" }
    $Elapsed = Stop-TimeLog -Time $Time -Option OneLiner
    Write-Verbose -Message "Get-EventsInformation - processing end - $Elapsed"
    return $AllEvents
}
function Get-EventsSettings {
    [cmdletBinding()]
    param([string] $LogName,
        [string] $ComputerName,
        [int] $MaximumSize)
    $Log = Get-PSRegistry -RegistryPath "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog\$LogName" -ComputerName $ComputerName
    if ($Log.PSError -eq $true) {
        $Log = Get-PSRegistry -RegistryPath "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\$LogName" -ComputerName $ComputerName
        $PSRegistryPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\$LogName"
    } else { $PSRegistryPath = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog\$LogName" }
    if ($Log.AutoBackupLogFiles -eq 1 -and $Log.Retention -eq 4294967295) { $EventAction = 'ArchiveTheLogWhenFullDoNotOverwrite' } elseif ($Log.AutoBackupLogFiles -eq 0 -and $Log.Retention -eq 4294967295) { $EventAction = 'DoNotOverwriteEventsClearLogManually' } else { $EventAction = 'OverwriteEventsAsNeededOldestFirst' }
    if ($Log.RestrictGuestAccess -eq 1) { $RestrictGuestAccess = $true } else { $RestrictGuestAccess = $false }
    $MaxSizeMB = Convert-Size -Value $Log.MaxSize -From Bytes -To MB -Precision 2
    [PSCustomObject] @{PSError = $Log.PSError
        PSRegistryPath         = $PSRegistryPath
        MaxSizeMB              = $MaxSizeMB
        EventAction            = $EventAction
        RestrictGuestAccess    = $RestrictGuestAccess
    }
}
function Set-EventsSettings {
    [cmdletBinding()]
    param([string] $LogName,
        [string] $ComputerName,
        [int] $MaximumSizeMB,
        [ValidateSet('OverwriteEventsAsNeededOldestFirst', 'ArchiveTheLogWhenFullDoNotOverwrite', 'DoNotOverwriteEventsClearLogManually', 'None')][string] $EventAction)
    if ($MaximumSizeMB) {
        $MaxSize = $MaximumSizeMB * 1MB
        $Log = Get-EventsSettings -LogName $LogName
        if ($Log.PSError -eq $false) {
            if ($MaximumSizeMB -ne 0) { Set-PSRegistry -RegistryPath $Log.PSRegistryPath -ComputerName $ComputerName -Key 'MaxSize' -Value $MaxSize -Type REG_DWORD }
            if ($EventAction) {
                if ($EventAction -eq 'ArchiveTheLogWhenFullDoNotOverwrite') {
                    Set-PSRegistry -RegistryPath $Log.PSRegistryPath -ComputerName $ComputerName -Key 'AutoBackupLogFiles' -Value 1 -Type REG_DWORD
                    Set-PSRegistry -RegistryPath $Log.PSRegistryPath -ComputerName $ComputerName -Key 'Retention' -Value 4294967295 -Type REG_DWORD
                } elseif ($EventAction -eq 'DoNotOverwriteEventsClearLogManually') {
                    Set-PSRegistry -RegistryPath $Log.PSRegistryPath -ComputerName $ComputerName -Key 'AutoBackupLogFiles' -Value 0 -Type REG_DWORD
                    Set-PSRegistry -RegistryPath $Log.PSRegistryPath -ComputerName $ComputerName -Key 'Retention' -Value 4294967295 -Type REG_DWORD
                } elseif ($EventAction -eq 'OverwriteEventsAsNeededOldestFirst') {
                    Set-PSRegistry -RegistryPath $Log.PSRegistryPath -ComputerName $ComputerName -Key 'AutoBackupLogFiles' -Value 0 -Type REG_DWORD
                    Set-PSRegistry -RegistryPath $Log.PSRegistryPath -ComputerName $ComputerName -Key 'Retention' -Value 0 -Type REG_DWORD
                } else {}
            }
        }
    }
}
function Write-Event {
    [alias('Write-WinEvent', 'Write-Events')]
    [cmdletBinding()]
    param([string[]] $Computer,
        [Parameter(Mandatory)][alias('EventLog')][string] $LogName,
        [Parameter(Mandatory)][alias('Provider', 'ProviderName')][string] $Source,
        [int] $Category,
        [alias('Level')][System.Diagnostics.EventLogEntryType] $EntryType = [System.Diagnostics.EventLogEntryType]::Information,
        [Parameter(Mandatory)][alias('EventID')][int] $ID,
        [Parameter(Mandatory)][string] $Message,
        [Array] $AdditionalFields)
    Begin {}
    Process {
        if (-not $Computer) {
            $SourceExists = Get-WinEvent -ListProvider $Source -ErrorAction SilentlyContinue
            if ($null -eq $SourceExists -or $SourceExists.LogLinks.LogName -notcontains $LogName) {
                try { New-EventLog -LogName $LogName -Source $Source -ErrorAction Stop } catch {
                    Write-Warning "New-WinEvent - Couldn't create new event log source - $($_.Exception.Message)"
                    return
                }
            }
            $Computer = $Env:COMPUTERNAME
        }
        foreach ($Machine in $Computer) {
            $EventInstance = [System.Diagnostics.EventInstance]::new($ID, $Category, $EntryType)
            $Event = [System.Diagnostics.EventLog]::new()
            $Event.Log = $LogName
            $Event.Source = $Source
            if ($Machine -ne $Env:COMPUTERNAME) { $Event.MachineName = $Machine }
            [Array] $JoinedMessage = @($Message
                $AdditionalFields | ForEach-Object { $_ })
            try { $Event.WriteEvent($EventInstance, $JoinedMessage) } catch { Write-Warning "Write-Event - Couldn't create new event - $($_.Exception.Message)" }
        }
    }
}
Export-ModuleMember -Function @('Get-Events', 'Get-EventsFilter', 'Get-EventsInformation', 'Get-EventsSettings', 'Set-EventsSettings', 'Write-Event') -Alias @('Write-Events', 'Write-WinEvent')