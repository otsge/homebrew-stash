class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v13.0.2/forgejo-src-13.0.2.tar.gz"
  sha256 "6731d5e73a025c1a04aba0f84caf80886d5be0031f4c154ac63026e7fe30918a"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "9ecd0821eea54b4c989217a26b36232516dabf012f6070bb894435d2bc4dcea0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "320217860acf79e12971f2eaac012eb7c73541fcc603f608181a30b71b032c21"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "d5e7791c982d7a4222e99806fe6ce4731a737ffbb9f67df9ad369c8c966e35c6"
    sha256 cellar: :any_skip_relocation, sequoia:       "0823acd8050f357b0cdd39c7e24592590a6dd0ac0e00ef56274901246a7153cd"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "f85df1da31762c694a838bb0e92d05a297de0be7e0f25bbe76c4515759c9c6a8"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "1583a22b0afa899ebeb625edf7368fab899bc92bc801b4bd01ae2e0583c5b57e"
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
