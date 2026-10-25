cask "finderwrap" do
  version "1.0.2,5"
  sha256 "e1ce7b2bf68d342800eb988ae8644a1bca7083eb97b161eebc2fbb17aa148e27"

  url "https://github.com/ygnstudio/FinderWrap/releases/download/v#{version.csv.first}/FinderWrap-#{version.csv.first}-b#{version.csv.second}-fixed-universal.dmg"
  name "FinderWrap"
  desc "Row-wrapping arrow-key navigation for Finder icon views"
  homepage "https://github.com/ygnstudio/FinderWrap"

  livecheck do
    url :url
    regex(/^FinderWrap-(\d+(?:\.\d+)+)-b(\d+)-fixed-universal\.dmg$/i)
    strategy :github_latest do |json, regex|
      Array(json["assets"]).filter_map do |asset|
        match = asset["name"]&.match(regex)
        next if match.nil?

        "#{match[1]},#{match[2]}"
      end
    end
  end

  depends_on macos: :sequoia

  app "FinderWrap.app"

  uninstall quit: "dev.finderwrap.finderwrap"

  caveats <<~EOS
    应用使用固定自签证书，未进行 Apple 公证；Homebrew 保留系统安全检查。
    首次打开若被拦截，请核对来源，再到「系统设置 → 隐私与安全性」允许打开。
    启动后需开启辅助功能、输入监控，再启用「左右键自动换行」。
    从旧 ad-hoc 版本首次迁移时，可能需要重新授权；后续更新沿用同一签名身份。
    手动安装的用户请先退出并备份原应用，避免直接覆盖正在运行的版本。
  EOS
end
