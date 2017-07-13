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
    using: CacheDownloadStrategy
  sha256 "71aa366c961166fb070eb6ee9e5905358c61d5ede9dffd5fb073301d32cbd20c"

  resource "sqlplus" do
    url "file://#{HOMEBREW_CACHE}/instantclient-sqlplus-macos.x64-12.1.0.2.0.zip",
      using: CacheDownloadStrategy
    sha256 "a663937e2e32c237bb03df1bda835f2a29bc311683087f2d82eac3a8ea569f81"
  end

  bottle :unneeded

  depends_on macos: :mavericks

  def install
    buildpath.install resource("sqlplus")

    # Fix permissions
    chmod "u+w,go-w", Dir["./*"]
    chmod "u+w,a-x", "glogin.sql"

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
