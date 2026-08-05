# Homebrew Formula for sc
#
# 放置位置：github.com/ygnstudio/homebrew-ygn 的 Formula/sc.rb
# 用户安装：brew tap ygnstudio/ygn && brew install sc
#
# 安装策略：
#   稳定版  → 直接下载 Release 里的 universal 预编译二进制（x86_64 + arm64），秒装
#   --HEAD  → clone main 分支从源码构建（想自己编就走这条）
#
# 仅支持 macOS：唤起浏览器依赖 /usr/bin/open，密钥保管依赖系统钥匙串（security），
# 在 Linux 上即使能编译也无法正常工作，所以直接 depends_on :macos。
#
# 升级版本时要改三处：version、url 里的版本号、sha256。
#   shasum -a 256 sc-<版本>-macos-universal.tar.gz

class Sc < Formula
  desc "Launch web searches from your terminal, with built-in AI Q&A"
  homepage "https://github.com/ygnstudio/sc-search"
  url "https://github.com/ygnstudio/sc-search/releases/download/v0.2.2/sc-0.2.2-macos-universal.tar.gz"
  sha256 "f2f582079d2a1a8db629bf105e57f0882ae26cd9c4d5ae5205914894db810c00"
  version "0.2.2"
  license "MIT"

  depends_on :macos

  head do
    url "https://github.com/ygnstudio/sc-search.git", branch: "main"
    depends_on "rust" => :build
  end

  def install
    if build.head?
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
        sc 关键词                    用默认引擎搜索（出厂为 DuckDuckGo）
        sc bilibili 测试             指定引擎（search 子命令可省略）
        sc gh+bilibili rust          多引擎并行，一次开多个标签页
        sc i                         交互式挑引擎再搜
        sc list                      查看内置搜索引擎
        sc set-default google        改默认引擎
        sc tui                       打开交互式面板（引擎 + AI 协议双页签，Tab 切换）

      AI 问答：
        sc ai 你的问题               用默认 AI 提供方提问（首跑填 API Key）
        sc ai --session work 问题    命名会话，按话题隔离上下文
        sc provider list             查看已配置的 AI 提供方
        sc ai --help                 查看全部 AI 选项（流式 / 管道 / 多轮 / AI 选引擎）

      Shell 补全：
        sc completions zsh > "${fpath[1]}/_sc"

      配置搬家：
        sc config export > sc.toml   导出
        sc config import sc.toml     导入（先校验再写盘）
        sc config backup             就地备份

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
    # 注意：省略式下旧别名会退化成关键词交给默认引擎，要看报错得写显式 search
    assert_match "google → gg", shell_output("#{bin}/sc edit google --alias gg")
    assert_equal output, shell_output("#{bin}/sc gg 'hello world' --dry-run")
    assert_match "未找到别名", shell_output("#{bin}/sc search google test --dry-run 2>&1", 1)

    # 禁用后拒绝搜索
    system bin/"sc", "disable", "gg"
    assert_match "禁用", shell_output("#{bin}/sc gg test --dry-run 2>&1", 1)

    # 默认引擎：不带别名时走 DuckDuckGo
    assert_match "DuckDuckGo", shell_output("#{bin}/sc set-default")
    assert_match "https://duckduckgo.com/?q=hello%20world",
                 shell_output("#{bin}/sc 'hello world' --dry-run")

    # 换默认引擎后立即生效
    system bin/"sc", "set-default", "bing"
    assert_match "https://cn.bing.com/search?q=test",
                 shell_output("#{bin}/sc test --dry-run")

    # 多引擎并行：一次输出多条地址
    multi = shell_output("#{bin}/sc gh+bilibili rust --dry-run")
    assert_match "github.com/search?q=rust", multi
    assert_match "search.bilibili.com/all?keyword=rust", multi

    # 显式 search 下，任一别名不存在应整体失败，不打开任何一个
    assert_match "未找到别名", shell_output("#{bin}/sc search gh+nope rust --dry-run 2>&1", 1)

    # 省略式下 `gh+nope` 不是合法组合，整串退化为关键词交给默认引擎（bing）
    assert_match "cn.bing.com/search?q=gh%2Bnope%20rust",
                 shell_output("#{bin}/sc gh+nope rust --dry-run")

    # 含 + 的普通关键词不会被误判成引擎组合
    assert_match "q=C%2B%2B", shell_output("#{bin}/sc C++ 教程 --dry-run")

    # shell 补全脚本可生成
    assert_match "compdef sc", shell_output("#{bin}/sc completions zsh")

    # 配置导出 / 导入闭环
    (testpath/"backup.toml").write shell_output("#{bin}/sc config export")
    assert_match "url_template", (testpath/"backup.toml").read
    assert_match "配置已写入", shell_output("#{bin}/sc config import #{testpath}/backup.toml")
    assert_match "格式有误", shell_output("echo 'not toml [[[' | #{bin}/sc config import 2>&1", 1)
  end
end
