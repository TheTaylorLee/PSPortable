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
            $LocalServer = Get-ADDomainController -Discover -DomainName $D -ErrorAction Stop -Writable
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
            $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('Computer', $event.MachineName.ToString()))
            $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('Date', $Event.TimeCreated))
            $EventTopNodes = $eventXML.Event.PSAdapted.PSObject.Properties.Name
            [Array] $EventTopNodes = foreach ($Entry in $EventTopNodes) { if ($Entry -ne 'System' -and $Entry -ne 'xmlns') { $Entry } }
            foreach ($TopNode in $EventTopNodes) {
                $EventSubsSubs = $eventXML.Event.$TopNode.PSAdapted.PSObject.Properties
                $h = 0
                foreach ($EventSubSub in $EventSubsSubs) {
                    $SubNode = $EventSubSub.Name
                    if ($EventSubSub.TypeNameOfValue -like "System.Object*") {
                        if ($eventXML.Event.$TopNode.$SubNode) {
                            $SubSubNode = $eventXML.Event.$TopNode.$SubNode.PSAdapted.PSObject.Properties
                            [Array] $SubSubNode = foreach ($Entry in $SubSubNode) { if ($Entry.Name -ne 'xmls' -and $_.TypeNameOfValue -like "string*") { $Entry } }
                            foreach ($Name in $SubSubNode.Name) {
                                $fieldName = $Name
                                $fieldValue = $eventXML.Event.$TopNode.$SubNode.$Name
                                $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new($fieldName, $fieldValue))
                            }
                            For ($i = 0; $i -lt $eventXML.Event.$TopNode.$SubNode.Count; $i++) {
                                if ($eventXML.Event.$TopNode.$SubNode[$i].Name) {
                                    $fieldName = $eventXML.Event.$TopNode.$SubNode[$i].Name
                                    if ($eventXML.Event.$TopNode.$SubNode[$i]."#text") {
                                        $fieldValue = $eventXML.Event.$TopNode.$SubNode[$i]."#text"
                                        if ($fieldValue -eq "-".Trim()) { $fieldValue = $fieldValue -replace "-" }
                                    } else { $fieldValue = "" }
                                    if ($fieldName -ne "") { $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new($fieldName, $fieldValue)) }
                                } else {
                                    $Value = $eventXML.Event.$TopNode.$SubNode[$i]
                                    if ($Value.Name -ne 'Name' -and $Value.Name -ne '#text') {
                                        $fieldName = "NoNameA$i"
                                        $fieldValue = $Value
                                        $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new($fieldName, $fieldValue))
                                    }
                                }
                            }
                        }
                    } elseif ($EventSubSub.TypeNameOfValue -like "System.Xml.XmlElement*") {
                        $SubSubNode = $eventXML.Event.$TopNode.$SubNode.PSAdapted.PSObject.Properties
                        [Array] $SubSubNode = foreach ($Entry in $SubSubNode) { if ($Entry.Name -ne 'xmls' -and $_.TypeNameOfValue -like "string*") { $Entry } }
                        foreach ($Name in $SubSubNode.Name) {
                            $fieldName = $Name
                            $fieldValue = $eventXML.Event.$TopNode.$SubNode.$Name
                            $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new($fieldName, $fieldValue))
                        }
                    } else {
                        $fieldValue = $eventXML.Event.$TopNode.$SubNode
                        if ($fieldValue -match "\n") {
                            $SplittedValues = $fieldValue -split '\n'
                            foreach ($Split in $SplittedValues) {
                                $h++
                                $fieldName = "NoNameB$h"
                                $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new($fieldName, $Split))
                            }
                        } else {
                            $h++
                            $fieldName = "NoNameB$h"
                            $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new($fieldName, $fieldValue))
                        }
                    }
                }
            }
            [string] $MessageSubject = ($Event.Message -split '\n')[0] -replace "`n", '' -replace "`r", '' -replace "`t", ''
            $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('MessageSubject', $MessageSubject))
            $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('Action', $MessageSubject))
            $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('KeywordDisplayName', ($Event.KeywordsDisplayNames -join ',')))
            if ($Event.SubjectDomainName -and $Event.SubjectUserName) { $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('Who', "$($Event.SubjectDomainName)\$($Event.SubjectUserName)")) } elseif ($Event.SubjectUserName) { $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('Who', "$($Event.SubjectUserName)")) }
            if ($Event.TargetDomainName -and $Event.TargetUserName) { $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('ObjectAffected', "$($Event.TargetDomainName)\$($Event.TargetUserName)")) } elseif ($Event.TargetUserName) { $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('ObjectAffected', "$($Event.TargetUserName)")) }
            if ($Event.MemberName) {
                [string] $MemberNameWithoutCN = $Event.MemberName -replace 'CN=|\\|,(OU|DC|CN).*$'
                $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('MemberNameWithoutCN', $MemberNameWithoutCN))
            }
            if ($EventFilter.Path) { $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('GatheredFrom', $EventFilter.Path)) } else { $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('GatheredFrom', $Comp)) }
            $Event.PSObject.Properties.Add([System.Management.Automation.PSNoteProperty]::new('GatheredLogName', $EventFilter.LogName))
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
    Get-Events is a wrapper function around Get-WinEvent providing additional features and options exposing most of the Get-WinEvent functionality in easy to use manner.

    .PARAMETER Machine
    Specifies the name of the computer that this cmdlet gets events from the event logs. Type the NetBIOS name, an IP address, or the fully qualified domain name (FQDN) of the computer. The default value is the local computer, localhost. This parameter accepts only one computer name at a time.

    To get event logs from remote computers, configure the firewall port for the event log service to allow remote access.

    This cmdlet does not rely on PowerShell remoting. You can use the ComputerName parameter even if your computer is not configured to run remote commands.

    .PARAMETER DateFrom
    Specifies the date and time of the earliest event in the event log you want to search for.

    .PARAMETER DateTo
    Specifies the date and time of the latest event in the event log you want to search for.

    .PARAMETER ID
    Specifies the event ID (or events) of the event you want to search for. If provided more than 23 the cmdlet will split the events into multiple queries automatically.

    .PARAMETER ExcludeID
    Specifies the event ID (or events) of the event you want to exclude from the search. If provided more than 23 the cmdlet will split the events into multiple queries automatically.

    .PARAMETER LogName
    Specifies the event logs that this cmdlet get events from. Enter the event log names in a comma-separated list. Wildcards are permitted.

    .PARAMETER ProviderName
    Specifies, as a string array, the event log providers from which this cmdlet gets events. Enter the provider names in a comma-separated list, or use wildcard characters to create provider name patterns.

    An event log provider is a program or service that writes events to the event log. It is not a PowerShell provider.

    .PARAMETER NamedDataFilter
    Provide NamedDataFilter in specific form to optimize search performance looking for specific events.

    .PARAMETER NamedDataExcludeFilter
    Provide NamedDataExcludeFilter in specific form to optimize search performance looking for specific events.

    .PARAMETER UserID
    The UserID key can take a valid security identifier (SID) or a domain account name that can be used to construct a valid System.Security.Principal.NTAccount object.

    .PARAMETER Level
    Define the event level that this cmdlet gets events from. Options are Verbose, Informational, Warning, Error, Critical, LogAlways

    .PARAMETER UserSID
    Search events by UserSID

    .PARAMETER Data
    The Data value takes event data in an unnamed field. For example, events in classic event logs.

    .PARAMETER MaxEvents
    Specifies the maximum number of events that are returned. Enter an integer such as 100. The default is to return all the events in the logs or files.

    .PARAMETER Credential
    Specifies the name of the computer that this cmdlet gets events from the event logs. Type the NetBIOS name, an IP address, or the fully qualified domain name (FQDN) of the computer. The default value is the local computer, localhost. This parameter accepts only one computer name at a time.

    To get event logs from remote computers, configure the firewall port for the event log service to allow remote access.

    This cmdlet does not rely on PowerShell remoting. You can use the ComputerName parameter even if your computer is not configured to run remote commands.

    .PARAMETER Path
    Specifies the path to the event log files that this cmdlet get events from. Enter the paths to the log files in a comma-separated list, or use wildcard characters to create file path patterns.

    .PARAMETER Keywords
    Define keywords to search for by their name. Available keywords are: AuditFailure, AuditSuccess, CorrelationHint2, EventLogClassic, Sqm, WdiDiagnostic, WdiContext, ResponseTime, None

    .PARAMETER RecordID
    Find a single event in the event log using it's RecordId

    .PARAMETER MaxRunspaces
    Limit the number of concurrent runspaces that can be used to process the events. By default it uses $env:NUMBER_OF_PROCESSORS + 1

    .PARAMETER Oldest
    Indicate that this cmdlet gets the events in oldest-first order. By default, events are returned in newest-first order.

    .PARAMETER DisableParallel
    Disables parallel processing of the events. By default, events are processed in parallel.

    .PARAMETER ExtendedOutput
    Indicates that this cmdlet returns an extended set of output parameters. By default, this cmdlet does not generate any extended output.

    .PARAMETER ExtendedInput
    Indicates that this cmdlet takes an extended set of input parameters. Extended input is used by PSWinReportingV2 to provide special input parameters.

    .EXAMPLE
    Get-Events -LogName 'Application' -ID 1001 -MaxEvents 1 -Verbose -DisableParallel

    .EXAMPLE
    Get-Events -LogName 'Setup' -ID 2 -ComputerName 'AD1' -MaxEvents 1 -Verbose | Format-List *

    .EXAMPLE
    Get-Events -LogName 'Setup' -ID 2 -ComputerName 'AD1','AD2','AD3' -MaxEvents 1 -Verbose | Format-List *

    .EXAMPLE
    Get-Events -LogName 'Security' -ID 5379 -RecordID 19626 -Verbose

    .EXAMPLE
    Get-Events -LogName 'System' -ID 1001,1018 -ProviderName 'Microsoft-Windows-WER-SystemErrorReporting' -Verbose
    Get-Events -LogName 'System' -ID 42,41,109 -ProviderName 'Microsoft-Windows-Kernel-Power' -Verbose
    Get-Events -LogName 'System' -ID 1,12,13 -ProviderName 'Microsoft-Windows-Kernel-General' -Verbose
    Get-Events -LogName 'System' -ID 6005,6006,6008,6013 -ProviderName 'EventLog' -Verbose

    .EXAMPLE
    $List = @(
        @{ Server = 'AD1'; LogName = 'Security'; EventID = '5136', '5137'; Type = 'Computer' }
        @{ Server = 'AD2'; LogName = 'Security'; EventID = '5136', '5137'; Type = 'Computer' }
        @{ Server = 'C:\MyEvents\Archive-Security-2018-08-21-23-49-19-424.evtx'; LogName = 'Security'; EventID = '5136', '5137'; Type = 'File' }
        @{ Server = 'C:\MyEvents\Archive-Security-2018-09-15-09-27-52-679.evtx'; LogName = 'Security'; EventID = '5136', '5137'; Type = 'File' }
        @{ Server = 'Evo1'; LogName = 'Setup'; EventID = 2; Type = 'Computer'; }
        @{ Server = 'AD1.ad.evotec.xyz'; LogName = 'Security'; EventID = 4720, 4738, 5136, 5137, 5141, 4722, 4725, 4767, 4723, 4724, 4726, 4728, 4729, 4732, 4733, 4746, 4747, 4751, 4752, 4756, 4757, 4761, 4762, 4785, 4786, 4787, 4788, 5136, 5137, 5141, 5136, 5137, 5141, 5136, 5137, 5141; Type = 'Computer' }
        @{ Server = 'Evo1'; LogName = 'Security'; Type = 'Computer'; MaxEvents = 15; Keywords = 'AuditSuccess' }
        @{ Server = 'Evo1'; LogName = 'Security'; Type = 'Computer'; MaxEvents = 15; Level = 'Informational'; Keywords = 'AuditFailure' }
    )
    $Output = Get-Events -ExtendedInput $List -Verbose
    $Output | Format-Table Computer, Date, LevelDisplayName

    .EXAMPLE
    Get-Events -MaxEvents 2 -LogName 'Security' -ComputerName 'AD1.AD.EVOTEC.XYZ','AD2' -ID 4720, 4738, 5136, 5137, 5141, 4722, 4725, 4767, 4723, 4724, 4726, 4728, 4729, 4732, 4733, 4746, 4747, 4751, 4752, 4756, 4757, 4761, 4762, 4785, 4786, 4787, 4788, 5136, 5137, 5141, 5136, 5137, 5141, 5136, 5137, 5141 -Verbose

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
        [alias ("Provider", "Source")] [string[]] $ProviderName,
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
            $ConvertedLevels = foreach ($DataLevel in $EventEntry.Level) { ([PSEventViewer.Level]::$DataLevel).value__ }
            $ConvertedKeywords = foreach ($DataKeyword in $EventEntry.Keywords) { ([PSEventViewer.Keywords]::$DataKeyword).value__ }
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
    param([parameter(Mandatory)][string] $LogName,
        [string] $ComputerName)
    try { if ($ComputerName) { $Log = Get-WinEvent -ListLog $LogName -ErrorAction Stop } else { $Log = Get-WinEvent -ListLog $LogName -ComputerName $ComputerName -ErrorAction Stop } } catch {
        if ($ErrorActionPreference -eq 'Stop') { throw } else {
            Write-Warning -Message "Get-EventsSettings - Error occured during reading of event log $LogName - $($_.Exception.Message)"
            return
        }
    }
    if ($Log.LogMode -eq 'AutoBackup') { $EventAction = 'ArchiveTheLogWhenFullDoNotOverwrite' } elseif ($Log.LogMode -eq 'Circular') { $EventAction = 'OverwriteEventsAsNeededOldestFirst' } elseif ($Log.LogMode -eq 'Retain') { $EventAction = 'DoNotOverwriteEventsClearLogManually' } else { $EventAction = 'Unknown' }
    [PSCustomObject] @{EventAction     = $EventAction
        LogName                        = $Log.LogName
        LogType                        = $Log.LogType
        LogMode                        = $Log.LogMode
        FileSize                       = $Log.FileSize
        FileSizeMB                     = Convert-Size -Value $Log.FileSize -From Bytes -To MB -Precision 2
        MaximumSizeInBytes             = $Log.MaximumSizeInBytes
        MaximumSizeinMB                = Convert-Size -Value $Log.MaximumSizeInBytes -From Bytes -To MB -Precision 2
        IsLogFull                      = $Log.IsLogFull
        LogFilePath                    = $Log.LogFilePath
        LastAccessTime                 = $Log.LastAccessTime
        LastWriteTime                  = $Log.LastWriteTime
        OldestRecordNumber             = $Log.OldestRecordNumber
        RecordCount                    = $Log.RecordCount
        LogIsolation                   = $Log.LogIsolation
        IsEnabled                      = $Log.IsEnabled
        IsClassicLog                   = $Log.IsClassicLog
        SecurityDescriptor             = $Log.SecurityDescriptor
        OwningProviderName             = $Log.OwningProviderName
        ProviderNames                  = $Log.ProviderNames
        ProviderLevel                  = $Log.ProviderLevel
        ProviderKeywords               = $Log.ProviderKeywords
        ProviderBufferSize             = $Log.ProviderBufferSize
        ProviderMinimumNumberOfBuffers = $Log.ProviderMinimumNumberOfBuffers
        ProviderMaximumNumberOfBuffers = $Log.ProviderMaximumNumberOfBuffers
        ProviderLatency                = $Log.ProviderLatency
        ProviderControlGuid            = $Log.ProviderControlGuid
    }
}
function Set-EventsSettings {
    [cmdletBinding(SupportsShouldProcess)]
    param([Parameter(Mandatory)][string] $LogName,
        [string] $ComputerName,
        [int] $MaximumSizeMB,
        [int] $MaximumSizeInBytes,
        [ValidateSet('OverwriteEventsAsNeededOldestFirst', 'ArchiveTheLogWhenFullDoNotOverwrite', 'DoNotOverwriteEventsClearLogManually')][string] $EventAction,
        [alias('LogMode')][System.Diagnostics.Eventing.Reader.EventLogMode] $Mode)
    $TranslateEventAction = @{'OverwriteEventsAsNeededOldestFirst' = [System.Diagnostics.Eventing.Reader.EventLogMode]::Circular
        'ArchiveTheLogWhenFullDoNotOverwrite'                      = [System.Diagnostics.Eventing.Reader.EventLogMode]::AutoBackup
        'DoNotOverwriteEventsClearLogManually'                     = [System.Diagnostics.Eventing.Reader.EventLogMode]::Retain
    }
    try { if ($ComputerName) { $Log = Get-WinEvent -ListLog $LogName -ErrorAction Stop } else { $Log = Get-WinEvent -ListLog $LogName -ComputerName $ComputerName -ErrorAction Stop } } catch {
        if ($ErrorActionPreference -eq 'Stop') { throw } else {
            Write-Warning -Message "Set-EventsSettings - Error occured during reading $LogName log - $($_.Exception.Message)"
            return
        }
    }
    if ($PSBoundParameters.ContainsKey('EventAction')) { $Log.LogMode = $TranslateEventAction[$EventAction] }
    if ($PSBoundParameters.ContainsKey('Mode')) { $Log.LogMode = $Mode }
    if ($PSBoundParameters.ContainsKey('MaximumSizeMB')) {
        $MaxSize = $MaximumSizeMB * 1MB
        $Log.MaximumSizeInBytes = $MaxSize
    }
    if ($PSBoundParameters.ContainsKey('MaximumSizeInBytes')) { $Log.MaximumSizeInBytes = $MaximumSizeInBytes }
    if ($PSCmdlet.ShouldProcess($LogName, "Saving event log settings")) {
        try { $Log.SaveChanges() } catch {
            if ($ErrorActionPreference -eq 'Stop') { throw } else {
                Write-Warning -Message "Set-EventsSettings - Error occured during saving of changes for $LogName log - $($_.Exception.Message)"
                return
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
Export-ModuleMember -Function @('Get-Events', 'Get-EventsFilter', 'Get-EventsInformation', 'Get-EventsSettings', 'Set-EventsSettings', 'Write-Event') -Alias @('Write-Events', 'Write-WinEvent')
# SIG # Begin signature block
# MIIhjgYJKoZIhvcNAQcCoIIhfzCCIXsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUOQbz4qDPu0DYGo7g7XOLGaw+
# /HigghusMIIDtzCCAp+gAwIBAgIQDOfg5RfYRv6P5WD8G/AwOTANBgkqhkiG9w0B
# AQUFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVk
# IElEIFJvb3QgQ0EwHhcNMDYxMTEwMDAwMDAwWhcNMzExMTEwMDAwMDAwWjBlMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3Qg
# Q0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCtDhXO5EOAXLGH87dg
# +XESpa7cJpSIqvTO9SA5KFhgDPiA2qkVlTJhPLWxKISKityfCgyDF3qPkKyK53lT
# XDGEKvYPmDI2dsze3Tyoou9q+yHyUmHfnyDXH+Kx2f4YZNISW1/5WBg1vEfNoTb5
# a3/UsDg+wRvDjDPZ2C8Y/igPs6eD1sNuRMBhNZYW/lmci3Zt1/GiSw0r/wty2p5g
# 0I6QNcZ4VYcgoc/lbQrISXwxmDNsIumH0DJaoroTghHtORedmTpyoeb6pNnVFzF1
# roV9Iq4/AUaG9ih5yLHa5FcXxH4cDrC0kqZWs72yl+2qp/C3xag/lRbQ/6GW6whf
# GHdPAgMBAAGjYzBhMA4GA1UdDwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB0G
# A1UdDgQWBBRF66Kv9JLLgjEtUYunpyGd823IDzAfBgNVHSMEGDAWgBRF66Kv9JLL
# gjEtUYunpyGd823IDzANBgkqhkiG9w0BAQUFAAOCAQEAog683+Lt8ONyc3pklL/3
# cmbYMuRCdWKuh+vy1dneVrOfzM4UKLkNl2BcEkxY5NM9g0lFWJc1aRqoR+pWxnmr
# EthngYTffwk8lOa4JiwgvT2zKIn3X/8i4peEH+ll74fg38FnSbNd67IJKusm7Xi+
# fT8r87cmNW1fiQG2SVufAQWbqz0lwcy2f8Lxb4bG+mRo64EtlOtCt/qMHt1i8b5Q
# Z7dsvfPxH2sMNgcWfzd8qVttevESRmCD1ycEvkvOl77DZypoEd+A5wwzZr8TDRRu
# 838fYxAe+o0bJW1sj6W3YQGx0qMmoRBxna3iw/nDmVG3KwcIzi7mULKn+gpFL6Lw
# 8jCCBTAwggQYoAMCAQICEAQJGBtf1btmdVNDtW+VUAgwDQYJKoZIhvcNAQELBQAw
# ZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQ
# d3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBS
# b290IENBMB4XDTEzMTAyMjEyMDAwMFoXDTI4MTAyMjEyMDAwMFowcjELMAkGA1UE
# BhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2lj
# ZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIENvZGUg
# U2lnbmluZyBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAPjTsxx/
# DhGvZ3cH0wsxSRnP0PtFmbE620T1f+Wondsy13Hqdp0FLreP+pJDwKX5idQ3Gde2
# qvCchqXYJawOeSg6funRZ9PG+yknx9N7I5TkkSOWkHeC+aGEI2YSVDNQdLEoJrsk
# acLCUvIUZ4qJRdQtoaPpiCwgla4cSocI3wz14k1gGL6qxLKucDFmM3E+rHCiq85/
# 6XzLkqHlOzEcz+ryCuRXu0q16XTmK/5sy350OTYNkO/ktU6kqepqCquE86xnTrXE
# 94zRICUj6whkPlKWwfIPEvTFjg/BougsUfdzvL2FsWKDc0GCB+Q4i2pzINAPZHM8
# np+mM6n9Gd8lk9ECAwEAAaOCAc0wggHJMBIGA1UdEwEB/wQIMAYBAf8CAQAwDgYD
# VR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMDMHkGCCsGAQUFBwEBBG0w
# azAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUF
# BzAChjdodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVk
# SURSb290Q0EuY3J0MIGBBgNVHR8EejB4MDqgOKA2hjRodHRwOi8vY3JsNC5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMDqgOKA2hjRodHRw
# Oi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3Js
# ME8GA1UdIARIMEYwOAYKYIZIAYb9bAACBDAqMCgGCCsGAQUFBwIBFhxodHRwczov
# L3d3dy5kaWdpY2VydC5jb20vQ1BTMAoGCGCGSAGG/WwDMB0GA1UdDgQWBBRaxLl7
# KgqjpepxA8Bg+S32ZXUOWDAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823I
# DzANBgkqhkiG9w0BAQsFAAOCAQEAPuwNWiSz8yLRFcgsfCUpdqgdXRwtOhrE7zBh
# 134LYP3DPQ/Er4v97yrfIFU3sOH20ZJ1D1G0bqWOWuJeJIFOEKTuP3GOYw4TS63X
# X0R58zYUBor3nEZOXP+QsRsHDpEV+7qvtVHCjSSuJMbHJyqhKSgaOnEoAjwukaPA
# JRHinBRHoXpoaK+bp1wgXNlxsQyPu6j4xRJon89Ay0BEpRPw5mQMJQhCMrI2iiQC
# /i9yfhzXSUWW6Fkd6fp0ZGuy62ZD2rOwjNXpDd32ASDOmTFjPQgaGLOBm0/GkxAG
# /AeB+ova+YJJ92JuoVP6EpQYhS6SkepobEQysmah5xikmmRR7zCCBT0wggQloAMC
# AQICEATV3B9I6snYUgC6zZqbKqcwDQYJKoZIhvcNAQELBQAwcjELMAkGA1UEBhMC
# VVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0
# LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIENvZGUgU2ln
# bmluZyBDQTAeFw0yMDA2MjYwMDAwMDBaFw0yMzA3MDcxMjAwMDBaMHoxCzAJBgNV
# BAYTAlBMMRIwEAYDVQQIDAnFmmzEhXNraWUxETAPBgNVBAcTCEthdG93aWNlMSEw
# HwYDVQQKDBhQcnplbXlzxYJhdyBLxYJ5cyBFVk9URUMxITAfBgNVBAMMGFByemVt
# eXPFgmF3IEvFgnlzIEVWT1RFQzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
# ggEBAL+ygd4sga4ZC1G2xXvasYSijwWKgwapZ69wLaWaZZIlY6YvXTGQnIUnk+Tg
# 7EoT7mQiMSaeSPOrn/Im6N74tkvRfQJXxY1cnt3U8//U5grhh/CULdd6M3/Z4h3n
# MCq7LQ1YVaa4MYub9F8WOdXO84DANoNVG/t7YotL4vzqZil3S9pHjaidp3kOXGJc
# vxrCPAkRFBKvUmYo23QPFa0Rd0qA3bFhn97WWczup1p90y2CkOf28OVOOObv1fNE
# EqMpLMx0Yr04/h+LPAAYn6K4YtIu+m3gOhGuNc3B+MybgKePAeFIY4EQzbqvCMy1
# iuHZb6q6ggRyqrJ6xegZga7/gV0CAwEAAaOCAcUwggHBMB8GA1UdIwQYMBaAFFrE
# uXsqCqOl6nEDwGD5LfZldQ5YMB0GA1UdDgQWBBQYsTUn6BxQICZOCZA0CxS0TZSU
# ZjAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwdwYDVR0fBHAw
# bjA1oDOgMYYvaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1j
# cy1nMS5jcmwwNaAzoDGGL2h0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFz
# c3VyZWQtY3MtZzEuY3JsMEwGA1UdIARFMEMwNwYJYIZIAYb9bAMBMCowKAYIKwYB
# BQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwCAYGZ4EMAQQBMIGE
# BggrBgEFBQcBAQR4MHYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0
# LmNvbTBOBggrBgEFBQcwAoZCaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0Rp
# Z2lDZXJ0U0hBMkFzc3VyZWRJRENvZGVTaWduaW5nQ0EuY3J0MAwGA1UdEwEB/wQC
# MAAwDQYJKoZIhvcNAQELBQADggEBAJq9bM+JbCwEYuMBtXoNAfH1SRaMLXnLe0py
# VK6el0Z1BtPxiNcF4iyHqMNVD4iOrgzLEVzx1Bf/sYycPEnyG8Gr2tnl7u1KGSjY
# enX4LIXCZqNEDQCeTyMstNv931421ERByDa0wrz1Wz5lepMeCqXeyiawqOxA9fB/
# 106liR12vL2tzGC62yXrV6WhD6W+s5PpfEY/chuIwVUYXp1AVFI9wi2lg0gaTgP/
# rMfP1wfVvaKWH2Bm/tU5mwpIVIO0wd4A+qOhEia3vn3J2Zz1QDxEprLcLE9e3Gmd
# G5+8xEypTR23NavhJvZMgY2kEXBEKEEDaXs0LoPbn6hMcepR2A4wggauMIIElqAD
# AgECAhAHNje3JFR82Ees/ShmKl5bMA0GCSqGSIb3DQEBCwUAMGIxCzAJBgNVBAYT
# AlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2Vy
# dC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMjAz
# MjMwMDAwMDBaFw0zNzAzMjIyMzU5NTlaMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQK
# Ew5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBS
# U0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0EwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQDGhjUGSbPBPXJJUVXHJQPE8pE3qZdRodbSg9GeTKJtoLDM
# g/la9hGhRBVCX6SI82j6ffOciQt/nR+eDzMfUBMLJnOWbfhXqAJ9/UO0hNoR8XOx
# s+4rgISKIhjf69o9xBd/qxkrPkLcZ47qUT3w1lbU5ygt69OxtXXnHwZljZQp09ns
# ad/ZkIdGAHvbREGJ3HxqV3rwN3mfXazL6IRktFLydkf3YYMZ3V+0VAshaG43IbtA
# rF+y3kp9zvU5EmfvDqVjbOSmxR3NNg1c1eYbqMFkdECnwHLFuk4fsbVYTXn+149z
# k6wsOeKlSNbwsDETqVcplicu9Yemj052FVUmcJgmf6AaRyBD40NjgHt1biclkJg6
# OBGz9vae5jtb7IHeIhTZgirHkr+g3uM+onP65x9abJTyUpURK1h0QCirc0PO30qh
# HGs4xSnzyqqWc0Jon7ZGs506o9UD4L/wojzKQtwYSH8UNM/STKvvmz3+DrhkKvp1
# KCRB7UK/BZxmSVJQ9FHzNklNiyDSLFc1eSuo80VgvCONWPfcYd6T/jnA+bIwpUzX
# 6ZhKWD7TA4j+s4/TXkt2ElGTyYwMO1uKIqjBJgj5FBASA31fI7tk42PgpuE+9sJ0
# sj8eCXbsq11GdeJgo1gJASgADoRU7s7pXcheMBK9Rp6103a50g5rmQzSM7TNsQID
# AQABo4IBXTCCAVkwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUuhbZbU2F
# L3MpdpovdYxqII+eyG8wHwYDVR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08w
# DgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMIMHcGCCsGAQUFBwEB
# BGswaTAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsG
# AQUFBzAChjVodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVz
# dGVkUm9vdEc0LmNydDBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNybDAgBgNVHSAEGTAXMAgG
# BmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZIhvcNAQELBQADggIBAH1ZjsCTtm+Y
# qUQiAX5m1tghQuGwGC4QTRPPMFPOvxj7x1Bd4ksp+3CKDaopafxpwc8dB+k+YMjY
# C+VcW9dth/qEICU0MWfNthKWb8RQTGIdDAiCqBa9qVbPFXONASIlzpVpP0d3+3J0
# FNf/q0+KLHqrhc1DX+1gtqpPkWaeLJ7giqzl/Yy8ZCaHbJK9nXzQcAp876i8dU+6
# WvepELJd6f8oVInw1YpxdmXazPByoyP6wCeCRK6ZJxurJB4mwbfeKuv2nrF5mYGj
# VoarCkXJ38SNoOeY+/umnXKvxMfBwWpx2cYTgAnEtp/Nh4cku0+jSbl3ZpHxcpzp
# SwJSpzd+k1OsOx0ISQ+UzTl63f8lY5knLD0/a6fxZsNBzU+2QJshIUDQtxMkzdwd
# eDrknq3lNHGS1yZr5Dhzq6YBT70/O3itTK37xJV77QpfMzmHQXh6OOmc4d0j/R0o
# 08f56PGYX/sr2H7yRp11LB4nLCbbbxV7HhmLNriT1ObyF5lZynDwN7+YAN8gFk8n
# +2BnFqFmut1VwDophrCYoCvtlUG3OtUVmDG0YgkPCr2B2RP+v6TR81fZvAT6gt4y
# 3wSJ8ADNXcL50CN/AAvkdgIm2fBldkKmKYcJRyvmfxqkhQ/8mJb2VVQrH4D6wPIO
# K+XW+6kvRBVK5xMOHds3OBqhK/bt1nz8MIIGxjCCBK6gAwIBAgIQCnpKiJ7JmUKQ
# BmM4TYaXnTANBgkqhkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMO
# RGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNB
# NDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMB4XDTIyMDMyOTAwMDAwMFoXDTMz
# MDMxNDIzNTk1OVowTDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJ
# bmMuMSQwIgYDVQQDExtEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMiAtIDIwggIiMA0G
# CSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC5KpYjply8X9ZJ8BWCGPQz7sxcbOPg
# JS7SMeQ8QK77q8TjeF1+XDbq9SWNQ6OB6zhj+TyIad480jBRDTEHukZu6aNLSOiJ
# QX8Nstb5hPGYPgu/CoQScWyhYiYB087DbP2sO37cKhypvTDGFtjavOuy8YPRn80J
# xblBakVCI0Fa+GDTZSw+fl69lqfw/LH09CjPQnkfO8eTB2ho5UQ0Ul8PUN7UWSxE
# dMAyRxlb4pguj9DKP//GZ888k5VOhOl2GJiZERTFKwygM9tNJIXogpThLwPuf4UC
# yYbh1RgUtwRF8+A4vaK9enGY7BXn/S7s0psAiqwdjTuAaP7QWZgmzuDtrn8oLsKe
# 4AtLyAjRMruD+iM82f/SjLv3QyPf58NaBWJ+cCzlK7I9Y+rIroEga0OJyH5fsBrd
# Gb2fdEEKr7mOCdN0oS+wVHbBkE+U7IZh/9sRL5IDMM4wt4sPXUSzQx0jUM2R1y+d
# +/zNscGnxA7E70A+GToC1DGpaaBJ+XXhm+ho5GoMj+vksSF7hmdYfn8f6CvkFLIW
# 1oGhytowkGvub3XAsDYmsgg7/72+f2wTGN/GbaR5Sa2Lf2GHBWj31HDjQpXonrub
# S7LitkE956+nGijJrWGwoEEYGU7tR5thle0+C2Fa6j56mJJRzT/JROeAiylCcvd5
# st2E6ifu/n16awIDAQABo4IBizCCAYcwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB
# /wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwIAYDVR0gBBkwFzAIBgZngQwB
# BAIwCwYJYIZIAYb9bAcBMB8GA1UdIwQYMBaAFLoW2W1NhS9zKXaaL3WMaiCPnshv
# MB0GA1UdDgQWBBSNZLeJIf5WWESEYafqbxw2j92vDTBaBgNVHR8EUzBRME+gTaBL
# hklodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRSU0E0
# MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3JsMIGQBggrBgEFBQcBAQSBgzCBgDAk
# BggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMFgGCCsGAQUFBzAC
# hkxodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRS
# U0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3J0MA0GCSqGSIb3DQEBCwUAA4IC
# AQANLSN0ptH1+OpLmT8B5PYM5K8WndmzjJeCKZxDbwEtqzi1cBG/hBmLP13lhk++
# kzreKjlaOU7YhFmlvBuYquhs79FIaRk4W8+JOR1wcNlO3yMibNXf9lnLocLqTHbK
# odyhK5a4m1WpGmt90fUCCU+C1qVziMSYgN/uSZW3s8zFp+4O4e8eOIqf7xHJMUpY
# tt84fMv6XPfkU79uCnx+196Y1SlliQ+inMBl9AEiZcfqXnSmWzWSUHz0F6aHZE8+
# RokWYyBry/J70DXjSnBIqbbnHWC9BCIVJXAGcqlEO2lHEdPu6cegPk8QuTA25POq
# aQmoi35komWUEftuMvH1uzitzcCTEdUyeEpLNypM81zctoXAu3AwVXjWmP5UbX9x
# qUgaeN1Gdy4besAzivhKKIwSqHPPLfnTI/KeGeANlCig69saUaCVgo4oa6TOnXbe
# qXOqSGpZQ65f6vgPBkKd3wZolv4qoHRbY2beayy4eKpNcG3wLPEHFX41tOa1DKKZ
# pdcVazUOhdbgLMzgDCS4fFILHpl878jIxYxYaa+rPeHPzH0VrhS/inHfypex2Efq
# HIXgRU4SHBQpWMxv03/LvsEOSm8gnK7ZczJZCOctkqEaEf4ymKZdK5fgi9OczG21
# Da5HYzhHF1tvE9pqEG4fSbdEW7QICodaWQR2EaGndwITHDGCBUwwggVIAgEBMIGG
# MHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsT
# EHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJl
# ZCBJRCBDb2RlIFNpZ25pbmcgQ0ECEATV3B9I6snYUgC6zZqbKqcwCQYFKw4DAhoF
# AKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisG
# AQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcN
# AQkEMRYEFFqoUPswdTPe1y3Uk4SqQoi/dSCqMA0GCSqGSIb3DQEBAQUABIIBAIfC
# HUZlMuavfEdjHjRsyhyvYURkUwRCg45oZKm0Kit65k0BjG691cWo0LmQ/Mp/tgho
# qMqVnk2tkD/3PJkfxvaOOXW7PaELMLgTVfKDVC/3UDFXLDZ4a5NYbMqaNfIot+c/
# KPPOSGjf4yyBdix55F/i2xsyzSS8mbShifj7WKCwx11kTkVGvPHg1UzypQKXjKjw
# MbTMJIq3qaCO5GkY22eMuCkzRiBsRt0pK0/gzn0eYY1OX1godeHeR+TwbNfMW7lm
# UP+RgQSPOjM4TclAP6OLj0xNdqMh0Q9kPYyu2zzSoum6IZioIBCfT7gHP80jAhQu
# QEc2fRJkKbhIedqmIyOhggMgMIIDHAYJKoZIhvcNAQkGMYIDDTCCAwkCAQEwdzBj
# MQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMT
# MkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5n
# IENBAhAKekqInsmZQpAGYzhNhpedMA0GCWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcN
# AQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjIwNTI2MDgyNzM3WjAv
# BgkqhkiG9w0BCQQxIgQg2zm4U5ykaaoMvPitTZH5gOBZIGutYgT0aJ5q6LAyqEsw
# DQYJKoZIhvcNAQEBBQAEggIAPJVeyQI3WQrkLzqQFARV9utIpVf4myKB4xctaIuB
# GTFykj5neEngKed9d7b8EHJUvX34eP7O/HqZvxK3M+f4woW4h8j9Y7RP04ku9bd1
# ZT3VsPpiWyJZ+SSOcSqOmWFv2F9Y3cScKuJFTDEr4dLFhNVwHRHascub7MEyuhGo
# 9W0w65ja3sL/1hnbM2Teki96bHbLrt3ds2wBXm59U27IvVfxn9GtuU8y5F9WILyp
# wxkiYgkY/X1rCrtLMg+WQopCU8/N4r7H45wzs24K4Jc7PEADdXcgkX1PWQvEvmxQ
# xA4jHGUP+BhTD+hYmh+SG0JAQ4qwo+hnAsqzCeosN9kT/9887tkAi8updYFoAYTn
# hCHq4jVXW5pvtjhv7NMQMFmALM8xEp3xl9NxFxaQLZlV1NMwJAbFcJMPcf2TG4Sb
# wt1Xh6ezT28wqwnvBS/oBo2VJpR9hr4J6yQAgM6/C7zXDn49IzSu/sZFnvHHWNgQ
# aOhOPT8f+IZbqsns9ZQIoBzsS+tplevFNEnl41h/LKpStup5fI69+zB2sRvcrvV1
# wrMQyU2SX/ln/aSIpESO77dsiZcr6lFKTndg9NLz7tIyyWq1J9j0iN42lBThNFm6
# BJL4kVtMUn1LbGOh5mzTxk7dSLg37XU7U9moTziMcyG22yLltQxPm4xvIIWdpeWv
# xGc=
# SIG # End signature block
