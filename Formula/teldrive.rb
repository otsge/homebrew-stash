class Teldrive < Formula
  desc "Organizer for your telegram files"
  homepage "https://github.com/tgdrive/teldrive"
  url "https://github.com/tgdrive/teldrive.git",
        tag:      "1.7.5",
        revision: "4f431280ae5ef9ab56eb3c68ff5ceafb178504f1"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "fb511c31206058e7d639ff5aa6b5201efc9ed9bd425a06cfed0f05d528c1cf91"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "932355bb7aa9090f1cef7d70ca99448525ffcfa6828f07defb311f9199a325a2"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "079bc869e6d11aa02abe4f853333b0dcac4eba275dd1061e9daba4ab75ad2817"
    sha256 cellar: :any_skip_relocation, sequoia:       "07cca72bd5e3e2ec1b5976f06ad3ee17693c13fedd047ede325aa73e23b13133"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "6c0728bb92632a8ae89232f52cab16a1c5001092aaa76a40bacd8c7fee5d74ad"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "74bc9795d3cad2e3d1164f85911558b2765681de014615e44f1d2f3c1b369cdf"
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
