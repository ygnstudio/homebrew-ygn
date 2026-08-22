cask "buddyswap" do
  version "1.0.0"
  sha256 "3a8207166bc140aa6744a963f0ddccc7bb75f698280d2f5116df54650a1a0f28"

  url "https://github.com/ygnstudio/buddyswap/releases/download/v#{version}/BuddySwap.dmg"
  name "BuddySwap"
  desc "WorkBuddy 多账号一键切换工具"
  homepage "https://github.com/ygnstudio/buddyswap"

  depends_on macos: :ventura
  depends_on arch: :arm64

  app "BuddySwap.app"

  caveats <<~EOS
    应用未进行 Apple 公证，首次打开被 Gatekeeper 拦截时，终端执行：
      xattr -cr "#{appdir}/BuddySwap.app"
  EOS
end
