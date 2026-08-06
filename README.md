# homebrew-ygn

[ygnstudio](https://github.com/ygnstudio) 的个人 Homebrew Tap，收录我维护的命令行工具与 macOS 应用。

## 快速开始

```zsh
brew tap ygnstudio/ygn
brew trust ygnstudio/ygn   # 新版 Homebrew Tap Trust 安全机制需要信任此源
```

---

## 软件清单

### sc（命令行工具 · formula）

在终端里用任意搜索引擎一键唤起浏览器打开结果页。不抓取网页、不发起任何网络请求，只做「关键词 URL 编码 → 模板拼接 → 打开浏览器」。

```zsh
brew install sc
brew update && brew upgrade sc        # 升级
brew uninstall sc                      # 卸载
```

- 源码与文档：<https://github.com/ygnstudio/sc-search>
- 支持 Apple Silicon 与 Intel（预编译 universal 二进制，无需本地 Rust 工具链）；其他平台自动回退源码编译
- 快速上手：`sc list` 查看内置引擎，`sc bilibili 测试` 直接搜索，`sc tui` 打开交互式管理面板


### DutiUI（应用 · cask）

```zsh
brew install --cask ygnstudio/ygn/dutiui
brew update && brew upgrade --cask dutiui            # 升级
brew uninstall --cask dutiui                         # 卸载
```

> ⚠️ 应用未完成 Apple 公证。若 Gatekeeper 拦截启动，请执行：
> ```zsh
> xattr -cr /Applications/DutiUI.app
> ```

---
