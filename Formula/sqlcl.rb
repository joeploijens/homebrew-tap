class CacheDownloadStrategy < CurlDownloadStrategy
  def fetch(timeout: nil, **options)
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
  url "file://#{HOMEBREW_CACHE}/sqlcl-21.1.0.104.1544.zip",
    using: CacheDownloadStrategy
  sha256 "39469ff39c91c116b48895d56cbfc837633e0fbc1a4605d6e513486f139260ef"

  bottle :unneeded

  depends_on arch: :x86_64
  depends_on "java"

  def install
    # Remove Windows files
    rm_f "bin/sql.exe"

    prefix.install "README.md"
    rm_f "21.1.0.104.1544"
    rm_f "bin/README.md"
    rm_f "bin/dependencies.txt"
    rm_f "bin/version.txt"

    bin.install "bin/sql" => "sqlcl"
    libexec.install "lib"
    bin.env_script_all_files(libexec/"bin", JAVA_HOME: Formula["java"].opt_prefix)
  end

  test do
    system bin/"sqlcl", "-V"
  end
end
