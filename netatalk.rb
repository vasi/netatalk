class Netatalk < Formula
  desc "Open source Apple Filing Protocol fileserver"
  homepage "https://netatalk.sourceforge.net"
  head "https://github.com/dgsga/netatalk.git", using: :git, branch: "main"
  version "3.1.13"
  license "BSD-3-Clause"

  depends_on "automake"
  depends_on "autoconf"
  depends_on "libtool"
  depends_on "libgcrypt"
  depends_on "berkeley-db"
  depends_on "openssl@1.1"
  depends_on "libevent"
  depends_on "mysql"
  depends_on "pkg-config"
  depends_on "docbook"
  depends_on "docbook-xsl"

  def install
    ENV["XML_CATALOG_FILES"] = "#{HOMEBREW_PREFIX}/etc/xml/catalog"
    system "autoreconf", "-fi"
    system "./configure", "--prefix=#{prefix}"
    system "make", "-j8"
    system "make" "html"
    system "make", "install"
  end
  
  plist_options :startup => true

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>EnvironmentVariables</key>
          <dict>
            <key>PATH</key>
            <string>/bin:/sbin:/usr/bin:/usr/sbin:#{HOMEBREW_PREFIX}/bin:#{HOMEBREW_PREFIX}/sbin</string>
          </dict>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>ProgramArguments</key>
          <array>
            <string>#{bin}/netatalkd</string>
            <string>start</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
        </dict>
      </plist>
    EOS
  end
end
