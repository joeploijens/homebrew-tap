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
  url "file://#{HOMEBREW_CACHE}/instantclient-basic-macos.x64-12.1.0.2.0.zip",
    :using => CacheDownloadStrategy
  sha256 "8c72abe1ee29c6f85c82851cfe5cdfc31bff09e162438aa755fc76f7a78bd1b6"

  resource "sqlplus" do
    url "file://#{HOMEBREW_CACHE}/instantclient-sqlplus-macos.x64-12.1.0.2.0.zip",
      :using => CacheDownloadStrategy
    sha256 "8eb5bc4da372c6d58de3b3af30a5736a392278272ea04d4400e0b3926a9bf6b8"
  end

  bottle :unneeded

  depends_on :macos => :mavericks

  def install
    buildpath.install resource("sqlplus")

    # Fix permissions
    chmod "u+w,go-w", Dir["./*"]

    # Fix install names
    system "install_name_tool", "-id", "@rpath/liboramysql12.dylib", "liboramysql12.dylib"

    prefix.install Dir["*_README"]
    bin.install %W[adrci genezi uidrvci sqlplus]
    %W[libclntsh.dylib libocci.dylib].each do |dylib|
      ln_s "#{dylib}.12.1", dylib
    end
    lib.install Dir["*.dylib*"]
    (prefix/"sqlplus/admin").mkpath
    (prefix/"sqlplus/admin").install "glogin.sql"
  end

  test do
    system bin/"sqlplus", "-V"
  end
end
