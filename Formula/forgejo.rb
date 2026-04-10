class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v14.0.4/forgejo-src-14.0.4.tar.gz"
  sha256 "34326eb230015f12f2a6610b0f4559447e62b4730b3d2607c31342ec8fb65556"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "c107bf2d4582931e5e1189aac0807e82085568ca4d875278ee4ea78637e9a9fd"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "ebd4a1c2756d8a179a1c24ca12f36b2d045476433ea28901ea87348b19e6dcb1"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "3396cd6325aecec1b38abe63fe83f307aad9a2f57ecf441da311d31ea0db34b5"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "163c7b5608fd2fe4112be95c1727c1cfbf67a48c46d06912e3acaff874cbfa17"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "f688ee580ea6e95475d98fd170c05e11df9081ae952692223e4b89968e5636ef"
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
