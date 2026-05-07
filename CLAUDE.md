# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

This is a MusicBee configuration backup. It stores user config so MusicBee can be restored on a new PC with identical settings, layout, ratings, play counts, and playlists.

Files here are NOT the live MusicBee installation — they are a clean snapshot for version control and portability.

## Directory to target mapping

| Repo dir | Target path |
|---|---|
| `program/` | `D:\Music\MusicBee\` (installation configs only, not binaries) |
| `settings/` | `%APPDATA%\MusicBee\` (layout, hotkeys, sync rules) |
| `library/` | `%USERPROFILE%\Music\MusicBee\` (database, playlists, lyrics) |

Music files live at `D:\Music\Music\` and are NOT tracked — they must be present on the target PC with the same path for the library to resolve.

## Updating the backup

When user config changes (new playlists, skin changes, layout tweaks), re-copy from live locations:

```powershell
# Install config
Copy-Item D:\Music\MusicBee\Configuration.xml, MusicBee.exe.config, TagHierarchyDefault.dat program/
Copy-Item D:\Music\MusicBee\Skins, Plugins, BBplugin, Localisation, Tooltips program/ -Recurse

# User settings
Copy-Item $env:APPDATA\MusicBee\* settings/ -Recurse

# Library
Copy-Item $env:USERPROFILE\Music\MusicBee\* library/ -Recurse
```

Then commit and push.

## Critical rules

### Never touch live directories
- NEVER run `rm`, `mv`, or destructive commands inside `D:\Music\MusicBee\`, `D:\Music\Music\`, or any AppData path
- When restructuring or cleaning, work in a completely separate temp directory (e.g., `D:\mb-temp\`)
- Copy files into the temp dir, build the new structure there, verify, then integrate with git

### Windows case-insensitivity
- `MusicBee` and `musicbee` resolve to the SAME directory on Windows
- If you need a separate directory, use a completely different name (e.g., `mb-config`, `backup-temp`)
- Never create a sibling directory whose name differs only in case from an existing directory

### Delete safety
- Always ask user permission before deleting any file outside the repo
- Use `git rm --cached` for index-only removals; only `rm` files in temp directories

### Binary exclusion
- `.gitignore` must exclude actual music files (`.mp3`, `.flac`, `.wav`, etc.) and MusicBee program binaries (`.exe`, `.dll`)
- The `program/` directory only contains config XML, skins, and plugin DLLs — not the MusicBee executable itself

## Restore workflow (new PC)

1. User installs MusicBee portable to `D:\Music\MusicBee`
2. User places music files at `D:\Music\Music\` with identical structure
3. Run `.\restore.ps1` to deploy program/settings/library to their target paths
4. Launch MusicBee — all config, ratings, and playlists should be intact
