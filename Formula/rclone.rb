class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.74.0.tar.gz"
  sha256 "fac84dba8daf15112507adf9f7913a8e566969e485fb4d5abdc3b8f7974e853a"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "80af65f90dafa5170f7af5cb4639ff39237d014c74a9aec10a872e19bcd2938f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "16134e1468b75b48a90a5f2af778625ba845e07a68d6b794f70290bb05fe2dc8"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "6c804c789d1e98007ea2c368d7d44d977c27a0d61c3e567ce1743782727b63eb"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "7acd4b749fcf919512ef3684c68237dbfe86116f7dd2294fb8cdcbc7ca5784bf"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "f0b3eacc9e0fb6ebb7e3c010b46dbfb58b1e692c3242bd1dc2fc4c5ba8afecbd"
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
