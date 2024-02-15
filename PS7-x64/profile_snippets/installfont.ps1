Function Install-Font {
    [CmdletBinding()]
    [Alias('font')]
    Param ()
    Start-Process "$PSScriptRoot\font\MesloLGMNerdFontMono-Regular.ttf"
}