$packages = @('*Z-Atlas-NoTelemetry-Package*')
if (Test-Option 'defender-disable') { $packages += '*Z-Atlas-NoDefender-Package*' }
& "..\Scripts\install-packages.ps1" -InstallPackages $packages
