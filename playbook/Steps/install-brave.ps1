$ErrorActionPreference = 'Stop'

# The machine-wide offline installers, also used by winget
$asset = ('BraveBrowserStandaloneSetup.exe', 'BraveBrowserStandaloneSetupArm64.exe')[[int](Test-Arm64)]
$installer = Join-Path $env:TEMP $asset
try {
    Save-GitHubAsset -Repository 'brave/brave-browser' -Name $asset -Path $installer

    Write-Output "Installing Brave..."
    # Not Start-Process -Wait, which also waits for Brave's update service
    $process = Start-Process -FilePath $installer -ArgumentList '/silent /install' -WindowStyle Hidden -PassThru
    # Reading the handle keeps ExitCode available after the process exits
    $null = $process.Handle
    $process.WaitForExit()
    if ($process.ExitCode -ne 0) { throw "Installing Brave failed (exit code $($process.ExitCode))." }
}
finally {
    Remove-Item -Path $installer -Force -EA 0
}

Stop-Process -Name 'brave' -Force -EA 0
if (!(Test-Path "$env:ProgramFiles\BraveSoftware\Brave-Browser\Application\brave.exe")) {
    throw "Installing Brave failed, brave.exe wasn't found."
}
