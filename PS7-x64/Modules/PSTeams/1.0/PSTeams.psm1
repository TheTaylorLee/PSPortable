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
function New-TeamsActivityImage {
    [CmdletBinding()]
    [alias('ActivityImageLink', 'TeamsActivityImageLink', 'New-TeamsActivityImageLink', 'ActivityImage', 'TeamsActivityImage')]
    param(
        [string][ValidateSet('Alert', 'Cancel', 'Disable', 'Download', 'Minus', 'Check', 'Add', 'None')] $Image,
        [string] $Link
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
        [bool] $Supress = $true,
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
        $Execute = Invoke-RestMethod -Uri $Uri -Method Post -Body $Body -ContentType 'application/json; charset=UTF-8'
    } catch {
        $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
        if ($ShowErrors) {
            Write-Error "Couldn't send message. Error $ErrorMessage"
        } else {
            Write-Warning "Send-TeamsMessage - Couldn't send message. Error: $ErrorMessage"
        }
    }
    Write-Verbose "Send-TeamsMessage - Execute $Execute Body $Body"
    if (-not $Supress) { return $Body }
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



Export-ModuleMember -Function @('New-TeamsActivityImage', 'New-TeamsActivitySubtitle', 'New-TeamsActivityText', 'New-TeamsActivityTitle', 'New-TeamsBigImage', 'New-TeamsButton', 'New-TeamsFact', 'New-TeamsImage', 'New-TeamsList', 'New-TeamsListItem', 'New-TeamsSection', 'Send-TeamsMessage', 'Send-TeamsMessageBody') -Alias @('ActivityImage', 'ActivityImageLink', 'ActivitySubtitle', 'ActivityText', 'ActivityTitle', 'New-TeamsActivityImageLink', 'TeamsActivityImage', 'TeamsActivityImageLink', 'TeamsActivitySubtitle', 'TeamsActivityText', 'TeamsActivityTitle', 'TeamsBigImage', 'TeamsButton', 'TeamsFact', 'TeamsImage', 'TeamsList', 'TeamsListItem', 'TeamsMessage', 'TeamsMessageBody', 'TeamsSection')