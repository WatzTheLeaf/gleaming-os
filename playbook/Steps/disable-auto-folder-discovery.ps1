Remove-RegistryKey 'HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags'
Set-RegistryValue 'HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell' 'FolderType' 'NotSpecified' String
