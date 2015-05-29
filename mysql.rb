class Mysql < Formula
  homepage "https://dev.mysql.com/doc/refman/5.6/en/"
  url "https://cdn.mysql.com/Downloads/MySQL-5.6/mysql-5.6.25.tar.gz"
  sha256 "15079c0b83d33a092649cbdf402c9225bcd3f33e87388407be5cdbf1432c7fbd"

  depends_on :macos => :mountain_lion
  depends_on "cmake" => :build

  def install
    # Don't hard-code the libtool path. See:
    # https://github.com/Homebrew/homebrew/issues/20185
    inreplace "cmake/libutils.cmake",
      "COMMAND /usr/bin/libtool -static -o ${TARGET_LOCATION}",
      "COMMAND libtool -static -o ${TARGET_LOCATION}"

    # Build without compiler or CPU specific optimization flags to facilitate
    # compilation of gems and other software that queries `mysql_config`.
    ENV.minimal_optimization

    # -DINSTALL_* are relative to prefix
    args = %W[
      .
      -DBUILD_CONFIG=mysql_release
      -DFEATURE_SET=community
      -DCMAKE_FIND_FRAMEWORK=LAST
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_VERBOSE_MAKEFILE=ON
      -DINSTALL_DOCDIR=share/doc/#{name}
      -DINSTALL_INCLUDEDIR=include/mysql
      -DINSTALL_INFODIR=share/info
      -DINSTALL_MANDIR=share/man
      -DINSTALL_MYSQLSHAREDIR=share/mysql
      -DINSTALL_MYSQLTESTDIR=
      -DINSTALL_PLUGINDIR=lib/mysql/plugin
      -DINSTALL_SCRIPTDIR=bin
      -DINSTALL_SQLBENCHDIR=
      -DINSTALL_SUPPORTFILESDIR=share/mysql
      -DMYSQL_DATADIR=#{var}/db/mysql
      -DSYSCONFDIR=#{etc}
      -DDEFAULT_CHARSET=utf8
      -DDEFAULT_COLLATION=utf8_general_ci
      -DENABLED_LOCAL_INFILE=ON
      -DWITH_DEBUG=OFF
      -DWITH_EMBEDDED_SERVER=OFF
      -DWITH_EDITLINE=bundled
      -DWITH_INNOBASE_STORAGE_ENGINE=1
      -DWITH_SSL=bundled
    ]

    system "cmake", *args
    system "make"
    system "make", "install"

    # Don't create databases inside of the prefix!
    # See: https://github.com/Homebrew/homebrew/issues/4975
    rm_rf prefix/"data"

    # Fix up the control script and link into bin
    inreplace "#{share}/mysql/mysql.server" do |s|
      s.gsub!(/^(PATH=".*)(")/, "\\1:#{HOMEBREW_PREFIX}/bin\\2")
      # pidof can be replaced with pgrep from proctools on Mountain Lion
      s.gsub!(/pidof/, "pgrep")
    end
    bin.install_symlink prefix/"share/mysql/mysql.server"

    # Move mysqlaccess to libexec
    libexec.mkpath
    mv "#{bin}/mysqlaccess", libexec
    mv "#{bin}/mysqlaccess.conf", libexec
    chmod 0644, "#{libexec}/mysqlaccess.conf"
  end

  def post_install
    # Make sure the run-time directories exist
    %w[db/mysql log run].each { |p| (var+p).mkpath }
  end

  test do
    system "#{bin}/mysqld", "--version"
  end
end
