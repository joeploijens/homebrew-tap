class Mitmproxy < Formula
  desc "Intercept, modify, replay, save HTTP/S traffic"
  homepage "https://mitmproxy.org"
  version "3.0.4"
  url "https://github.com/mitmproxy/mitmproxy/releases/download/v#{version}/mitmproxy-v#{version}-osx.tar.gz"
  sha256 "e6aaec126a266ca8a524eddf74cd46528832a44fdbc5a1a02cd6d69fb6712b92"

  bottle :unneeded

  def install
    bin.install "mitmdump", "mitmproxy", "mitmweb"
  end

  test do
    ENV["LANG"] = "en_US.UTF-8"
    assert_match version.to_s, shell_output("#{bin}/mitmproxy --version 2>&1")
  end
end
