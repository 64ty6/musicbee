# MusicBee 配置备份

MusicBee 完整配置备份，在新电脑上 clone 后一键还原。

## 快速还原

```powershell
# 1. 安装 MusicBee 便携版到 D:\Music\MusicBee
# 2. 确保音乐文件在 D:\Music\Music\ （保持 歌手\专辑\歌曲 结构）
# 3. 执行还原
.\restore.ps1
```

## 目录说明

```
.
├── restore.ps1         # 一键还原
├── backup.ps1          # 一键备份
├── program/            # → D:\Music\MusicBee\     (安装目录配置)
│   ├── Configuration.xml
│   ├── Skins/          # 皮肤 (One-Dark 等)
│   ├── Plugins/        # 插件 (歌词、剧院模式)
│   ├── BBplugin/       # 可视化效果
│   └── Localisation/   # 语言包 (简体中文)
├── settings/           # → %APPDATA%\MusicBee\    (用户偏好)
│   └── MusicBee3Settings.ini  # 布局/快捷键/排序/同步
└── library/            # → %USERPROFILE%\Music\MusicBee\  (曲库)
    ├── MusicBeeLibrary.mbl    # 歌曲元数据/评分/播放次数
    ├── MusicBeeLibrary.lyrics # 已下载歌词
    └── Playlists/             # 播放列表
```

## 备份当前配置

```powershell
.\backup.ps1
```

会生成 `MusicBee-Backup\<时间戳>\`，包含 `program/`、`settings/`、`library/` 三个目录。

## 配置详情

- **布局**: 三栏 — 曲库 + 播放列表 | 正在播放 + 曲目信息 | 歌词
- **皮肤**: One-Dark
- **文件组织**: `Album Artist\Album\Disc-Track# Title`
- **语言**: 简体中文
- **排序**: Album Artist / Artist / Album Sort-Order，忽略 `The ` 前缀
- **歌词**: 自动下载并嵌入

## 注意事项

- 音乐文件路径必须和原来一致（`D:\Music\Music\`），否则库中歌曲会显示为"丢失"
- 还原前请关闭 MusicBee
