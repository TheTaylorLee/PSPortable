Function Install-Font {
    [CmdletBinding()]
    [Alias('font')]
    Param ()
    Start-Process "$PSScriptRoot\font\Meslo LG M Regular Nerd Font Complete Mono.ttf"
}