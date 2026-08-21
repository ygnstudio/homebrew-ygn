cask "duty" do
  version "1.0.0"
  sha256 "dbb572559b59f6d1cb89331b99667cb5281e94f69cbe62872b30258d5dd2c3e8"

  url "https://github.com/ygnstudio/Duty/releases/download/v#{version}/Duty.dmg"
  name "Duty"
  desc "菜单栏文件关联锁定工具"
  homepage "https://github.com/ygnstudio/Duty"

  depends_on macos: :sonoma
  depends_on arch: :arm64

  app "Duty.app"

  caveats <<~EOS
    应用未进行 Apple 公证，首次打开被 Gatekeeper 拦截时，终端执行：
      xattr -cr "#{appdir}/Duty.app"
  EOS
end
