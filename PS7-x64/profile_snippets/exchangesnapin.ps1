#Imports the Exchange Snapins if they exists by initiating a PSSession
$t1 = Test-Path "C:\Program Files\Microsoft\Exchange Server"
$t2 = Test-Path "C:\Program Files (x86)\Microsoft\Exchange Server"

if ($t1 -or $t2 -eq $true) {

    Write-Host "Importing Exchange Module into the ps7 session" -ForegroundColor Green
    $fqdn = [System.Net.Dns]::GetHostByName(($env:computerName)).hostname
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$fqdn/PowerShell/
    Import-PSSession $Session -DisableNameChecking
}