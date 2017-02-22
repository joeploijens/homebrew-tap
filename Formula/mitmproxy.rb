class Mitmproxy < Formula
  desc "Intercept, modify, replay, save HTTP/S traffic"
  homepage "https://mitmproxy.org"
  url "https://github.com/mitmproxy/mitmproxy/releases/download/v2.0.0/mitmproxy-2.0.0-osx.tar.gz"
  sha256 "cc64ac5f797ee001b54b4df4de1cc67c751ea94bb0878b2cc1fb254dc3a3daf4"

  bottle :unneeded

  def install
    bin.install "mitmdump", "mitmproxy", "mitmweb"
  end

  test do
    ENV["LANG"] = "en_US.UTF-8"
    system bin/"mitmproxy", "--version"
  end
end
