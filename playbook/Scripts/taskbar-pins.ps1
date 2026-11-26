param (
    [switch]$AddTerminal
)

$browserPath = "$([Environment]::GetFolderPath('ProgramFiles'))\BraveSoftware\Brave-Browser\Application\brave.exe"
if (!(Test-Path $browserPath)) {
    Write-Error "Brave wasn't found!"
    exit 1
}

$shell = New-Object -ComObject WScript.Shell
$browserLink = Get-ChildItem -Path ([Environment]::GetFolderPath('CommonPrograms')), ([Environment]::GetFolderPath('Programs')) -Filter '*.lnk' -Recurse -EA 0 |
    Where-Object { $lnk = $shell.CreateShortcut($_.FullName); $lnk.TargetPath -eq $browserPath -and !$lnk.Arguments } |
    Select-Object -First 1 -ExpandProperty FullName
if (!$browserLink) {
    $browserLink = "$([Environment]::GetFolderPath('CommonPrograms'))\Brave.lnk"
    $shortcut = $shell.CreateShortcut($browserLink)
    $shortcut.TargetPath = $browserPath
    $shortcut.WorkingDirectory = Split-Path $browserPath
    $shortcut.Save()
}

$terminalPin = if ($AddTerminal) { '<taskbar:UWA AppUserModelID="Microsoft.WindowsTerminal_8wekyb3d8bbwe!App" PinGeneration="1"/>' }

Write-Output "Pinning the taskbar apps, Brave being '$browserLink'..."
$layout = @"
<?xml version="1.0" encoding="utf-8"?>
<LayoutModificationTemplate
    xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification"
    xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
    xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout"
    xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout"
    Version="1">
  <CustomTaskbarLayoutCollection PinListPlacement="Replace">
    <defaultlayout:TaskbarLayout>
      <taskbar:TaskbarPinList>
        <taskbar:DesktopApp DesktopApplicationID="Microsoft.Windows.Explorer" PinGeneration="1"/>
        <taskbar:DesktopApp DesktopApplicationLinkPath="$([Security.SecurityElement]::Escape($browserLink))" PinGeneration="1"/>
        <taskbar:UWA AppUserModelID="windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel" PinGeneration="1"/>
        $terminalPin
      </taskbar:TaskbarPinList>
    </defaultlayout:TaskbarLayout>
  </CustomTaskbarLayoutCollection>
</LayoutModificationTemplate>
"@
$layoutPath = "$([Environment]::GetFolderPath('Windows'))\GleamingOS\taskbar-layout.xml"
New-Item -Path (Split-Path $layoutPath) -ItemType Directory -Force | Out-Null
[IO.File]::WriteAllText($layoutPath, $layout, (New-Object Text.UTF8Encoding $false))

$policyPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
if (!(Test-Path $policyPath)) { New-Item -Path $policyPath -Force | Out-Null }
Set-ItemProperty -Path $policyPath -Name 'StartLayoutFile' -Value $layoutPath -Type ExpandString
Set-ItemProperty -Path $policyPath -Name 'LockedStartLayout' -Value 1 -Type DWord
