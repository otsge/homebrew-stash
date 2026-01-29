class Forgejo < Formula
  desc "Self-hosted lightweight software forge"
  homepage "https://forgejo.org/"
  url "https://codeberg.org/forgejo/forgejo/releases/download/v14.0.2/forgejo-src-14.0.2.tar.gz"
  sha256 "422f04bfa0f615e4d686cfae9012693f821eaaf7efae8eb4905416c5633440af"
  license "GPL-3.0-or-later"
  head "https://codeberg.org/forgejo/forgejo.git", branch: "forgejo"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "764b66780fc5964e30e31e588284d5d6ef1f57ce263eba6d8be2eb68e365ef0c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "e0cf7dae0f825968d3150ddb15d397c3b450a389728241bd5008c4464050a667"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "da3af0d575bd50bd4a4a712e491c6028ddb2f9bd429c56631689a5872bc6c04e"
    sha256 cellar: :any_skip_relocation, sequoia:       "6ac69b13330c0be5a85c12558657a42efb7788ffdbde16517bfd42514ba50b00"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "6d218f1e366d9f47d7bed06fea361b6a543e88c540032b90794649d9b01a1e27"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "2bb0cde773d95bac7813dd86ebac558a5bb06aaf0839c5a7e9fae92ac3ba52dc"
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
