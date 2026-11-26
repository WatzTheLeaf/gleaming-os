# disable-copilot
Set-RegistryValue 'HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot' 1

# disable-windows-chat
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Chat' 'ChatIcon' 3
Set-RegistryValue 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarMn' 0

# set-to-center
Set-RegistryValue 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarAl' 1

# end-task
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings' 'TaskbarEndTask' 1

# always-more-details-transfer
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager' 'EnthusiastMode' 1

# disable-invalid-shortcuts-search
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoResolveSearch' 1
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoResolveTrack' 1

# disable-check-boxes
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'AutoCheckSelect' 0
