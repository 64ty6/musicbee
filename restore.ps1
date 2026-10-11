#requires -Version 7.0
# MusicBee 恢复，全部源目录通过校验后再覆盖。
param(
    [string]$Source = $PSScriptRoot,
    [string]$ProgramDirectory = 'D:\Music\MusicBee',
    [string]$LibraryDirectory = (Join-Path $env:USERPROFILE 'Music/MusicBee')
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'scripts/config-common.ps1')

Assert-ApplicationStopped @('MusicBee')
Assert-RequiredPaths $ProgramDirectory @('MusicBee.exe')
Assert-RequiredPaths (Join-Path $Source 'program') @('Configuration.xml')
Assert-RequiredPaths (Join-Path $Source 'settings') @('MusicBee3Settings.ini')
Assert-RequiredPaths (Join-Path $Source 'library') @('MusicBeeLibrary.mbl', 'MusicBeeLibrarySettings.ini')
if (Test-Path -LiteralPath (Join-Path $Source '.backup-incomplete')) { throw '该备份尚未完成，不能恢复。' }
Restore-Configuration @(
    @{ Source = (Join-Path $Source 'program'); Destination = $ProgramDirectory },
    @{ Source = (Join-Path $Source 'settings'); Destination = (Join-Path $ProgramDirectory 'AppData') },
    @{ Source = (Join-Path $Source 'library'); Destination = $LibraryDirectory }
)

