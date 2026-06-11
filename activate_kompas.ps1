# activate_kompas.ps1

# === ВСТАВЬТЕ КЛЮЧ СЮДА ===
$Key = "OrjKBN-5bwTKo-Ts1NCu-wXUbWB-XfK4ZH"
# ==========================

# Возможные пути установки КОМПАС-3D V24
$PossiblePaths = @(
    "C:\Program Files\ASCON\KOMPAS-3D V24",
    "C:\Program Files (x86)\ASCON\KOMPAS-3D V24",
    "D:\Program Files\ASCON\KOMPAS-3D V24",
    "D:\ASCON\KOMPAS-3D V24"
)

$InstallDir = $null
foreach ($p in $PossiblePaths) {
    if (Test-Path $p) { $InstallDir = $p; break }
}

if (-not $InstallDir) {
    # Поиск по реестру
    $reg = Get-ItemProperty "HKLM:\SOFTWARE\ASCON\*" -ErrorAction SilentlyContinue |
           Where-Object { $_.InstallPath -match "V24" } |
           Select-Object -First 1
    if ($reg) { $InstallDir = $reg.InstallPath }
}

if (-not $InstallDir) {
    Write-Host "КОМПАС-3D V24 не найден. Укажите путь вручную:" -ForegroundColor Red
    $InstallDir = Read-Host "Путь"
}

Write-Host "Папка установки: $InstallDir" -ForegroundColor Cyan

# Поиск утилиты активации
$ActivationTool = Get-ChildItem -Path $InstallDir -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match "kActivat|Activat|licens|protect" -and $_.Extension -eq ".exe" } |
    Select-Object -First 1

if ($ActivationTool) {
    Write-Host "Запуск утилиты активации: $($ActivationTool.Name)" -ForegroundColor Green
    Write-Host "Введите ключ в открывшемся окне: $Key" -ForegroundColor Yellow
    Start-Process -FilePath $ActivationTool.FullName -Wait
} else {
    # Запуск самого КОМПАС — он предложит активацию при старте
    $Kompas = Get-ChildItem -Path $InstallDir -Filter "kompas*.exe" -ErrorAction SilentlyContinue |
              Select-Object -First 1
    if ($Kompas) {
        Write-Host "Запуск КОМПАС-3D для активации..." -ForegroundColor Green
        Write-Host "Ваш ключ: $Key" -ForegroundColor Yellow
        Start-Process -FilePath $Kompas.FullName
    } else {
        Write-Host "Исполняемый файл не найден в $InstallDir" -ForegroundColor Red
    }
}

Read-Host "Press Enter to exit"
