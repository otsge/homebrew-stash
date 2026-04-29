class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v15.0.1/forgejo-src-15.0.1.tar.gz"
  sha256 "c57b8aaf0f5e4b041f6e47238bff0366f47ef2757ac3bda588300e588d8142fd"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "30bcda6d69aea017c1f3907a6763f1ca9b9622a66da9d593baad6dad8edfa3e6"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d1fb6aafd1e66d8bf315c6d150a62087ffff16a589e26cc14f84cf98ef4c7061"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "df72436ddf68c014a24f73fc3ee9b67e22246d5bc011ca933e2e27834fda52c7"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "d44446d418a3e04adacd121ef88df3469e71b6f7b32b65e4e5781bf7cec8c3d1"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "6439f350b0adb9066386dae9fcd9242e5de130c7fdfda78b577899a1ed9bfa40"
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
