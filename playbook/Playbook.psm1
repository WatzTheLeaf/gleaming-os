function Write-Failure ([string]$Message) {
    [Console]::Error.WriteLine($Message)
}

function Invoke-Action ([string]$Description, [scriptblock]$Action, [switch]$IgnoreErrors) {
    try {
        & $Action
    } catch {
        if (!$IgnoreErrors) { Write-Failure "$Description failed: $($_.Exception.Message)" }
    }
}

function Test-Option ([string]$Expression) {
    $selected = $env:PLAYBOOK_OPTIONS -split ';'
    foreach ($term in $Expression -split '&') {
        if (($selected -contains $term.TrimStart('!')) -eq $term.StartsWith('!')) { return $false }
    }
    return $true
}

function Test-Arm64 {
    ((Get-CimInstance -ClassName Win32_ComputerSystem).SystemType -match 'ARM64') -or ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64')
}

# Downloads an asset of a repository's latest release, checked against the SHA-256 hash GitHub publishes
function Save-GitHubAsset ([string]$Repository, [string]$Name, [string]$Path) {
    $release = Invoke-RestMethod "https://api.github.com/repos/$Repository/releases/latest" -ErrorAction Stop
    $asset = $release.assets | Where-Object name -eq $Name
    if (!$asset) { throw "$Repository $($release.tag_name) has no $Name." }
    Write-Output "Downloading $Name $($release.tag_name)..."
    curl.exe -fLSs $asset.browser_download_url -o $Path --connect-timeout 10 --retry 5 --retry-delay 0 --retry-all-errors
    if ($LASTEXITCODE -ne 0) { throw "Downloading $Name failed (curl exit code $LASTEXITCODE)." }
    if ("sha256:$((Get-FileHash $Path -Algorithm SHA256 -ErrorAction Stop).Hash)" -ne $asset.digest) {
        throw "The downloaded $Name doesn't match its SHA-256 hash."
    }
}

function Get-UserHives {
    $users = [Microsoft.Win32.Registry]::Users
    $users.GetSubKeyNames() | Where-Object { $_ -match '^S-1-5-21-[\d-]+$' -and $users.OpenSubKey("$_\Volatile Environment") }
}

function Resolve-RegistryPath ([string]$Path) {
    $root, $subKey = $Path -split '\\', 2
    switch ($root) {
        'HKCU' { Get-UserHives | ForEach-Object { @{ Hive = 'Users'; SubKey = "$_\$subKey" } } }
        'HKLM' { @{ Hive = 'LocalMachine'; SubKey = $subKey } }
        'HKCR' { @{ Hive = 'ClassesRoot'; SubKey = $subKey } }
        'HKU' { @{ Hive = 'Users'; SubKey = $subKey } }
        default { throw "Unsupported registry root '$root' in '$Path'." }
    }
}

function Open-RegistryHive ([Microsoft.Win32.RegistryHive]$Hive) {
    [Microsoft.Win32.RegistryKey]::OpenBaseKey($Hive, [Microsoft.Win32.RegistryView]::Registry64)
}

function Set-RegistryValue ([string]$Path, [string]$Name, $Data, [Microsoft.Win32.RegistryValueKind]$Type = 'DWord') {
    $value = switch ($Type) {
        'DWord' { [int]$Data }
        'Binary' { , [byte[]]($Data -split '(..)' -ne '' | ForEach-Object { [Convert]::ToByte($_, 16) }) }
        'None' { , [byte[]]@() }
        'MultiString' { , [string[]]@($Data | Where-Object { $_ }) }
        default { [string]$Data }
    }
    foreach ($target in Resolve-RegistryPath $Path) {
        Invoke-Action "Setting '$Path\$Name'" {
            $key = (Open-RegistryHive $target.Hive).CreateSubKey($target.SubKey)
            $key.SetValue($Name, $value, $Type)
            $key.Close()
        }
    }
}

function Remove-RegistryValue ([string]$Path, [string]$Name) {
    foreach ($target in Resolve-RegistryPath $Path) {
        Invoke-Action "Removing '$Path\$Name'" {
            $key = (Open-RegistryHive $target.Hive).OpenSubKey($target.SubKey, $true)
            if ($key) {
                $key.DeleteValue($Name, $false)
                $key.Close()
            }
        }
    }
}

function Add-RegistryKey ([string]$Path) {
    foreach ($target in Resolve-RegistryPath $Path) {
        Invoke-Action "Adding '$Path'" { (Open-RegistryHive $target.Hive).CreateSubKey($target.SubKey).Close() }
    }
}

function Remove-RegistryKey ([string]$Path) {
    foreach ($target in Resolve-RegistryPath $Path) {
        Invoke-Action "Removing '$Path'" { (Open-RegistryHive $target.Hive).DeleteSubKeyTree($target.SubKey, $false) }
    }
}

function Set-ServiceStartup ([string]$Name, [int]$Startup) {
    $services = Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services' |
        Where-Object { $_.PSChildName -eq $Name -or $_.PSChildName -like "$($Name)_*" }
    if (!$services) {
        Write-Output "Service '$Name' not found, skipped."
        return
    }
    foreach ($service in $services) {
        Invoke-Action "Setting the startup of '$($service.PSChildName)'" {
            Set-ItemProperty -Path $service.PSPath -Name 'Start' -Value $Startup -Type DWord -ErrorAction Stop
        }
    }
}

function Set-ScheduledTaskState ([string]$Path, [bool]$Enabled, [switch]$IgnoreErrors) {
    $separator = $Path.LastIndexOf('\')
    $taskPath, $taskName = $Path.Substring(0, $separator + 1), $Path.Substring($separator + 1)
    Invoke-Action "Changing the scheduled task '$Path'" -IgnoreErrors:$IgnoreErrors {
        $task = Get-ScheduledTask -TaskPath $taskPath -TaskName $taskName -ErrorAction Stop
        if ($Enabled) { $task | Enable-ScheduledTask -ErrorAction Stop | Out-Null }
        else { $task | Disable-ScheduledTask -ErrorAction Stop | Out-Null }
    }
}

function Set-AppxDeprovisioned ([string]$Family) {
    Add-RegistryKey "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\$Family"
}

function Remove-AppxFamily ([string]$Name) {
    $families = @()
    foreach ($package in Get-AppxPackage -AllUsers | Where-Object PackageFamilyName -like $Name) {
        $families += $package.PackageFamilyName
        Invoke-Action "Removing '$($package.PackageFullName)'" {
            Remove-AppxPackage -Package $package.PackageFullName -AllUsers -ErrorAction Stop
        }
    }
    foreach ($package in Get-AppxProvisionedPackage -Online | Where-Object { "$($_.DisplayName)_$($_.PublisherId)" -like $Name }) {
        $families += "$($package.DisplayName)_$($package.PublisherId)"
        Invoke-Action "Deprovisioning '$($package.PackageName)'" {
            Remove-AppxProvisionedPackage -Online -PackageName $package.PackageName -ErrorAction Stop | Out-Null
        }
    }
    $families | Select-Object -Unique | ForEach-Object { Set-AppxDeprovisioned $_ }
}

function Clear-AppxCache ([string]$Name) {
    $profiles = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList').ProfilesDirectory
    foreach ($package in Get-ChildItem "$profiles\*\AppData\Local\Packages\$Name" -Directory -Force -ErrorAction SilentlyContinue) {
        foreach ($folder in 'LocalCache', 'LocalState', 'TempState') {
            Remove-Item "$($package.FullName)\$folder\*" -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

function Invoke-Program ([string]$FilePath, [string]$ArgumentList, [switch]$IgnoreErrors, [switch]$NoWait) {
    $command = "$FilePath $ArgumentList".Trim()
    Invoke-Action "'$command'" -IgnoreErrors:$IgnoreErrors {
        $startInfo = New-Object System.Diagnostics.ProcessStartInfo $FilePath, $ArgumentList
        $startInfo.UseShellExecute = $false
        $process = [System.Diagnostics.Process]::Start($startInfo)
        if ($NoWait) { return }
        $process.WaitForExit()
        if ($process.ExitCode -ne 0) { throw "exit code $($process.ExitCode)" }
    }
}

$windir = [Environment]::GetFolderPath('Windows')

function Stop-ThemeProcesses {
    Get-Process 'SystemSettings', 'control' -EA 0 | Stop-Process -Force -EA 0
}

function Set-Theme {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    if (!((Get-Item $Path -EA 0).Extension -eq '.theme')) {
        throw "'$Path' is not a valid path to a theme file."
    }
    
    function Set-ThemeUsingExplorer {
        Write-Warning "Failed to apply theme using COM, falling back to launching file..."
        
        Stop-ThemeProcesses
        Start-Process -FilePath explorer -ArgumentList $Path
        Start-Sleep 10
    }

    Add-Type @'
using System;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

public static class ThemeManagerAPI
{
    public static void ApplyTheme(string themeFilePath)
    {
        IThemeManager themeManager = new ThemeManagerClass();
        themeManager.ApplyTheme(themeFilePath);
    }

    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    [Guid("D23CC733-5522-406D-8DFB-B3CF5EF52A71")]
    [ComImport]
    public interface ITheme
    {
    }

    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    [Guid("0646EBBE-C1B7-4045-8FD0-FFD65D3FC792")]
    [ComImport]
    public interface IThemeManager
    {
        [DispId(1610678272)]
        ITheme CurrentTheme { get; }

        [MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
        void ApplyTheme([MarshalAs(UnmanagedType.BStr)] string themeFilePath);
    }

    [TypeLibType(TypeLibTypeFlags.FCanCreate)]
    [Guid("C04B329E-5823-4415-9C93-BA44688947B0")]
    [ClassInterface(ClassInterfaceType.None)]
    [ComImport]
    public class ThemeManagerClass : IThemeManager
    {
        [DispId(1610678272)]
        public virtual extern ITheme CurrentTheme { [MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)] get; }

        [MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime)]
        public virtual extern void ApplyTheme([MarshalAs(UnmanagedType.BStr)] string themeFilePath);
    }
}
'@

    try {
        [ThemeManagerAPI]::ApplyTheme($Path)
    } catch {
        Set-ThemeUsingExplorer
    }

    Stop-ThemeProcesses
}

function Set-ThemeMRU {
    Stop-ThemeProcesses
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes" -Name "ThemeMRU" -Value "$((@(
        "gleaming-dark.theme",
        "gleaming-light.theme",
        "dark.theme",
        "aero.theme"
    ) | ForEach-Object { "$windir\resources\Themes\$_" }) -join ';');" -Type String -Force
}

function Set-LockscreenImage {
    param (
        [ValidateNotNullOrEmpty()]
        [string]$Path = "$([Environment]::GetFolderPath('Windows'))\GleamingOS\Wallpapers\gleaming.png"
    )

    if (!(Test-Path $Path)) {
        throw "Path ('$Path') for lockscreen not found."
    }
    $newImagePath = [System.IO.Path]::GetTempPath() + (New-Guid).Guid + [System.IO.Path]::GetExtension($Path)
    Copy-Item $Path $newImagePath

    Add-Type -AssemblyName System.Runtime.WindowsRuntime
    [Windows.System.UserProfile.LockScreen, Windows.System.UserProfile, ContentType = WindowsRuntime] | Out-Null

    $asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | ? {
            $_.Name -eq 'AsTask' -and
            $_.GetParameters().Count -eq 1 -and
            $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'
        })[0]
    Function Await($WinRtTask, $ResultType) {
        $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
        $netTask = $asTask.Invoke($null, @($WinRtTask))
        $netTask.Wait(-1) | Out-Null
        $netTask.Result
    }
    Function AwaitAction($WinRtAction) {
        $asTask = ([System.WindowsRuntimeSystemExtensions].GetMethods() | ? { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and !$_.IsGenericMethod })[0]
        $netTask = $asTask.Invoke($null, @($WinRtAction))
        $netTask.Wait(-1) | Out-Null
    }

    [Windows.Storage.StorageFile, Windows.Storage, ContentType = WindowsRuntime] | Out-Null
    $image = Await ([Windows.Storage.StorageFile]::GetFileFromPathAsync($newImagePath)) ([Windows.Storage.StorageFile])
    
    AwaitAction ([Windows.System.UserProfile.LockScreen]::SetImageFileAsync($image))
    
    Remove-Item $newImagePath
}

function Set-TerminalSettings {
    param (
        [ValidateNotNullOrEmpty()]
        [string]$Path = "$PSScriptRoot\Files\terminal-settings.json"
    )

    if (!(Test-Path $Path)) {
        throw "Path ('$Path') for Windows Terminal settings not found."
    }
    if (!(Get-AppxPackage -Name 'Microsoft.WindowsTerminal')) {
        Write-Warning "Windows Terminal isn't installed, not configuring it."
        return
    }

    $localState = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    New-Item -Path $localState -ItemType Directory -Force | Out-Null
    Copy-Item -Path $Path -Destination "$localState\settings.json" -Force

    $startup = 'HKCU:\Console\%%Startup'
    if (!(Test-Path -LiteralPath $startup)) { New-Item -Path $startup | Out-Null }
    Set-ItemProperty -LiteralPath $startup -Name 'DelegationConsole' -Value '{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}' -Type String -Force
    Set-ItemProperty -LiteralPath $startup -Name 'DelegationTerminal' -Value '{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}' -Type String -Force
}
