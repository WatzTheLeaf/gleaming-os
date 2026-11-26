param (
    [Parameter(Mandatory)][ValidateSet('Cloudflare', 'Quad9')][string]$Provider
)

$providers = @{
    Cloudflare = @{ Template = 'https://cloudflare-dns.com/dns-query'; Servers = '1.1.1.1', '1.0.0.1', '2606:4700:4700::1111', '2606:4700:4700::1001' }
    Quad9      = @{ Template = 'https://dns.quad9.net/dns-query';      Servers = '9.9.9.9', '149.112.112.112', '2620:fe::fe', '2620:fe::9' }
}
$p = $providers.$Provider

foreach ($ip in $p.Servers) {
    $dohArgs = @{ ServerAddress = $ip; DohTemplate = $p.Template; AllowFallbackToUdp = $false; AutoUpgrade = $true }
    if (Get-DnsClientDohServerAddress -ServerAddress $ip -EA 0) { Set-DnsClientDohServerAddress @dohArgs }
    else { Add-DnsClientDohServerAddress @dohArgs }
}

foreach ($adapter in Get-NetAdapter -Physical) {
    Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses $p.Servers
    foreach ($ip in $p.Servers) {
        $family = ('Doh', 'Doh6')[$ip -like '*:*']
        $key = "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters\$($adapter.InterfaceGuid)\DohInterfaceSettings\$family\$ip"
        New-Item -Path $key -Force | Out-Null
        New-ItemProperty -Path $key -Name 'DohFlags' -Value 1 -PropertyType QWord -Force | Out-Null
    }
}

Clear-DnsClientCache