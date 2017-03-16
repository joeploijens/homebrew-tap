class Mitmproxy < Formula
  desc "Intercept, modify, replay, save HTTP/S traffic"
  homepage "https://mitmproxy.org"
  url "https://github.com/mitmproxy/mitmproxy/releases/download/v2.0.1/mitmproxy-2.0.1-osx.tar.gz"
  sha256 "e2515e8d72347d49a42476b5db51fbf9e576bbc76aa3fe5f735aa750bfa44500"

  bottle :unneeded

  def install
    bin.install "mitmdump", "mitmproxy", "mitmweb"
  end

  test do
    ENV["LANG"] = "en_US.UTF-8"
    system bin/"mitmproxy", "--version"
  end
end
