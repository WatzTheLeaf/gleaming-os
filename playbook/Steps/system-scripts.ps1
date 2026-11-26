# script-file-associations
Invoke-Program 'cmd.exe' '/c ..\Scripts\set-file-associations.cmd'

# script-core-isolation
if (Test-Option 'disable-core-isolation') {
    Invoke-Action 'Disabling virtualization-based security' {
        $memIntegrity = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
        $kernelShadowStacks = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\KernelShadowStacks"
        $credentialGuard = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\CredentialGuard"

        Write-Warning "Disabling VBS features..."

        if (!(Test-Path $memIntegrity)) { New-Item -Path $memIntegrity -Force | Out-Null }
        New-ItemProperty -Path $memIntegrity -Name "Enabled" -Value 0 -PropertyType DWORD -Force

        if (Test-Path $kernelShadowStacks) {
            New-ItemProperty -Path $kernelShadowStacks -Name "Enabled" -Value 0 -PropertyType DWORD -Force
            Remove-ItemProperty -Path $kernelShadowStacks -Name "ChangedInBootCycle" -EA 0
            Remove-ItemProperty -Path $kernelShadowStacks -Name "WasEnabledBy" -EA 0
        }

        if (Test-Path $credentialGuard) {
            New-ItemProperty -Path $credentialGuard -Name "Enabled" -Value 0 -PropertyType DWORD -Force
            Remove-ItemProperty -Path $credentialGuard -Name "ChangedInBootCycle" -EA 0
            Remove-ItemProperty -Path $credentialGuard -Name "WasEnabledBy" -EA 0
        }

        New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL" -Value 0 -PropertyType DWORD -Force

        New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" -Name "EnableVirtualizationBasedSecurity" -Value 0 -PropertyType DWORD -Force
    }
}

# script-devices
Disable-NetAdapterBinding -Name "*" -ComponentID ms_lldp

# script-pfp
Invoke-Action 'Setting the account pictures' {
    Add-Type -AssemblyName System.Drawing
    $img = [System.Drawing.Image]::FromFile((Get-Item '.\user.png'))

    $resolutions = @{
        "user.png" = 448
        "user.bmp" = 448
        "guest.png" = 448
        "guest.bmp" = 448
        "user-192.png" = 192
        "user-48.png" = 48
        "user-40.png" = 40
        "user-32.png" = 32
    }

    foreach ($image in $resolutions.Keys) {
        $resolution = $resolutions[$image]

        $a = New-Object System.Drawing.Bitmap($resolution, $resolution)
        $graph = [System.Drawing.Graphics]::FromImage($a)
        $graph.DrawImage($img, 0, 0, $resolution, $resolution)
        $a.Save("$([Environment]::GetFolderPath('CommonApplicationData'))\Microsoft\User Account Pictures\$image")
    }
}

# script-clientcbs
..\Scripts\client-cbs.ps1
