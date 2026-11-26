#Requires -RunAsAdministrator

param (
	[array]$InstallPackages,
	[string]$PackagesPath = "$([Environment]::GetFolderPath('Windows'))\GleamingOS\Packages"
)

if (!([Security.Principal.WindowsIdentity]::GetCurrent().User.Value -eq 'S-1-5-18')) {
	throw "This script must be ran as TrustedInstaller/SYSTEM."
}

$windir = [Environment]::GetFolderPath('Windows')
$errorLevel = 0

if ($InstallPackages) {
	$arch = ('amd64', 'arm64')[[int](Test-Arm64)]
	$matchedPackages = @()
	$notMatchedPackages = $InstallPackages
	(Get-ChildItem $PackagesPath -File -Filter "*.cab").FullName | Sort-Object -Descending | ForEach-Object {
		foreach ($package in $notMatchedPackages) {
			if (($_ -like $package) -and ($_ -match "$arch")) {
				$matchedPackages += $_
				$notMatchedPackages = $notMatchedPackages -ne $package
				break
			}
		}
	}

	if ($matchedPackages.Count -eq 0) {
		Write-Failure "The specified CABs ($InstallPackages) to install weren't found."
		exit 1
	}
	if ($notMatchedPackages.Count -gt 0) {
		Write-Host "[WARN] These CABs to install weren't found: $notMatchedPackages" -ForegroundColor Yellow
	}
}

function ProcessCab($cabPath) {
	$filePath = Split-Path $cabPath -Leaf
	Write-Host "`nInstalling $filePath..." -ForegroundColor Cyan
	Write-Host ("-" * 84) -ForegroundColor Magenta

	Write-Host "[INFO] Checking certificate..."
	try {
		$cert = (Get-AuthenticodeSignature $cabPath).SignerCertificate
		if ($cert.Extensions.EnhancedKeyUsages.Value -ne "1.3.6.1.4.1.311.10.3.6") {
			Write-Failure "${filePath}: the certificate doesn't have the proper key usages."
			$script:errorLevel++
			return $false
		}

		$certRegPath = "HKLM:\Software\Microsoft\SystemCertificates\ROOT\Certificates\8A334AA8052DD244A647306A76B8178FA215F344"
		if (!(Test-Path "$certRegPath")) {
			New-Item -Path $certRegPath -Force | Out-Null
		}
	} catch {
		Write-Failure "${filePath}: certificate error: $_"
		$script:errorLevel++
		return $false
	}

	Write-Host "[INFO] Adding package..."
	try {
		Add-WindowsPackage -Online -PackagePath $cabPath -NoRestart -IgnoreCheck -LogLevel 1 *>$null
	} catch {
		Write-Failure "${filePath}: adding the package failed: $_"
		$script:errorLevel++
		return $false
	}

	Write-Host "[INFO] Completed successfully."
	return $true
}

function MakeRepairSource {
	$version = '38655.38527.65535.65535'
	$srcPath = "%SystemRoot%\GleamingOS\Packages\WinSxS"
	$srcPathExpanded = [System.Environment]::ExpandEnvironmentVariables($srcPath)

	Write-Host "`nMaking repair source..." -ForegroundColor Cyan
	Write-Host ("-" * 84) -ForegroundColor Magenta

	Write-Host "[INFO] Getting manifests..."
	$manifests = Get-ChildItem "$windir\WinSxS\Manifests" -File -Filter "*$version*"
	if ($manifests.Count -eq 0) {
		Write-Host "[WARN] No manifests found! Can't create repair source." -ForegroundColor Yellow
		return $false
	}

	if (Test-Path $srcPathExpanded -PathType Container) {
		Write-Host "[INFO] Deleting old RepairSrc..."
		Remove-Item $srcPathExpanded -Force -Recurse
	}
	Write-Host "[INFO] Creating RepairSrc path..."
	New-Item "$srcPathExpanded\Manifests" -Force -ItemType Directory | Out-Null

	Write-Host "[INFO] Hard linking manifests..."
	foreach ($manifest in $manifests) {
		New-Item -ItemType HardLink -Path "$srcPathExpanded\Manifests\$manifest" -Target $manifest.FullName | Out-Null
	}

	$servicingPolicyKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Servicing"
	if (!(Test-Path $servicingPolicyKey)) { New-Item -Path $servicingPolicyKey -Force | Out-Null }
	Set-ItemProperty -Path $servicingPolicyKey -Name LocalSourcePath -Value "$srcPath" -Type ExpandString -Force
}

$installed = 0
foreach ($package in $matchedPackages) {
	if (ProcessCab $package) { $installed++ }
}

if ($installed -gt 0) {
	MakeRepairSource
}

exit $errorLevel
