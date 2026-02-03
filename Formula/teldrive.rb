class Teldrive < Formula
  desc "Organizer for your telegram files"
  homepage "https://github.com/tgdrive/teldrive"
  url "https://github.com/tgdrive/teldrive.git",
        tag:      "1.8.1",
        revision: "d883d15325e74d8fa3f9306d2ad93442fe63a2f0"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "6b71ccdd0bdd4d3dbc04b3402c4635997ffa25022a408dd3cc2fc70a565601ff"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "500c190f7d4ad26e0bcd6eae7d40a2851e07f49145a541402374f497460f9c4b"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "77dbef07855e6355f98a19c415125c42014fa702e9cf16c2965eeddac4a9fdaf"
    sha256 cellar: :any_skip_relocation, sequoia:       "f51f08101c5b8b34eb24c5e5ac906aa71f75719bab1ba1e9f390c3bb08b7c41b"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "f8f267644774beb38d40eaff368e9faf727e5209507a2c87ce480bc42099e452"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "6893a8a1b17b56776d0ae05890fdd9b888ce14140aff24bbe06b3ac688eca147"
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
