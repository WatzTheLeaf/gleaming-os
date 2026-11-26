# disable-tablet-mode
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell' 'SignInMode' 1

# hide-meet-now
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'HideSCAMeetNow' 1

# hide-task-view
Remove-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MultiTaskingView\AllUpView' 'Enabled'
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowTaskViewButton' 0
