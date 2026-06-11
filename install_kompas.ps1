# ============================================================
# install_kompas.ps1
# Поместите этот скрипт в ту же папку, что и установщик КОМПАС-3D
# ============================================================

# === ВСТАВЬТЕ КЛЮЧ АКТИВАЦИИ СЮДА ===
$ActivationKey = "XXXXX-XXXXX-XXXXX-XXXXX"
# =====================================

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# --- 1. Поиск установщика в папке скрипта ---
$Installer = Get-ChildItem -Path $ScriptDir -Filter "*.exe" | Where-Object { $_.Name -match "kompas|KOMPAS|Kompas" } | Select-Object -First 1

if (-not $Installer) {
    Write-Host "ОШИБКА: Установщик КОМПАС не найден в папке $ScriptDir" -ForegroundColor Red
    exit 1
}

Write-Host "Найден установщик: $($Installer.Name)" -ForegroundColor Cyan

# --- 2. Удаление старого КОМПАС-3D ---
Write-Host "`nШаг 1: Удаление существующего КОМПАС-3D..." -ForegroundColor Yellow

$UninstallKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$KompasEntry = $null
foreach ($Key in $UninstallKeys) {
    $KompasEntry = Get-ItemProperty $Key -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -match "КОМПАС|KOMPAS" } |
        Select-Object -First 1
    if ($KompasEntry) { break }
}

if ($KompasEntry) {
    Write-Host "Найдена установка: $($KompasEntry.DisplayName)" -ForegroundColor Green
    $UninstallString = $KompasEntry.UninstallString

    # Для тихого удаления
    if ($UninstallString -match "msiexec") {
        $ProductCode = $KompasEntry.PSChildName
        Write-Host "Удаление (MSI)..."
        Start-Process "msiexec.exe" -ArgumentList "/x $ProductCode /qn /norestart" -Wait
    } else {
        Write-Host "Удаление (EXE)..."
        Start-Process -FilePath $UninstallString -ArgumentList "/S /silent /quiet" -Wait
    }

    Write-Host "Удаление завершено." -ForegroundColor Green
} else {
    Write-Host "Установка КОМПАС не найдена, пропускаем удаление." -ForegroundColor Gray
}

# --- 3. Установка нового КОМПАС-3D ---
Write-Host "`nШаг 2: Установка нового КОМПАС-3D..." -ForegroundColor Yellow
Write-Host "Запуск: $($Installer.FullName)"

# Тихая установка — если установщик поддерживает ключ /S или /silent
Start-Process -FilePath $Installer.FullName -ArgumentList "/S /silent" -Wait

Write-Host "Установка завершена." -ForegroundColor Green

# --- 4. Активация ---
Write-Host "`nШаг 3: Активация КОМПАС-3D..." -ForegroundColor Yellow
Write-Host "Ключ активации: $ActivationKey"
Write-Host ""
Write-Host "ВАЖНО: КОМПАС-3D не поддерживает полностью автоматическую активацию через командную строку." -ForegroundColor Magenta
Write-Host "После запуска программы введите ключ вручную в окне активации, либо используйте утилиту активации из папки установки." -ForegroundColor Magenta

# Попытка найти и запустить утилиту активации АСКОН
$KompasInstallDir = "C:\Program Files\ASCON\KOMPAS-3D*"
$ActivationTool = Get-ChildItem -Path $KompasInstallDir -Filter "*activ*" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

if ($ActivationTool) {
    Write-Host "Найдена утилита активации: $($ActivationTool.FullName)" -ForegroundColor Cyan
    Start-Process -FilePath $ActivationTool.FullName
} else {
    Write-Host "Утилита активации не найдена автоматически. Запустите активацию вручную." -ForegroundColor Gray
}

Write-Host "`nГотово!" -ForegroundColor Green
Read-Host "Нажмите Enter для выхода"
