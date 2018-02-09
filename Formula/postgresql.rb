class Postgresql < Formula
  desc "Object-relational database system"
  homepage "https://www.postgresql.org/"
  version "10.2"
  url "https://ftp.postgresql.org/pub/source/v#{version}/postgresql-#{version}.tar.bz2"
  sha256 "fe32009b62ddb97f7f014307ce9d0edb6972f5a698e63cb531088e147d145bad"

  depends_on "openssl"
  depends_on "readline"

  # Don't strip fully expanded directory names already containing the string
  # "postgres" or "pgsql".
  patch :DATA

  def install
    args = %W[
      --prefix=#{prefix}
      --datadir=#{pkgshare}
      --docdir=#{doc}
      --includedir=#{include}/#{name}
      --sysconfdir=#{etc}
      --enable-dtrace
      --with-bonjour
      --with-gssapi
      --with-ldap
      --with-libxml
      --with-libxslt
      --with-openssl
      --with-uuid=e2fs
      --with-pam
      --with-perl
      --with-python
      --with-tcl
      --with-tclconfig=#{MacOS.sdk_path}/System/Library/Frameworks/Tcl.framework
      XML2_CONFIG=:
    ]

    # Add include and library directories of dependencies, so that they can be
    # used for compiling extensions. Superenv does this when compiling this
    # package, but won't record it for pg_config.
    deps = %w[openssl readline]
    with_includes = deps.map { |f| Formula[f].opt_include }.join(":")
    with_libraries = deps.map { |f| Formula[f].opt_lib }.join(":")
    args << "--with-includes=#{with_includes}"
    args << "--with-libraries=#{with_libraries}"

    system "./configure", *args
    system "make", "install-world"
  end

  def post_install
    # Make sure the run-time directories exist
    %w[db/postgresql log run].each { |p| (var+p).mkpath }
    (etc/"postgresql").mkpath
  end

  plist_options :manual => "pg_ctl -D #{HOMEBREW_PREFIX}/var/db/postgresql start"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/postgres</string>
        <string>-D</string>
        <string>#{var}/db/postgresql</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/postgres.log</string>
    </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/pg_config"
  end
end

__END__
--- a/src/Makefile.global.in	2017-10-02 23:09:15.000000000 +0200
+++ b/src/Makefile.global.in	2017-10-09 12:14:45.000000000 +0200
@@ -118,20 +118,12 @@
 libdir := @libdir@

 pkglibdir = $(libdir)
-ifeq "$(findstring pgsql, $(pkglibdir))" ""
-ifeq "$(findstring postgres, $(pkglibdir))" ""
 override pkglibdir := $(pkglibdir)/postgresql
-endif
-endif

 includedir := @includedir@

 pkgincludedir = $(includedir)
-ifeq "$(findstring pgsql, $(pkgincludedir))" ""
-ifeq "$(findstring postgres, $(pkgincludedir))" ""
 override pkgincludedir := $(pkgincludedir)/postgresql
-endif
-endif

 mandir := @mandir@

