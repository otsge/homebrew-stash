class Libssh2 < Formula
  desc "C library implementing the SSH2 protocol"
  homepage "https://libssh2.org/"
  url "https://libssh2.org/download/libssh2-1.11.1.tar.gz"
  mirror "https://github.com/libssh2/libssh2/releases/download/libssh2-1.11.1/libssh2-1.11.1.tar.gz"
  mirror "http://download.openpkg.org/components/cache/libssh2/libssh2-1.11.1.tar.gz"
  sha256 "d9ec76cbe34db98eec3539fe2c899d26b0c837cb3eb466a56b0f109cabf658f7"
  license "BSD-3-Clause"

  livecheck do
    url "https://libssh2.org/download/"
    regex(/href=.*?libssh2[._-]v?(\d+(?:\.\d+)+)\./i)
  end

  bottle do
    root_url "https://ghcr.io/v2/otsge/stash"
    sha256 cellar: :any,                 arm64_tahoe:   "8d17d7dc0c404ce77d38fb0c2ba598c8b6b0c5a29d046c6f97c247201086bccb"
    sha256 cellar: :any,                 arm64_sequoia: "366ca086221d13f0a25492896a4ea594c0f1c80ec49b6e74630e4205d81b0949"
    sha256 cellar: :any,                 arm64_sonoma:  "838a0f8e712756ffdf8ed30b12e0af5292f59c35daa21915cb809d10d4ed6bd1"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "0f5fdab71b3da877f9a2bad15bd35412a3984840d9fef6b9c24b6aa19696b413"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "a6b72662711c2d4fa6a5fe5d7ce0764bf42617a9fda5d26fc24996dc4eb54097"
  end

  head do
    url "https://github.com/libssh2/libssh2.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "otsge/stash/openssl@4"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    args = %W[
      --disable-silent-rules
      --disable-examples-build
      --with-openssl
      --with-libz
      --with-libssl-prefix=#{Formula["openssl@4"].opt_prefix}
    ]

    system "./buildconf" if build.head?
    system "./configure", *std_configure_args, *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <libssh2.h>

      int main(void)
      {
      libssh2_exit();
      return 0;
      }
    C

    system ENV.cc, "test.c", "-L#{lib}", "-lssh2", "-o", "test"
    system "./test"
  end
end
