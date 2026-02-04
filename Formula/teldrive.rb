class Teldrive < Formula
  desc "Organizer for your telegram files"
  homepage "https://github.com/tgdrive/teldrive"
  url "https://github.com/tgdrive/teldrive.git",
        tag:      "1.8.2",
        revision: "ea414e6387a47382155b30ff45e36dcb0484781e"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "cc43e1ba2593bca329dca10ef3578a949559da2fd1489e2f9ef5c9b979af97ec"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "9c25e6f8b078ed239efba80d66721579646ae2ced86aa68370b25b1e8672f6eb"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "927197334140c9a7b1e3e8693b927669f193e952f9e15e24692267b704d73dde"
    sha256 cellar: :any_skip_relocation, sequoia:       "b563a1b058406c33fa39067b47ab1e0d78fec44383191759040b96bdbc72f255"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "bdd7bfd68eb0678078d22a299e528e45e14d725e329a1d7f82d2341252e908e0"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "77e74f391da34e1c87ed93c9d90f4e3a7c691ec188a4a403afea50d56637886f"
  end

  depends_on "go" => :build
  depends_on "go-task" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ENV["GO111MODULE"] = "on"
    ldflags = %W[
      -extldflags=-static
      -s -w
      -X github.com/tgdrive/teldrive/internal/version.Version=#{version}
      -X github.com/tgdrive/teldrive/internal/version.CommitSHA=#{Utils.git_short_head(length: 7)}
    ]
    system "task", "ui"
    system "task", "gen"
    system "go", "build", "-trimpath", *std_go_args(ldflags:)
  end

  test do
    system bin/"teldrive", "version"
  end
end
