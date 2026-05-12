class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v15.0.2/forgejo-src-15.0.2.tar.gz"
  sha256 "c52a7df751de7426657bc06df336248e05fb663bcc9205e870557ce6a020a199"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "c0add84a0dc93c7239622a4b695d0ebf387dc1544c776fdcbe28ca147aaa040d"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0e0aa4098da5f0a1a268f978924714b7d859b348384d4886ad6d7dd5b6cf3655"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "c74207372505cd724a1d4765319ab326e4f41e4e3f28cd597557083f8370dea8"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "a59e113080687650b7f3652541ee1f006f171812cf22ba01e73e762a9777e0dc"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "2d58589dbe73e8a8d449d9a33f38af145d6ac4b77505b17d11c6e901a22d1b29"
  end

  depends_on "go" => :build
  depends_on "node" => :build

  uses_from_macos "sqlite"

  def install
    ENV["CGO_ENABLED"] = "1" if OS.linux? && Hardware::CPU.arm?
    ENV["TAGS"] = "bindata timetzdata sqlite sqlite_unlock_notify"
    system "make", "build"
    system "go", "build", "contrib/environment-to-ini/environment-to-ini.go"
    bin.install "gitea" => "forgejo"
    bin.install "environment-to-ini"
  end

  service do
    run [opt_bin/"forgejo", "web", "--work-path", var/"forgejo"]
    keep_alive true
    log_path var/"log/forgejo.log"
    error_log_path var/"log/forgejo.log"
  end

  test do
    ENV["FORGEJO_WORK_DIR"] = testpath
    port = free_port

    pid = spawn bin/"forgejo", "web", "--port", port.to_s, "--install-port", port.to_s

    output = shell_output("curl --silent --retry 5 --retry-connrefused http://localhost:#{port}/api/settings/api")
    assert_match "Go to default page", output

    output = shell_output("curl --silent http://localhost:#{port}/")
    assert_match "Installation - Forgejo: Beyond coding. We Forge.", output

    assert_match version.to_s, shell_output("#{bin}/forgejo -v")
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
