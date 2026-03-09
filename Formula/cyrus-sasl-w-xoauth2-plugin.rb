class CyrusSaslWXoauth2Plugin < Formula
  desc "Simple Authentication and Security Layer"
  homepage "https://www.cyrusimap.org/sasl/"
  url "https://github.com/cyrusimap/cyrus-sasl/releases/download/cyrus-sasl-2.1.28/cyrus-sasl-2.1.28.tar.gz"
  sha256 "7ccfc6abd01ed67c1a0924b353e526f1b766b21f42d4562ee635a8ebfc5bb38c"
  license "BSD-3-Clause-Attribution"
  revision 2

  keg_only :provided_by_macos

  depends_on "krb5"
  depends_on "openssl@3"
  depends_on 'libtool' => :build
  depends_on 'autoconf' => :build
  depends_on 'automake' => :build
  depends_on 'coreutils' => :build
  depends_on 'make' => :build

  uses_from_macos "libxcrypt"

  resource "xoauth2-plugin" do
    url 'https://github.com/futuro/cyrus-sasl-xoauth2.git', branch: 'main'
  end

  def install
    system "./configure",
      "--disable-macos-framework",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
      "--prefix=#{prefix}"
    system "make", "install"

    resource('xoauth2-plugin').stage do
      ENV.prepend_path "PATH", "#{Formula["libtool"].opt_libexec}/gnubin"
      ENV.prepend_path "PATH", "#{Formula["make"].opt_libexec}/gnubin"
      ENV.prepend_path "PATH", "#{Formula["coreutils"].opt_libexec}/gnubin"
      ENV.append "LDFLAGS", "-L#{opt_lib}"
      ENV.append "CPPFLAGS", "-I#{opt_include}"
      ENV.prepend_path "PKG_CONFIG_PATH", "#{opt_lib}/pkgconfig"

      system './autogen.sh'
      system './configure',
             '--disable-silent-rules',
             # "--prefix=#{cyrus_sasl.opt_prefix}",
             "--with-cyrus-sasl=#{opt_prefix}"
      system 'make', 'install'

    end
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <sasl/saslutil.h>
      #include <assert.h>
      #include <stdio.h>
      int main(void) {
        char buf[123] = "\\0";
        unsigned len = 0;
        int ret = sasl_encode64("Hello, world!", 13, buf, sizeof buf, &len);
        assert(ret == SASL_OK);
        printf("%u %s", len, buf);
        return 0;
      }
    CPP

    system ENV.cxx, "-o", "test", "test.cpp", "-I#{include}", "-L#{lib}", "-lsasl2"
    assert_equal "20 SGVsbG8sIHdvcmxkIQ==", shell_output("./test")
  end
end
