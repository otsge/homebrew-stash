cask "fuse-t" do
  version "1.0.54"
  sha256 "1bb02e4a2903d576d3088997e0c2fac74e7565e1072378e6d34aa4af4afce7a6"

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
