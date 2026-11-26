@echo off

set associations=".url:InternetShortcut"^
 "Proto:https:BraveHTML"^
 "Proto:http:BraveHTML"^
 ".htm:BraveHTML"^
 ".html:BraveHTML"^
 ".pdf:BraveFile"^
 ".shtml:BraveHTML"

echo Making temporary PowerShell...
for /f "tokens=* delims=" %%a in ('where powershell.exe') do (set "powershellPath=%%a")
for %%A in ("%powershellPath%") do (set "powershellDir=%%~dpA")
set "powershellTemp=%powershellDir%\powershell%random%%random%%random%%random%.exe"
copy /y "%powershellPath%" "%powershellTemp%" > nul

for /f "usebackq tokens=2 delims=\" %%a in (`reg query HKU ^| findstr /r /x /c:"HKEY_USERS\\S-.*"`) do (
    reg query "HKU\%%a" | findstr /c:"Volatile Environment" > nul && (
        echo Setting associations for "%%a"...
        "%powershellTemp%" -NoP -NonI -EP Bypass -File ..\Scripts\file-associations.ps1 "Placeholder" "%%a" %associations%
    )
)

echo Deleting temporary PowerShell...
del /f /q "%powershellTemp%" > nul

exit /b
