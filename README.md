# MusicBee 配置备份

本仓库是 MusicBee 播放器**便携模式**的配置快照，用于在新电脑上完整恢复相同的曲库、评分、播放次数、播放列表、布局、皮肤与插件。

> 本文是**给 AI 助手执行还原的操作手册**。clone 本仓库后，请 AI 助手按"还原步骤"逐步执行。

---

## 前置要求

1. **安装 MusicBee 3.x 便携版（Portable）到 `D:\Music\MusicBee\`**
   - 必须是**便携版（Portable）**。本备份的设置目标是安装目录下的 `AppData\`，只有便携模式才使用该目录；若装成标准安装版，设置会写到 `%APPDATA%\MusicBee\`，本仓库的 `settings/` 不会生效。
   - 具体版本号：**需确认**（本备份由 MusicBee 3.x 生成，设置文件名为 `MusicBee3Settings.ini`）。

2. **音乐文件必须先复制回 `D:\Music\Music\`，且目录结构一致**（如 `歌手\专辑\曲目`）。
   - 音乐文件**不在本仓库中**。曲库数据库记录的是绝对路径，音乐缺失或路径不同会导致曲库全部显示"丢失"。

3. **还原前必须关闭 MusicBee**（含托盘图标），否则文件被占用会导致复制失败，或被运行中的程序回写覆盖。

---

## 还原步骤（AI 操作指引）

> **写给 AI 助手：**
> 请在**仓库根目录**（即包含 `program/`、`settings/`、`library/` 的目录）依次执行下列步骤。
> 每条命令执行后，先核对"期望结果"再继续下一步。
> 一旦出现**路径不存在、进程占用、文件缺失、复制报错**等与预期不符的情况，**立即停下并如实告知用户**，不要猜测、不要强行继续、不要擅自删除任何文件。
> 命令均为 **PowerShell**。

### 步骤 0：检查环境

**目的**：确认仓库三大目录完整、目标盘与关键路径存在。

```powershell
# 在仓库根目录执行
Get-Location
Test-Path program, settings, library          # 应为 True True True
Test-Path D:\Music                            # 应为 True
Test-Path D:\Music\Music                      # 应为 True（音乐文件已就位）
Test-Path D:\Music\MusicBee                   # 应为 True（MusicBee 已安装）
```

**期望结果**：`program, settings, library` 三项全为 `True`；`D:\Music`、`D:\Music\Music`、`D:\Music\MusicBee` 均为 `True`。

**不满足时**：
- 仓库目录缺失 → clone 不完整，请用户重新 clone。
- `D:\Music\Music` 为 `False` → 音乐文件尚未就位，**停止**，请用户先复制音乐文件。
- `D:\Music\MusicBee` 为 `False` → MusicBee 尚未安装，**停止**，请用户先安装便携版。

### 步骤 1：确认 MusicBee 已退出

**目的**：避免文件占用与配置回写污染。

```powershell
$p = Get-Process MusicBee -ErrorAction SilentlyContinue
if ($p) { "MusicBee 仍在运行，PID: $($p.Id)" } else { "已退出，可继续" }
```

**期望结果**：输出 `已退出，可继续`。

**不满足时**：请用户关闭 MusicBee（包括系统托盘图标）后重新检查。**不要**自行执行 `Stop-Process`；若进程无响应，提示用户从任务管理器结束。

### 步骤 2：复制 program → `D:\Music\MusicBee\`

**目的**：部署安装目录下的配置、皮肤、插件、语言包、可视化效果。

```powershell
Copy-Item .\program\* D:\Music\MusicBee\ -Recurse -Force
Test-Path D:\Music\MusicBee\Configuration.xml   # 应为 True
```

**期望结果**：无报错；`D:\Music\MusicBee\Configuration.xml` 为 `True`。

**不满足时**：
- 出现"拒绝访问 / 文件被占用" → 回到步骤 1 确认 MusicBee 已退出。
- 目标目录不存在 → 回到步骤 0 确认 MusicBee 已安装。

> 说明：仓库不含 MusicBee 主程序（`.exe`），本步骤只覆盖配置与资源，不会替换用户已安装的程序本体。

### 步骤 3：复制 settings → `D:\Music\MusicBee\AppData\`

**目的**：恢复便携模式下的用户设置（布局、快捷键、排序、同步规则、歌词插件设置等）。

```powershell
$dst = 'D:\Music\MusicBee\AppData'
if (-not (Test-Path $dst)) { New-Item -ItemType Directory -Path $dst -Force | Out-Null }
Copy-Item .\settings\* $dst -Recurse -Force
Test-Path (Join-Path $dst 'MusicBee3Settings.ini')   # 应为 True
```

**期望结果**：无报错；`D:\Music\MusicBee\AppData\MusicBee3Settings.ini` 为 `True`。

**不满足时**：
- 目标目录无法创建 → 确认 `D:\Music\MusicBee` 存在且当前用户有写权限。
- **切勿**复制到 `%APPDATA%\MusicBee\`——那是标准安装版的目录，便携模式不读取它。

### 步骤 4：复制 library → `%USERPROFILE%\Music\MusicBee\`

**目的**：恢复曲库数据库、评分与播放次数、歌词库、播放列表。

```powershell
$dst = Join-Path $env:USERPROFILE 'Music\MusicBee'
if (-not (Test-Path $dst)) { New-Item -ItemType Directory -Path $dst -Force | Out-Null }
Copy-Item .\library\* $dst -Recurse -Force
$dst
Test-Path (Join-Path $dst 'MusicBeeLibrary.mbl')     # 应为 True
Test-Path (Join-Path $dst 'Playlists')               # 应为 True
```

**期望结果**：输出目标路径；`MusicBeeLibrary.mbl` 与 `Playlists` 均为 `True`。

**不满足时**：
- 若目标目录已存在旧的 `.mbl` 且用户不希望覆盖 → **先征求用户确认**，不要擅自删除旧文件（`-Force` 会覆盖同名文件）。
- 目标目录不可写 → 检查用户配置文件目录权限。

### 步骤 5：验证

**目的**：确认三处均已到位。

```powershell
Test-Path D:\Music\MusicBee\Configuration.xml
Test-Path D:\Music\MusicBee\AppData\MusicBee3Settings.ini
Test-Path (Join-Path $env:USERPROFILE 'Music\MusicBee\MusicBeeLibrary.mbl')
Test-Path (Join-Path $env:USERPROFILE 'Music\MusicBee\Playlists')
```

**期望结果**：四项全为 `True`。

**不满足时**：对应回到步骤 2 / 3 / 4 重做；并核对源目录确有该文件（可用 `git ls-files program/ settings/ library/` 查看仓库实际内容）。

---

## 还原后要做的事

1. 启动 `D:\Music\MusicBee\MusicBee.exe`。
2. **检查曲库**：左侧曲库应显示歌曲、评分、播放次数、播放列表与歌词。若大量歌曲显示"丢失"，见"注意事项"。
3. **检查界面**：布局（三栏）、皮肤（One-Dark）、语言（简体中文）、排序规则应与备份一致。
4. 确认无误后即可正常使用。（如需把新改动同步回仓库，见"更新备份"。）

---

## 目录对照表

| 仓库内路径 | 目标路径 | 说明 |
|---|---|---|
| `program/Configuration.xml` | `D:\Music\MusicBee\Configuration.xml` | 主配置 |
| `program/MusicBee.exe.config` | `D:\Music\MusicBee\MusicBee.exe.config` | .NET 运行时配置 |
| `program/TagHierarchyDefault.dat` | `D:\Music\MusicBee\TagHierarchyDefault.dat` | 标签层级 |
| `program/Skins/` | `D:\Music\MusicBee\Skins\` | 皮肤（One-Dark 等） |
| `program/Plugins/` | `D:\Music\MusicBee\Plugins\` | 插件（歌词、剧院模式等） |
| `program/BBplugin/` | `D:\Music\MusicBee\BBplugin\` | 可视化效果（DLL 与纹理） |
| `program/Localisation/` | `D:\Music\MusicBee\Localisation\` | 语言包（含简体中文） |
| `program/Tooltips/` | `D:\Music\MusicBee\Tooltips\` | 悬停提示 |
| `settings/*` | `D:\Music\MusicBee\AppData\` | 便携模式用户设置 |
| `settings/MusicBee3Settings.ini` | `D:\Music\MusicBee\AppData\MusicBee3Settings.ini` | 核心设置（布局/快捷键/排序/同步） |
| `library/MusicBeeLibrary.mbl` | `%USERPROFILE%\Music\MusicBee\MusicBeeLibrary.mbl` | 曲库数据库（元数据/评分/播放次数） |
| `library/MusicBeeLibrary.lyrics` | `%USERPROFILE%\Music\MusicBee\MusicBeeLibrary.lyrics` | 已下载歌词库 |
| `library/Playlists/` | `%USERPROFILE%\Music\MusicBee\Playlists\` | 播放列表（`.mbp`） |
| （不在仓库）音乐文件 | `D:\Music\Music\` | 需用户手动放置，路径必须一致 |

---

## 备份范围

**包含**：
- `program/` —— 安装目录配置、皮肤、插件、语言包、可视化
- `settings/` —— 便携模式用户设置
- `library/` —— 曲库数据库、歌词库、播放列表

**排除**（`.gitignore` 与 `backup.ps1` 均会剔除；这些内容可由 MusicBee 自动重建或每次启动都在变化，无需备份）：
- `settings/InternalCache/`、`settings/AlbumCoverHashes.dat` —— 专辑封面缓存
- `settings/ActivityLog.dat`、`settings/ErrorLog.dat`、`settings/Downloads.dat`、`settings/mb_LyricsReloaded/Log.log` —— 运行日志

**不在仓库**：
- 音乐文件本身（`D:\Music\Music\`，体积大且不属配置）
- MusicBee 程序二进制（`.exe` / `.dll`，`program/` 中仅含插件 DLL）

---

## 更新备份

在正在使用的电脑上修改过配置（新增播放列表、换皮肤、调布局）后，重新导出并提交。

**方式一：手动复制（与还原步骤一一对应，在仓库根目录执行）**

```powershell
# 安装配置
Copy-Item D:\Music\MusicBee\Configuration.xml, D:\Music\MusicBee\MusicBee.exe.config, D:\Music\MusicBee\TagHierarchyDefault.dat .\program\ -Force
Copy-Item D:\Music\MusicBee\Skins, D:\Music\MusicBee\Plugins, D:\Music\MusicBee\BBplugin, D:\Music\MusicBee\Localisation, D:\Music\MusicBee\Tooltips .\program\ -Recurse -Force

# 用户设置（便携模式）
Copy-Item D:\Music\MusicBee\AppData\* .\settings\ -Recurse -Force
# 剔除缓存与日志
Remove-Item .\settings\InternalCache -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item .\settings\AlbumCoverHashes.dat, .\settings\ActivityLog.dat, .\settings\ErrorLog.dat, .\settings\Downloads.dat -Force -ErrorAction SilentlyContinue
Remove-Item .\settings\mb_LyricsReloaded\Log.log -Force -ErrorAction SilentlyContinue

# 曲库
Copy-Item $env:USERPROFILE\Music\MusicBee\* .\library\ -Recurse -Force
```

**方式二：运行 `.\backup.ps1`**，生成 `MusicBee-Backup\<时间戳>\`，再把其中的 `program/`、`settings/`、`library/` 内容并入仓库对应目录。

**最后提交并推送**（使用 Windows git）：

```powershell
git add -A
git commit -m "更新配置备份"
git push
```

---

## 注意事项

- **路径必须完全一致**：音乐文件固定在 `D:\Music\Music\`，曲库在 `%USERPROFILE%\Music\MusicBee\`。曲库数据库记录的是绝对路径，任一路径改变都会导致歌曲"丢失"。
- **便携模式的意义**：便携模式把设置保存在安装目录 `D:\Music\MusicBee\AppData\`。因此本仓库的 `settings/` 要还原到该处，**不是** `%APPDATA%\MusicBee\`。装成标准安装版会使设置失效。
- **曲库显示"丢失"怎么办**：
  1. 确认音乐文件确实在 `D:\Music\Music\`，且目录结构与旧电脑一致；
  2. 若旧机音乐根目录曾不同，可在 MusicBee 中使用"重新链接音乐文件"或曲库重映射功能修正路径；
  3. **不要**直接删除 `.mbl` 重新入库——那样会丢失评分与播放次数。
- **还原与更新前都先关闭 MusicBee**（含托盘图标）。
- **备用方式**：仓库自带 `restore.ps1`，可一键完成上述步骤 2–4（同样要求先关闭 MusicBee）。若不想运行脚本，按本文手动步骤执行即可。
