# CLAUDE.md

本文件为 Claude Code 在此仓库中工作时提供指引。

## 仓库用途

这是 MusicBee 的配置备份仓库。它保存用户配置，以便在新电脑上还原完全一致的设置、布局、评分、播放次数和播放列表。

仓库中的文件**不是** MusicBee 的实时安装目录，而是用于版本管理与跨机迁移的干净快照。

## 目录映射

| 仓库目录 | 目标路径 |
|---|---|
| `program/` | `D:\Music\MusicBee\`（仅安装配置，不含程序二进制） |
| `settings/` | `D:\Music\MusicBee\AppData\`（便携模式设置目录：布局、快捷键、同步规则） |
| `library/` | `%USERPROFILE%\Music\MusicBee\`（数据库、播放列表、歌词） |

音乐文件位于 `D:\Music\Music\`，不纳入版本管理 —— 目标电脑必须保持相同路径，曲库才能正常解析。

> 早期版本把设置放在 `%APPDATA%\MusicBee\`。当前 MusicBee 以**便携模式**运行，设置目录为 `D:\Music\MusicBee\AppData\`（可在 `MusicBee3Settings.ini` 的 `ENV_OrigSetPath` 中确认）。

## 更新备份

用户配置发生变化（新增播放列表、更换皮肤、调整布局）后，从实时位置重新复制：

```powershell
# 安装配置
Copy-Item D:\Music\MusicBee\Configuration.xml, MusicBee.exe.config, TagHierarchyDefault.dat program/
Copy-Item D:\Music\MusicBee\Skins, Plugins, BBplugin, Localisation, Tooltips program/ -Recurse

# 用户设置（便携模式）
Copy-Item D:\Music\MusicBee\AppData\* settings/ -Recurse

# 曲库
Copy-Item $env:USERPROFILE\Music\MusicBee\* library/ -Recurse
```

随后提交并推送。

## 不纳入备份的内容

`settings/` 下的以下内容已由 `.gitignore` 排除，`backup.ps1` 也会在导出后剔除：

- `InternalCache/`、`AlbumCoverHashes.dat` —— 专辑封面缓存，MusicBee 会自动重建
- `ActivityLog.dat`、`ErrorLog.dat`、`Downloads.dat`、`mb_LyricsReloaded/Log.log` —— 运行日志，每次启动都会变化

## 关键规则

### 不要触碰实时目录
- 禁止在 `D:\Music\MusicBee\`、`D:\Music\Music\` 或任何 AppData 路径中执行 `rm`、`mv` 等破坏性命令
- 需要重构或清理时，在完全独立的临时目录中操作（例如 `D:\Music\mb-config\`）
- 先把文件复制到临时目录，在那里构建新结构，验证无误后再与 git 集成

### Windows 大小写不敏感
- `MusicBee` 与 `musicbee` 在 Windows 上指向同一目录
- 如需独立目录，请使用完全不同的名称（例如 `mb-config`、`backup-temp`）
- 不要创建与现有目录仅大小写不同的兄弟目录

### 删除安全
- 删除仓库之外的任何文件前，必须先征得用户同意
- 索引级移除使用 `git rm --cached`；只在临时目录中使用 `rm`

### 二进制排除
- `.gitignore` 必须排除音乐文件（`.mp3`、`.flac`、`.wav` 等）和 MusicBee 程序二进制（`.exe`、`.dll`）
- `program/` 只包含配置 XML、皮肤和插件 DLL，不包含 MusicBee 主程序

## 还原流程（新电脑）

1. 安装 MusicBee 便携版到 `D:\Music\MusicBee`
2. 将音乐文件放到 `D:\Music\Music\`，保持原有目录结构
3. 运行 `.\restore.ps1`，把 program/settings/library 部署到各自目标路径
4. 启动 MusicBee —— 配置、评分和播放列表应完整恢复
