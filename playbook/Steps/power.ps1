if (Test-Option 'disable-power-saving') { & "..\Scripts\disable-power-saving.ps1" }

Set-RegistryValue 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power' 'HiberbootEnabled' 0

if (Test-Option 'disable-hibernation') {
    Invoke-Program 'powercfg.exe' '/h off'
    Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings' 'ShowHibernateOption' 0
}

if (Test-Option '!disable-power-saving') { Invoke-Program 'powercfg.exe' '/setactive "381b4222-f694-41f0-9685-ff5bb260df2e"' }
