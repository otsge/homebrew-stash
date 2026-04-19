class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.73.5.tar.gz"
  sha256 "e52541bc238dd434a0335f467697d7d9575529698a74aab534ad39b8649f8a49"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "9891483d2795ab34566d6e79c10c66baeade7773f6a3ea9a8761c0eee46129bc"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "f03ff5b8529aa2211dffa3a7b60cbdffd0e0d8bcff99915500b249eeb0527d8d"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "a7c9e02ef099231e6a25c92ab9252a6cc1850f11c62f82d39d15fb1e9e073d09"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "bb63a9a8cd247cd66cc597e8fedeb26239c36251aa5029c8f506db5fd2092e6e"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "c20a801c7630fc68983ff0993936ea199ccb84eda053586c78ac7907d926e217"
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
