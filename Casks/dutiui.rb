cask "dutiui" do
  version "1.0.0"
  sha256 "dba87580b76a292421d5bf1c466159a8721bd9094348a13524264a9a90d5acd7"

  url "https://github.com/ygnstudio/homebrew-ygn/releases/download/DatiUI-v#{version}/dutiui-#{version}-arm64.zip"
  desc "DutiUI 文件关联图形管理工具"
  name "DutiUI"
  homepage "https://github.com/ygnstudio/homebrew-ygn"

  depends_on arch: :arm64
  app "DutiUI.app"

  caveats <<~EOS
    应用未进行Apple公证，首次打开被Gatekeeper拦截时，终端执行：
      xattr -cr "#{appdir}/DutiUI.app"
  EOS
end
