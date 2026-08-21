# homebrew-ygn

[ygnstudio](https://github.com/ygnstudio) 的个人 Homebrew Tap：一条 `brew install` 装好我维护的命令行工具与 macOS 应用。添加 Tap → 信任源 → 按需安装，升级卸载全走 brew。

🍺 **Tap 地址**：`ygnstudio/ygn` · <https://github.com/ygnstudio/homebrew-ygn>

## 快速开始

```zsh
brew tap ygnstudio/ygn
brew trust ygnstudio/ygn   # 新版 Homebrew Tap Trust 安全机制需要信任此源
```

## 软件清单

### sc（命令行工具 · formula）

终端搜索唤起工具：关键词 URL 编码 → 引擎模板拼接 → 打开浏览器，不抓网页、零等待。支持多引擎并行、交互选择器、TUI 管理面板与 `sc ai` 问答（OpenAI 兼容协议，密钥走钥匙串）。

```zsh
brew install sc
brew update && brew upgrade sc        # 升级
brew uninstall sc                      # 卸载
```

- 源码与文档：<https://github.com/ygnstudio/sc-search>
- Apple Silicon 与 Intel 通用（预编译 universal 二进制，无需本地 Rust 工具链）
- 快速上手：`sc list` 查看内置引擎，`sc bilibili 测试` 直接搜索，`sc tui` 打开管理面板

### Duty（应用 · cask）

macOS 菜单栏小工具：把文件扩展名「锁定」到指定默认应用，被其他应用抢占时自动恢复，并记录变更历史。

```zsh
brew install --cask duty
brew update && brew upgrade --cask duty              # 升级
brew uninstall --cask duty                           # 卸载
```

- 源码与文档：<https://github.com/ygnstudio/Duty>
- 需要 macOS 14+，仅 Apple Silicon；未公证，首次打开被拦截时执行 `xattr -cr /Applications/Duty.app`
- （2026-08 由 DutiUI 更名而来，旧 cask `dutiui` 已停用，请先 `brew uninstall --cask dutiui` 再安装 `duty`）

## 目录结构

```
homebrew-ygn/
├── Formula/
│   └── sc.rb               # sc 的 formula（universal 二进制 + 源码回退）
└── Casks/
    └── duty.rb             # Duty 的 cask（DMG 直链 GitHub Releases）
```

发新版时更新对应文件里的 `version` 与 `sha256` 即可，无需其他改动。

## License

详见 [LICENSE](LICENSE)。各软件本身的许可证以其源码仓库为准。
