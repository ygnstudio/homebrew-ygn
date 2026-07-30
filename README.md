# homebrew-ygn
Homebrew tap for ygnstudio formulae and casks.

## Quick Start
Add this tap and trust repository (required for new Homebrew Tap Trust policy):
```zsh
brew tap ygnstudio/ygn
brew trust ygnstudio/ygn
Applications
施工管理 (shigong-manager)
Install:
zsh
brew install --cask ygnstudio/ygn/shigong-manager
Upgrade:
zsh
brew update && brew upgrade --cask shigong-manager
Uninstall:
zsh
brew uninstall --cask shigong-manager
⚠️ Notarization missing. If Gatekeeper blocks launch, run:
zsh
xattr -cr /Applications/施工管理.app
DutiUI
Install:
zsh
brew install --cask ygnstudio/ygn/dutiui
Upgrade:
zsh
brew update && brew upgrade --cask dutiui
Uninstall:
zsh
brew uninstall --cask dutiui
⚠️ Notarization missing. If Gatekeeper blocks launch, run:
zsh
xattr -cr /Applications/DutiUI.app
Maintainer Commands
Verify cask syntax
zsh
brew audit --cask ygnstudio/ygn/shigong-manager
brew audit --cask ygnstudio/ygn/dutiui
Reinstall for testing
zsh
brew reinstall --cask ygnstudio/ygn/dutiui
View raw cask source
zsh
brew cat --cask ygnstudio/ygn/dutiui
Notes
Only supports Apple Silicon (arm64) Macs.
Pre-release macOS versions (macOS 27+) are unsupported by Homebrew, version warnings are expected.
When releasing new builds, update both version and sha256 inside corresponding cask file.
plaintext

如果你想要**纯中文版本**，这一版：
```markdown
# homebrew-ygn
Homebrew tap for ygnstudio formulae and casks.

## 快速开始
添加源并信任仓库（新版Homebrew Tap Trust安全机制必需）
```zsh
brew tap ygnstudio/ygn
brew trust ygnstudio/ygn
软件清单
施工管理 shigong-manager
安装：
zsh
brew install --cask ygnstudio/ygn/shigong-manager
升级：
zsh
brew update && brew upgrade --cask shigong-manager
卸载：
zsh
brew uninstall --cask shigong-manager
⚠️ 应用未完成 Apple 公证。首次打开被系统拦截，请执行：
zsh
xattr -cr /Applications/施工管理.app
DutiUI
安装：
zsh
brew install --cask ygnstudio/ygn/dutiui
升级：
zsh
brew update && brew upgrade --cask dutiui
卸载：
zsh
brew uninstall --cask dutiui
⚠️ 应用未完成 Apple 公证。首次打开被系统拦截，请执行：
zsh
xattr -cr /Applications/DutiUI.app
仓库维护调试命令
校验 Cask 语法
zsh
brew audit --cask ygnstudio/ygn/shigong-manager
brew audit --cask ygnstudio/ygn/dutiui
强制重装用于测试
zsh
brew reinstall --cask ygnstudio/ygn/dutiui
查看 Cask 原始代码
zsh
brew cat --cask ygnstudio/ygn/dutiui
重要说明
当前仅支持 Apple Silicon（arm64）设备
macOS 27 等预发布测试系统不受 Homebrew 官方支持，出现版本警告属于正常情况
新版本发布时，必须同步更新对应 Cask 文件内 version 和 sha256 参数
