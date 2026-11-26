# drivers
Set-ServiceStartup 'GpuEnergyDrv' 4
Set-ServiceStartup 'NetBT' 4
Set-ServiceStartup 'Telemetry' 4

# components
Remove-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' 'SecurityHealth'

Set-RegistryValue 'HKLM\SYSTEM\CurrentControlSet\Control\CI\Policy' 'VerifiedAndReputablePolicyState' 0
