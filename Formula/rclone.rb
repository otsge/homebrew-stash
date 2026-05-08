class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.74.1.tar.gz"
  sha256 "aa0470151fe2e33d6bb96657892dfc4d56f92472a2dedebdda4ff296e87b79dc"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "92ab2f3f8b0fdacb017dbe0ba99597ed7b54be9afeafd484948240d732867b0d"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "a8dc8f4771a3d784fc71a09806bd003c90a508f83e7a8cd7dbb206571eb13b47"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "1d0240f675d9fbe8db1638464505b092ecd0dcbae34b370434b9418d69337d4f"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "93b4a5704dd3f670af1ad2b812b8f10c2d03923effb796b1dcfbc956cf8f0c9f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "0137566d966ac16328dd9410d6d51d39e6d522dd43f2315c4358156270f4e7df"
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
