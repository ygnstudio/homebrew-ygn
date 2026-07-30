cask "shigong-manager" do
  version "1.0.0"
  sha256 "34abfb9a28605188637d1c498defe38ed4abbd892ddca0a940282d8ff6a82e7d"

  url "https://github.com/ygnstudio/homebrew-ygn/releases/download/shigong-v1.0.0/shigong-manager-1.0.0-arm64.zip"
  name "施工管理"
  homepage "https://github.com/ygnstudio/homebrew-ygn"
  depends_on arch: :arm64
  app "施工管理.app"
end
