class Rclone < Formula
  desc "Rsync for cloud storage"
  homepage "https://rclone.org/"
  url "https://github.com/rclone/rclone/archive/refs/tags/v1.71.2.tar.gz"
  sha256 "54c619a2f6921981f276f01a12209bf2f2b5d94f580cd8699e93aa7c3e9ee9ba"
  license "MIT"
  head "https://github.com/rclone/rclone.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "178643c1c6182bb9d1ba3fd0633197dfe0acd07152fb7ec2517a6c16302d60a9"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "2e76d05f68a61f60a80ddf30731c18cced2a2767a363060e4de48696956630fd"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "6fea20ec6c5ebdc5fbff354335ddb14fdb88015a54c8e362f25fa9b92f169519"
    sha256 cellar: :any_skip_relocation, sequoia:       "f63224a77ea03066887f99fdcc214397147297ab4a22b52de0259206b06ba210"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "581dd8e0a9b3e27a962222eeb5dd30106055807bb579e032e34b1436e9d81375"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "48a611868440586ae715edfef4cf70401368f31442777348e2afe564b50ad596"
  end

  depends_on "go" => :build

  on_linux do
    depends_on "libfuse@2"
  end

  def install
    ENV["GOPATH"] = prefix.to_s
    ENV["GOBIN"] = bin.to_s
    ENV["GOMODCACHE"] = "#{HOMEBREW_CACHE}/go_mod_cache/pkg/mod"
    ENV["CGO_FLAGS"] = "-g -O3"
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
