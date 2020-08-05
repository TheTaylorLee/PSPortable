Function Get-MailboxScaleReport {

    <#
    .DESCRIPTION
    Get a mailbox report to help with troubleshooting where a mailbox may have exceeded outlook limits

    .PARAMETER MailboxAliases
    Array of aliases for mailboxes to pull a report from if not all

    .PARAMETER Path
    Where to export the excel file to

    .EXAMPLE
    Gets a report for all mailboxes

    Get-MailboxScaleReport -Path C:\report.xlsx

    .EXAMPLE
    Gets a report for one mailbox

    Get-MailboxScaleReport -Path C:\report.xlsx -MailboxAliases JSmith

    .EXAMPLE
    Gets a report for some but not all mailboxes

    Get-MailboxScaleReport -Path C:\report.xlsx -MailboxAliases JOSmith, JASmith, SSmith

    .NOTES
    Must have the Exchange module loaded
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]$Path,
        [Parameter(Mandatory = $false)]$MailboxAliases
    )

    $ErrorActionPreference = 'silentlycontinue'

    if ($null -eq $MailboxAliases) {
        $MailboxAliases1 = get-mailbox | Select-Object alias | Sort-Object alias
        $MailboxAliases2 = $MailboxAliases1.alias

        foreach ($MailboxAlias in $MailboxAliases2) {
            $Mailfolderstats = Get-MailboxFolderStatistics $MailboxAlias | Select-Object *
            $FolderCount = ($Mailfolderstats | Select-Object Name).count
            $FolderCount | Export-Excel -WorksheetName "$MailboxAlias" -Path "$Path" -FreezeTopRow -TableName "Folder Count" -AutoSize -Title "Folder Count" -TitleSize 11 -TitleBold
            $Mailboxstats = Get-MailboxStatistics $MailboxAlias | Select-Object Totalitemsize, itemcount
            $Mailboxstats | Export-Excel -WorksheetName "$MailboxAlias" -Path "$Path" -FreezeTopRow -TableName "$MailboxAlias MailboxSize" -AutoSize -Title "MailboxSize" -TitleSize 11 -TitleBold  -StartRow 4
            $Mailfolderstats | Select-Object Name, FolderandSubFolderSize, ItemsinFolderandSubfolders | Export-Excel -WorksheetName "$MailboxAlias" -Path "$Path" -FreezeTopRow -TableName "Folders" -AutoSize -StartColumn 4
        }
    }

    else {
        foreach ($MailboxAlias in $MailboxAliases) {
            $Mailfolderstats = Get-MailboxFolderStatistics $MailboxAlias | Select-Object *
            $FolderCount = ($Mailfolderstats | Select-Object Name).count
            $FolderCount | Export-Excel -WorksheetName "$MailboxAlias" -Path "$Path" -FreezeTopRow -TableName "Folder Count" -AutoSize -Title "Folder Count" -TitleSize 11 -TitleBold
            $Mailboxstats = Get-MailboxStatistics $MailboxAlias | Select-Object Totalitemsize, itemcount
            $Mailboxstats | Export-Excel -WorksheetName "$MailboxAlias" -Path "$Path" -FreezeTopRow -TableName "$MailboxAlias MailboxSize" -AutoSize -Title "MailboxSize" -TitleSize 11 -TitleBold  -StartRow 4
            $Mailfolderstats | Select-Object Name, FolderandSubFolderSize, ItemsinFolderandSubfolders | Export-Excel -WorksheetName "$MailboxAlias" -Path "$Path" -FreezeTopRow -TableName "Folders" -AutoSize -StartColumn 4
        }
    }

    $ErrorActionPreference = 'continue'
}