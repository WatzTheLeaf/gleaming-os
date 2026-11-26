@echo off

(
    sc config lfsvc start=disabled
    sc config MapsBroker start=disabled
    reg add "HKLM\SOFTWARE\Policies\Microsoft\FindMyDevice" /v AllowFindMyDevice /t REG_DWORD /d 0 /f
    reg add "HKLM\SOFTWARE\Policies\Microsoft\FindMyDevice" /v LocationSyncEnabled /t REG_DWORD /d 0 /f
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" /v "ShowGlobalPrompts" /t REG_DWORD /d 0 /f
) > nul

(
    sc stop lfsvc
    sc stop MapsBroker
) > nul 2>&1

for %%a in (
    "privacy-location"
    "findmydevice"
) do (
    call "..\Scripts\settings-pages.cmd" /hide %%~a /silent
)

exit /b
