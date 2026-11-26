$themes = "$([Environment]::GetFolderPath('Windows'))\Resources\Themes"

if (Test-Option 'theme-dark') { Set-Theme -Path "$themes\gleaming-dark.theme" }

if (Test-Option 'theme-light') {
    Set-Theme -Path "$themes\gleaming-light.theme"
    Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'EnableTransparency' 0
    Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'ColorPrevalence' 0
}

Set-ThemeMRU

if (Test-Option 'theme-dark&taskbar-solid') {
    Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'EnableTransparency' 0
    Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'ColorPrevalence' 1
}

if (Test-Option 'theme-dark&taskbar-transparent') {
    Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'EnableTransparency' 1
    Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'ColorPrevalence' 0
}

Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization' 'LockScreenOverlaysDisabled' 1
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'RotatingLockScreenEnabled' 0

foreach ($userKey in (Get-ChildItem "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Creative").PsPath) {
    Set-ItemProperty -Path $userKey -Name 'RotatingLockScreenEnabled' -Type DWORD -Value 0 -Force
}

Set-LockscreenImage
