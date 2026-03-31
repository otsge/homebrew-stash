cask "fuse-t" do
  version "1.2.0"
  sha256 "6e21e4fcf072a8cd41e13bed080289531621e35a5f484d81ac7953f6bd3cd8d2"

  url "https://github.com/macos-fuse-t/fuse-t/releases/download/#{version}/fuse-t-macos-installer-#{version}.pkg",
      verified: "github.com/macos-fuse-t/fuse-t/"
  name "FUSE-T"
  desc "Kext-less implementation of FUSE"
  homepage "https://www.fuse-t.org/"

  livecheck do
    url :url
    strategy :github_latest
  end

  pkg "fuse-t-macos-installer-#{version}.pkg"

  postflight do
    system_command "#{HOMEBREW_PREFIX}/bin/brew",
                   args: ["fuse-t-links-add"]
    set_ownership ["/usr/local/include", "/usr/local/lib"]
  end

  uninstall script: {
    executable: "#{HOMEBREW_PREFIX}/bin/brew",
    args:       ["fuse-t-links-del"],
    input:      ["Y"],
  }

  zap delete: "/Library/Frameworks/fuse_t.framework"
end
