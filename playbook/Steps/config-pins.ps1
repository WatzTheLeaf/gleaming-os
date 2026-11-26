Remove-RegistryKey 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband'
Add-RegistryKey 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband'

Set-RegistryValue 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband\AuxilliaryPins' 'MailPin' 0
Set-RegistryValue 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband\AuxilliaryPins' 'CopilotPWAPin' 0

..\Scripts\taskbar-pins.ps1 -AddTerminal:(Test-Option 'pin-terminal')
