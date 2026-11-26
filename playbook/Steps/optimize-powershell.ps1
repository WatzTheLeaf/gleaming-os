# script-ngen
Invoke-Action 'Precompiling the .NET assemblies' {
    $env:path = "$([Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory());" + $env:path
    [AppDomain]::CurrentDomain.GetAssemblies().Location | ? {$_} | % {
        Write-Host "NGENing: $(Split-Path $_ -Leaf)" -ForegroundColor Yellow
        ngen install $_ | Out-Null
    }
}

# config-powershell
Invoke-Program 'cmd.exe' '/c setx POWERSHELL_TELEMETRY_OPTOUT 1 /M'
