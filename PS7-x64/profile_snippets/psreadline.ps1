Set-PSReadLineOption -BellStyle None -EditMode Windows
Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete

#Configure PSReadline Intellisense
$query = Get-Module PSReadLine
if ($query.Version -le "2.2") {
    Install-Module psreadline -AllowPrerelease -AllowClobber -Force
}

Function Set-PSReadlineIntellisenseOptions {

    #Set viewStyle based on powershell version requirements
    if ($psversiontable.psversion.major -ge 7 ) {
        Set-PSReadLineOption -PredictionViewStyle ListView
    }
    else {
        Set-PSReadLineOption -PredictionViewStyle InlineView
    }
    #Set prediction source for intellisense
    try {
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    }
    catch {
        Set-PSReadLineOption -PredictionSource History
    }
}
Set-PSReadlineIntellisenseOptions

Set-PSReadLineKeyHandler -Key F12 `
    -BriefDescription History `
    -LongDescription 'Show command history' `
    -ScriptBlock {
    $pattern = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$pattern, [ref]$null)
    if ($pattern) {
        $pattern = [regex]::Escape($pattern)
    }

    $history = [System.Collections.ArrayList]@(
        $last = ''
        $lines = ''
        foreach ($line in [System.IO.File]::ReadLines((Get-PSReadLineOption).HistorySavePath)) {
            if ($line.EndsWith('`')) {
                $line = $line.Substring(0, $line.Length - 1)
                $lines = if ($lines) {
                    "$lines`n$line"
                }
                else {
                    $line
                }
                continue
            }

            if ($lines) {
                $line = "$lines`n$line"
                $lines = ''
            }

            if (($line -cne $last) -and (!$pattern -or ($line -match $pattern))) {
                $last = $line
                $line
            }
        }
    )
    $history.Reverse()

    $command = $history | Out-GridView -Title 'Select a command to repeat' -PassThru
    if ($command) {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert(($command -join "`n"))
    }
}