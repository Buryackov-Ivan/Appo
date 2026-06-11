[System.IO.File]::WriteAllText("D:\Компас\install_kompas.ps1", @'
$ActivationKey = "OrjKBN-5bwTKo-Ts1NCu-wXUbWB-XfK4ZH"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Installer = Get-ChildItem -Path $ScriptDir -Filter "*.exe" | Select-Object -First 1
if (-not $Installer) { Write-Host "Installer not found"; exit 1 }
Write-Host "Found: $($Installer.Name)"
$keys = @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*","HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*")
foreach ($k in $keys) {
    $e = Get-ItemProperty $k -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -match "KOMPAS|KOMPAS-3D" } | Select-Object -First 1
    if ($e) {
        Write-Host "Removing: $($e.DisplayName)"
        if ($e.UninstallString -match "msiexec") { Start-Process msiexec.exe -ArgumentList "/x $($e.PSChildName) /qn /norestart" -Wait }
        else { Start-Process -FilePath $e.UninstallString -ArgumentList "/S" -Wait }
        break
    }
}
Write-Host "Installing..."
Start-Process -FilePath $Installer.FullName -ArgumentList "/S" -Wait
Write-Host "Done. Enter activation key manually: $ActivationKey"
Read-Host "Press Enter to exit"
'@, [System.Text.Encoding]::UTF8)
