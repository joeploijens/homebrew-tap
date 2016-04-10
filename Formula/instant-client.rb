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
  desc "Free, light-weight client software for connecting to Oracle databases"
  homepage "https://www.oracle.com/technetwork/topics/intel-macsoft-096467.html"
  url "file://#{HOMEBREW_CACHE}/instantclient-basiclite-macos.x64-11.2.0.4.0.zip",
    :using => CacheDownloadStrategy
  sha256 "d51c5fb67d1213c9b3c6301c6f73fe1bef45f78197e1bae7804df4c0abb468a7"

  resource "sqlplus" do
    url "file://#{HOMEBREW_CACHE}/instantclient-sqlplus-macos.x64-11.2.0.4.0.zip",
      :using => CacheDownloadStrategy
    sha256 "127d2baaa4c72d8591af829f00dea5e2a77c0e272ce8fc091dd853e9406845b9"
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

    system "install_name_tool",
           "-add_rpath",
           "#{opt_lib}",
           "libclntsh.dylib.11.1"

    prefix.install Dir["*_README"]
    bin.install oracle_bin
    %w[libclntsh.dylib libocci.dylib].each do |dylib|
      ln_s "#{dylib}.11.1", dylib
    end
    lib.install Dir["*.dylib*"]
    (prefix/"sqlplus/admin").mkpath
    (prefix/"sqlplus/admin").install "glogin.sql"
  end

  test do
    system bin/"sqlplus", "-V"
  end
end
