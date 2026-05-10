class Wget < Formula
  desc "Internet file retriever"
  homepage "https://www.gnu.org/software/wget/"
  url "https://ftpmirror.gnu.org/gnu/wget/wget-1.25.0.tar.gz"
  sha256 "766e48423e79359ea31e41db9e5c289675947a7fcf2efdcedb726ac9d0da3784"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 arm64_tahoe:   "76df91bd66f4a991e2993821970eb2bcf7bb67bbb2dbb93085d2ce7a259cda35"
    sha256 arm64_sequoia: "94575387bcabc74beb8ab35508ceaecab1ab30610ef584a821c798c8d39f7bba"
    sha256 arm64_sonoma:  "9318b622dec469c938ee271361b285e68cbcbc49f11cc2b897b2898ac0d6a42d"
    sha256 arm64_linux:   "46cc707578a726f2995d14f004b58b9b25fc91cc838138021748d93bf1c43c2b"
    sha256 x86_64_linux:  "011204e55f933c10e2f846d9d9baa42664ac8ae14b4c9751c98d3a961d0ae433"
  end

  head do
    url "https://git.savannah.gnu.org/git/wget.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "xz" => :build
  end

  depends_on "pkgconf" => :build
  depends_on "libidn2"
  depends_on "libmetalink"
  depends_on "otsge/stash/openssl@4"

  on_macos do
    depends_on "gettext"
    depends_on "libunistring"
  end

  on_linux do
    depends_on "util-linux"
    depends_on "zlib-ng-compat"
  end

  def install
    inreplace "src/openssl.c", "#ifndef OPENSSL_NO_SSL3_METHOD",
              "#if !defined OPENSSL_NO_SSL3_METHOD && OPENSSL_VERSION_NUMBER < 0x40000000L"
    system "./bootstrap", "--skip-po" if build.head?
    system "./configure", "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}",
                          "--with-ssl=openssl",
                          "--with-libssl-prefix=#{Formula["openssl@4"].opt_prefix}",
                          "--with-metalink",
                          "--disable-pcre",
                          "--disable-pcre2",
                          "--without-libpsl",
                          "--without-included-regex"
    system "make", "install"
  end

  test do
    system bin/"wget", "-O", File::NULL, "https://google.com"
  end
end
