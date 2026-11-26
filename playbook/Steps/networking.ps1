# config-dns
if (Test-Option 'dns-cloudflare') { ..\Scripts\set-dns.ps1 -Provider Cloudflare }
if (Test-Option 'dns-quad9') { ..\Scripts\set-dns.ps1 -Provider Quad9 }

# restrict-anonymous-access
Set-RegistryValue 'HKLM\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters' 'RestrictNullSessAccess' 1

# restrict-anonymous-enumeration
Set-RegistryValue 'HKLM\SYSTEM\CurrentControlSet\Control\Lsa' 'RestrictAnonymous' 1

# disable-smb-bandwidth-throttling
Set-RegistryValue 'HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters' 'DisableBandwidthThrottling' 1
