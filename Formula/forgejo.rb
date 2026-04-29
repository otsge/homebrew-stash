class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v15.0.1/forgejo-src-15.0.1.tar.gz"
  sha256 "c57b8aaf0f5e4b041f6e47238bff0366f47ef2757ac3bda588300e588d8142fd"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "9036b8be2a8bb95182dcb49955989c401a41f15590e02028089fbb81f9157d31"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "5ea4c1495d5c19722242b7df6a4b05072d0134bcf8cbccfc7246071954f545ba"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "44b130fea80cff0b132de1a436e7b5c0e59fabfca4f67aee6c0bbccfc6ff02e4"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "792c40cf065c7f7d7b854b5c83d777f3129c9681ea257603bc3d5148b3cef947"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "9412217b79a7d292357c79b36a5e59eea8a05fa0044ea2143963a1e932d88544"
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
