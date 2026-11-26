# disable-uac-secure-desktop
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'PromptOnSecureDesktop' 0

# alt-tab-open-windows
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'MultiTaskingAltTabFilter' 3

# disable-aero-shake
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'DisallowShaking' 1

# disable-low-disk-warning
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoLowDiskSpaceChecks' 1

# disable-menu-delay
Set-RegistryValue 'HKCU\Control Panel\Desktop' 'MenuShowDelay' '0' String

# disable-network-location-wizard
Add-RegistryKey 'HKLM\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff'

# set-unpinned-notification-items
Stop-Process -Name 'explorer' -Force

Set-RegistryValue 'HKCU\Control Panel\Quick Actions\Control Center\Unpinned' 'Microsoft.QuickAction.Cast' '' None
Set-RegistryValue 'HKCU\Control Panel\Quick Actions\Control Center\Unpinned' 'Microsoft.QuickAction.NearShare' '' None
Set-RegistryValue 'HKCU\Control Panel\Quick Actions\Control Center\QuickActionsStateCapture' 'Toggles' 'Toggles,Microsoft.QuickAction.BlueLightReduction:false,Microsoft.QuickAction.Accessibility:false,Microsoft.QuickAction.ProjectL2:false' String
