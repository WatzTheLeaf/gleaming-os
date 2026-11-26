$ErrorActionPreference = 'Stop'

$removeEdge = Join-Path $env:TEMP 'Remove-Edge.exe'
try {
    Save-GitHubAsset -Repository 'ShadowWhisperer/Remove-MS-Edge' -Name 'Remove-Edge.exe' -Path $removeEdge
    Write-Output 'Uninstalling Microsoft Edge...'
    Start-Process -FilePath $removeEdge -WindowStyle Hidden -Wait
}
finally {
    Remove-Item -Path $removeEdge -Force -EA 0
}
if (Test-Path "$([Environment]::GetFolderPath('ProgramFilesX86'))\Microsoft\Edge\Application\msedge.exe") {
    throw 'Microsoft Edge is still installed after running Remove-Edge.'
}

Write-Output 'Removing Edge user data...'
Get-Service -Name '*edge*' -EA 0 | Where-Object DisplayName -like '*Microsoft Edge*' | Stop-Service -Force -EA 0
Get-Process -Name 'msedge*', 'MicrosoftEdge*' -EA 0 | Stop-Process -Force -EA 0
$edgeData = "$([Environment]::GetFolderPath('LocalApplicationData'))\Microsoft\Edge"
if (Test-Path $edgeData) { Remove-Item -Path $edgeData -Recurse -Force }
