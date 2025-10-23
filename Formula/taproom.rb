class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.4.5.tar.gz"
  sha256 "311a7a3fb39cfbf478bd0a9ac2c6b5cc5fc509383edad223b119ec89f7ef66b5"
  license "MIT"
  head "https://github.com/hzqtc/taproom.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "746325dddae3d390ce3463d18e8aa1b112eeeaa81ae539327d2f44c7c49cf9ea"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "01585fd1778b2ed28b93157f63f7cfb2f5151ea8ddcb84b3e6d55ec8534291a5"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "2a65440ef012ca2fb550ab82ccf40b882bd318697a247e97519dac46e6780919"
    sha256 cellar: :any_skip_relocation, sequoia:       "3ff2d783badb23446922ef421d70520494113198d3363d84c03d92fe486fb0ac"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "17411805d2aef42370ed4e7e9e1f0ebab889e3a6d748833ff428d3bcd3b3efc2"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "a29a8a33edafc7bce53a197fa77570dc096ee9dfeb16ba98648b10f73bc307e5"
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
