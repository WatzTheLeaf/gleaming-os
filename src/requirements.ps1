$ErrorActionPreference = 'SilentlyContinue'

$version = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
"build=$($version.CurrentBuildNumber)"
"applied=$([int]((Get-ItemProperty 'HKLM:\SOFTWARE\GleamingOS').Applied -eq 1))"

$defender = @()
$status = Get-MpComputerStatus
$preferences = Get-MpPreference
if ($status -and $preferences) {
    if ($status.RealTimeProtectionEnabled) { $defender += 'Real-time protection' }
    if ($preferences.MAPSReporting -ne 0) { $defender += 'Cloud-delivered protection' }
    if ($preferences.SubmitSamplesConsent -in 1, 3) { $defender += 'Automatic sample submission' }
    if ($status.IsTamperProtected) { $defender += 'Tamper Protection' }
}
"defender=$($defender -join ', ')"
"smart_app_control=$((Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy').VerifiedAndReputablePolicyState)"

$antivirus = Get-CimInstance -Namespace 'root\SecurityCenter2' -ClassName 'AntiVirusProduct' |
    Where-Object { $_.displayName -notmatch 'Defender' } | ForEach-Object displayName
"antivirus=$($antivirus -join ', ')"

$internet = [bool](Invoke-WebRequest 'http://www.msftconnecttest.com/connecttest.txt' -UseBasicParsing -TimeoutSec 10)
"internet=$([int]$internet)"

$pending = (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending') -or
    (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired')
"pending=$([int]$pending)"

$ucpd = Get-CimInstance -ClassName Win32_SystemDriver -Filter "Name='UCPD'"
"ucpd_disabled=$([int](!$ucpd -or $ucpd.StartMode -eq 'Disabled'))"
"ucpd_running=$([int]($ucpd.State -eq 'Running'))"

Add-Type -AssemblyName System.Windows.Forms
"plugged_in=$([int]([Windows.Forms.SystemInformation]::PowerStatus.PowerLineStatus -ne 'Offline'))"

"installed_days=$([int]((Get-Date) - (Get-CimInstance -ClassName Win32_OperatingSystem).InstallDate).TotalDays)"
