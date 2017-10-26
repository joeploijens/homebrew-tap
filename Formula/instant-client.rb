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
  url "file://#{HOMEBREW_CACHE}/instantclient-basic-macos.x64-12.2.0.1.0.zip",
    using: CacheDownloadStrategy
  sha256 "04a84542b5bd0a04bc45445e220a67c959a8826ce987000270705f9a1d553157"

  resource "sqlplus" do
    url "file://#{HOMEBREW_CACHE}/instantclient-sqlplus-macos.x64-12.2.0.1.0.zip",
      using: CacheDownloadStrategy
    sha256 "df4ab35ed15c49f0c341a487afb50f38b65f80cde385d4007af5d922a9e0e5bf"
  end

  bottle :unneeded

  depends_on macos: :el_capitan

  def install
    buildpath.install resource("sqlplus")

    # Fix permissions
    chmod "u+w,go-w", Dir["./*"]
    chmod "u+w,a-x", "glogin.sql"

    # Fix install names
    system "install_name_tool", "-id", "@rpath/liboramysql12.dylib", "liboramysql12.dylib"

    prefix.install Dir["*_README"]
    bin.install %W[adrci genezi uidrvci sqlplus]
    lib.install Dir["*.dylib*"]
    (prefix/"sqlplus/admin").mkpath
    (prefix/"sqlplus/admin").install "glogin.sql"
  end

  test do
    system bin/"sqlplus", "-V"
  end
end
