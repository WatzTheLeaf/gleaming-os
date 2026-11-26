# restore-old-context-menu
Set-RegistryValue 'HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32' '' '' String

# show-more-pins
Set-RegistryValue 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_Layout' 1

# no-recommendations-start-menu
Set-RegistryValue 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_IrisRecommendations' 0
Set-RegistryValue 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_AccountNotifications' 0

# disable-nearby-sharing
Set-RegistryValue 'HKCU\Software\Microsoft\Windows\CurrentVersion\CDP\SettingsPage' 'BluetoothLastDisabledNearShare' 0
Set-RegistryValue 'HKCU\Software\Microsoft\Windows\CurrentVersion\CDP' 'NearShareChannelUserAuthzPolicy' 0
Set-RegistryValue 'HKCU\Software\Microsoft\Windows\CurrentVersion\CDP' 'CdpSessionUserAuthzPolicy' 1

# config-autorun
Set-RegistryValue 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers' 'DisableAutoplay' 1
Set-RegistryValue 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlersDefaultSelection\CameraAlternate' 'MSTakeNoAction' '' None
Set-RegistryValue 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlersDefaultSelection\StorageOnArrival' 'MSTakeNoAction' '' None
Set-RegistryValue 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\UserChosenExecuteHandlers\CameraAlternate\ShowPicturesOnArrival' 'MSTakeNoAction' '' None
Set-RegistryValue 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\UserChosenExecuteHandlers\StorageOnArrival' 'MSTakeNoAction' '' None

# decrease-shutdown-time
Set-RegistryValue 'HKCU\Control Panel\Desktop' 'HungAppTimeout' '2000' String
Set-RegistryValue 'HKCU\Control Panel\Desktop' 'WaitToKillAppTimeOut' '2000' String
Set-RegistryValue 'HKLM\SYSTEM\CurrentControlSet\Control' 'WaitToKillServiceTimeout' '2000' String

# disable-startup-delay
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize' 'StartupDelayInMSec' 0

# crash-control-qol
Set-RegistryValue 'HKLM\SYSTEM\CurrentControlSet\Control\CrashControl' 'AutoReboot' 0
Set-RegistryValue 'HKLM\SYSTEM\CurrentControlSet\Control\CrashControl' 'CrashDumpEnabled' 0
Set-RegistryValue 'HKLM\SYSTEM\CurrentControlSet\Control\CrashControl' 'LogEvent' 0
Set-RegistryValue 'HKLM\SYSTEM\CurrentControlSet\Control\CrashControl' 'DisplayParameters' 1
Set-RegistryValue 'HKLM\SYSTEM\CurrentControlSet\Control\CrashControl\StorageTelemetry' 'DeviceDumpEnabled' 0

# disable-wpbt
Set-RegistryValue 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager' 'DisableWpbtExecution' 1
