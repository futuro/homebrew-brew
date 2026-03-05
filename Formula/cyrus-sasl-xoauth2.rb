class CyrusSaslXoauth2 < Formula
  desc "Add XOAUTH2 authentication method to SASL framework"
  homepage 'https://github.com/moriyoshi/cyrus-sasl-xoauth2.git'
  head do
    url 'https://github.com/moriyoshi/cyrus-sasl-xoauth2.git', branch: 'master'
    depends_on 'libtool' => :build
    depends_on 'autoconf' => :build
    depends_on 'automake' => :build
  end

  depends_on 'cyrus-sasl'

  def install
    system '/usr/bin/sed', '-e', 's/^libtoolize/glibtoolize/', '-i', '', 'autogen.sh'
    system './autogen.sh'
    system './configure', '--disable-silent-rules', *std_configure_args
    system 'make', 'install'
  end
end
