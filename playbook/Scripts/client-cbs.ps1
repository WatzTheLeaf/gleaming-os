$windir = [Environment]::GetFolderPath('Windows')
$settingsExtensions = (Get-ChildItem "$windir\SystemApps" -Recurse).FullName | Where-Object { $_ -like '*wsxpacks\Account\SettingsExtensions.json*' }

function Find-VelocityID($Node) {
    $ids = @()
    if ($Node -is [PSCustomObject]) {
        foreach ($property in $Node.PSObject.Properties) {
            if ($property.Name -eq 'velocityKey' -and $property.Value.id) {
                $ids += $property.Value.id
            }
            Find-VelocityID -Node $property.Value
        }
    } elseif ($Node -is [Array]) {
        foreach ($element in $Node) {
            Find-VelocityID -Node $element
        }
    }

    return $ids
}
$ids = @()
foreach ($settingsJson in $settingsExtensions) {
    $ids += Find-VelocityID -Node $(Get-Content -Path $settingsJson | ConvertFrom-Json)
}

if ($ids.Count -le 0) {
    Write-Output "No velocity IDs were found. Exiting."
    exit 1
}

& "..\Scripts\settings-pages.cmd" /hide account

$viveZip = Get-ChildItem "ViVeTool-*.zip" -Name
if (Test-Arm64) {
    $viveZip = $viveZip | Where-Object { $_ -match '-ARM64CLR' }
} else {
    $viveZip = $viveZip | Where-Object { $_ -notmatch '-ARM64CLR' }
}

if ($viveZip) {
    $viveFolder = Join-Path -Path (Get-Location) -ChildPath "vivetool"
    if (!(Test-Path -Path $viveFolder)) {
        New-Item -ItemType Directory -Path $viveFolder | Out-Null
    }
    Expand-Archive -Path $viveZip -DestinationPath $viveFolder -Force
} else {
    throw "ViVeTool not found!"
}
$env:PATH += ";$viveFolder"
if (!(Get-Command 'vivetool' -EA 0)) {
    throw "ViVeTool EXE not found in ZIP!"
}

foreach ($id in $($ids | Sort-Object -Unique)) {
    Write-Output "Disabling feature ID $id..."
    ViVeTool.exe /disable /id:$id | Out-Null
}