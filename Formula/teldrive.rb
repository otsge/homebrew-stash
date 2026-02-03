class Teldrive < Formula
  desc "Organizer for your telegram files"
  homepage "https://github.com/tgdrive/teldrive"
  url "https://github.com/tgdrive/teldrive.git",
        tag:      "1.8.1",
        revision: "d883d15325e74d8fa3f9306d2ad93442fe63a2f0"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "d06036e72859fe171b7995e50ce640322ca63ff60e9958fe96c3a281b8966c66"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "7ecfdaf2d43d6fcadd889643e437ae6272787a359447501ffadebee911c11159"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "d7d33debf85a60bd03477e7beff4c059b1baa6fa16c21b26665bb03224902740"
    sha256 cellar: :any_skip_relocation, sequoia:       "4bbc3e9e73184ff9ddfb7eff66b0dae16985dfd39ae468eb158df005cc09d1dc"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "4afe08c6478dd9e71ae2715305bc231fd4241c02e93614499da2281164673246"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "a148d4f6ca5cb416b1f5b2fab2fa0e06d02c3ebf6edf311651c291de82baf649"
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
