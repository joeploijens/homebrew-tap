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

class Sqlcl < Formula
  desc "Free, Java-based command-line interface for Oracle databases"
  homepage "https://www.oracle.com/technetwork/developer-tools/sql-developer/overview/index.html"
  url "file://#{HOMEBREW_CACHE}/sqlcl-17.2.0.184.1230-no-jre.zip",
    using: CacheDownloadStrategy
  sha256 "62ec4348dc44cda1b4622617159a4f9fd7a29fe79864af26fc97555d6093fc23"

  bottle :unneeded

  depends_on java: "1.8+"

  def install
    # Remove Windows script files
    rm_f Dir["bin/*.bat", "bin/*.exe"]

    libexec.install %w[bin lib]
    bin.write_exec_script Dir["#{libexec}/bin/sql"]
    mv "#{bin}/sql", "#{bin}/sqlcl"
  end

  test do
    system bin/"sqlcl", "-V"
  end
end
