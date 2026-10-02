# homebrew-ygn

[ygnstudio](https://github.com/ygnstudio) 的个人 Homebrew Tap，提供我维护的命令行工具与 macOS 应用，安装、升级和卸载均通过 Homebrew 管理。

🍺 **Tap 地址**：`ygnstudio/ygn` · <https://github.com/ygnstudio/homebrew-ygn>

## 快速开始

```zsh
brew tap ygnstudio/ygn
```

若 Homebrew 提示确认第三方源，请先核对仓库和要安装的 cask 内容。

## 软件清单

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
brew install --cask ygnstudio/ygn/blinker
brew update
brew upgrade --cask ygnstudio/ygn/blinker       # 升级
brew uninstall --cask ygnstudio/ygn/blinker     # 卸载
```

- 源码与文档：<https://github.com/ygnstudio/Blinker>
- 需要 macOS 15+，Universal（Apple Silicon 与 Intel）。
- 使用 ad-hoc 签名，未经过 Apple 公证。首次打开被拦截时，核对下载来源，再按 [Apple 的说明](https://support.apple.com/102445) 到「系统设置 → 隐私与安全性」允许打开。安装流程不移除 quarantine，也不关闭 Gatekeeper。
- 启动后需在「系统设置 → 隐私与安全性 → 辅助功能」中授权。具体功能与权限以安装版本的说明为准。

## 目录结构

```
homebrew-ygn/
├── Formula/                # 当前为空
├── Casks/
│   ├── blinker.rb          # Blinker 的 cask
│   └── duty.rb             # Duty 的 cask（DMG 直链 GitHub Releases）
├── Scripts/                # Blinker 稳定版更新与校验
└── .github/workflows/      # 校验与手动更新入口
```

## 更新 Blinker cask

先在 [Blinker](https://github.com/ygnstudio/Blinker/releases) 发布稳定版，再从本仓库默认分支运行 Actions 中的 **Update Blinker cask**，填写完整标签，例如 `v0.4.0`。工作流会下载该版本的 DMG 和 `SHA256SUMS.txt`，核对校验值后提交 cask 的版本与 SHA-256。它不会创建应用版本，也不会把 Beta 加入稳定通道。

本地可先预览变更，再写入：

```sh
python3 Scripts/test-update-blinker.py
python3 Scripts/update-blinker.py v0.4.0
python3 Scripts/update-blinker.py v0.4.0 --write
ruby -c Casks/blinker.rb
```

以上版本号是示例，必须替换为已经发布的稳定版。脚本拒绝草稿、预发布版、降级、缺失或不匹配的资产，以及同一版本校验值发生变化的情况。默认只展示差异；检查失败时不修改 cask。版本更新后，用户通过 `brew update` 和 `brew upgrade` 获取更新。

其他软件仍按其发布流程维护对应 cask 的 `version` 与 `sha256`。

## License

详见 [LICENSE](LICENSE)。各软件本身的许可证以其源码仓库为准。
