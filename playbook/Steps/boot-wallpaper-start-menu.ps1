# bcdedit-tweaks
Invoke-Program 'bcdedit' '/timeout 10'

Invoke-Program 'bcdedit' '/set bootmenupolicy legacy'

# best-wallpaper-quality
Set-RegistryValue 'HKCU\Control Panel\Desktop' 'JPEGImportQuality' 100

# config-start-menu
Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start' 'ConfigureStartPins' '{"pinnedList":[{"packagedAppId":"windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel"},{"packagedAppId":"Microsoft.WindowsTerminal_8wekyb3d8bbwe!App"},{"desktopAppLink":"%APPDATA%\\Microsoft\\Windows\\Start Menu\\Programs\\File Explorer.lnk"},{"packagedAppId":"Microsoft.WindowsStore_8wekyb3d8bbwe!App"},{"packagedAppId":"Microsoft.GamingApp_8wekyb3d8bbwe!Microsoft.Xbox.App"},{"packagedAppId":"Microsoft.WindowsCalculator_8wekyb3d8bbwe!App"},{"packagedAppId":"Microsoft.WindowsNotepad_8wekyb3d8bbwe!App"},{"packagedAppId":"Microsoft.Paint_8wekyb3d8bbwe!App"},{"packagedAppId":"Microsoft.SecHealthUI_8wekyb3d8bbwe!SecHealthUI"}]}' String

Stop-Process -Name 'StartMenuExperienceHost' -Force -ErrorAction SilentlyContinue
Invoke-Action 'Resetting the Start menu layout' {
    foreach ($sid in Get-UserHives) {
        $userKey = "Registry::HKEY_USERS\$sid"

        $appData = (Get-ItemProperty "$userKey\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -Name 'Local AppData' -EA 0).'Local AppData'

        Write-Output "Configuring Start Menu for '$sid'..."
        if ([string]::IsNullOrEmpty($appData) -or !(Test-Path $appData)) {
            Write-Error "Couldn't find AppData value for $sid!"
        } else {
            Write-Output "Copying default layout XML"
            Copy-Item -Path "Layout.xml" -Destination "$appdata\Microsoft\Windows\Shell\LayoutModification.xml" -Force

            Write-Output "Clearing Start Menu pinned items"
            $packages = Get-ChildItem -Path "$appdata\Packages" -Directory | Where-Object { $_.Name -match "Microsoft.Windows.StartMenuExperienceHost" }
            foreach ($package in $packages) {
                $bins = Get-ChildItem -Path "$appdata\Packages\$($package.Name)\LocalState" -File | Where-Object { $_.Name -like "start*.bin" }
                foreach ($bin in $bins.FullName) {
                    Remove-Item -Path $bin -Force
                }
            }
        }

        Write-Output "Clearing default 'tilegrid'"
        $tilegrid = Get-ChildItem -Path "$userKey\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount" -Recurse | Where-Object { $_.Name -match "start.tilegrid" }
        foreach ($key in $tilegrid) {
            Remove-Item -Path $key.PSPath -Force
        }

        Write-Output "Removing advertisements/stubs from Start Menu (23H2+)"
        Remove-ItemProperty -Path "$userKey\SOFTWARE\Microsoft\Windows\CurrentVersion\Start" -Name 'Config' -Force -EA 0
    }
}
Clear-AppxCache 'Microsoft.Windows.StartMenuExperienceHost*'

Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoStartMenuMFUprogramsList' 1

Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'ShowOrHideMostUsedApps' 2

Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'HideRecentlyAddedApps' 1

Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'HideRecommendedPersonalizedSites' 1
