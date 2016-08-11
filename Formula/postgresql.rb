class Postgresql < Formula
  desc "Object-relational database system"
  homepage "https://www.postgresql.org/"
  url "https://ftp.postgresql.org/pub/source/v9.5.4/postgresql-9.5.4.tar.bz2"
  sha256 "cf5e571164ad66028ecd7dd8819e3765470d45bcd440d258b686be7e69c76ed0"

  depends_on "openssl"
  depends_on "readline"

  # Don't strip fully expanded directory names already containing the string
  # "postgres" or "pgsql".
  patch :DATA

  def install
    ENV.libxml2 if MacOS.version >= :snow_leopard

    args = %W[
      --prefix=#{prefix}
      --datadir=#{share}/#{name}
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

  test do
    system "#{bin}/pg_config"
  end
end

__END__
--- a/src/Makefile.global.in 2014-07-21 21:10:42.000000000 +0200
+++ b/src/Makefile.global.in 2014-10-27 13:37:59.000000000 +0100
@@ -101,20 +101,12 @@
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
 
