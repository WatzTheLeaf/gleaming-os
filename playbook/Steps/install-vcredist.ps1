$timeouts = @("--connect-timeout", "10", "--retry", "5", "--retry-delay", "0", "--retry-all-errors")

function Remove-TempDirectory { Pop-Location; Remove-Item -Path $tempDir -Force -Recurse -EA 0 }
$tempDir = Join-Path -Path $env:TEMP -ChildPath ([guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
Push-Location $tempDir

$failed = $false
function Write-UtilityFailure ([string]$Message) {
    Write-Error $Message
    $script:failed = $true
}

foreach ($vcArch in 'x64', 'x86') {
    $vcExePath = "$tempDir\vc_redist.$vcArch.exe"
    Write-Output "Downloading and installing Visual C++ Runtime ($vcArch)..."
    & curl.exe -fLSs "https://aka.ms/vs/17/release/vc_redist.$vcArch.exe" -o $vcExePath $timeouts
    if ($LASTEXITCODE -ne 0) {
        Write-UtilityFailure "Downloading Visual C++ Runtime ($vcArch) failed (curl exit code $LASTEXITCODE)."
        continue
    }
    $exitCode = (Start-Process -FilePath $vcExePath -ArgumentList '/install /quiet /norestart' -Wait -PassThru -WindowStyle Hidden).ExitCode
    if ($exitCode -notin 0, 1638, 3010) {
        Write-UtilityFailure "Installing Visual C++ Runtime ($vcArch) failed (exit code $exitCode)."
    }
}

Remove-TempDirectory
if ($failed) { exit 1 }
