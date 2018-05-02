class Mysql < Formula
  desc "Relational database management system"
  homepage "https://dev.mysql.com/doc/refman/8.0/en/"
  url "https://cdn.mysql.com/Downloads/MySQL-8.0/mysql-boost-8.0.11.tar.gz"
  sha256 "f40711a9bd91ab2ccea331484a6d281f806b0fdecf78f4c9e9d8a4c91208f309"

  depends_on "cmake" => :build
  depends_on "openssl"
  depends_on :macos => :sierra

  def install
    # -DINSTALL_* are relative to prefix
    args = %W[
      -DBUILD_CONFIG=mysql_release
      -DENABLED_LOCAL_INFILE=ON
      -DINSTALL_DOCDIR=share/doc/mysql
      -DINSTALL_INCLUDEDIR=include/mysql
      -DINSTALL_INFODIR=share/info
      -DINSTALL_LIBDIR=lib/mysql
      -DINSTALL_MANDIR=share/man
      -DINSTALL_MYSQLSHAREDIR=share/mysql
      -DINSTALL_MYSQLTESTDIR=
      -DINSTALL_PLUGINDIR=lib/mysql/plugin
      -DINSTALL_SUPPORTFILESDIR=share/mysql
      -DMYSQL_DATADIR=#{var}/db/mysql
      -DSYSCONFDIR=#{etc}
      -DWITH_BOOST=boost
      -DWITH_EDITLINE=system
      -DWITH_SSL=system
    ]

    system "cmake", ".", *std_cmake_args, *args
    system "make"
    system "make", "install"

    # Fix up the control script and link into bin
    inreplace "#{pkgshare}/mysql.server",
      /^(PATH=".*)(")/,
      "\\1:#{HOMEBREW_PREFIX}/bin\\2"
    bin.install_symlink prefix/"share/mysql/mysql.server"
  end

  def post_install
    # Make sure the run-time directories exist
    %w[db/mysql log run].each { |p| (var+p).mkpath }
  end

  plist_options :manual => "mysql.server start"

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
        <string>#{opt_bin}/mysqld_safe</string>
        <string>--datadir=#{var}/db/mysql</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
    </dict>
    </plist>
    EOS
  end

  test do
    system bin/"mysqld", "--version"
  end
end
