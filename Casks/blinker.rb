cask "blinker" do
  version "0.2.3"
  sha256 "a7c445be66de8d0a141b15313c86fba3f12eaab56ef1948626380b183a1e9654"

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
