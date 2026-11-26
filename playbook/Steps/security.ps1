# block-anonymous-enum-sam
Set-RegistryValue 'HKLM\SYSTEM\CurrentControlSet\Control\Lsa' 'RestrictAnonymousSAM' 1

# disable-remote-assistance
Set-RegistryValue 'HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance' 'fAllowFullControl' 0
Set-RegistryValue 'HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance' 'fAllowToGetHelp' 0

Get-NetFirewallRule -Group '@FirewallAPI.dll,-33002' -EA 0 | Disable-NetFirewallRule
