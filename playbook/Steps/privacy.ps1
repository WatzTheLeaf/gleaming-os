# config-app-permissions
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics' 'Value' 'Deny' String
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location' 'Value' 'Deny' String
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation' 'Value' 'Deny' String

# config-windows-media-player
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\WMDRM' 'DisableOnline' 1

Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\MediaPlayer\Preferences' 'AcceptedPrivacyStatement' 1

Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\MediaPlayer\Preferences' 'UsageTracking' 0

# disable-activity-feed
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\System' 'EnableActivityFeed' 0

# disable-app-launch-tracking
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_TrackProgs' 0

# disable-experimentation
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\PolicyManager\default\System\AllowExperimentation' 'Value' 0

# disable-lockscreen-camera
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization' 'NoLockScreenCamera' 1

# disable-online-speech-recognition
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy' 'HasAccepted' 0

# disable-pca
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat' 'AITEnable' 0
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat' 'AllowTelemetry' 0
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat' 'DisableEngine' 1
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat' 'DisableInventory' 1
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat' 'DisablePCA' 1
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat' 'DisableUAR' 1

# disable-perf-track
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WDI\{9c5a40da-b965-4fc3-8781-88dd50a6299d}' 'ScenarioExecutionEnabled' 0

# disable-privacy-experience
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\OOBE' 'DisablePrivacyExperience' 1

# disable-recall-snap
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableAIDataAnalysis' 1

# disable-device-monitoring
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\DeviceHealthAttestationService' 'EnableDeviceHealthAttestationService' 0

# disable-rsop-logging
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\System' 'RSoPLogging' 0

# disable-speech-auto-updates
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Speech' 'AllowSpeechModelUpdate' 0

# disable-tailored-experiences
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy' 'TailoredExperiencesWithDiagnosticDataEnabled' 0
Set-RegistryValue 'HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableTailoredExperiencesWithDiagnosticData' 1

# disable-user-tracking
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoInstrumentation' 1

# disable-web-lang-list-access
Set-RegistryValue 'HKCU\Control Panel\International\User Profile' 'HttpAcceptLanguageOptOut' 1

# disable-win-error-reporting
Set-RegistryValue 'HKCU\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting' 'Disabled' 1
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\PCHealth\ErrorReporting' 'DoReport' 0
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting' 'Disabled' 1
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting' 'DontShowUI' 1
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\PCHealth\ErrorReporting' 'ShowUI' 0
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting' 'LoggingDisabled' 1
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting' 'DontSendAdditionalData' 1
Set-RegistryValue 'HKLM\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing' 'DisableWerReporting' 1

Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Settings' 'DisableSendGenericDriverNotFoundToWER' 1

Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Settings' 'DisableSendRequestAdditionalSoftwareToWER' 1

# disallow-ms-accounts
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'NoConnectedUser' 1

# disallow-user-activity-upload
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\System' 'UploadUserActivities' 0
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\System' 'PublishUserActivities' 0

# search-settings
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'BingSearchEnabled' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings' 'IsAADCloudSearchEnabled' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings' 'IsDeviceSearchHistoryEnabled' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings' 'IsMSACloudSearchEnabled' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings' 'SafeSearchMode' 0

Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'ConnectedSearchUseWeb' 0
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'DisableWebSearch' 1
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'AllowSearchToUseLocation' 0
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'EnableDynamicContentInWSB' 0

Set-RegistryValue 'HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'DisableSearchBoxSuggestions' 1

Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'SearchboxTaskbarMode' 0

# disable-nvidia-telemetry
Set-RegistryValue 'HKCU\Software\NVIDIA Corporation\NVControlPanel2\Client' 'OptInOrOutPreference' 0

# disable-office-telemetry
Set-RegistryValue 'HKCU\Software\Policies\Microsoft\office\16.0\common' 'sendcustomerdata' 0
Set-RegistryValue 'HKCU\Software\Policies\Microsoft\office\common\clienttelemetry' 'sendtelemetry' 3

Set-RegistryValue 'HKCU\Software\Policies\Microsoft\office\16.0\common' 'qmenable' 0

# disable-advertising-info
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo' 'Enabled' 0
Set-RegistryValue 'HKLM\Software\Policies\Microsoft\Windows\AdvertisingInfo' 'DisabledByGroupPolicy' 1

# disable-sync-provider-notifs
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowSyncProviderNotifications' 0

# disable-setting-sync
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync' 'DisableSettingSync' 2
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync' 'DisableSettingSyncUserOverride' 1
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync' 'DisableSyncOnPaidNetwork' 1
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync' 'DisableWindowsSettingSync' 2
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization' 'Enabled' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\BrowserSettings' 'Enabled' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials' 'Enabled' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility' 'Enabled' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows' 'Enabled' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync' 'SyncPolicy' 5

# disable-suggest-ways-to-finish-setup
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement' 'ScoobeSystemSettingEnabled' 0

# disallow-message-cloud-sync
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Messaging' 'AllowMessageSync' 0

# disable-activation-telemetry
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform' 'NoGenTicket' 1

# disable-ceip
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\AppV\CEIP' 'CEIPEnable' 0
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows' 'CEIPEnable' 0

# disable-diagnostic-tracing
Set-RegistryValue 'HKLM\SYSTEM\CurrentControlSet\Control\Diagnostics\Performance' 'DisableDiagnosticTracing' 1

# disable-dotnet-cli-telemetry
Invoke-Program 'cmd.exe' '/c setx DOTNET_CLI_TELEMETRY_OPTOUT 1 /M'

# disable-input-telemetry
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\InputPersonalization' 'RestrictImplicitInkCollection' 1
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\InputPersonalization' 'RestrictImplicitTextCollection' 1
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore' 'HarvestContacts' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Personalization\Settings' 'AcceptedPrivacyPolicy' 0
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\TabletPC' 'PreventHandwritingDataSharing' 1
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports' 'PreventHandwritingErrorReports' 1

Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Input\Settings' 'InsightsEnabled' 0

Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Input\TIPC' 'Enabled' 0
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Input\TIPC' 'Enabled' 0

# disallow-data-collection
Stop-Service -Name 'DiagTrack' -Force -ErrorAction SilentlyContinue
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack' 'ShowedToastAtLevel' 1
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' 'AllowTelemetry' 0
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' 'MaxTelemetryAllowed' 0
Set-RegistryValue 'HKLM\Software\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 0
Set-RegistryValue 'HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection' 'AllowTelemetry' 0

Set-RegistryValue 'HKLM\Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\EventTranscriptKey' 'EnableEventTranscript' 0
Set-RegistryValue 'HKLM\Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\EventTranscriptKey' 'MiniTraceSlotEnabled' 0
Set-RegistryValue 'HKLM\Software\Policies\Microsoft\Windows\DataCollection' 'AllowDeviceNameInTelemetry' 0

Set-RegistryValue 'HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\Diagtrack-Listener' 'Start' 0
Invoke-Program 'cmd.exe' '/c del "%ProgramData%\Microsoft\Diagnosis\ETLLogs\AutoLogger\DiagTrack*" "%ProgramData%\Microsoft\Diagnosis\ETLLogs\ShutdownLogger\DiagTrack*" > nul 2>&1'
