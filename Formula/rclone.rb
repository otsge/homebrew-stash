class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.73.5.tar.gz"
  sha256 "e52541bc238dd434a0335f467697d7d9575529698a74aab534ad39b8649f8a49"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "85c12cb4d4865805e2be8cd869f4564257820a7a0e5500c817dc7ad2f106f22f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "db6549309334f8394034d4f924bcb69ab7878c908b4aac6894033328ea1f9ed4"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "969f9fe600c59d644ab0ddee70592bc67bb332e1950694f6c39600111b0b22ef"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "e27242f7a1b7d08cb6a9411f8255af66efcc61bddc6abbf10963a6d787c0d499"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "4ee61c4cddc20931714a45ef3f6db90ec4d2dd423d9626bf4bbc00f8781841f9"
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
