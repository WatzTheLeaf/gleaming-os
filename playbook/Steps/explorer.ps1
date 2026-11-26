# full-context-on-more-than-15-items
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' 'MultipleInvokePromptMinimum' 100

# hide-frequently-used-items
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' 'ShowFrequent' 0
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' 'ShowRecent' 0

Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_TrackDocs' 0

Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'ClearRecentDocsOnExit' 1

Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoRecentDocsHistory' 1

Set-RegistryValue 'HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'NoRemoteDestinations' 1

# import-power-plan
Set-RegistryValue 'HKCR\powerscheme\DefaultIcon' '' '%windir%\System32\powercpl.dll,1' String
Set-RegistryValue 'HKCR\powerscheme\Shell\open\command' '' 'powercfg /import "%1"' String
Set-RegistryValue 'HKCR\.pow' '' 'powerscheme' String
Set-RegistryValue 'HKCR\.pow' 'FriendlyTypeName' 'Power Scheme' String

# extend-cache
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' 'Max Cached Icons' '4096' String

# minimize-mouse-hover-time
Set-RegistryValue 'HKCU\Control Panel\Desktop' 'MouseHoverTime' '20' String

# no-internet-open-with
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoInternetOpenWith' 1

# open-to-this-pc
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'LaunchTo' 1

# removable-drives-only-this-pc
Remove-RegistryKey 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}'
Remove-RegistryKey 'HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}'

# remove-previous-versions
Remove-RegistryKey 'HKCR\AllFilesystemObjects\shellex\PropertySheetHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}'
Remove-RegistryKey 'HKCR\CLSID\{450D8FBA-AD25-11D0-98A8-0800361B1103}\shellex\PropertySheetHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}'
Remove-RegistryKey 'HKCR\Directory\shellex\PropertySheetHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}'
Remove-RegistryKey 'HKCR\Drive\shellex\PropertySheetHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}'
Remove-RegistryKey 'HKCR\AllFilesystemObjects\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}'
Remove-RegistryKey 'HKCR\CLSID\{450D8FBA-AD25-11D0-98A8-0800361B1103}\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}'
Remove-RegistryKey 'HKCR\Directory\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}'
Remove-RegistryKey 'HKCR\Drive\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}'
Remove-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' 'NoPreviousVersionsPage'
Remove-RegistryValue 'HKCU\SOFTWARE\Policies\Microsoft\PreviousVersions' 'DisableLocalPage'

# remove-shortcut-text
Set-RegistryValue 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates' 'ShortcutNameTemplate' '"%s.lnk"' String

# show-files
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Hidden' 1
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'HideFileExt' 0

# classic-search
Set-RegistryValue 'HKLM\SOFTWARE\Classes\CLSID\{1d64637d-31e9-4b06-9124-e83fb178ac6e}\TreatAs' '' '{64bc32b5-4eec-4de7-972d-bd8bd0324537}' String
Set-RegistryValue 'HKLM\SOFTWARE\Classes\WOW6432Node\CLSID\{1d64637d-31e9-4b06-9124-e83fb178ac6e}\TreatAs' '' '{64bc32b5-4eec-4de7-972d-bd8bd0324537}' String
Set-RegistryValue 'HKLM\SOFTWARE\WOW6432Node\Classes\CLSID\{1d64637d-31e9-4b06-9124-e83fb178ac6e}\TreatAs' '' '{64bc32b5-4eec-4de7-972d-bd8bd0324537}' String

# dont-show-office-files
Set-RegistryValue 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer' 'ShowCloudFilesInQuickAccess' 0

# use-compact-mode
Set-RegistryValue 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'UseCompactMode' 1
