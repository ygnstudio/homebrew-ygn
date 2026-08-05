# Homebrew Formula for sc
#
# 放置位置：github.com/ygnstudio/homebrew-ygn 的 Formula/sc.rb
# 用户安装：brew tap ygnstudio/ygn && brew install sc
#
# 安装策略：
#   macOS  → 直接下载 Release 里的 universal 预编译二进制（x86_64 + arm64），秒装
#   Linux  → 从源码 tarball 用 cargo 构建
#   --HEAD → clone main 分支从源码构建（macOS 想自己编也走这条）
#
# 升级版本时要改四处：version、两个 url 里的版本号、两个 sha256。
# 取校验和（务必在 tag 推送之后算，源码 tarball 由 GitHub 现场打包）：
#   shasum -a 256 sc-<版本>-macos-universal.tar.gz
#   curl -sL https://github.com/ygnstudio/sc-search/archive/refs/tags/v<版本>.tar.gz | shasum -a 256

class Sc < Formula
  desc "Launch web searches from your terminal, with built-in AI Q&A"
  homepage "https://github.com/ygnstudio/sc-search"
  version "0.2.1"
  license "MIT"

  # 预编译 universal 二进制：Apple Silicon 与 Intel 共用，无需 Rust 工具链
  on_macos do
    url "https://github.com/ygnstudio/sc-search/releases/download/v0.2.1/sc-0.2.1-macos-universal.tar.gz"
    # 构建后执行 shasum -a 256 sc-0.2.1-macos-universal.tar.gz 填入下方
    sha256 "e5874e6f8935f47d87169adfa24537e4d6e4d503283e1344ee9bed8b9946b6f7"
  end

  # 非 macOS 平台回退到源码构建
  on_linux do
    url "https://github.com/ygnstudio/sc-search/archive/refs/tags/v0.2.1.tar.gz"
    # TODO: tag 推送后执行 curl -sL <上述 url> | shasum -a 256 填入下方
    sha256 "REPLACE_WITH_SOURCE_SHA256"
    depends_on "rust" => :build
  end

  head do
    url "https://github.com/ygnstudio/sc-search.git", branch: "main"
    depends_on "rust" => :build
  end

  def install
    if build.head? || OS.linux?
      system "cargo", "install", *std_cargo_args
    else
      bin.install "sc"
    end
  end

  def caveats
    <<~EOS
      配置文件位于 ~/.sc/config.toml，首次执行任意 sc 命令时自动生成。
      搜索引擎内置 7 个（Google / 必应 / DuckDuckGo / GitHub / B站 / 抖音 / 小红书）。

      快速上手：
        sc list                      查看内置搜索引擎
        sc bilibili 测试             用 B 站搜索（search 子命令可省略）
        sc edit bilibili --alias bb  改引擎的名称 / 别名 / URL
        sc tui                       打开交互式面板（引擎 + AI 协议双页签，Tab 切换）

      AI 问答：
        sc ai 你的问题               用默认 AI 提供方提问（首跑填 API Key）
        sc provider list             查看已配置的 AI 提供方
        sc model                     查看当前提供方的可用模型
        sc ai --help                 查看全部 AI 选项（流式 / 管道 / 多轮 / AI 选引擎）

      搜索结果由 macOS 系统设置里的默认浏览器打开；
      想固定用某个 App 时执行 sc set-browser <浏览器名称>。
    EOS
  end

  test do
    # 全程使用隔离的 HOME，避免污染用户真实配置
    ENV["HOME"] = testpath

    assert_match version.to_s, shell_output("#{bin}/sc --version")
    assert_match "search", shell_output("#{bin}/sc --help")

    # AI 子命令与内置 DeepSeek 协议在线下也应可见
    assert_match "deepseek", shell_output("#{bin}/sc ai --help")
    assert_match "deepseek", shell_output("#{bin}/sc provider list")

    # 预热：首次运行会额外打印一行「已生成默认配置文件」，
    # 先让它生成好，后面比对两条命令的输出才是干净的
    system bin/"sc", "list"
    assert_predicate testpath/".sc/config.toml", :exist?

    # 关键词 URL 编码 + 模板填充；--dry-run 只打印地址不唤起浏览器
    output = shell_output("#{bin}/sc search google 'hello world' --dry-run")
    assert_match "https://www.google.com/search?q=hello%20world", output

    # 省略 search 子命令的写法应完全等价
    assert_equal output, shell_output("#{bin}/sc google 'hello world' --dry-run")

    # 中文关键词按 UTF-8 逐字节百分号编码
    assert_match "keyword=%E6%B5%8B%E8%AF%95",
                 shell_output("#{bin}/sc bilibili 测试 --dry-run")

    # 改别名后新别名生效、旧别名失效
    assert_match "google → gg", shell_output("#{bin}/sc edit google --alias gg")
    assert_equal output, shell_output("#{bin}/sc gg 'hello world' --dry-run")
    assert_match "未找到别名", shell_output("#{bin}/sc google test --dry-run 2>&1", 1)

    # 禁用后拒绝搜索
    system bin/"sc", "disable", "gg"
    assert_match "禁用", shell_output("#{bin}/sc gg test --dry-run 2>&1", 1)
  end
end
