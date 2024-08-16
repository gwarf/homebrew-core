class Liburing < Formula
  desc "Helpers to setup and teardown io_uring instances"
  homepage "https://github.com/axboe/liburing"
  # not need to check github releases, as tags are sufficient, see https://github.com/axboe/liburing/issues/1008
  url "https://github.com/axboe/liburing/archive/refs/tags/liburing-2.7.tar.gz"
  sha256 "56202ad443c50e684dde3692819be3b91bbe003e1c14bf5abfa11973669978c1"
  license any_of: ["MIT", "LGPL-2.1-only"]
  head "https://github.com/axboe/liburing.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, x86_64_linux: "a369928abdce516f5cbaedc983900a24b3e22d345f5942e0d62f464578095fbc"
  end

  depends_on "gcc" => :test
  depends_on "pkg-config" => :test
  depends_on :linux

  def install
    # not autotools based configure, so std_configure_args is not suitable
    system "./configure", "--prefix=#{prefix}", "--libdir=#{lib}", "--mandir=#{man}"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <assert.h>
      #include <liburing.h>
      int main() {
        struct io_uring ring;
        assert(io_uring_queue_init(1, &ring, 0) == 0);
        return 0;
      }
    EOS

    pkg_config_flags = shell_output("pkg-config --cflags --libs liburing").chomp.split
    gcc_major_ver = Formula["gcc"].any_installed_version.major
    gcc = Formula["gcc"].opt_bin/"gcc-#{gcc_major_ver}"
    system gcc.to_s, "test.c", "-o", "test", *pkg_config_flags
    system "./test"
  end
end
