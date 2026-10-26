cask "finderwrap" do
  version "1.0.11,14"
  sha256 "9247cdc65acc86c7a660bf5b88dc71a3b5e9c3f08ecd60bb7ca3dcb659962a23"

  url "https://github.com/ygnstudio/FinderWrap/releases/download/v#{version.csv.first}/FinderWrap-#{version.csv.first}-b#{version.csv.second}-fixed-arm64.dmg"
  name "FinderWrap"
  desc "Row-wrapping arrow-key navigation for Finder icon views"
  homepage "https://github.com/ygnstudio/FinderWrap"

  livecheck do
    url :url
    regex(/^FinderWrap-(\d+(?:\.\d+)+)-b(\d+)-fixed-arm64\.dmg$/i)
    strategy :github_latest do |json, regex|
      Array(json["assets"]).filter_map do |asset|
        match = asset["name"]&.match(regex)
        next if match.nil?

        "#{match[1]},#{match[2]}"
      end
    end
  end

  depends_on arch: :arm64
  depends_on macos: :ventura

  app "FinderWrap.app"

  uninstall quit: "dev.finderwrap.finderwrap"

  caveats <<~EOS
    应用使用固定自签证书，未进行 Apple 公证；Homebrew 保留系统安全检查。
    首次打开若被拦截，请核对来源，再到「系统设置 → 隐私与安全性」允许打开。
    仅提供 Apple Silicon（arm64），最低 macOS 13；Intel 用户请保留 1.0.3。
    只需开启辅助功能、输入监控，再启用「左右键自动换行」；开关状态会被记住。
    应用只驻留菜单栏（无 Dock 图标与主窗口），点菜单栏图标即可开关、查看权限与复制诊断。
    从旧 ad-hoc 版本首次迁移时，可能需要重新授权；后续更新沿用同一签名身份。
    手动安装的用户请先退出并备份原应用，避免直接覆盖正在运行的版本。
  EOS
end
