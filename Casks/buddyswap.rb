cask "buddyswap" do
  version "1.0.1"
  sha256 "c654a80b87dcc51a8e08cd930f5f15120fde79bd7c3afa81ed65dd4ddcaf9bc7"

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
