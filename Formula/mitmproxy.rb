class Mitmproxy < Formula
  desc "Intercept, modify, replay, save HTTP/S traffic"
  homepage "https://mitmproxy.org"
  url "https://github.com/mitmproxy/mitmproxy/releases/download/v0.17/mitmproxy-0.17-osx.tar.gz"
  sha256 "0a29842c476f5ba94486dfbce9e4c6a53c87e99a0747ddd2241fe079e109b6ab"

  bottle :unneeded

  def install
    bin.install "mitmdump", "mitmproxy"
  end

  test do
    ENV["LANG"] = "en_US.UTF-8"
    system bin/"mitmproxy", "--version"
  end
end
