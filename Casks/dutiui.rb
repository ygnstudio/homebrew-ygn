cask "dutiui" do
  version "1.0.0"
  sha256 "【这里替换成你zip文件算出的sha256】"

  url "https://github.com/ygnstudio/homebrew-ygn/releases/download/v#{version}/dutiui-#{version}-arm64.zip"
  desc "DutiUI - 文件关联图形化管理工具"
  name "DutiUI"
  homepage "https://github.com/ygnstudio/homebrew-ygn"

  depends_on arch: :arm64
  app "DutiUI.app"

  caveats <<~EOS
    应用未进行Apple公证，首次打开被Gatekeeper拦截时，终端执行：
      xattr -cr "#{appdir}/DutiUI.app"
  EOS
end
