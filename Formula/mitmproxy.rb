class Mitmproxy < Formula
  desc "Intercept, modify, replay, save HTTP/S traffic"
  homepage "https://mitmproxy.org"
  url "https://github.com/mitmproxy/mitmproxy/releases/download/v0.18.1/mitmproxy-0.18.1-osx.tar.gz"
  sha256 "ae28e57ca317966e9cfb7f1654587a6a1f4e3d936c7647d322a407902ef62754"

  bottle :unneeded

  def install
    bin.install "mitmdump", "mitmproxy"
  end

  test do
    ENV["LANG"] = "en_US.UTF-8"
    system bin/"mitmproxy", "--version"
  end
end
