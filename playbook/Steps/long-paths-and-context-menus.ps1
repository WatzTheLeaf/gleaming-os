# enable-long-paths
Set-RegistryValue 'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem' 'LongPathsEnabled' 1

# merge-as-trustedinstaller
Set-RegistryValue 'HKCR\regfile\Shell\RunAs' '' 'Merge As TrustedInstaller' String
Set-RegistryValue 'HKCR\regfile\Shell\RunAs' 'HasLUAShield' '1' String
Set-RegistryValue 'HKCR\regfile\Shell\RunAs\Command' '' 'cmd /c "%windir%\GleamingOS\RunAsTI.cmd" "%1"' String

# new-bat
Set-RegistryValue 'HKCR\.bat\ShellNew' 'ItemName' '%windir%\System32\acppage.dll,-6002' ExpandString
Set-RegistryValue 'HKCR\.bat\ShellNew' 'NullFile' '' String

# new-ps1
Set-RegistryValue 'HKCR\.ps1' '' 'Microsoft.PowerShellScript.1' String
Set-RegistryValue 'HKCR\.ps1\ShellNew' 'NullFile' '' String
Set-RegistryValue 'HKCR\Microsoft.PowerShellScript.1' '' 'Windows PowerShell Script' String
Set-RegistryValue 'HKCR\Microsoft.PowerShellScript.1' 'FriendlyTypeName' 'Windows PowerShell Script' String

# new-reg
Set-RegistryValue 'HKCR\.reg\ShellNew' 'NullFile' '' String
Set-RegistryValue 'HKCR\.reg\ShellNew' 'ItemName' '%windir%\regedit.exe,-309' ExpandString

# cast-to-device
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked' '{7AD84985-87B4-4a16-BE58-8B72A5B390F7}' '' String

# extract
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked' '{b8cdcb65-b1bf-4b42-9428-1dfdb7ee92af}' '' String
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked' '{BD472F60-27FA-11cf-B8B4-444553540000}' '' String
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked' '{EE07CEF5-3441-4CFB-870A-4002C724783A}' '' String
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked' '{D12E3394-DE4B-4777-93E9-DF0AC88F8584}' '' String

# give-access-to
Remove-RegistryKey 'HKCR\*\shellex\ContextMenuHandlers\Sharing'
Remove-RegistryKey 'HKCR\Directory\Background\shellex\ContextMenuHandlers\Sharing'
Remove-RegistryKey 'HKCR\Directory\shellex\ContextMenuHandlers\Sharing'
Remove-RegistryKey 'HKCR\Drive\shellex\ContextMenuHandlers\Sharing'
Remove-RegistryKey 'HKCR\LibraryFolder\background\shellex\ContextMenuHandlers\Sharing'
Remove-RegistryKey 'HKCR\UserLibraryFolder\shellex\ContextMenuHandlers\Sharing'

# include-in-library
Remove-RegistryKey 'HKCR\Folder\ShellEx\ContextMenuHandlers\Library Location'

# new-bitmap
Remove-RegistryKey 'HKCR\.bmp\ShellNew'

# new-rtf
Remove-RegistryKey 'HKCR\.rtf\ShellNew'

# paint-3D
Remove-RegistryKey 'HKCR\SystemFileAssociations\.3mf\Shell\3D Edit'
Remove-RegistryKey 'HKCR\SystemFileAssociations\.bmp\Shell\3D Edit'
Remove-RegistryKey 'HKCR\SystemFileAssociations\.fbx\Shell\3D Edit'
Remove-RegistryKey 'HKCR\SystemFileAssociations\.gif\Shell\3D Edit'
Remove-RegistryKey 'HKCR\SystemFileAssociations\.jfif\Shell\3D Edit'
Remove-RegistryKey 'HKCR\SystemFileAssociations\.jpe\Shell\3D Edit'
Remove-RegistryKey 'HKCR\SystemFileAssociations\.jpeg\Shell\3D Edit'
Remove-RegistryKey 'HKCR\SystemFileAssociations\.jpg\Shell\3D Edit'
Remove-RegistryKey 'HKCR\SystemFileAssociations\.png\Shell\3D Edit'
Remove-RegistryKey 'HKCR\SystemFileAssociations\.tif\Shell\3D Edit'
Remove-RegistryKey 'HKCR\SystemFileAssociations\.tiff\Shell\3D Edit'

# share
Remove-RegistryKey 'HKCR\*\shellex\ContextMenuHandlers\ModernSharing'
Remove-RegistryKey 'HKCR\AllFilesystemObjects\shellex\ContextMenuHandlers\ModernSharing'

# troubleshooting-compat
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked' '{1d27f844-3a1f-4410-85ac-14651078412d}' '' String
Set-RegistryValue 'HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked' '{1d27f844-3a1f-4410-85ac-14651078412d}' '' String
