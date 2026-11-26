#Requires -RunAsAdministrator

Disable-NetAdapterBinding -Name "*" -ComponentID ms_msclient, ms_server, ms_lltdio, ms_rspndr | Out-Null

$interfaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces" -Recurse | Where-Object { $_.GetValue("NetbiosOptions") -ne $null }
foreach ($interface in $interfaces) {
    Set-ItemProperty -Path $interface.PSPath -Name "NetbiosOptions" -Value 2 | Out-Null
}

Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Public

Get-NetFirewallRule | Where-Object {
    ($_.Group -eq "@FirewallAPI.dll,-28502" -or $_.Group -eq "@FirewallAPI.dll,-32752") -or
    ($_.DisplayGroup -eq "File and Printer Sharing" -or $_.DisplayGroup -eq "Network Discovery") -and
    $_.Profile -like "*Private*"
} | Disable-NetFirewallRule
