cask "buddyswap" do
  version "1.0.3"
  sha256 "800d8a07670abd74faab6a7a5bc33eeb58ae877d8bdda449877cc2b895cce9c2"

  url "https://github.com/ygnstudio/buddyswap/releases/download/v#{version}/BuddySwap.dmg"
  name "BuddySwap"
  desc "WorkBuddy 多账号一键切换工具"
  homepage "https://github.com/ygnstudio/buddyswap"

  depends_on macos: :ventura
  depends_on arch: :arm64

  app "BuddySwap.app"

  caveats <<~EOS
    应用未进行 Apple 公证。首次打开被 Gatekeeper 拦截时，完整命令请用 brew info --cask buddyswap 查看 Caveats 段。
  EOS
end
