class Postgresql < Formula
  desc "Object-relational database system"
  homepage "https://www.postgresql.org/"
  version "11.5"
  url "https://ftp.postgresql.org/pub/source/v#{version}/postgresql-#{version}.tar.bz2"
  sha256 "7fdf23060bfc715144cbf2696cf05b0fa284ad3eb21f0c378591c6bca99ad180"

  depends_on "pkg-config" => :build
  depends_on "icu4c"
  depends_on "openssl@1.1"
  depends_on "readline"

  uses_from_macos "libxml2"
  uses_from_macos "libxslt"
  uses_from_macos "perl"

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
      --with-icu
      --with-ldap
      --with-libxml
      --with-libxslt
      --with-openssl
      --with-uuid=e2fs
      --with-pam
      --with-perl
      --with-python
      --with-tcl
      XML2_CONFIG=:
    ]

    # Add include and library directories of dependencies, so that they can be
    # used for compiling extensions. Superenv does this when compiling this
    # package, but won't record it for pg_config.
    deps = %w[icu4c openssl@1.1 readline]
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

