# config-windows-ink-workspace
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\PenWorkspace' 'PenWorkspaceAppSuggestionsEnabled' 0

# disable-mouse-accel
Set-RegistryValue 'HKCU\Control Panel\Mouse' 'MouseSpeed' '0' String
Set-RegistryValue 'HKCU\Control Panel\Mouse' 'MouseThreshold1' '0' String
Set-RegistryValue 'HKCU\Control Panel\Mouse' 'MouseThreshold2' '0' String

# disable-settings-tips
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\PolicyManager\default\Settings\AllowOnlineTips' 'value' 0
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'AllowOnlineTips' 0

# disable-spell-checking
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\TabletTip\1.7' 'EnableAutocorrection' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\TabletTip\1.7' 'EnableDoubleTapSpace' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\TabletTip\1.7' 'EnablePredictionSpaceInsertion' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\TabletTip\1.7' 'EnableSpellchecking' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\TabletTip\1.7' 'EnableTextPrediction' 0

# disable-store-auto-updates
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate' 'AutoDownload' 2

# disable-touch-keyboard-features
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\TabletTip\1.7' 'EnableAutoShiftEngage' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\TabletTip\1.7' 'EnableKeyAudioFeedback' 0

# disable-touch-visual-feedback
Set-RegistryValue 'HKCU\Control Panel\Cursors' 'GestureVisualization' 0
Set-RegistryValue 'HKCU\Control Panel\Cursors' 'ContactVisualization' 0

# disable-usb-issues-notifications
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Shell\USB' 'NotifyOnUsbErrors' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Shell\USB' 'NotifyOnWeakCharger' 0

# disable-windows-feedback
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Siuf\Rules' 'NumberOfSIUFInPeriod' 0
Remove-RegistryValue 'HKCU\SOFTWARE\Microsoft\Siuf\Rules' 'PeriodInNanoSeconds'
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' 'DoNotShowFeedbackNotifications' 1

# disable-windows-spotlight
Set-RegistryValue 'HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsSpotlightFeatures' 1
Set-RegistryValue 'HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsSpotlightWindowsWelcomeExperience' 1
Set-RegistryValue 'HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsSpotlightOnActionCenter' 1
Set-RegistryValue 'HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsSpotlightOnSettings' 1
Set-RegistryValue 'HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableThirdPartySuggestions' 1
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' '{2cc5ca98-6485-489a-920e-b3e88a6ccce3}' 1

# do-not-reduce-sounds
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Multimedia\Audio' 'UserDuckingPreference' 3

# hide-disabled-disconnected-sounds
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Multimedia\Audio\DeviceCpl' 'ShowDisconnectedDevices' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Multimedia\Audio\DeviceCpl' 'ShowHiddenDevices' 0

# show-all-tasks-control-panel
Set-RegistryValue 'HKCR\CLSID\{D15ED2E1-C75B-443c-BD7C-FC03B2F08C17}' '' 'All Tasks' String
Set-RegistryValue 'HKCR\CLSID\{D15ED2E1-C75B-443c-BD7C-FC03B2F08C17}' 'InfoTip' 'View list of all Control Panel tasks' String
Set-RegistryValue 'HKCR\CLSID\{D15ED2E1-C75B-443c-BD7C-FC03B2F08C17}' 'System.ControlPanel.Category' '5' String
Set-RegistryValue 'HKCR\CLSID\{D15ED2E1-C75B-443c-BD7C-FC03B2F08C17}\DefaultIcon' '' '%windir%\System32\imageres.dll,-27' String
Set-RegistryValue 'HKCR\CLSID\{D15ED2E1-C75B-443c-BD7C-FC03B2F08C17}\Shell\Open\Command' '' 'explorer.exe shell:::{ED7BA470-8E54-465E-825C-99712043E01C}' String
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\{D15ED2E1-C75B-443c-BD7C-FC03B2F08C17}' '' 'All Tasks' String

# visual-effects
Set-RegistryValue 'HKCU\Control Panel\Desktop' 'FontSmoothing' '2' String
Set-RegistryValue 'HKCU\Control Panel\Desktop' 'UserPreferencesMask' '9012038010000000' Binary
Set-RegistryValue 'HKCU\Control Panel\Desktop' 'DragFullWindows' '1' String
Set-RegistryValue 'HKCU\Control Panel\Desktop\WindowMetrics' 'MinAnimate' '0' String
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ListviewAlphaSelect' 1
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'IconsOnly' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarAnimations' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ListviewShadow' 1
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' 'VisualFXSetting' 3
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\DWM' 'EnableAeroPeek' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\DWM' 'AlwaysHibernateThumbnails' 0

# disable-tips
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableSoftLanding' 1

# disable-win11-settings-banner
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\ValueBanner.IdealStateFeatureControlProvider' 'ActivationType' 0

# disable-dynamic-lighting
Set-RegistryValue 'HKCU\Software\Microsoft\Lighting' 'AmbientLightingEnabled' 0

# disable-auto-app-archival
Set-RegistryValue 'HKLM\Software\Policies\Microsoft\Windows\Appx' 'AllowAutomaticAppArchiving' 0
