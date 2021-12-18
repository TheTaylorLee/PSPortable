function reset-colors {
    #Set Colors
    [Console]::ResetColor()
    Set-PSReadLineOption -Colors @{ Command = "`e[97m" }
    Set-PSReadLineOption -Colors @{ Comment = "`e[32m" }
    Set-PSReadLineOption -Colors @{ ContinuationPrompt = "`e[37m" }
    Set-PSReadLineOption -Colors @{ Emphasis = "`e[96m" }
    Set-PSReadLineOption -Colors @{ Error = "`e[91m" }
    Set-PSReadLineOption -Colors @{ Keyword = "`e[92m" }
    Set-PSReadLineOption -Colors @{ ListPredictionSelected = "`e[48;5;238m" }
    Set-PSReadLineOption -Colors @{ Member = "`e[97m" }
    Set-PSReadLineOption -Colors @{ Number = "`e[97m" }
    Set-PSReadLineOption -Colors @{ Operator = "`e[90m" }
    Set-PSReadLineOption -Colors @{ Parameter = "`e[90m" }
    Set-PSReadLineOption -Colors @{ Selection = "`e[30;47m" }
    Set-PSReadLineOption -Colors @{ String = "`e[36m" }
    Set-PSReadLineOption -Colors @{ Type = "`e[37m" }
    Set-PSReadLineOption -Colors @{ Variable = "`e[92m" }
    Set-PSReadLineOption -Colors @{ ListPrediction = "`e[38;2;39;255;0m" }
    Set-PSReadLineOption -Colors @{ InlinePrediction = "`e[38;2;133;193;233m" }
}