class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.73.1.tar.gz"
  sha256 "8aefe227099825b5a8eeda44a2e1623b657914be0e06d2287f71d17b0a4ed559"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "9f45046536b286eff191d90638d26a8c0aee837988d317394790d350f8a9352d"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "ce8cf200c1195e8389ab35a2d4274242d9f247cae45d997364512edf88d46f7b"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "2f5a7262bfcc4b6c92b1564580ab126f1b31f52786564a0546232d874ff16b31"
    sha256 cellar: :any_skip_relocation, sequoia:       "c82e73b47c3b33bb33e7f7d69d36812c638259ea22af5aa94a184681cb82f169"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "c1b7980dc0676eb98458b889a488a67273258c875f1aae4b30fe13edb6000b0b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "da76e4a9cc9d75149855dfe9a8a0f987ff9c8faeeae1ee41eb94a081068e458c"
  end

  depends_on "go" => :build

  on_linux do
    depends_on "libfuse@2"
  end

  def install
    ENV["GOPATH"] = prefix.to_s
    ENV["GOBIN"] = bin.to_s
    ENV["GOMODCACHE"] = "#{HOMEBREW_CACHE}/go_mod_cache/pkg/mod"

    if OS.mac? && Hardware::CPU.arm?
      ENV.append "CGO_FLAGS", "-I/usr/local/include"
      ENV.append "CGO_LDFLAGS", "-L/usr/local/lib"
    end

    args = ["GOTAGS=cmount"]
    system "make", *args
    man1.install "rclone.1"
    system bin/"rclone", "genautocomplete", "bash", "rclone.bash"
    system bin/"rclone", "genautocomplete", "zsh", "_rclone"
    system bin/"rclone", "genautocomplete", "fish", "rclone.fish"
    bash_completion.install "rclone.bash" => "rclone"
    zsh_completion.install "_rclone"
    fish_completion.install "rclone.fish"
  end

  test do
    (testpath/"file1.txt").write "Test!"
    system bin/"rclone", "copy", testpath/"file1.txt", testpath/"dist"
    assert_match File.read(testpath/"file1.txt"), File.read(testpath/"dist/file1.txt")
  end
end
