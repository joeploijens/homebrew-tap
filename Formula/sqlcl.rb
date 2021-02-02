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

class Sqlcl < Formula
  desc "Free, Java-based command-line interface for Oracle databases"
  homepage "https://www.oracle.com/database/technologies/appdev/sqlcl.html"
  url "file://#{HOMEBREW_CACHE}/sqlcl-20.4.1.351.1718.zip",
    using: CacheDownloadStrategy
  sha256 "7d69d50408e010c223e6f6a3efbf8b9d20832032219d53afe36a84707ba5073b"

  bottle :unneeded

  depends_on "openjdk@11"

  def install
    # Remove Windows files
    rm_f "bin/sql.exe"

    prefix.install "README.md"
    rm_f "20.4.1.351.1718"
    rm_f "bin/README.md"
    rm_f "bin/dependencies.txt"
    rm_f "bin/version.txt"

    bin.install "bin/sql" => "sqlcl"
    libexec.install "lib"
    bin.env_script_all_files(libexec/"bin", JAVA_HOME: Formula["openjdk@11"].opt_prefix)
  end

  test do
    system bin/"sqlcl", "-V"
  end
end
