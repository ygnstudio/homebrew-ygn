# homebrew-ygn

[ygnstudio](https://github.com/ygnstudio) 的个人 Homebrew Tap：一条 `brew install` 装好我维护的命令行工具与 macOS 应用。添加 Tap → 信任源 → 按需安装，升级卸载全走 brew。

🍺 **Tap 地址**：`ygnstudio/ygn` · <https://github.com/ygnstudio/homebrew-ygn>

## 快速开始

```zsh
brew tap ygnstudio/ygn
brew trust ygnstudio/ygn   # 新版 Homebrew Tap Trust 安全机制需要信任此源
```

## 软件清单

### sc（已下架 · formula）

sc-search 仓库已于 2026-09-17 转为**私有**，`sc` formula 同步移除，`brew install sc` 不再可用。已安装用户可继续 `brew uninstall sc` 卸载；源码与文档见私有仓库 `ygnstudio/sc-search`。

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

### Blinker（应用 · cask）

macOS 菜单栏小工具：红绿灯行为重定义与悬停放大工具。

```zsh
brew install --cask blinker
brew update && brew upgrade --cask blinker       # 升级
brew uninstall --cask blinker                    # 卸载
```

- 源码与文档：<https://github.com/ygnstudio/Blinker>
- 需要 macOS 15+，Universal（Apple Silicon 与 Intel）；未公证，首次打开被拦截时执行 `xattr -cr /Applications/Blinker.app`，启动后需在「系统设置 → 隐私与安全性 → 辅助功能」中授权

### BuddySwap（已下架 · cask）

BuddySwap 项目已于 2026-08-28 封存，cask 同步移除，`brew install --cask buddyswap` 不再可用。已安装用户可 `brew uninstall --cask buddyswap` 卸载。

## 目录结构

```
homebrew-ygn/
├── Formula/                # 当前为空（sc 已下架）
└── Casks/
    ├── blinker.rb          # Blinker 的 cask
    └── duty.rb             # Duty 的 cask（DMG 直链 GitHub Releases）
```

发新版时更新对应文件里的 `version` 与 `sha256` 即可，无需其他改动。

## License

详见 [LICENSE](LICENSE)。各软件本身的许可证以其源码仓库为准。
