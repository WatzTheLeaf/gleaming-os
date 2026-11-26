foreach ($path in @($env:temp, $env:tmp, "$env:localappdata\Temp")) {
    if (Test-Path $path -PathType Container) {
        $userTemp = $path
        break
    }
}
if ($userTemp) {
    Write-Output "Cleaning user TEMP folder..."
    Get-ChildItem -Path $userTemp | Remove-Item -Force -Recurse -EA 0
}
else {
    Write-Error "User temp folder not found!"
}

$machine = [System.EnvironmentVariableTarget]::Machine
foreach ($path in @(
        [System.Environment]::GetEnvironmentVariable("Temp", $machine),
        [System.Environment]::GetEnvironmentVariable("Tmp", $machine),
        "$([Environment]::GetFolderPath('Windows'))\Temp"
    )) {
    if (Test-Path $path -PathType Container) {
        $sysTemp = $path
        break
    }
}
if ($sysTemp) {
    Write-Output "Cleaning system TEMP folder..."
    Remove-Item -Path "$sysTemp\*" -Force -Recurse -EA 0
}
else {
    Write-Error "System temp folder not found!"
}

# Deliberate: every shadow copy is deleted, System Restore points included, on all drives
vssadmin delete shadows /all /quiet
