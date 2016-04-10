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
  url "file://#{HOMEBREW_CACHE}/sqlcl-4.2.0.16.049.0843-no-jre.zip",
    :using => CacheDownloadStrategy
  sha256 "4215ba3ca3ba57e213e837d3bb1be2e46c5596e5366aef553d89869c2506fd65"

  bottle :unneeded

  depends_on :java => "1.8+"

  def install
    # Remove Windows script files
    rm_f Dir["bin/*.bat", "bin/*.exe"]

    libexec.install %w[bin lib]
    bin.write_exec_script Dir["#{libexec}/bin/*"]
  end

  test do
    system bin/"sql", "-V"
  end
end
