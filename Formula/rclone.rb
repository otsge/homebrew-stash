class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.73.1.tar.gz"
  sha256 "8aefe227099825b5a8eeda44a2e1623b657914be0e06d2287f71d17b0a4ed559"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "41ecd5ba507318ea4e77dbe939c67d38a3141d62ff48c0a66ca7c3ae49b9d761"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "9bc00dfaeb878657b6da237b83d475dec55f5da91e035e2f9fc1e1d4b0f2be3f"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "eb9c0c297615ce625b27dc8ac184c17b51a2fed99c6bc913d8e6bd97060af994"
    sha256 cellar: :any_skip_relocation, sequoia:       "73c01213bcac646b90e7f263d84376676197361c644b26606e7170fdc5e8e2a8"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "cd66bc8c18f519d7d01ad2fce14e1661e11be7e825aa27dc3f47c33e4854a319"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "3d5f56fd1f2a761f173a839dce6a23dc936f3fd222a0b48beae5f7163f007475"
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
