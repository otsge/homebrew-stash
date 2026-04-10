class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v14.0.4/forgejo-src-14.0.4.tar.gz"
  sha256 "34326eb230015f12f2a6610b0f4559447e62b4730b3d2607c31342ec8fb65556"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "f489f316262c03b8eb1d4ddbea659c94a49f4f135329badb0549f66347012218"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "6bb74baa896ce23f1eb442111fda3c2caac5c5b9c1f4167f1e9852802254e598"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "aea3ec2f9f637467083a373a5ab14ad9f6a0454fd6aa6241a2e7dbd8e9e8ce45"
    sha256 cellar: :any_skip_relocation, sequoia:       "2b6ec5e94331acf04d36d3828d8d6b0b588fdc43746197fa1fe82d099339d5d0"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "d4416e90913f574852b24fca74682329dd36f8a6d72714d2da98c89c9643b122"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "d5072ee60a8e6572f705980fb07ec4d30f5682d4e14e6e82f142b5d4cfbcd980"
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
