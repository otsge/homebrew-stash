class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.73.4.tar.gz"
  sha256 "b68b5c55bac24ccfd86fd4b70f722181a689fb6ea2b1cc2ad0bd53de94c4ef99"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "92d781dd8f7bcdd04b6cfbe624508c4f561612d6d95636fde446e4565a5413f9"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d2833d5a134ab3e5b0f69ad52bd7e4d019771201d6248d9afbbf81c3115339ae"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "a187514abd84e7588ec8a0aaba67e9a82fe2d4b5ada46a4ffac4793cb7effff1"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "c985211b7af9f4343a7244f7f3f4b2bf8ac81fbaeaa1afaf09877eb5119422bb"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "4ab10dddd8637728f65d386f470c65e5b6e8fe80dc9dc5fe57dd2c3941869583"
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
