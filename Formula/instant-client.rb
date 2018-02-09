class CacheDownloadStrategy < CurlDownloadStrategy
  def fetch
    archive = @url.sub(%r[^file://], "")
    unless File.exists?(archive)
      odie <<~EOS
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
  url "file://#{HOMEBREW_CACHE}/instantclient-basic-macos.x64-12.2.0.1.0-2.zip",
    using: CacheDownloadStrategy
  sha256 "3ed3102e5a24f0da638694191edb34933309fb472eb1df21ad5c86eedac3ebb9"
  version "12.2.0.1.0"

  resource "sqlplus" do
    url "file://#{HOMEBREW_CACHE}/instantclient-sqlplus-macos.x64-12.2.0.1.0-2.zip",
      using: CacheDownloadStrategy
    sha256 "d147cbb5b2a954fdcb4b642df4f0bd1153fd56e0f56e7fa301601b4f7e2abe0e"
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
