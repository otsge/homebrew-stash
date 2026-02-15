class Teldrive < Formula
  desc "Organizer for your telegram files"
  homepage "https://github.com/tgdrive/teldrive"
  url "https://github.com/tgdrive/teldrive.git",
        tag:      "1.8.3",
        revision: "d258f230876928de4798166376090593b53e4d72"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "5cb55fbfcb45b090dfc4af53a0582683fdabacf2832d48da1ecb2fca9cffe0ac"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "c43b6b5790aba5dd2025d1f164bd05d2072274834b23d636654c6aac982295ba"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "9a02d5b0f9a5ff8aecc512ca45c262f3ef4fa72d9f50d73220fd42b262ef41ad"
    sha256 cellar: :any_skip_relocation, sequoia:       "bf52db5429777b526ccc0b69d20d2abef2b59accb717129aa1ca8bdc0a0126c1"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "9bde6eb278a95bf9aa0b62da14b46c8910ad95daf808d93ef691c82ee788c202"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "0be7dd8d3034e4bc71b7af7fe27ab46cbe2bbf25f212b867d5078a51f6b51068"
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
