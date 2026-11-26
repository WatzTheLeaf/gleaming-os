@echo off

set "indexConf=call "..\Scripts\index-conf.cmd""

%indexConf% /stop
%indexConf% /cleanpolicies
%indexConf% /include "%programdata%\Microsoft\Windows\Start Menu\Programs"
%indexConf% /exclude "%systemdrive%\Users"

reg add "HKLM\Software\Microsoft\Windows Search\Gather\Windows\SystemIndex" /v "RespectPowerModes" /t REG_DWORD /d 1 /f > nul

%indexConf% /start
reg add "HKLM\SOFTWARE\Microsoft\Windows Search" /v SetupCompletedSuccessfully /t REG_DWORD /d 0 /f > nul

exit /b
