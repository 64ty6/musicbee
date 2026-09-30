# MusicBee 配置备份
# 将当前配置导出到备份目录

$dest = Join-Path $PSScriptRoot "MusicBee-Backup" (Get-Date -Format "yyyyMMdd-HHmmss")

Write-Host "=== MusicBee 配置备份 ===" -ForegroundColor Cyan
Write-Host "→ $dest`n"

# program/ — D:\Music\MusicBee 中的配置
Write-Host "[1/3] 安装目录配置..." -ForegroundColor Yellow
$dst = Join-Path $dest "program"
New-Item -ItemType Directory -Path $dst -Force | Out-Null
@("Configuration.xml","MusicBee.exe.config","TagHierarchyDefault.dat",
  "Skins","Plugins","BBplugin","Localisation","Tooltips") | ForEach-Object {
    $s = Join-Path "D:\Music\MusicBee" $_
    if (Test-Path $s) { Copy-Item $s -Destination $dst -Recurse -Force }
}
Write-Host "  完成" -ForegroundColor Green

# settings/ — D:\Music\MusicBee\AppData (便携模式设置目录)
Write-Host "[2/3] 用户设置..." -ForegroundColor Yellow
$s = "D:\Music\MusicBee\AppData"
$d = Join-Path $dest "settings"
if (Test-Path $s) {
    Copy-Item $s -Destination $d -Recurse -Force
    # 剔除缓存和运行日志：可由 MusicBee 自动重建，见 .gitignore
    @("InternalCache","ActivityLog.dat","ErrorLog.dat","Downloads.dat",
      "AlbumCoverHashes.dat") | ForEach-Object {
        $p = Join-Path $d $_
        if (Test-Path $p) { Remove-Item $p -Recurse -Force }
    }
    $log = Join-Path $d "mb_LyricsReloaded\Log.log"
    if (Test-Path $log) { Remove-Item $log -Force }
    Write-Host "  完成" -ForegroundColor Green
}

# library/ — %USERPROFILE%\Music\MusicBee
Write-Host "[3/3] 曲库数据库..." -ForegroundColor Yellow
$s = "$env:USERPROFILE\Music\MusicBee"
$d = Join-Path $dest "library"
if (Test-Path $s) { Copy-Item $s -Destination $d -Recurse -Force; Write-Host "  完成" -ForegroundColor Green }

Write-Host "`n=== 完成 ===" -ForegroundColor Cyan
