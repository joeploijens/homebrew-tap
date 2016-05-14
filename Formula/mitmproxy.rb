class Mitmproxy < Formula
  desc "Intercept, modify, replay, save HTTP/S traffic"
  homepage "https://mitmproxy.org"
  url "https://github.com/mitmproxy/mitmproxy/releases/download/v0.17.1/mitmproxy-0.17.1-osx.tar.gz"
  sha256 "dd5b2779f078c3208c02c673ee6343bf7aedf1c1759df20f8103241147d833ea"

  bottle :unneeded

  def install
    bin.install "mitmdump", "mitmproxy"
  end

  test do
    ENV["LANG"] = "en_US.UTF-8"
    system bin/"mitmproxy", "--version"
  end
end
