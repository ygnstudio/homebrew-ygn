cask "blinker" do
  version "0.3.0"
  sha256 "46b15e254df61b3b08c3f6a944276607bfe0828a76fb59e3754f68d60896bdf5"

  url "https://github.com/ygnstudio/Blinker/releases/download/v#{version}/Blinker-v#{version}.dmg"
  name "Blinker"
  desc "红绿灯行为重定义与悬停放大工具"
  homepage "https://github.com/ygnstudio/Blinker"

  # Universal binary (arm64 + x86_64); deployment target macOS 15.
  depends_on macos: :sequoia

  app "Blinker.app"

  caveats <<~EOS
    应用未进行 Apple 公证，首次打开被 Gatekeeper 拦截时，终端执行：
      xattr -cr "#{appdir}/Blinker.app"
    启动后需在 系统设置 → 隐私与安全性 → 辅助功能 中授权。
  EOS
end
