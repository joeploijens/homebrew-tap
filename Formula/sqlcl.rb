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
  url "file://#{HOMEBREW_CACHE}/sqlcl-4.2.0.16.260.1205-no-jre.zip",
    using: CacheDownloadStrategy
  sha256 "a063064ec1f725a9c5e40b5c7d94219c6dab5756c7a925afa775d62eb79aa6a5"

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
