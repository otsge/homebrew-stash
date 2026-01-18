class Teldrive < Formula
  desc "Organizer for your telegram files"
  homepage "https://github.com/tgdrive/teldrive"
  url "https://github.com/tgdrive/teldrive.git",
        tag:      "1.7.5",
        revision: "4f431280ae5ef9ab56eb3c68ff5ceafb178504f1"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "bf77809f0f439abd657cff41e9a8198daf50acb1e5345235c6f397690400af3a"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "18e648f7b2e160bd7de7283f42b211af89da0dcdb0dd2a2fb625f6d96f85e411"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "045f355d24ab2d5ff25ec1893664666bb210588f32f011891c002baf1de6144f"
    sha256 cellar: :any_skip_relocation, sequoia:       "f73a56bf13a5d45ce90133385608d36efa6422aa33d51338be4bcecbc040812e"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "65277b695a11639262fe87824c4bcfc0bb1254217ed10611acdca4dcf414a156"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "4b51dc50b7fbf8c05fe9ada04708e585cc5a893bc5b1d8aae50b96bbc3b7288f"
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
