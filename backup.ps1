#requires -Version 7.0
# MusicBee 便携版配置和曲库备份。
param(
    [string]$ProgramDirectory = 'D:\Music\MusicBee',
    [string]$LibraryDirectory = (Join-Path $env:USERPROFILE 'Music/MusicBee'),
    [string]$Destination = (Join-Path $PSScriptRoot 'MusicBee-Backup' (Get-Date -Format 'yyyyMMdd-HHmmss-fffffff'))
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'scripts/config-common.ps1')

Assert-ApplicationStopped @('MusicBee')
$settings = Join-Path $ProgramDirectory 'AppData'
Assert-RequiredPaths $ProgramDirectory @('Configuration.xml')
Assert-RequiredPaths $settings @('MusicBee3Settings.ini')
Assert-RequiredPaths $LibraryDirectory @('MusicBeeLibrary.mbl', 'MusicBeeLibrarySettings.ini')
foreach ($src in @($ProgramDirectory, $LibraryDirectory)) { Assert-SeparatePaths $src $Destination }
New-BackupDirectory $Destination
Copy-SelectedItems $ProgramDirectory (Join-Path $Destination 'program') @('Configuration.xml', 'MusicBee.exe.config', 'TagHierarchyDefault.dat', 'Skins', 'Plugins', 'BBplugin', 'Localisation', 'Tooltips')
Copy-DirectoryContents $settings (Join-Path $Destination 'settings') @('InternalCache', 'ActivityLog.dat', 'ErrorLog.dat', 'Downloads.dat', 'AlbumCoverHashes.dat', 'Log.log')
Copy-DirectoryContents $LibraryDirectory (Join-Path $Destination 'library')
Complete-Backup $Destination

