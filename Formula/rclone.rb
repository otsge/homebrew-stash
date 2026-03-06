class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.73.2.tar.gz"
  sha256 "1bbb94dedf84fff7bb769a40fafda148d5987f97e26a3a3ceef08dcf18c7e534"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "e83c71377b00eb8de6fb71eda2681761126859c78442df418b463d1b28a589de"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "38a74546c0e010ded21992aa7b88ada44d0c1e815045f6fb1387c5172079bc14"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "6a9e8c9879941140677e3b1e8fa652bc242696ae47ed30680ce183f143548f71"
    sha256 cellar: :any_skip_relocation, sequoia:       "80cab6170bdec8f475e4e828b0940c09965ae726e93f5c33c2b264e4fb94262e"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "41e552bcc2e7b85ae42798f707feaed1443aee217e8bfd89c0b48ec8f20c32d6"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "e6331e391602ac685ba3fa34d6cdc27f3867a1ef59eaa5a5a04518a84b2f47e2"
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
