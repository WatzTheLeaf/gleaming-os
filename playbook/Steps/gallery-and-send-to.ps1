# disable-gallery
Set-RegistryValue 'HKCU\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}' 'System.IsPinnedToNameSpaceTree' 0

# debloat-send-to
# A dash before the CLSID disables the "Send to" menu handler and keeps its value to restore it
Set-RegistryValue 'HKCR\AllFilesystemObjects\shellex\ContextMenuHandlers\SendTo' '' '-{7BA4C740-9E81-11CF-99D3-00AA004AE837}' String
