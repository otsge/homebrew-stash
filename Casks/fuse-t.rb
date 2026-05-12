cask "fuse-t" do
  version "1.2.5"
  sha256 "f8c8c0c346d78533fa4d6f27baa0d86ea32d4f27cfdd432a5e8812719aba712c"

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

  uninstall script:  {
              executable: "#{HOMEBREW_PREFIX}/bin/brew",
              args:       ["fuse-t-links-del"],
              input:      ["Y"],
            },
            pkgutil: [
              "org.fuse-t.core.#{version}",
              "org.fuse-t.fskit.#{version}",
            ]

  zap delete: "/Library/Frameworks/fuse_t.framework"

  caveats do
    license "https://github.com/macos-fuse-t/fuse-t/blob/main/License.txt"
  end
end
