class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v14.0.1/forgejo-src-14.0.1.tar.gz"
  sha256 "375505d2155769f5b4b388c3550b2e7fa758e843f59d08bccf812beed548bf42"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "38b16bee6a42dd1fae595964c020a42c575e934dda8dd9fa3cebc501c60a839a"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "abcc613cf1448c089d0aa73a8345195882aee40eb5aab07dca6ca9dd57d4eb89"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "9f52ac97986bf0d8d710b35e2e43b5f62e437656460ed8d25eb0bde8c8f962a7"
    sha256 cellar: :any_skip_relocation, sequoia:       "f698dccf52bacad57bc20679d9d2b74a2a101099e84a6a1fb02ac56c550ee06f"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "4195603be0559d030213f5c938d13ff7c15119a0825e795b6ecf097132f12d92"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "4196fb206852cccc6623828753a047d80fbd242cf6df2e015abe5f14f8a393cc"
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
