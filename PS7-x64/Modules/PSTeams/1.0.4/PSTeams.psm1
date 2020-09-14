function Add-TeamsBody {
    [CmdletBinding()]
    param (
        [string] $MessageTitle,
        [string] $ThemeColor,
        [string] $MessageText,
        [string] $MessageSummary,
        [System.Collections.IDictionary[]] $Sections,
        [switch] $HideOriginalBody
    )

    $Body = [ordered] @{
        sections = $Sections
    }
    if ($ThemeColor) {
        $body.themeColor = $ThemeColor
    }
    if ($MessageTitle) {
        $Body.title = $MessageTitle
    }
    if ($HideOriginalBody.IsPresent) {
        $Body.hideOriginalBody = $HideOriginalBody.IsPresent
    }
    if ($MessageSummary -ne '') {
        $Body.summary = $MessageSummary
    } else {
        if ($MessageTitle -ne '') {
            $Body.summary = $MessageTitle
        } elseif ($MessageText -ne '') {
            $Body.summary = $MessageText
        }
    }
    if ($MessageText -ne '') {
        $Body.text = $MessageText
    }
    return $Body | ConvertTo-Json -Depth 6
}
function Convert-Color {
    <#
    .Synopsis
    This color converter gives you the hexadecimal values of your RGB colors and vice versa (RGB to HEX)
    .Description
    This color converter gives you the hexadecimal values of your RGB colors and vice versa (RGB to HEX). Use it to convert your colors and prepare your graphics and HTML web pages.
    .Parameter RBG
    Enter the Red Green Blue value comma separated. Red: 51 Green: 51 Blue: 204 for example needs to be entered as 51,51,204
    .Parameter HEX
    Enter the Hex value to be converted. Do not use the '#' symbol. (Ex: 3333CC converts to Red: 51 Green: 51 Blue: 204)
    .Example
    .\convert-color -hex FFFFFF
    Converts hex value FFFFFF to RGB

    .Example
    .\convert-color -RGB 123,200,255
    Converts Red = 123 Green = 200 Blue = 255 to Hex value

    #>
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName = "RGB", Position = 0)]
        [ValidateScript( { $_ -match '^([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])$' })]
        $RGB,
        [Parameter(ParameterSetName = "HEX", Position = 0)]
        [ValidateScript( { $_ -match '[A-Fa-f0-9]{6}' })]
        [string]
        $HEX
    )
    switch ($PsCmdlet.ParameterSetName) {
        "RGB" {
            if ($null -eq $RGB[2]) {
                Write-Error "Value missing. Please enter all three values seperated by comma."
            }
            $red = [convert]::Tostring($RGB[0], 16)
            $green = [convert]::Tostring($RGB[1], 16)
            $blue = [convert]::Tostring($RGB[2], 16)
            if ($red.Length -eq 1) {
                $red = '0' + $red
            }
            if ($green.Length -eq 1) {
                $green = '0' + $green
            }
            if ($blue.Length -eq 1) {
                $blue = '0' + $blue
            }
            Write-Output $red$green$blue
        }
        "HEX" {
            $red = $HEX.Remove(2, 4)
            $Green = $HEX.Remove(4, 2)
            $Green = $Green.remove(0, 2)
            $Blue = $hex.Remove(0, 4)
            $Red = [convert]::ToInt32($red, 16)
            $Green = [convert]::ToInt32($green, 16)
            $Blue = [convert]::ToInt32($blue, 16)
            Write-Output $red, $Green, $blue
        }
    }
}
function ConvertFrom-Color {
    [alias('Convert-FromColor')]
    [CmdletBinding()]
    param (
        [ValidateScript( {
                if ($($_ -in $Script:RGBColors.Keys -or $_ -match "^#([A-Fa-f0-9]{6})$" -or $_ -eq "") -eq $false) {
                    throw "The Input value is not a valid colorname nor an valid color hex code."
                } else { $true }
            })]
        [alias('Colors')][string[]] $Color,
        [switch] $AsDecimal
    )
    $Colors = foreach ($C in $Color) {
        $Value = $Script:RGBColors."$C"
        if ($C -match "^#([A-Fa-f0-9]{6})$") {
            return $C
        }
        if ($null -eq $Value) {
            return
        }
        $HexValue = Convert-Color -RGB $Value
        Write-Verbose "Convert-FromColor - Color Name: $C Value: $Value HexValue: $HexValue"
        if ($AsDecimal) {
            [Convert]::ToInt64($HexValue, 16)
        } else {
            "#$($HexValue)"
        }
    }
    $Colors
}
Register-ArgumentCompleter -CommandName ConvertFrom-Color -ParameterName Color -ScriptBlock { $Script:RGBColors.Keys }
function Get-Image {
    [CmdletBinding()]
    param(
        [string] $PathToImages,
        [string] $FileName,
        [string] $FileExtension
    )
    Write-Verbose "Get-Image - PathToImages $PathToImages FileName $FileName FileExtension $FileExtension"
    $ImagePath = [IO.Path]::Combine( $PathToImages, "$($FileName)$FileExtension")
    Write-Verbose "Get-Image - ImagePath $ImagePath"
    if (Test-Path $ImagePath) {
        if ($PSEdition -eq 'Core') {
            $Image = [convert]::ToBase64String((Get-Content $ImagePath -AsByteStream))
        } else {
            $Image = [convert]::ToBase64String((Get-Content $ImagePath -Encoding byte))
        }
        Write-Verbose "Get-Image - Image Type: $($Image.GetType())"
        return "data:image/png;base64,$Image"
    }
    return ''
}
function Repair-Text {
    [CmdletBinding()]
    param(
        [string] $Text
    )
    if ($Text -ne $null) {
        $Text = $Text.ToString().Replace('"', '\"').Replace('\', '\\').Replace("`n", '\n\n').Replace("`r", '').Replace("`t", '\t')
        $Text = [System.Text.RegularExpressions.Regex]::Unescape($($Text))
    }
    if ($Text -eq '') { $Text = ' ' }
    return $Text
}
$Script:RGBColors = @{
    "None"                 = $null
    "Black"                = 0, 0, 0
    "Navy"                 = 0, 0, 128
    "DarkBlue"             = 0, 0, 139
    "MediumBlue"           = 0, 0, 205
    "Blue"                 = 0, 0, 255
    "DarkGreen"            = 0, 100, 0
    "Green"                = 0, 128, 0
    "Teal"                 = 0, 128, 128
    "DarkCyan"             = 0, 139, 139
    "DeepSkyBlue"          = 0, 191, 255
    "DarkTurquoise"        = 0, 206, 209
    "MediumSpringGreen"    = 0, 250, 154
    "Lime"                 = 0, 255, 0
    "SpringGreen"          = 0, 255, 127
    "Aqua"                 = 0, 255, 255
    "Cyan"                 = 0, 255, 255
    "MidnightBlue"         = 25, 25, 112
    "DodgerBlue"           = 30, 144, 255
    "LightSeaGreen"        = 32, 178, 170
    "ForestGreen"          = 34, 139, 34
    "SeaGreen"             = 46, 139, 87
    "DarkSlateGray"        = 47, 79, 79
    "DarkSlateGrey"        = 47, 79, 79
    "LimeGreen"            = 50, 205, 50
    "MediumSeaGreen"       = 60, 179, 113
    "Turquoise"            = 64, 224, 208
    "RoyalBlue"            = 65, 105, 225
    "SteelBlue"            = 70, 130, 180
    "DarkSlateBlue"        = 72, 61, 139
    "MediumTurquoise"      = 72, 209, 204
    "Indigo"               = 75, 0, 130
    "DarkOliveGreen"       = 85, 107, 47
    "CadetBlue"            = 95, 158, 160
    "CornflowerBlue"       = 100, 149, 237
    "MediumAquamarine"     = 102, 205, 170
    "DimGray"              = 105, 105, 105
    "DimGrey"              = 105, 105, 105
    "SlateBlue"            = 106, 90, 205
    "OliveDrab"            = 107, 142, 35
    "SlateGray"            = 112, 128, 144
    "SlateGrey"            = 112, 128, 144
    "LightSlateGray"       = 119, 136, 153
    "LightSlateGrey"       = 119, 136, 153
    "MediumSlateBlue"      = 123, 104, 238
    "LawnGreen"            = 124, 252, 0
    "Chartreuse"           = 127, 255, 0
    "Aquamarine"           = 127, 255, 212
    "Maroon"               = 128, 0, 0
    "Purple"               = 128, 0, 128
    "Olive"                = 128, 128, 0
    #"Grey" = 92, 92, 92
    "Gray"                 = 128, 128, 128
    "Grey"                 = 128, 128, 128
    "SkyBlue"              = 135, 206, 235
    "LightSkyBlue"         = 135, 206, 250
    "BlueViolet"           = 138, 43, 226
    "DarkRed"              = 139, 0, 0
    "DarkMagenta"          = 139, 0, 139
    "SaddleBrown"          = 139, 69, 19
    "DarkSeaGreen"         = 143, 188, 143
    "LightGreen"           = 144, 238, 144
    "MediumPurple"         = 147, 112, 219
    "DarkViolet"           = 148, 0, 211
    "PaleGreen"            = 152, 251, 152
    "DarkOrchid"           = 153, 50, 204
    "YellowGreen"          = 154, 205, 50
    "Sienna"               = 160, 82, 45
    "Brown"                = 165, 42, 42
    "DarkGray"             = 169, 169, 169
    "DarkGrey"             = 169, 169, 169
    "LightBlue"            = 173, 216, 230
    "GreenYellow"          = 173, 255, 47
    "PaleTurquoise"        = 175, 238, 238
    "LightSteelBlue"       = 176, 196, 222
    "PowderBlue"           = 176, 224, 230
    "FireBrick"            = 178, 34, 34
    "DarkGoldenrod"        = 184, 134, 11
    "MediumOrchid"         = 186, 85, 211
    "RosyBrown"            = 188, 143, 143
    "DarkKhaki"            = 189, 183, 107
    "Silver"               = 192, 192, 192
    "MediumVioletRed"      = 199, 21, 133
    "IndianRed"            = 205, 92, 92
    "Peru"                 = 205, 133, 63
    "Chocolate"            = 210, 105, 30
    "Tan"                  = 210, 180, 140
    "LightGray"            = 211, 211, 211
    "LightGrey"            = 211, 211, 211
    "Thistle"              = 216, 191, 216
    "Orchid"               = 218, 112, 214
    "Goldenrod"            = 218, 165, 32
    "PaleVioletRed"        = 219, 112, 147
    "Crimson"              = 220, 20, 60
    "Gainsboro"            = 220, 220, 220
    "Plum"                 = 221, 160, 221
    "BurlyWood"            = 222, 184, 135
    "LightCyan"            = 224, 255, 255
    "Lavender"             = 230, 230, 250
    "DarkSalmon"           = 233, 150, 122
    "Violet"               = 238, 130, 238
    "PaleGoldenrod"        = 238, 232, 170
    "LightCoral"           = 240, 128, 128
    "Khaki"                = 240, 230, 140
    "AliceBlue"            = 240, 248, 255
    "Honeydew"             = 240, 255, 240
    "Azure"                = 240, 255, 255
    "SandyBrown"           = 244, 164, 96
    "Wheat"                = 245, 222, 179
    "Beige"                = 245, 245, 220
    "WhiteSmoke"           = 245, 245, 245
    "MintCream"            = 245, 255, 250
    "GhostWhite"           = 248, 248, 255
    "Salmon"               = 250, 128, 114
    "AntiqueWhite"         = 250, 235, 215
    "Linen"                = 250, 240, 230
    "LightGoldenrodYellow" = 250, 250, 210
    "OldLace"              = 253, 245, 230
    "Red"                  = 255, 0, 0
    "Fuchsia"              = 255, 0, 255
    "Magenta"              = 255, 0, 255
    "DeepPink"             = 255, 20, 147
    "OrangeRed"            = 255, 69, 0
    "Tomato"               = 255, 99, 71
    "HotPink"              = 255, 105, 180
    "Coral"                = 255, 127, 80
    "DarkOrange"           = 255, 140, 0
    "LightSalmon"          = 255, 160, 122
    "Orange"               = 255, 165, 0
    "LightPink"            = 255, 182, 193
    "Pink"                 = 255, 192, 203
    "Gold"                 = 255, 215, 0
    "PeachPuff"            = 255, 218, 185
    "NavajoWhite"          = 255, 222, 173
    "Moccasin"             = 255, 228, 181
    "Bisque"               = 255, 228, 196
    "MistyRose"            = 255, 228, 225
    "BlanchedAlmond"       = 255, 235, 205
    "PapayaWhip"           = 255, 239, 213
    "LavenderBlush"        = 255, 240, 245
    "Seashell"             = 255, 245, 238
    "Cornsilk"             = 255, 248, 220
    "LemonChiffon"         = 255, 250, 205
    "FloralWhite"          = 255, 250, 240
    "Snow"                 = 255, 250, 250
    "Yellow"               = 255, 255, 0
    "LightYellow"          = 255, 255, 224
    "Ivory"                = 255, 255, 240
    "White"                = 255, 255, 255

    <# Alternative version
    "darkSlateGray" = 42, 42, 42
    "darkGray" = 163, 163, 163
    "whiteSmoke" = 240, 240, 240
    "whiteSmoke" = 242, 242, 242
    "DeepSkyBlue" = 0, 102, 221
    "DarkSlateGrey" = 38, 38, 38
    "DarkSlateGrey" = 51, 51, 51
    "cornflowerblue" = 0, 102, 153
    "WhiteSmoke" = 248, 248, 248
    "Green" = 0, 130, 0
    "SteelBlue" = 127, 157, 185
    "Red" = 163, 21, 21
    "cornflowerblue" = 43, 145, 175
    "Royalblue" = 46, 117, 181
    #>
}
function ConvertTo-TeamsFact {
    <#
    .SYNOPSIS
    Convert a PSCustomObject or a Hashtable to Teams facts.

    .DESCRIPTION
    Teams facts are name-value pairs. This function helps convert a PSObject or a Hashtable to Teams facts (only one level deep).

    .PARAMETER InputObject
    The Hashtable or PSObject that is output by another cmdlet.

    .EXAMPLE
    Get-ChildItem | Select-Object -First 1 | ConvertTo-TeamsFact

    .EXAMPLE
    @{ Product = 'Microsoft Teams'; Developer = 'Microsoft Corporation'; ReleaseYear = '2018' } | ConvertTo-TeamsFact

    .NOTES
    Ram Iyer (https://ramiyer.me)
    #>

    [CmdletBinding()]
    param (
        # The input object
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        $InputObject
    )
    foreach ($Object in $InputObject) {
        if ($Object -is [System.Collections.IDictionary]) {
            $Facts = foreach ($Key in $Object.Keys) {
                New-TeamsFact -Name $Key -Value $Object.$Key
            }
            #} elseif (($Object -is [int]) -or ($Object -is [long]) -or ($Object -is [string]) -or ($Object -is [char]) -or ($Object -is [bool]) -or ($Object -is [byte]) -or ($Object -is [double]) -or ($Object -is [decimal]) -or ($Object -is [single]) -or ($Object -is [array]) -or ($Object -is [xml])) {
        } elseif ($Object.GetType().Name -match 'bool|byte|char|datetime|decimal|double|xml|float|int|long|sbyte|short|string|timespan|uint|ulong|URI|ushort') {
            # Because PowerShell implicitly converts datatypes to PSObject
            Write-Error -Message 'The input is neither a PSObject nor a Hashtable. Operation aborted.' -Category InvalidData -ErrorAction Stop
        } else {
            # Assumes that the input is a PSObject; anyway there would be an implicit conversion if not caught in the previous block
            $Facts = foreach ($Property in $Object.PsObject.Properties) {
                New-TeamsFact -Name $Property.Name -Value $Property.Value
            }
        }
        $Facts
    }
}
function ConvertTo-TeamsSection {
    <#
    .SYNOPSIS
    Convert an array of PSCustomObject or a Hashtable to separate Teams sections.

    .DESCRIPTION
    Teams sections are chunks of information that appear within a Teams message. This function helps convert an array of PSObject or an array of Hashtables to Teams sections (only one level deep).

    .PARAMETER InputObject
    The Hashtable or PSObject that is output by another cmdlet.

    .EXAMPLE
    Get-ChildItem -Directory | ConvertTo-TeamsSection -SectionTitleProperty Name

    .NOTES
    Ram Iyer (https://ramiyer.me)
    #>
    param (
        # The input object
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        $InputObject,

        # The property to use for title
        [Parameter(Mandatory = $false, Position = 1)]
        [string]
        $SectionTitleProperty
    )

    process {
        #$TotalCount = $InputObject.Count
        #$CurrentCount = 1

        foreach ($Item in $InputObject) {
            $SectionParams = @{
                ActivityDetails = $Item | ConvertTo-TeamsFact
            }
            if ($SectionTitleProperty) {
                $SectionParams.ActivityTitle = "$(($SectionTitleProperty -creplace '([A-Z])', ' $1').Trim()) $($Item.$SectionTitleProperty)"
            }
            New-TeamsSection @SectionParams
        }
    }
}
function New-TeamsActivityImage {
    [CmdletBinding(DefaultParameterSetName = 'Link')]
    [alias('ActivityImageLink', 'TeamsActivityImageLink', 'New-TeamsActivityImageLink', 'ActivityImage', 'TeamsActivityImage')]
    param(
        [Parameter(ParameterSetName = 'Image')][string][ValidateSet('Add', 'Alert', 'Cancel', 'Check', 'Disable', 'Download', 'Info', 'Minus', 'Question', 'Reload', 'None')] $Image,
        [Parameter(ParameterSetName = 'Link')][string] $Link
    )
    if ($Image) {
        if ($Image -ne 'None') {
            $StoredImages = [IO.Path]::Combine("$(Split-Path -Path $PSScriptRoot -Parent)", "Images")
            @{
                ActivityImageLink = Get-Image -PathToImages $StoredImages -FileName $Image -FileExtension '.jpg' # -Verbose
                type              = 'ActivityImage'
            }
        }
    } else {
        @{
            ActivityImageLink = $Link
            Type              = 'ActivityImageLink'
        }
    }
}
function New-TeamsActivitySubtitle {
    [CmdletBinding()]
    [alias('ActivitySubtitle', 'TeamsActivitySubtitle')]
    param(
        [string] $Subtitle
    )
    @{
        ActivitySubtitle = $Subtitle
        Type             = 'ActivitySubtitle'
    }
}
function New-TeamsActivityText {
    [CmdletBinding()]
    [alias('ActivityText', 'TeamsActivityText')]
    param(
        [string] $Text
    )
    @{
        ActivityText = $Text
        Type         = 'ActivityText'
    }
}
function New-TeamsActivityTitle {
    [CmdletBinding()]
    [alias('ActivityTitle', 'TeamsActivityTitle')]
    param(
        [string] $Title
    )
    @{
        ActivityTitle = $Title
        Type          = 'ActivityTitle'
    }

}
function New-TeamsBigImage {
    [alias('TeamsBigImage')]
    [CmdletBinding()]
    param(
        [alias('Url', 'Uri')] $Link,
        [string] $AlternativeText = 'Alternative Text'
    )
    if ($Link) {
        [ordered] @{
            image = "![$AlternativeText]($Link)"
            type  = 'HeroImageWorkaround'
        }
    }
}
function New-TeamsButton {
    [alias('TeamsButton')]
    [CmdletBinding()]
    param (
        [alias('ButtonName')][Parameter(Mandatory)][ValidateNotNull()][ValidateNotNullOrEmpty()][string] $Name,
        [alias('TargetUri', 'Uri', 'Url')][Parameter(Mandatory)][ValidateNotNull()][ValidateNotNullOrEmpty()][string] $Link,
        [alias('ButtonType')][string][ValidateSet('ViewAction', 'TextInput', 'DateInput', 'HttpPost', 'OpenUri')] $Type = 'ViewAction'
    )
    if ($Type -eq 'ViewAction') {
        $Button = [ordered] @{
            '@context' = 'http://schema.org'
            '@type'    = 'ViewAction'
            name       = "$Name"
            target     = @("$Link")
            type       = 'button' # this is only needed for module to process this correctly. JSON doesn't care
        }
    } elseif ($Type -eq 'TextInput') {
        $Button = [ordered] @{
            #'@context' = 'http://schema.org'
            '@type'  = 'ActionCard'
            'Name'   = $Name
            'Inputs' = @(
                @{
                    '@type'       = 'TextInput'
                    'id'          = 'Comment'
                    'isMultiLine' = $true
                    'title'       = 'Enter Your Text Input Here'
                }
            )
            actions  = @(
                @{
                    '@type'  = 'HttpPOST'
                    'Name'   = 'OK'
                    'target' = $Link
                }
            )
            type     = 'button' # this is only needed for module to process this correctly. JSON doesn't care
        }
    } elseif ($Type -eq 'DateInput') {
        $Button = [ordered] @{
            '@type'  = 'ActionCard'
            'Name'   = $Name
            'Inputs' = @(
                @{
                    '@type' = 'DateInput'
                    'id'    = 'dueDate'
                }
            )
            actions  = @(
                @{
                    '@type'  = 'HttpPOST'
                    'Name'   = 'OK'
                    'target' = $Link
                }
            )
            type     = 'button' # this is only needed for module to process this correctly. JSON doesn't care
        }
    } elseif ($Type -eq 'HttpPost') {
        $Button = [ordered] @{
            'name'   = $Name
            '@type'  = 'HttpPOST'
            'Target' = $Link
            type     = 'button' # this is only needed for module to process this correctly. JSON doesn't care
        }
    } elseif ($Type -eq 'OpenUri') {
        $Button = [ordered] @{
            'name'    = $Name
            '@type'   = 'OpenURI'
            'Targets' = @(
                @{
                    'os'  = 'default'
                    'uri' = $Link
                }
            )
            type      = 'button' # this is only needed for module to process this correctly. JSON doesn't care
        }
    }
    return $Button
}
function New-TeamsFact {
    [alias('TeamsFact')]
    [CmdletBinding()]
    param (
        [string] $Name,
        [string] $Value
    )
    $Fact = [ordered] @{
        name  = "$Name"
        value = "$Value"
        type  = 'fact' # this is only needed for module to process this correctly. JSON doesn't care
        #wrap = $false
    }
    return $Fact
}
function New-TeamsImage {
    [alias('TeamsImage')]
    [CmdletBinding()]
    param(
        [alias('Url', 'Uri')] $Link
    )
    if ($Link) {
        [ordered] @{
            image = $Link
            type  = 'image'
        }
    }
}
function New-TeamsList {
    [alias('TeamsList')]
    [CmdletBinding()]
    param(
        [scriptblock] $List,
        [string] $Name
    )

    if ($List) {
        $Output = & $List
        [Array] $Fact = foreach ($_ in $Output) {
            if ($_.Numbered) {
                $Type = '1. '
            } else {
                $Type = "- "
            }
            if ($_.Type -eq 'ListItem') {
                "`t" * $_.Level + $Type + $_.Text
            }
        }
        [string] $Value = $Fact -join "`r" #[System.Environment]::NewLine

        New-TeamsFact -Name $Name -Value $Value
    }
}
function New-TeamsListItem {
    [alias('TeamsListItem')]
    [CmdletBinding()]
    param(
        [string] $Text,
        [int] $Level,
        [switch] $Numbered
    )
    [ordered] @{
        Text     = $Text
        Level    = $Level
        Numbered = $Numbered.IsPresent
        Type     = 'ListItem'
    }
}
function New-TeamsSection {
    [alias('TeamsSection')]
    [CmdletBinding()]
    param (
        [scriptblock] $SectionInput,
        [string] $Title,
        [string] $ActivityTitle,
        [string] $ActivitySubtitle ,
        [string] $ActivityImageLink,
        [string][ValidateSet('Alert', 'Cancel', 'Disable', 'Download', 'Minus', 'Check', 'Add', 'None')] $ActivityImage = 'None',
        [string] $ActivityText,
        [string] $Text,
        [System.Collections.IDictionary[]]$ActivityDetails,
        [System.Collections.IDictionary[]]$Buttons,
        [switch] $StartGroup
    )
    if ($ActivityImage -ne 'None') {
        $StoredImages = [IO.Path]::Combine("$(Split-Path -Path $PSScriptRoot -Parent)", "Images")
        $ActivityImageLink = Get-Image -PathToImages $StoredImages -FileName $ActivityImage -FileExtension '.jpg' # -Verbose
    }

    $ButtonsList = [System.Collections.Generic.List[System.Collections.IDictionary]]::new()
    $FactList = [System.Collections.Generic.List[System.Collections.IDictionary]]::new()
    $ImagesList = [System.Collections.Generic.List[System.Collections.IDictionary]]::new()
    $ImageHeroList = [System.Collections.Generic.List[System.Collections.IDictionary]]::new()

    if ($SectionInput) {
        $SectionOutput = & $SectionInput
        foreach ($_ in $SectionOutput) {
            if ($_.Type -eq 'button') {
                $_.Remove('Type')
                $ButtonsList.Add($_)
            } elseif ($_.Type -eq 'fact') {
                $_.Remove('Type')
                $FactList.Add($_)
            } elseif ($_.Type -eq 'image') {
                $_.Remove('Type')
                $ImagesList.Add($_)
            } elseif ($_.Type -eq 'HeroImageWorkaround') {
                $ImageHeroList.Add($_)
            } elseif ($_.Type -eq 'ActivityTitle') {
                $ActivityTitle = $_.ActivityTitle
            } elseif ($_.Type -eq 'ActivitySubtitle') {
                $ActivitySubtitle = $_.ActivitySubtitle
            } elseif ($_.Type -eq 'ActivityImageLink') {
                $ActivityImageLink = $_.ActivityImageLink
            } elseif ($_.Type -eq 'ActivityText') {
                $ActivityText = $_.ActivityText
            } elseif ($_.Type -eq 'ActivityImage') {
                $ActivityImageLink = $_.ActivityImageLink
            }
        }
    }

    $Section = [ordered] @{ }
    if ($Title) {
        $Section.title = $Title
    }
    if ($ActivityTitle) {
        $Section.activityTitle = "$($ActivityTitle)"
    }
    if ($ActivitySubtitle) {
        $Section.activitySubtitle = "$($ActivitySubtitle)"
    }
    if ($ActivityImageLink) {
        $Section.activityImage = "$($ActivityImageLink)"
    }
    if ($ActivityText) {
        $Section.activityText = "$($ActivityText)"
    }


    # $section.heroImage = @{ image = "https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/Seattle_monorail01_2008-02-25.jpg/1024px-Seattle_monorail01_2008-02-25.jpg" }

    if ($Text -or $ImageHeroList.Count -gt 0) {
        if ($ImageHeroList.Count -gt 0) {
            [string] $TextBundle = @(
                foreach ($_ in $ImageHeroList) {
                    $_.Image
                }
                if ($Text) {
                    $Text
                }
            )
        } else {
            [string] $TextBundle = $Text
        }
        $section.text = $TextBundle
    }
    if ($ImagesList.Count -gt 0) {
        $section.images = @( $ImagesList )
    }
    if ($StartGroup) {
        $Section.startGroup = $startGroup.IsPresent
    }
    if ($null -ne $ActivityDetails -or $FactList.Count -gt 0) {
        $Section.facts = @(
            if ($SectionInput) {
                $FactList
            } else {
                $ActivityDetails
            }
        )
    }
    if ($null -ne $Buttons -or $ButtonsList.Count -gt 0) {
        $Section.potentialAction = @(
            if ($SectionInput) {
                $ButtonsList
            } else {
                $Buttons
            }
        )
    }
    return $Section
}
function Send-TeamsMessage {
    [alias('TeamsMessage')]
    [CmdletBinding()]
    Param (
        [scriptblock] $SectionsInput,
        [alias("TeamsID", 'Url')][Parameter(Mandatory = $true)][string]$Uri,
        [string]$MessageTitle,
        [string]$MessageText,
        [string]$MessageSummary,
        [string]$Color,
        [switch]$HideOriginalBody,
        [System.Collections.IDictionary[]]$Sections,
        [alias('Supress')][bool] $Suppress = $true,
        [switch] $ShowErrors
    )
    if ($SectionsInput) {
        $Output = & $SectionsInput
    } else {
        $Output = $Sections
    }

    if ($Color -or $Color -ne 'None') {
        try {
            $ThemeColor = ConvertFrom-Color -Color $Color
        } catch {
            $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
            Write-Warning "Send-TeamsMessage - Color conversion for $Color failed. Error message: $ErrorMessage"
            $ThemeColor = $null
        }
    }
    # Write-Verbose "Send-TeamsMessage - Color: $Color ColorConverted: $ThemeColor"
    #Write-Verbose "Send-TeamsMessage - Color: $Color Color HEX $ThemeColor"
    $Body = Add-TeamsBody -MessageTitle $MessageTitle `
        -MessageText $MessageText `
        -ThemeColor $ThemeColor `
        -Sections $Output `
        -MessageSummary $MessageSummary `
        -HideOriginalBody:$HideOriginalBody.IsPresent
    try {
        $Execute = Invoke-RestMethod -Uri $Uri -Method Post -Body $Body -ContentType 'application/json; charset=UTF-8' -ErrorAction Stop
    } catch {
        $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
        if ($ShowErrors) {
            Write-Error "Couldn't send message. Error $ErrorMessage"
        } else {
            Write-Warning "Send-TeamsMessage - Couldn't send message. Error: $ErrorMessage"
        }
    }
    if ($Execute -like '*failed*' -or $Execute -like '*error*') {
        if ($ShowErrors) {
            Write-Error "Send-TeamsMessage - Couldn't send message. Execute message: $Execute"
        } else {
            Write-Warning "Send-TeamsMessage - Couldn't send message. Execute message: $Execute"
        }
    }
    Write-Verbose "Send-TeamsMessage - Execute $Execute Body $Body"
    if (-not $Suppress) { return $Body }
}

Register-ArgumentCompleter -CommandName Send-TeamsMessage -ParameterName Color -ScriptBlock { $Script:RGBColors.Keys }
function Send-TeamsMessageBody {
    [alias('TeamsMessageBody')]
    [CmdletBinding()]
    param (
        [alias("TeamsID", 'Url')][Parameter(Mandatory = $true)][string]$Uri,
        [string] $Body,
        [bool] $Supress = $true
    )
    try {
        $Execute = Invoke-RestMethod -Uri $Uri -Method Post -Body $Body -ContentType 'application/json; charset=UTF-8'
    } catch {
        $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
        Write-Warning "Send-TeamsMessageBody - Failed with error message: $ErrorMessage"
    }
    Write-Verbose "Send-TeamsMessage - Execute $Execute Body $Body"
    if (-not $Supress) { return $Body }
}



Export-ModuleMember -Function @('ConvertTo-TeamsFact', 'ConvertTo-TeamsSection', 'New-TeamsActivityImage', 'New-TeamsActivitySubtitle', 'New-TeamsActivityText', 'New-TeamsActivityTitle', 'New-TeamsBigImage', 'New-TeamsButton', 'New-TeamsFact', 'New-TeamsImage', 'New-TeamsList', 'New-TeamsListItem', 'New-TeamsSection', 'Send-TeamsMessage', 'Send-TeamsMessageBody') -Alias @('ActivityImage', 'ActivityImageLink', 'ActivitySubtitle', 'ActivityText', 'ActivityTitle', 'New-TeamsActivityImageLink', 'TeamsActivityImage', 'TeamsActivityImageLink', 'TeamsActivitySubtitle', 'TeamsActivityText', 'TeamsActivityTitle', 'TeamsBigImage', 'TeamsButton', 'TeamsFact', 'TeamsImage', 'TeamsList', 'TeamsListItem', 'TeamsMessage', 'TeamsMessageBody', 'TeamsSection')
# SIG # Begin signature block
# MIIgQAYJKoZIhvcNAQcCoIIgMTCCIC0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUlLSWR0phxNg1L5RTNf4O7nhw
# FxCgghtvMIIDtzCCAp+gAwIBAgIQDOfg5RfYRv6P5WD8G/AwOTANBgkqhkiG9w0B
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
# G5+8xEypTR23NavhJvZMgY2kEXBEKEEDaXs0LoPbn6hMcepR2A4wggZqMIIFUqAD
# AgECAhADAZoCOv9YsWvW1ermF/BmMA0GCSqGSIb3DQEBBQUAMGIxCzAJBgNVBAYT
# AlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2Vy
# dC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IEFzc3VyZWQgSUQgQ0EtMTAeFw0xNDEw
# MjIwMDAwMDBaFw0yNDEwMjIwMDAwMDBaMEcxCzAJBgNVBAYTAlVTMREwDwYDVQQK
# EwhEaWdpQ2VydDElMCMGA1UEAxMcRGlnaUNlcnQgVGltZXN0YW1wIFJlc3BvbmRl
# cjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKNkXfx8s+CCNeDg9sYq
# 5kl1O8xu4FOpnx9kWeZ8a39rjJ1V+JLjntVaY1sCSVDZg85vZu7dy4XpX6X51Id0
# iEQ7Gcnl9ZGfxhQ5rCTqqEsskYnMXij0ZLZQt/USs3OWCmejvmGfrvP9Enh1DqZb
# FP1FI46GRFV9GIYFjFWHeUhG98oOjafeTl/iqLYtWQJhiGFyGGi5uHzu5uc0LzF3
# gTAfuzYBje8n4/ea8EwxZI3j6/oZh6h+z+yMDDZbesF6uHjHyQYuRhDIjegEYNu8
# c3T6Ttj+qkDxss5wRoPp2kChWTrZFQlXmVYwk/PJYczQCMxr7GJCkawCwO+k8IkR
# j3cCAwEAAaOCAzUwggMxMA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYG
# A1UdJQEB/wQMMAoGCCsGAQUFBwMIMIIBvwYDVR0gBIIBtjCCAbIwggGhBglghkgB
# hv1sBwEwggGSMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdpY2VydC5jb20v
# Q1BTMIIBZAYIKwYBBQUHAgIwggFWHoIBUgBBAG4AeQAgAHUAcwBlACAAbwBmACAA
# dABoAGkAcwAgAEMAZQByAHQAaQBmAGkAYwBhAHQAZQAgAGMAbwBuAHMAdABpAHQA
# dQB0AGUAcwAgAGEAYwBjAGUAcAB0AGEAbgBjAGUAIABvAGYAIAB0AGgAZQAgAEQA
# aQBnAGkAQwBlAHIAdAAgAEMAUAAvAEMAUABTACAAYQBuAGQAIAB0AGgAZQAgAFIA
# ZQBsAHkAaQBuAGcAIABQAGEAcgB0AHkAIABBAGcAcgBlAGUAbQBlAG4AdAAgAHcA
# aABpAGMAaAAgAGwAaQBtAGkAdAAgAGwAaQBhAGIAaQBsAGkAdAB5ACAAYQBuAGQA
# IABhAHIAZQAgAGkAbgBjAG8AcgBwAG8AcgBhAHQAZQBkACAAaABlAHIAZQBpAG4A
# IABiAHkAIAByAGUAZgBlAHIAZQBuAGMAZQAuMAsGCWCGSAGG/WwDFTAfBgNVHSME
# GDAWgBQVABIrE5iymQftHt+ivlcNK2cCzTAdBgNVHQ4EFgQUYVpNJLZJMp1KKnka
# g0v0HonByn0wfQYDVR0fBHYwdDA4oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0QXNzdXJlZElEQ0EtMS5jcmwwOKA2oDSGMmh0dHA6Ly9jcmw0
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRENBLTEuY3JsMHcGCCsGAQUF
# BwEBBGswaTAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEG
# CCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRB
# c3N1cmVkSURDQS0xLmNydDANBgkqhkiG9w0BAQUFAAOCAQEAnSV+GzNNsiaBXJuG
# ziMgD4CH5Yj//7HUaiwx7ToXGXEXzakbvFoWOQCd42yE5FpA+94GAYw3+puxnSR+
# /iCkV61bt5qwYCbqaVchXTQvH3Gwg5QZBWs1kBCge5fH9j/n4hFBpr1i2fAnPTgd
# KG86Ugnw7HBi02JLsOBzppLA044x2C/jbRcTBu7kA7YUq/OPQ6dxnSHdFMoVXZJB
# 2vkPgdGZdA0mxA5/G7X1oPHGdwYoFenYk+VVFvC7Cqsc21xIJ2bIo4sKHOWV2q7E
# LlmgYd3a822iYemKC23sEhi991VUQAOSK2vCUcIKSK+w1G7g9BQKOhvjjz3Kr2qN
# e9zYRDCCBs0wggW1oAMCAQICEAb9+QOWA63qAArrPye7uhswDQYJKoZIhvcNAQEF
# BQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UE
# CxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJ
# RCBSb290IENBMB4XDTA2MTExMDAwMDAwMFoXDTIxMTExMDAwMDAwMFowYjELMAkG
# A1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRp
# Z2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgQXNzdXJlZCBJRCBDQS0xMIIB
# IjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6IItmfnKwkKVpYBzQHDSnlZU
# XKnE0kEGj8kz/E1FkVyBn+0snPgWWd+etSQVwpi5tHdJ3InECtqvy15r7a2wcTHr
# zzpADEZNk+yLejYIA6sMNP4YSYL+x8cxSIB8HqIPkg5QycaH6zY/2DDD/6b3+6LN
# b3Mj/qxWBZDwMiEWicZwiPkFl32jx0PdAug7Pe2xQaPtP77blUjE7h6z8rwMK5nQ
# xl0SQoHhg26Ccz8mSxSQrllmCsSNvtLOBq6thG9IhJtPQLnxTPKvmPv2zkBdXPao
# 8S+v7Iki8msYZbHBc63X8djPHgp0XEK4aH631XcKJ1Z8D2KkPzIUYJX9BwSiCQID
# AQABo4IDejCCA3YwDgYDVR0PAQH/BAQDAgGGMDsGA1UdJQQ0MDIGCCsGAQUFBwMB
# BggrBgEFBQcDAgYIKwYBBQUHAwMGCCsGAQUFBwMEBggrBgEFBQcDCDCCAdIGA1Ud
# IASCAckwggHFMIIBtAYKYIZIAYb9bAABBDCCAaQwOgYIKwYBBQUHAgEWLmh0dHA6
# Ly93d3cuZGlnaWNlcnQuY29tL3NzbC1jcHMtcmVwb3NpdG9yeS5odG0wggFkBggr
# BgEFBQcCAjCCAVYeggFSAEEAbgB5ACAAdQBzAGUAIABvAGYAIAB0AGgAaQBzACAA
# QwBlAHIAdABpAGYAaQBjAGEAdABlACAAYwBvAG4AcwB0AGkAdAB1AHQAZQBzACAA
# YQBjAGMAZQBwAHQAYQBuAGMAZQAgAG8AZgAgAHQAaABlACAARABpAGcAaQBDAGUA
# cgB0ACAAQwBQAC8AQwBQAFMAIABhAG4AZAAgAHQAaABlACAAUgBlAGwAeQBpAG4A
# ZwAgAFAAYQByAHQAeQAgAEEAZwByAGUAZQBtAGUAbgB0ACAAdwBoAGkAYwBoACAA
# bABpAG0AaQB0ACAAbABpAGEAYgBpAGwAaQB0AHkAIABhAG4AZAAgAGEAcgBlACAA
# aQBuAGMAbwByAHAAbwByAGEAdABlAGQAIABoAGUAcgBlAGkAbgAgAGIAeQAgAHIA
# ZQBmAGUAcgBlAG4AYwBlAC4wCwYJYIZIAYb9bAMVMBIGA1UdEwEB/wQIMAYBAf8C
# AQAweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwgYEGA1UdHwR6MHgwOqA4oDaG
# NGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RD
# QS5jcmwwOqA4oDaGNGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFz
# c3VyZWRJRFJvb3RDQS5jcmwwHQYDVR0OBBYEFBUAEisTmLKZB+0e36K+Vw0rZwLN
# MB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3zbcgPMA0GCSqGSIb3DQEBBQUA
# A4IBAQBGUD7Jtygkpzgdtlspr1LPUukxR6tWXHvVDQtBs+/sdR90OPKyXGGinJXD
# UOSCuSPRujqGcq04eKx1XRcXNHJHhZRW0eu7NoR3zCSl8wQZVann4+erYs37iy2Q
# wsDStZS9Xk+xBdIOPRqpFFumhjFiqKgz5Js5p8T1zh14dpQlc+Qqq8+cdkvtX8JL
# FuRLcEwAiR78xXm8TBJX/l/hHrwCXaj++wc4Tw3GXZG5D2dFzdaD7eeSDY2xaYxP
# +1ngIw/Sqq4AfO6cQg7PkdcntxbuD8O9fAqg7iwIVYUiuOsYGk38KiGtSTGDR5V3
# cdyxG0tLHBCcdxTBnU8vWpUIKRAmMYIEOzCCBDcCAQEwgYYwcjELMAkGA1UEBhMC
# VVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0
# LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIENvZGUgU2ln
# bmluZyBDQQIQBNXcH0jqydhSALrNmpsqpzAJBgUrDgMCGgUAoHgwGAYKKwYBBAGC
# NwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU74xn8/rl
# b47GLZYE0uwL863DiZswDQYJKoZIhvcNAQEBBQAEggEAs8yfqTVLWf++5M9AVv0V
# ulJe80JfQCzThQlU0Fw7PO2MC7NWu+CVyL9gXNNIOB8BKUB17OMHgpEPjDl/r89h
# SUK45DZxzBK9JMz4fEbZ/B8QO6ccq7MSfwWWgDdwniqIZ5Lqb5sO/KeLTNPVB62R
# RAmpMDaIF3YFk6/WT2VjZWRVT+QnE6yeMSNjtGRIV/mqoAJ2guOFDY1datN8gGxe
# 9WQY3w9uE86L9TmnGXCdTyj5Xpczx9NsXC5uE6PVQIfW32AJKLELFKus2/pkS77/
# ZTRZSA+1OUl3eaoLoCHbDe2MSPV8XHHx8Sewn4zajz8h6z14xASlbD+POiTUv4bL
# L6GCAg8wggILBgkqhkiG9w0BCQYxggH8MIIB+AIBATB2MGIxCzAJBgNVBAYTAlVT
# MRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5j
# b20xITAfBgNVBAMTGERpZ2lDZXJ0IEFzc3VyZWQgSUQgQ0EtMQIQAwGaAjr/WLFr
# 1tXq5hfwZjAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAc
# BgkqhkiG9w0BCQUxDxcNMjAwNzI5MTkxMjAzWjAjBgkqhkiG9w0BCQQxFgQUis9V
# aNul71nxQt0qE4AGMvVXTaAwDQYJKoZIhvcNAQEBBQAEggEAk8y6xhmL/QfyGltt
# BtF69STZn45b4LdNIA2j5G8rhPvgbByLIHJLZYHOMz0nZLTZeX2dM+a+sqz9b/FR
# GRaofY5OQVZFxa1a8SSbnDHHAHVSdBoHfR8kYyzT3YqsZB+GUQbxCYejD9KTNJmE
# KMth2IAfygAWXzsGgqaOm3no9zvJi3xsnOdR7G0fTrmKS+HTLHKuuwKekG0mPoMF
# yc/pXpCSjZQ/mo2gd4N1a5pp3InF+TwHO5Y+HYQUNatvrsikg4jNFdKK1y2e9pxS
# W4eFanG9TyjwrjWx7Ru0MI57cHh6XNcGnMlDnkul9y7kkyaHuU2Ap0G1YiXsdYfV
# Vjacxw==
# SIG # End signature block
