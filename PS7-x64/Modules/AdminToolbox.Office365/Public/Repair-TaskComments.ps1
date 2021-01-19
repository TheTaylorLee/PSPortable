Function Repair-TaskComments {
    <#
    .DESCRIPTION
    This functions purpose is to resolve an issue where task comments dissapear for tasks in Teams. This may or may not resolve the issue. This function applies when the team does not show nested under the groups folder in outlook. If the team is not visible in outlook, then the comments will dissapear in teams. Run this function to resolve the group not being visible in teams and restart outlook after awhile. If the issue continues then further troubleshooting is required.

    .EXAMPLE
    Running the function without specifying the identity will deliver a grid view to select the group from, and populate the parameter that way.

    Repair-TaskComments

    .EXAMPLE
    Specifying the identity parameter will run the function without delivering a Grid View for selecting the identity. This is faster if you already know the team identity

    Repair-TaskComments -identity groupname@companyname.com

    .NOTES
    Requires the ExchangeOnline module be installed, imported, and Connected.
    #>

    [Cmdletbinding()]
    Param (
        [Parameter(Mandatory = $false)]$identity
    )

    if ($null -eq $identity) {
        $ident = Get-Unifiedgroup | Out-GridView -PassThru -Title 'Select the group that this issue is being resolved for'
        set-unifiedgroup -Identity $ident.primarysmtpaddress -HiddenFromExchangeClientsEnabled:$false
    }
    else {
        set-unifiedgroup -Identity $identity -HiddenFromExchangeClientsEnabled:$false
    }
}