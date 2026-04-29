class Curl < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server with HTTP/3 support using quiche"
  homepage "https://curl.se"
  url "https://curl.se/download/curl-8.20.0.tar.bz2"
  mirror "https://github.com/curl/curl/releases/download/curl-8_20_0/curl-8.20.0.tar.bz2"
  mirror "http://fresh-center.net/linux/www/curl-8.20.0.tar.bz2"
  mirror "http://fresh-center.net/linux/www/legacy/curl-8.20.0.tar.bz2"
  sha256 "4be48e69cf467246cb97d369b85d78a08528f2b37cffef2418ee16e6a4eb596e"
  license "curl"

  livecheck do
    url "https://curl.se/download/"
    regex(/href=.*?curl[._-]v?(.*?)\.t/i)
  end

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any, arm64_tahoe:   "d38696bdcca4b7a0b815c6fe01e080a1148719737074a50643adf8af2af29dfd"
    sha256 cellar: :any, arm64_sequoia: "b4ed085fdb120b5386b915c8dd3f49bbb7576d52e1dc5f8c96b3885ddd3faeb6"
    sha256 cellar: :any, arm64_sonoma:  "ef4b642dc26b4fb7d0d6004cbdd45f610401ba520ecaa9f2d9cd748b18c5c3a4"
  end

  head do
    url "https://github.com/curl/curl.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build

    resource "quiche" do
      url "https://github.com/cloudflare/quiche.git", branch: "master"
    end
  end

  keg_only :provided_by_macos

  depends_on "cmake" => :build
  depends_on "pkgconf" => [:build, :test]
  depends_on "brotli"
  depends_on "libnghttp2"
  depends_on "libssh2"
  depends_on :macos
  depends_on "zstd"

  uses_from_macos "krb5"
  uses_from_macos "openldap"

  on_macos do
    depends_on "rust" => :build
  end

  on_monterey :or_older do
    depends_on "libidn2"
  end

  resource "quiche" do
    url "https://github.com/cloudflare/quiche.git",
    tag:      "0.28.0",
    revision: "a9cb314563a5c13791bd7e5a1e32821e53114e75"
    mirror "http://www.surge.box.ca/files/quiche-0.28.0.tar.bz2"
    sha256 "50b17243afaa87367e19d916832274d92da68585d7f8b43a0cb6b78e044358e5"
  end

  def install
    tag_name = "curl-#{version.to_s.tr(".", "_")}"
    if build.stable? && stable.mirrors.grep(%r{\Ahttps?://(www\.)?github\.com/}).first.exclude?(tag_name)
      odie "Tag name #{tag_name} is not found in the GitHub mirror URL! " \
           "Please make sure the URL is correct."
    end

    # Use our `curl` formula with `wcurl`
    inreplace "scripts/wcurl", 'CMD="curl "', "CMD=\"#{opt_bin}/curl \""

    # Build with quiche:
    #  https://github.com/curl/curl/blob/master/docs/HTTP3.md#quiche-version
    quiche = buildpath/"quiche/quiche"
    # boring = buildpath/"quiche/quiche/deps/boringssl"
    # quiche_pc_path = buildpath/"quiche/target/release/quiche.pc"
    resource("quiche").stage quiche.parent
    cd "quiche" do
      # ENV["CARGO_C_LIBDIR"] = lib.to_s

      # ln_sf boring/"src", buildpath/"boringssl"

      # Build static libs only
      inreplace quiche/"Cargo.toml", /^crate-type = .*/, "crate-type = [\"staticlib\"]"
      inreplace quiche/"Cargo.toml", /^cmake = "0.1"/, "cmake = \"0.1.45\""
      inreplace "./Cargo.toml", /^debug = true/, "debug = false"

      system "cargo", "build", "--lib", "--package", "quiche", "--features", "ffi,pkg-config-meta,qlog", "--release"
      (quiche/"deps/boringssl/src/lib").install Pathname.glob("target/release/build/*/out/build/lib{crypto,ssl}.a")
      # (buildpath/"boringssl/lib").install Pathname.glob("target/release/build/*/out/build/lib{crypto,ssl}.a")
      # lib.install quiche.parent/"target/release/libquiche.a"
      # include.install quiche/"include/quiche.h"
      # inreplace quiche_pc_path do |s|
      #   s.gsub!(/includedir=.+/, "includedir=#{include}")
      #   s.gsub!(/libdir=.+/, "libdir=#{lib}")
      # end
      # (lib/"pkgconfig").install quiche_pc_path
    end

    # ENV.append "LDFLAGS", "-Wl,-rpath,#{lib}/pkgconfig"

    if build.head?
      ENV.append_to_cflags "-march=native -O3 -pipe -flto=auto"

      system "autoreconf", "--force", "--install", "--verbose"
    end

    args = %W[
      --disable-silent-rules
      --with-ssl=#{quiche}/deps/boringssl/src
      --without-ca-bundle
      --without-ca-path
      --with-ca-fallback
      --with-default-ssl-backend=openssl
      --with-apple-sectrust
      --with-gssapi
      --with-libssh2
      --with-quiche=#{quiche.parent}/target/release
      --without-libpsl
      --with-zsh-functions-dir=#{zsh_completion}
      --with-fish-functions-dir=#{fish_completion}
      --enable-alt-svc
      --enable-ech
    ]

    args += if MacOS.version >= :ventura
      %w[
        --with-apple-idn
        --without-libidn2
      ]
    else
      %w[
        --without-apple-idn
        --with-libidn2
      ]
    end

    # system "./configure", "LDFLAGS=#{ENV.ldflags}", *args, *std_configure_args
    system "./configure", *args, *std_configure_args
    system "make", "install"
    system "make", "install", "-C", "scripts"
    libexec.install "scripts/mk-ca-bundle.pl"
  end

  test do
    # Fetch the curl tarball and see that the checksum matches.
    # This requires a network connection, but so does Homebrew in general.
    filename = testpath/"test.tar.gz"
    system bin/"curl", "-L", stable.url, "-o", filename
    filename.verify_checksum stable.checksum

    # Verify QUIC and HTTP3 support
    system bin/"curl", "--verbose", "--http3-only", "--head", "https://cloudflare-quic.com"

    # Check dependencies linked correctly
    curl_features = shell_output("#{bin}/curl-config --features").split("\n")
    %w[brotli GSS-API HTTP2 HTTP3 IDN libz SSL zstd].each do |feature|
      assert_includes curl_features, feature
    end
    curl_protocols = shell_output("#{bin}/curl-config --protocols").split("\n")
    %w[LDAPS SCP SFTP].each do |protocol|
      assert_includes curl_protocols, protocol
    end

    system libexec/"mk-ca-bundle.pl", "test.pem"
    assert_path_exists testpath/"test.pem"
    assert_path_exists testpath/"certdata.txt"

    # ENV["PKG_CONFIG_PATH"] = lib/"pkgconfig"
    # system "pkgconf", "--cflags", "libcurl"
  end
end
