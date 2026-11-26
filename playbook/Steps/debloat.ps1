# config-content-delivery
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'ContentDeliveryAllowed' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'FeatureManagementEnabled' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SubscribedContentEnabled' 0

Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'RemediationRequired' 0

Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'OemPreInstalledAppsEnabled' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'PreInstalledAppsEnabled' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'PreInstalledAppsEverEnabled' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SilentInstalledAppsEnabled' 0

Set-RegistryValue 'HKCU\Software\Microsoft\Windows\CurrentVersion\SystemSettings\AccountNotifications' 'EnableAccountNotifications' 0

Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SubscribedContent-310093Enabled' 0

Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SubscribedContent-338393Enabled' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SubscribedContent-353694Enabled' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SubscribedContent-353696Enabled' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SystemPaneSuggestionsEnabled' 0

Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SubscribedContent-338387Enabled' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'RotatingLockScreenOverlayEnabled' 0

Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SubscribedContent-338388Enabled' 0

Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SubscribedContent-338389Enabled' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SoftLandingEnabled' 0

# disable-reserved-storage
Invoke-Program 'DISM.exe' '/Online /Set-ReservedStorageState /State:Disabled' -IgnoreErrors

# disable-scheduled-tasks
Set-ScheduledTaskState '\Microsoft\Windows\Application Experience\PcaPatchDbTask' -Enabled $false -IgnoreErrors

Set-ScheduledTaskState '\Microsoft\Windows\AppxDeploymentClient\UCPD velocity' -Enabled $false -IgnoreErrors

Set-ScheduledTaskState '\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector' -Enabled $false -IgnoreErrors

Set-ScheduledTaskState '\Microsoft\Windows\Customer Experience Improvement Program\Consolidator' -Enabled $false -IgnoreErrors
Set-ScheduledTaskState '\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip' -Enabled $false -IgnoreErrors

Set-ScheduledTaskState '\Microsoft\Windows\Flighting\FeatureConfig\UsageDataReporting' -Enabled $false -IgnoreErrors

Remove-RegistryValue 'HKLM\System\CurrentControlSet\Control\Ubpm' 'CriticalMaintenance_UsageDataReporting'

# hide-unused-security-pages
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Family options' 'UILockdown' 1
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device performance and health' 'UILockdown' 1
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Account protection' 'UILockdown' 1

# config-storage-sense
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' '01' 1

Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' '1024' 1

Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' '2048' 30

Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' '04' 1

Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' '32' 0

Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' '02' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' '128' 0

Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' '08' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' '256' 0

Set-ScheduledTaskState '\Microsoft\Windows\DiskCleanup\SilentCleanup' -Enabled $true
