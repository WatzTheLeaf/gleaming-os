# config-automatic-maintenance
Set-RegistryValue 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Task Scheduler\Maintenance' 'WakeUp' 0

# disable-background-apps
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' 'GlobalUserDisabled' 1
Set-RegistryValue 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'BackgroundAppGlobalToggle' 0

# disable-fth
if (-not (Test-Arm64)) {
    Invoke-Program 'rundll32.exe' 'fthsvc.dll,FthSysprepSpecialize'
    Set-RegistryValue 'HKLM\SOFTWARE\Microsoft\FTH' 'Enabled' 0
}

# disable-sleep-study
Invoke-Program 'wevtutil.exe' 'set-log "Microsoft-Windows-SleepStudy/Diagnostic" /e:false'
Invoke-Program 'wevtutil.exe' 'set-log "Microsoft-Windows-Kernel-Processor-Power/Diagnostic" /e:false'
Invoke-Program 'wevtutil.exe' 'set-log "Microsoft-Windows-UserModePowerService/Diagnostic" /e:false'
Set-ScheduledTaskState '\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem' -Enabled $false

# respect-power-modes-search
Set-RegistryValue 'HKLM\Software\Microsoft\Windows Search\Gather\Windows\SystemIndex' 'RespectPowerModes' 1

# optimize-ntfs
Invoke-Program 'fsutil' 'behavior set disablelastaccess 1'

Invoke-Program 'fsutil' '8dot3name set 1'

# disable-service-host-split
Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services' |
  Where-Object { $_.Name -notmatch 'Xbl|Xbox' } |
  Foreach-Object {
    if ($null -ne (Get-ItemProperty -Path "Registry::$_" -EA 0).Start) {
      Set-ItemProperty -Path "Registry::$_" -Name 'SvcHostSplitDisable' -Type DWORD -Value 1 -Force -EA 0
    }
  }

# win32-priority-separation
Set-RegistryValue 'HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl' 'Win32PrioritySeparation' 38
