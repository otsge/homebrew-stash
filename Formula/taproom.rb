class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "e4fc7e960fbb9bdca6f255f19e5edf8aa8be78925a8e36ab7b1344a7bb3dd505"
  license "MIT"
  head "https://github.com/hzqtc/taproom.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "d05d7df12fc2617a301f17c53901e96308e4bec983a23961b4e4ce4ff5fe81b2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "78d3c4b7602cbe0091d27750855e70e9b94a3e1ad64300ee6e14b5a62de11e19"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "08582aa6d00cff386919d3bd7a50c4f52cf09e956b3cde74cdca34313017596d"
    sha256 cellar: :any_skip_relocation, sequoia:       "b0d2863f1a8a3f5a462651800de7b9fa99f74767f8b5a5f58d42fa77b9204239"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "3a65e0ad37b204f6d067a1946f9d2f2c430b16e998a85f9bdbd38a7c5d89bb79"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "77ee493b4a7ba0bc0164a362d48858e35267550081052f38034a8d02933013f5"
  end

  depends_on "go" => :build

  def install
    system "go", "build", "-trimpath", *std_go_args(ldflags: "-s -w")
  end

  test do
    require "pty"
    require "expect"
    require "io/console"
    timeout = 30

    PTY.spawn("#{bin}/taproom --hide-columns Size") do |r, w, pid|
      r.winsize = [80, 130]
      begin
        refute_nil r.expect("Loading all Casks", timeout), "Expected cask loading message"
        w.write "q"
        r.read
      rescue Errno::EIO
        # GNU/Linux raises EIO when read is done on closed pty
      ensure
        r.close
        w.close
        Process.wait(pid)
      end
    end
  end
end
