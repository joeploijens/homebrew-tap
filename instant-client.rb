# Installs the necessary files for running SQL*Plus with Instant Client.
# The Basic Lite package with only English error messages and Unicode, ASCII,
# and Western European character set support is used.

class CacheDownloadStrategy < CurlDownloadStrategy
  def fetch
    archive = @url.sub(%r[^file://], "")
    unless File.exists?(archive)
      odie <<-EOS.undent
        Formula expects to locate the following archive:
          #{Pathname.new(archive).basename}

        in the HOMEBREW_CACHE directory:
          #{HOMEBREW_CACHE}

        Copy the archive to the cache or create a symlink in the cache to the archive:
          ln -sf /path/to/archive $(brew --cache)/
      EOS
    end
    super
  end
end

class InstantClient < Formula
  homepage "https://www.oracle.com/technetwork/topics/intel-macsoft-096467.html"
  url "file://#{HOMEBREW_CACHE}/instantclient-basiclite-macos.x64-11.2.0.4.0.zip",
    :using => CacheDownloadStrategy
  sha1 "79f4b3090e15c392ef85626bb24793e57d02fe24"

  resource "sqlplus" do
    url "file://#{HOMEBREW_CACHE}/instantclient-sqlplus-macos.x64-11.2.0.4.0.zip",
      :using => CacheDownloadStrategy
    sha1 "0ee3385f508d03136f8131672f38b636f0f9f274"
  end

  depends_on :macos => :lion

  def install
    buildpath.install resource("sqlplus")

    # Fix permissions
    chmod "u+w,go-w", Dir["./*"]

    # Fix install names
    oracle_bin = %W[adrci genezi uidrvci sqlplus]
    oracle_bin.each do |f|
      system "install_name_tool",
             "-change",
             "/ade/b/3071542110/oracle/rdbms/lib/libclntsh.dylib.11.1",
             "#{opt_lib}/libclntsh.dylib.11.1",
             f
      system "install_name_tool",
             "-change",
             "/ade/dosulliv_ldapmac/oracle/ldap/lib/libnnz11.dylib",
             "#{opt_lib}/libnnz11.dylib",
             f
      system "install_name_tool",
             "-change",
             "/ade/dosulliv_sqlplus_mac/oracle/sqlplus/lib/libsqlplus.dylib",
             "#{opt_lib}/libsqlplus.dylib",
             f
      system "install_name_tool",
             "-change",
             "/ade/b/2475221476/oracle/rdbms/lib/libclntsh.dylib.11.1",
             "#{opt_lib}/libclntsh.dylib.11.1",
             f
      system "install_name_tool",
             "-change",
             "/ade/b/2475221476/oracle/ldap/lib/libnnz11.dylib",
             "#{opt_lib}/libnnz11.dylib",
             f
    end

    oracle_dylib = %W[libclntsh.dylib.11.1 libnnz11.dylib libocci.dylib.11.1 libsqlplus.dylib]
    oracle_dylib.each do |f|
      system "install_name_tool", "-id", f, f
      system "install_name_tool",
             "-change",
             "/ade/dosulliv_ldapmac/oracle/ldap/lib/libnnz11.dylib",
             "#{opt_lib}/libnnz11.dylib",
             f
      system "install_name_tool",
             "-change",
             "/ade/b/2475221476/oracle/rdbms/lib/libclntsh.dylib.11.1",
             "#{opt_lib}/libclntsh.dylib.11.1",
             f
      system "install_name_tool",
             "-change",
             "/ade/b/2475221476/oracle/ldap/lib/libnnz11.dylib",
             "#{opt_lib}/libnnz11.dylib",
             f
    end

    oracle_bundle = %W[libociicus.dylib libocijdbc11.dylib libsqlplusic.dylib]
    oracle_bundle.each do |f|
      system "install_name_tool",
             "-change",
             "/ade/b/3071542110/oracle/rdbms/lib/libclntsh.dylib.11.1",
             "#{opt_lib}/libclntsh.dylib.11.1",
             f
      system "install_name_tool",
             "-change",
             "/ade/b/2475221476/oracle/rdbms/lib/libclntsh.dylib.11.1",
             "#{opt_lib}/libclntsh.dylib.11.1",
             f
      system "install_name_tool",
             "-change",
             "/ade/b/2475221476/oracle/ldap/lib/libnnz11.dylib",
             "#{opt_lib}/libnnz11.dylib",
             f
    end

    prefix.install Dir["*_README"]
    bin.install oracle_bin
    lib.install Dir["*.dylib*"]
    (prefix/"sqlplus/admin").mkpath
    (prefix/"sqlplus/admin").install "glogin.sql"
  end

  test do
    system bin/"sqlplus", "-V"
  end
end
