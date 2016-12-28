class Mitmproxy < Formula
  desc "Intercept, modify, replay, save HTTP/S traffic"
  homepage "https://mitmproxy.org"
  url "https://github.com/mitmproxy/mitmproxy/releases/download/v1.0.1/mitmproxy-1.0.1-osx.tar.gz"
  sha256 "d760fd2a54dbcc042b12e390c7da9a1f4f1b748cdd80ed578c5cf8ba884d1ede"

  bottle :unneeded

  def install
    bin.install "mitmdump", "mitmproxy", "mitmweb"
  end

  test do
    ENV["LANG"] = "en_US.UTF-8"
    system bin/"mitmproxy", "--version"
  end
end
