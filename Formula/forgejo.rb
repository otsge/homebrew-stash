class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v13.0.4/forgejo-src-13.0.4.tar.gz"
  sha256 "812c1d1f7e30170e614ce09406b76a0963068162862a9e3e7ffe3140b0569fe9"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "29611d7d40e3bc4bf2c56c80eb7828315af7efe4cf069c0db43e3251804d66a2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d3813804da838848c223cebd48f07501ea8f6d5a92357a2fa9e1240f8ec4c9c9"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "cd6fd612a2c0a816d03dd45dfea36c34cd5992d8cc9762c595b9b74dea3d37ec"
    sha256 cellar: :any_skip_relocation, sequoia:       "48fceca7f72034cffcfba1579affd32cad5ee71f2151c4b60b4da327ad3b5fd3"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "0fef4ff04166dcb0120be6a6876c046020b28debd09dcc3cd1c7841db65ae432"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "a5eff422d15cbf4a9be9e447099d932b71626d1dd2f60025f932f6c138bc47ba"
  end

  depends_on "go" => :build
  depends_on "node" => :build

  uses_from_macos "sqlite"

  def install
    ENV["CGO_ENABLED"] = "1"
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

    pid = fork do
      exec bin/"forgejo", "web", "--port", port.to_s, "--install-port", port.to_s
    end
    sleep 5
    sleep 10 if OS.mac? && Hardware::CPU.intel?

    output = shell_output("curl -s http://localhost:#{port}/api/settings/api")
    assert_match "Go to default page", output

    output = shell_output("curl -s http://localhost:#{port}/")
    assert_match "Installation - Forgejo: Beyond coding. We Forge.", output

    assert_match version.to_s, shell_output("#{bin}/forgejo -v")
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
