cask "fuse-t" do
  version "1.2.1"
  sha256 "77e0feca3d5a3dde5bd2683b1613fb52f23385381e41b9f47216dcc88644a346"

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
