Get-ChildItem -Path 'Fonts\HurmitNerdFont' -Filter '*.otf' | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination "$([Environment]::GetFolderPath('Windows'))\Fonts" -Force
    $style = $_.BaseName -replace '^HurmitNerdFont-' -creplace '(?<=[a-z])(?=[A-Z])', ' '
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' -Name "Hurmit Nerd Font $style (OpenType)" -Value $_.Name -Type String -Force
}

Set-TerminalSettings
