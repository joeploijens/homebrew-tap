class Postgresql < Formula
  desc "Object-relational database system"
  homepage "https://www.postgresql.org/"
  url "https://ftp.postgresql.org/pub/source/v9.4.5/postgresql-9.4.5.tar.bz2"
  sha256 "b87c50c66b6ea42a9712b5f6284794fabad0616e6ae420cf0f10523be6d94a39"

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
 
