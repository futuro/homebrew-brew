class CyrusSaslXoauth2 < Formula
  desc "Add XOAUTH2 authentication method to SASL framework"
  homepage 'https://github.com/moriyoshi/cyrus-sasl-xoauth2.git'
  head do
    url 'https://github.com/moriyoshi/cyrus-sasl-xoauth2.git', branch: 'master'
    depends_on 'libtool' => :build
    depends_on 'autoconf' => :build
    depends_on 'automake' => :build
    depends_on 'make' => :build
  end

  depends_on 'cyrus-sasl'

  def install
    ENV.prepend_path "PATH", "#{Formula["libtool"].opt_libexec}/gnubin"
    ENV.prepend_path "PATH", "#{Formula["make"].opt_libexec}/gnubin"
    ENV.append "LDFLAGS", "-L#{Formula['cyrus-sasl'].opt_lib}"
    ENV.append "CPPFLAGS", "-I#{Formula["cyrus-sasl"].opt_include}"
    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["cyrus-sasl"].opt_lib}/pkgconfig"

    # system '/usr/bin/sed', '-e', 's/^libtoolize/glibtoolize/', '-e', 's/^install/ginstall/', '-i', '', 'autogen.sh'
    system './autogen.sh'
    system './configure',
           '--disable-silent-rules',
           "--prefix=#{prefix}",
           "--with-cyrus-sasl=#{Formula['cyrus-sasl'].opt_prefix}"
    system 'make', 'install'
  end
end
