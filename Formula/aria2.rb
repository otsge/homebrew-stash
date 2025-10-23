class Aria2 < Formula
  desc "Download with resuming and segmented downloading"
  homepage "https://aria2.github.io/"
  url "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0.tar.xz"
  sha256 "60a420ad7085eb616cb6e2bdf0a7206d68ff3d37fb5a956dc44242eb2f79b66b"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any,                 arm64_tahoe:   "e5c1e288dae9e857fdec062f7572677577554f2de65beb202a24c7fefedcf281"
    sha256 cellar: :any,                 arm64_sequoia: "21611797bddcf2ead3cfdc4fb6741aba243c169cf347411aabcf796e598f60f2"
    sha256 cellar: :any,                 arm64_sonoma:  "4569e1d440e5b22169314897da2acd88b8cc49dc21ec68f946b1dcc8d560a624"
    sha256 cellar: :any,                 sequoia:       "00361e578e603ae65e6f06ef625f7b8c90da2a443d6256a205bd51debd27d0bf"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "cd1d6be7baa14ff7c38d9042219fd2bdc79f1f14059a6d8b1ae778ac0ecfc0c9"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "7222a3bd335778ff1992f8fcac6637b06369d7575023c63bb0e34f7958611a07"
  end

  head do
    url "https://github.com/aria2/aria2.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkgconf" => :build

  depends_on "c-ares"
  depends_on "libssh2"
  depends_on "sqlite"

  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  on_macos do
    depends_on "gettext"
  end

  on_linux do
    depends_on "openssl@3"
  end

  def install
    ENV.cxx11

    if build.head?
      ENV.append_to_cflags "-march=native -O3 -pipe -flto=auto"

      system "autoreconf", "--force", "--install", "--verbose"
    end

    args = %w[
      --disable-silent-rules
      --disable-nls
      --enable-metalink
      --enable-bittorrent
      --with-libcares
      --with-libssh2
      --with-libxml2
      --with-libz
      --without-gnutls
      --without-libgcrypt
      --without-libgmp
      --without-libnettle
    ]
    if OS.mac?
      args << "--with-appletls"
      args << "--without-openssl"
    else
      args << "--without-appletls"
      args << "--with-openssl"
    end

    system "./configure", *args, *std_configure_args
    system "make", "install"

    bash_completion.install "doc/bash_completion/aria2c"
  end

  test do
    system bin/"aria2c", "https://brew.sh/"
    assert_path_exists testpath/"index.html", "Failed to create index.html!"
  end
end
