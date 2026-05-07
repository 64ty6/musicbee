# MusicBee 配置还原
# 将仓库中的配置部署到系统对应路径

param(
    [string]$Source = $PSScriptRoot
)

Write-Host "=== MusicBee 配置还原 ===" -ForegroundColor Cyan

$mb = Get-Process MusicBee -ErrorAction SilentlyContinue
if ($mb) { Write-Host "请先关闭 MusicBee" -ForegroundColor Red; exit 1 }

# program/ → D:\Music\MusicBee
Write-Host "[1/3] 安装目录配置..." -ForegroundColor Yellow
$src = Join-Path $Source "program"
if (Test-Path $src) {
    Get-ChildItem $src | Copy-Item -Destination "D:\Music\MusicBee" -Recurse -Force
    Write-Host "  D:\Music\MusicBee\" -ForegroundColor Green
}

# settings/ → %APPDATA%\MusicBee
Write-Host "[2/3] 用户设置..." -ForegroundColor Yellow
$src = Join-Path $Source "settings"
$dst = "$env:APPDATA\MusicBee"
if (Test-Path $src) {
    if (-not (Test-Path $dst)) { New-Item -ItemType Directory -Path $dst -Force | Out-Null }
    Get-ChildItem $src | Copy-Item -Destination $dst -Recurse -Force
    Write-Host "  $dst" -ForegroundColor Green
}

# library/ → %USERPROFILE%\Music\MusicBee
Write-Host "[3/3] 曲库数据库..." -ForegroundColor Yellow
$src = Join-Path $Source "library"
$dst = "$env:USERPROFILE\Music\MusicBee"
if (Test-Path $src) {
    if (-not (Test-Path $dst)) { New-Item -ItemType Directory -Path $dst -Force | Out-Null }
    Get-ChildItem $src | Copy-Item -Destination $dst -Recurse -Force
    Write-Host "  $dst" -ForegroundColor Green
}

Write-Host "`n=== 完成 ===" -ForegroundColor Cyan
Write-Host "启动 MusicBee 即可。"
