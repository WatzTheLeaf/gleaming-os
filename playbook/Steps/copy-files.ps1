$windir = [Environment]::GetFolderPath('Windows')
if (!(Test-Path 'GleamingOS')) { exit 1 }
Copy-Item -Path 'GleamingOS' -Destination $windir -Force -Recurse
if (!$?) { exit 2 }
Copy-Item -Path 'Themes\*' -Destination "$windir\Resources\Themes" -Force -Recurse
