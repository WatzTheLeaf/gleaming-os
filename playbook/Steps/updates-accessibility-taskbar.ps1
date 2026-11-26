# disallow-theme-changes
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes' 'ThemeChangesMousePointers' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes' 'ThemeChangesDesktopIcons' 0

# disable-nagging
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'NoAUAsDefaultShutdownOption' 1

Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' 'HideMCTLink' 1

# disable-insider
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'ManagePreviewBuilds' 1
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'ManagePreviewBuildsPolicyValue' 0
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds' 'AllowBuildPreview' 0
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds' 'EnableConfigFlighting' 0
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds' 'EnableExperimentation' 0
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility' 'HideInsiderPage' 1

# disable-msrt-telemetry
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\MRT' 'DontReportInfectionInformation' 1
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\RemovalTools\MpGears' 'HeartbeatTrackingIndex' 0
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\RemovalTools\MpGears' 'SpyNetReportingLocation' '' MultiString

# disable-feature-updates
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'TargetReleaseVersion' 1
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'ProductVersion' 'Windows 11' String
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'TargetReleaseVersionInfo' (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').DisplayVersion String

# disable-auto-updates
if (Test-Option 'auto-updates-disable') { Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'AUOptions' 2 }

Remove-RegistryKey 'HKLM\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\DevHomeUpdate'
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\DevHomeUpdate' 'workCompleted' 1
Remove-RegistryKey 'HKLM\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate'
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\OutlookUpdate' 'workCompleted' 1

# disable-auto-reboot
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'AUPowerManagement' 0

Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'NoAutoRebootWithLoggedOnUsers' 1

# disable-delivery-optimization
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' 'DODownloadMode' 0

# disable-always-read-section
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Ease of Access' 'selfscan' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Ease of Access' 'selfvoice' 0

# disable-annoying-features-shortcuts
Set-RegistryValue 'HKCU\Control Panel\Accessibility\HighContrast' 'Flags' 0
Set-RegistryValue 'HKCU\Control Panel\Accessibility\Keyboard Response' 'Flags' 0
Set-RegistryValue 'HKCU\Control Panel\Accessibility\MouseKeys' 'Flags' 0
Set-RegistryValue 'HKCU\Control Panel\Accessibility\StickyKeys' 'Flags' 0
Set-RegistryValue 'HKCU\Control Panel\Accessibility\ToggleKeys' 'Flags' 0

Remove-RegistryKey 'HKCU\Control Panel\Input Method\Hot Keys\00000104'
Set-RegistryValue 'HKCU\Keyboard Layout\Toggle' 'Layout Hotkey' 3
Set-RegistryValue 'HKCU\Keyboard Layout\Toggle' 'Language Hotkey' 3
Set-RegistryValue 'HKCU\Keyboard Layout\Toggle' 'Hotkey' 3

Set-RegistryValue 'HKCU\Software\Microsoft\Narrator\NoRoam' 'WinEnterLaunchEnabled' 0

# disable-making-touch-easier
Set-RegistryValue 'HKCU\Control Panel\Accessibility\SlateLaunch' 'LaunchAT' 0

# disable-warning-sounds
Set-RegistryValue 'HKCU\Control Panel\Accessibility' 'Warning Sounds' 0
Set-RegistryValue 'HKCU\Control Panel\Accessibility' 'Sound on Activation' 0

Set-RegistryValue 'HKCU\Control Panel\Accessibility\SoundSentry' 'WindowsEffect' '0' String

# cmd-win-x
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'DontUsePowerShellOnWinX' 1

# disable-cloud-optimized-content
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableCloudOptimizedContent' 1

# disable-desktop-peek
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'DisablePreviewDesktop' 1

# disable-news-and-interests
Stop-Process -Name 'explorer' -Force
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds' 'EnableFeeds' 0
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Dsh' 'AllowNewsAndInterests' 0
