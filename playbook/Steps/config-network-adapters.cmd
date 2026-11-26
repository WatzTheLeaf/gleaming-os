@echo off

for /f "usebackq" %%a in (`powershell -NonI -NoP -C "(Get-CimInstance Win32_NetworkAdapter).PNPDeviceID | sls 'PCI\\VEN_'"`) do (
    for /f "tokens=3" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%a" /v "Driver" 2^>nul') do (
        call :configure "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%b"
    )
)

exit /b

:configure
for %%a in (
    "AutoDisableGigabit"

    "ApCompatMode"

    "SipsEnabled"
    "ReduceSpeedOnPowerDown"

    "DMACoalescing"
) do (
    for /f %%b in ('reg query "%~1" /v "%%~a" ^| findstr "HKEY"') do (
        reg add "%~1" /v "%%~a" /t REG_SZ /d "0" /f > nul
    )
    for /f %%b in ('reg query "%~1" /v "*%%~a" ^| findstr "HKEY"') do (
        reg add "%~1" /v "*%%~a" /t REG_SZ /d "0" /f > nul
    )
) > nul 2>&1
exit /b
