cask "shigong-manager" do
  version "1.0.0"
  sha256 "34abfb9a28605188637d1c498defe38ed4abbd892ddca0a940282d8ff6a82e7d"

  url "https://github.com/ygnstudio/homebrew-ygn/releases/download/shigong-v#{version}/shigong-manager-#{version}-arm64.zip"
  desc "施工管理客户端"
  name "施工管理"
  homepage "https://github.com/ygnstudio/homebrew-ygn"

  depends_on arch: :arm64
  app "施工管理.app"

  caveats <<~EOS
    应用未做 Apple 公证，首次打开如被 Gatekeeper 拦截，请在终端执行：
      xattr -cr "#{appdir}/施工管理.app"
  EOS
end
