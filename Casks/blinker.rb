cask "blinker" do
  version "0.7.0"
  sha256 "fc15de460e09616adfad6b909024531d802b75c53bb5e00d02162b7dfc6ecb13"

  url "https://github.com/ygnstudio/Blinker/releases/download/v#{version}/Blinker-v#{version}.dmg"
  name "Blinker"
  desc "红绿灯行为重定义与悬停放大工具"
  homepage "https://github.com/ygnstudio/Blinker"

  livecheck do
    url :url
    strategy :github_latest
  end

  # Universal binary (arm64 + x86_64); deployment target macOS 15.
  depends_on macos: :sequoia

  app "Blinker.app"

  caveats <<~EOS
    应用使用 ad-hoc 签名，未进行 Apple 公证。Homebrew 不会取消系统安全检查。
    下载后首次打开若被拦截，请核对来源，再到「系统设置 → 隐私与安全性」允许打开。
    启动后需在 系统设置 → 隐私与安全性 → 辅助功能 中授权。
  EOS
end
